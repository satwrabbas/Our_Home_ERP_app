//lib\payments\cubit\payments_cubit.dart
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show PaymentsLedgerCompanion;
import 'package:drift/drift.dart' show Value;

// استدعاء الحاسبة الهندسية التي تجلب معادلات الإكسل
import '../../core/utils/calculator_helper.dart';

part 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  PaymentsCubit(this._erpRepository) : super(const PaymentsState());

  final ErpRepository _erpRepository;

  Future<void> fetchInitialData() async {
    if (state.status == PaymentsStatus.initial) emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      final clients = await _erpRepository.getClients();
      final contracts = await _erpRepository.getAllContracts();
      
      emit(state.copyWith(
        status: PaymentsStatus.success,
        clients: clients,
        contracts: contracts,
      ));
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> selectContract(String contractId) async {
    emit(state.copyWith(selectedContractId: contractId, status: PaymentsStatus.loading));
    try {
      final ledgerEntries = await _erpRepository.getContractLedger(contractId);
      emit(state.copyWith(status: PaymentsStatus.success, ledgerEntries: ledgerEntries));
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// 🌟 النسخة المحسنة للمزامنة والرفع للسحابة مع دعم (الخصم/البونص المئوي)
  Future<void> addLedgerEntry({
    required String contractId, 
    required double amountPaid,
    double discountPercentage = 0, // 👈 1. تم الاستبدال بنسبة الخصم بدلاً من الرسوم
    String? scheduleId, 
  }) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      // 1. التحقق من وجود العقد
      final contractIndex = state.contracts.indexWhere((c) => c.id == contractId);
      if (contractIndex == -1) throw Exception('هذا العقد غير موجود.');
      final contract = state.contracts[contractIndex];

      // 2. التحقق من الأسعار الحالية
      final currentPrices = await _erpRepository.getLatestPrices();
      if (currentPrices == null) {
        throw Exception('يرجى إضافة أسعار المواد من شاشة الإعدادات أولاً.');
      }

      // 3. التحقق من تسجيل الدخول (للحصول على الـ userId)
      final String? userId = _erpRepository.currentUserId;
      if (userId == null) throw Exception('يجب تسجيل الدخول لضمان مزامنة البيانات.');

      // 4. الحسابات المالية
      Map<String, double> contractCoefficients = {};
      try {
        if (contract.coefficients.isNotEmpty && contract.coefficients != '{}') {
          final Map<String, dynamic> decoded = jsonDecode(contract.coefficients);
          contractCoefficients = decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
        }
      } catch (_) {}

      final calculations = CalculatorHelper.calculateContractValues(
        area: contract.totalArea,
        currentPrices: currentPrices,
        coefficients: contractCoefficients,
      );
      
      final double meterPriceToday = calculations['pricePerSqm']!;
      
      // 👈 2. حساب المبلغ المعتمد بعد إضافة (أو خصم) النسبة المئوية
      // مثال: دفع 100,000 وبونص 10% = 110,000 مبلغ معتمد
      final double effectiveAmount = amountPaid + (amountPaid * (discountPercentage / 100));

      // 👈 3. حساب الأمتار بناءً على المبلغ المعتمد (وليس المدفوع فقط)
      final double convertedMeters = effectiveAmount / meterPriceToday;

      // 5. حفظ الدفعة في قاعدة البيانات (محلياً ثم رفعها)
      final newEntry = PaymentsLedgerCompanion.insert(
        contractId: contractId,
        scheduleId: scheduleId != null ? Value(scheduleId) : const Value.absent(), 
        paymentDate: DateTime.now(),
        amountPaid: amountPaid, // 👈 نحتفظ بالمبلغ المالي الفعلي المقبوض للتوثيق المالي
        meterPriceAtPayment: meterPriceToday, 
        convertedMeters: convertedMeters, // 👈 الأمتار المستفيدة من البونص
        
        // 👈 4. نقوم بتخزين نسبة الخصم في حقل fees الموجود مسبقاً في قاعدة بياناتك 
        // لكي لا تضطر لتعديل الجداول وعمل build_runner من جديد
        fees: Value(discountPercentage), 
        
        userId: userId,
      );
      
      // نستخدم await للتأكد من انتهاء الحفظ والمزامنة الأولية
      await _erpRepository.addLedgerEntry(newEntry);

      // 6. تحديث جدول المراقبة (الأقساط)
      final allEntries = await _erpRepository.getContractLedger(contractId);
      double totalConvertedMetersAccumulated = allEntries.fold(0, (sum, item) => sum + item.convertedMeters);

      final int monthsCount = contract.installmentsCount > 0 ? contract.installmentsCount : 48;
      final double requiredMetersPerMonth = contract.totalArea / monthsCount;
      final int fullyPaidMonths = (totalConvertedMetersAccumulated / requiredMetersPerMonth).floor();
      
      final schedules = await _erpRepository.getContractSchedule(contractId);

      // تحديث حالات الأقساط محلياً
      for (var schedule in schedules) {
        String targetStatus = (schedule.installmentNumber <= fullyPaidMonths) ? 'paid' : 'pending';
        if (schedule.status != targetStatus) {
          // نقوم بالتحديث والانتظار لضمان عدم حدوث تضارب في المزامنة
          await _erpRepository.updateScheduleStatus(schedule.id, targetStatus);
        }
      }

      // 7. 🚀 الضربة القاضية: إجبار النظام على مزامنة كل شيء مع السحابة الآن
      await _erpRepository.forceSyncWithCloud();

      // 8. تحديث واجهة المستخدم
      await selectContract(contractId);
      
    } catch (e) {
      print('خطأ في إضافة الدفعة: $e');
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> markAsSent(String entryId, String contractId) async {
    try {
      await _erpRepository.markWhatsAppAsSent(entryId);
      // بعد تحديث حالة الواتساب، نرفع التحديث للسحابة
      await _erpRepository.syncPendingData(); 
      await selectContract(contractId);
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: 'فشل في تحديث حالة الواتساب: $e'));
    }
  }
}
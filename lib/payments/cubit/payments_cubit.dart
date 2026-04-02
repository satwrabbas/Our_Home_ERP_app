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

  /// 3. 🌟 جوهر النظام المالي: إضافة دفعة وتحديث جدول المراقبة آلياً (الخوارزمية الذكية)
  Future<void> addLedgerEntry({
    required String contractId, 
    required double amountPaid,
    double fees = 0,
    String? scheduleId, // لم يعد ضرورياً جداً بفضل الخوارزمية الجديدة، لكن سنبقيه
  }) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      final contract = state.contracts.firstWhere((c) => c.id == contractId);

      final currentPrices = await _erpRepository.getLatestPrices();
      if (currentPrices == null) {
        throw Exception('يرجى إضافة أسعار المواد من شاشة الإعدادات أولاً لحساب سعر المتر اليوم.');
      }

      Map<String, double> contractCoefficients = {};
      try {
        if (contract.coefficients.isNotEmpty && contract.coefficients != '{}') {
          final Map<String, dynamic> decoded = jsonDecode(contract.coefficients);
          contractCoefficients = decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
        }
      } catch (e) {
        print('تحذير: حدث خطأ أثناء قراءة نسب العقد: $e');
      }

      // حساب سعر المتر بناءً على السوق اليوم ومعاملات العقد
      final calculations = CalculatorHelper.calculateContractValues(
        area: contract.totalArea,
        currentPrices: currentPrices,
        coefficients: contractCoefficients,
      );
      final double meterPriceToday = calculations['pricePerSqm']!;

      // حساب عدد الأمتار لهذه الدفعة
      final double convertedMeters = amountPaid / meterPriceToday;

      // 1. حفظ الدفعة في دفتر الأستاذ
      final newEntry = PaymentsLedgerCompanion.insert(
        contractId: contractId,
        scheduleId: scheduleId != null ? Value(scheduleId) : const Value.absent(), 
        paymentDate: DateTime.now(),
        amountPaid: amountPaid,
        meterPriceAtPayment: meterPriceToday, 
        convertedMeters: convertedMeters,     
        fees: Value(fees),
        userId: '', 
      );
      await _erpRepository.addLedgerEntry(newEntry);

      // =========================================================================
      // 🌟🌟🌟 الخوارزمية الذكية: تسوية جدول المراقبة آلياً (Smart Schedule Sync) 🌟🌟🌟
      // =========================================================================
      
      // أ. جلب كل الدفعات السابقة لمعرفة إجمالي الأمتار التي يملكها العميل الآن
      final allEntries = await _erpRepository.getContractLedger(contractId);
      double totalConvertedMetersAccumulated = 0;
      for (var entry in allEntries) {
        totalConvertedMetersAccumulated += entry.convertedMeters;
      }

      // ب. حساب القسط الشهري المطلوب (بالأمتار)
      final int monthsCount = contract.installmentsCount > 0 ? contract.installmentsCount : 48;
      final double requiredMetersPerMonth = contract.totalArea / monthsCount;

      // ج. معرفة عدد الأشهر التي غطاها العميل بالكامل بناءً على الأمتار المتراكمة
      // نستخدم .floor() لنأخذ الرقم الصحيح للأشهر المغطاة بالكامل
      final int fullyPaidMonths = (totalConvertedMetersAccumulated / requiredMetersPerMonth).floor();

      // د. جلب جدول الاستحقاقات لهذا العقد من قاعدة البيانات
      final schedules = await _erpRepository.getContractSchedule(contractId);

      // هـ. تحديث حالة الأشهر بذكاء:
      // - يملأ الفراغات القديمة أولاً.
      // - يعطي مهلة (إغلاق أشهر مستقبلية) إذا كانت الدفعة ضخمة.
      for (var schedule in schedules) {
        if (schedule.installmentNumber <= fullyPaidMonths) {
          // إذا كان الشهر ضمن التغطية، نجعله مدفوعاً
          if (schedule.status != 'paid') {
            await _erpRepository.updateScheduleStatus(schedule.id, 'paid');
          }
        } else {
          // إذا كان الشهر خارج التغطية (مثلاً تراجع عن دفعة أو لم يكملها)، نعيده معلقاً
          if (schedule.status != 'pending') {
            await _erpRepository.updateScheduleStatus(schedule.id, 'pending');
          }
        }
      }
      // =========================================================================

      // تحديث الشاشة لإظهار التغييرات
      await selectContract(contractId);
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> markAsSent(String entryId, String contractId) async {
    try {
      await _erpRepository.markWhatsAppAsSent(entryId);
      await selectContract(contractId);
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: 'فشل في تحديث حالة الواتساب: $e'));
    }
  }
}
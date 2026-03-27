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

  /// 1. جلب البيانات الأساسية (العملاء والعقود الفعالة غير المحذوفة) لملء القوائم المنسدلة
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

  /// 2. عند اختيار عقد من القائمة، نجلب "دفتر الأستاذ" (Ledger) الخاص به
  /// 🌟 نستخدم String لأن الـ ID هو UUID
  Future<void> selectContract(String contractId) async {
    emit(state.copyWith(selectedContractId: contractId));
    try {
      final ledgerEntries = await _erpRepository.getContractLedger(contractId);
      emit(state.copyWith(status: PaymentsStatus.success, ledgerEntries: ledgerEntries));
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// 3. 🌟 جوهر النظام المالي: إضافة دفعة جديدة وحساب (الأمتار المحولة) آلياً وتجميدها
  Future<void> addLedgerEntry({
    required String contractId, // 🌟 UUID
    required double amountPaid,
    double fees = 0,
    String? scheduleId, // 🌟 الإضافة الجديدة: نمرر رقم الاستحقاق إذا جاء من شاشة المراقبة
  }) async {
    try {
      // أ. جلب العقد لمعرفة مساحة الشقة الإجمالية
      final contract = state.contracts.firstWhere((c) => c.id == contractId);

      // ب. جلب أحدث تسعيرة للمواد من السجل التاريخي (الإعدادات)
      final currentPrices = await _erpRepository.getLatestPrices();
      if (currentPrices == null) {
        throw Exception('يرجى إضافة أسعار المواد من شاشة الإعدادات أولاً لحساب سعر المتر اليوم.');
      }

      // ج. حساب سعر المتر المربع اليوم (وقت الدفع) بناءً على الكميات الثابتة للإكسل
      final calculations = CalculatorHelper.calculateContractValues(
        area: contract.totalArea,
        currentPrices: currentPrices,
      );
      final double meterPriceToday = calculations['pricePerSqm']!;

      // د. العملية الأهم: حساب عدد الأمتار التي اشتراها هذا المبلغ
      final double convertedMeters = amountPaid / meterPriceToday;

      // هـ. حفظ السجل وتجميد الأسعار (لكي لا تتغير الدفعات القديمة إذا تغير سعر السوق غداً)
      final newEntry = PaymentsLedgerCompanion.insert(
        contractId: contractId,
        scheduleId: scheduleId != null ? Value(scheduleId) : const Value.absent(), // 🌟 ربط الدفعة بالقسط المجدول
        paymentDate: DateTime.now(),
        amountPaid: amountPaid,
        meterPriceAtPayment: meterPriceToday, // 🌟 تجميد سعر المتر
        convertedMeters: convertedMeters,     // 🌟 تجميد الأمتار المحولة
        fees: Value(fees),
      );
      
      await _erpRepository.addLedgerEntry(newEntry);

      // 🌟 ز. السحر الآلي: إذا تم الدفع من خلال "شاشة المراقبة"، نغلق ذلك القسط فوراً ليصبح مدفوعاً!
      if (scheduleId != null) {
        await _erpRepository.updateScheduleStatus(scheduleId, 'paid');
      }
      
      // و. تحديث الجدول أمام المحاسب لرؤية الفاتورة فوراً
      await selectContract(contractId);
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// 4. تحديث حالة الفاتورة لتسجيل أنه تم إرسالها عبر الواتساب
  Future<void> markAsSent(String entryId, String contractId) async {
    try {
      await _erpRepository.markWhatsAppAsSent(entryId);
      // تحديث الشاشة لتنعكس التغييرات (تصبح أيقونة الواتساب رمادية)
      await selectContract(contractId);
    } catch (e) {
      print('Failed to mark WhatsApp as sent: $e');
    }
  }
}
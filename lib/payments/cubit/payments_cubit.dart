import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show PaymentsLedgerCompanion;
import 'package:drift/drift.dart' show Value;

// استدعاء الحاسبة الهندسية التي بنيناها
import '../../core/utils/calculator_helper.dart';

part 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  PaymentsCubit(this._erpRepository) : super(const PaymentsState());

  final ErpRepository _erpRepository;

  /// جلب البيانات الأساسية (العملاء والعقود الفعالة غير المحذوفة)
  Future<void> fetchInitialData() async {
    emit(state.copyWith(status: PaymentsStatus.loading));
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

  /// عند اختيار عقد من القائمة المنسدلة، نجلب دفتر الأستاذ الخاص به
  Future<void> selectContract(int contractId) async {
    emit(state.copyWith(status: PaymentsStatus.loading, selectedContractId: contractId));
    try {
      final ledgerEntries = await _erpRepository.getContractLedger(contractId);
      emit(state.copyWith(status: PaymentsStatus.success, ledgerEntries: ledgerEntries));
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// 🌟 إضافة دفعة جديدة وحساب (الأمتار المحولة) آلياً وتجميدها
  Future<void> addLedgerEntry({
    required int contractId,
    required double amountPaid,
    double fees = 0,
  }) async {
    try {
      // 1. جلب العقد لمعرفة المساحة
      final contract = state.contracts.firstWhere((c) => c.id == contractId);

      // 2. جلب أحدث تسعيرة للمواد من السجل التاريخي (الإعدادات)
      final currentPrices = await _erpRepository.getLatestPrices();
      if (currentPrices == null) {
        throw Exception('يرجى إضافة أسعار المواد من شاشة الإعدادات أولاً لحساب سعر المتر اليوم.');
      }

      // 3. حساب سعر المتر المربع اليوم (وقت الدفع)
      final calculations = CalculatorHelper.calculateContractValues(
        area: contract.totalArea,
        currentPrices: currentPrices,
      );
      final double meterPriceToday = calculations['pricePerSqm']!;

      // 4. الجوهر المالي: حساب عدد الأمتار التي اشتراها هذا المبلغ
      final double convertedMeters = amountPaid / meterPriceToday;

      // 5. حفظ السجل وتجميد الأسعار
      final newEntry = PaymentsLedgerCompanion.insert(
        contractId: contractId,
        paymentDate: DateTime.now(),
        amountPaid: amountPaid,
        meterPriceAtPayment: meterPriceToday, // تم تجميد السعر
        convertedMeters: convertedMeters,     // تم تجميد الأمتار
        fees: Value(fees),
      );
      
      await _erpRepository.addLedgerEntry(newEntry);
      
      // 6. تحديث الجدول أمام المحاسب
      await selectContract(contractId);
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// تحديث حالة إرسال الواتساب للدفعة
  Future<void> markAsSent(int entryId, int contractId) async {
    try {
      await _erpRepository.markWhatsAppAsSent(entryId);
      await selectContract(contractId);
    } catch (e) {
      print('Failed to mark WhatsApp as sent: $e');
    }
  }
}
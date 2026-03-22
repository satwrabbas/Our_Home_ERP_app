import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show PaymentsCompanion;
import 'package:drift/drift.dart' show Value;
part 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  PaymentsCubit(this._erpRepository) : super(const PaymentsState());

  final ErpRepository _erpRepository;

  /// جلب البيانات الأساسية (العملاء والعقود) لملء القوائم المنسدلة
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

  /// عند اختيار المستخدم لعقد معين، نجلب جميع الدفعات الخاصة به
  Future<void> selectContract(int contractId) async {
    emit(state.copyWith(status: PaymentsStatus.loading, selectedContractId: contractId));
    try {
      final payments = await _erpRepository.getContractPayments(contractId);
      emit(state.copyWith(status: PaymentsStatus.success, payments: payments));
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

 /// إضافة وصل استلام قسط جديد
  Future<void> addPayment({
    required int contractId,
    required int installmentNumber,
    required double amountPaid,
    required double originalInstallment,
    double fees = 0,
  }) async {
    try {
      // نحتاج استدعاء Value من مكتبة drift لأن حقل fees له قيمة افتراضية في القاعدة
      final newPayment = PaymentsCompanion.insert(
        contractId: contractId,
        installmentNumber: installmentNumber,
        amountPaid: amountPaid,
        originalInstallment: originalInstallment,
        fees: Value(fees), // ✅ التعديل هنا: وضعنا Value(fees) بدلاً من fees
        paymentDate: DateTime.now(),
      );
      
      await _erpRepository.addPayment(newPayment);
      
      // تحديث قائمة الدفعات لنفس العقد بعد الإضافة
      await selectContract(contractId);
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// تحديث حالة الفاتورة لتسجيل أنه تم إرسالها عبر الواتساب
  Future<void> markAsSent(int paymentId, int contractId) async {
    try {
      await _erpRepository.markWhatsAppAsSent(paymentId);
      // تحديث الشاشة لتنعكس التغييرات
      await selectContract(contractId);
    } catch (e) {
      print('Failed to mark WhatsApp as sent: $e');
    }
  }
}
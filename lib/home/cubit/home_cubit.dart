import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._erpRepository) : super(const HomeState());

  final ErpRepository _erpRepository;

  /// جلب وتحليل جميع بيانات الشركة لعرضها في لوحة القيادة (Dashboard)
  Future<void> fetchDashboardData() async {
    // 1. إظهار شاشة التحميل
    if (state.status == HomeStatus.initial) emit(state.copyWith(status: HomeStatus.loading));
    try {
      // 2. جلب البيانات الأساسية من المستودع
      final clients = await _erpRepository.getClients();
      final contracts = await _erpRepository.getAllContracts();

      // 3. حساب إجمالي مساحات الشقق المباعة (المتعاقد عليها)
      double soldMeters = 0.0;
      for (final contract in contracts) {
        soldMeters += contract.totalArea;
      }

      // 4. تجميع كل الدفعات (Ledger Entries) من كل العقود في قائمة واحدة
      List<PaymentsLedgerData> allPayments = [];
      for (final contract in contracts) {
        // 🌟 نستخدم ID العقد (String UUID) لجلب الدفعات الخاصة به
        final payments = await _erpRepository.getContractLedger(contract.id);
        allPayments.addAll(payments);
      }

      // 5. حساب الإجماليات (الإيرادات والأمتار المحولة) من القائمة المجمعة
      double totalRevenue = 0.0;
      double totalConvertedMeters = 0.0;
      for (final payment in allPayments) {
        totalRevenue += payment.amountPaid;
        totalConvertedMeters += payment.convertedMeters;
      }

      // 6. فرز الدفعات حسب التاريخ (من الأحدث للأقدم) لعرض آخر 5 عمليات فقط
      allPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
      final recentPayments = allPayments.take(5).toList();

      // 7. إرسال جميع البيانات النهائية إلى واجهة المستخدم
      emit(state.copyWith(
        status: HomeStatus.success,
        clientsCount: clients.length,
        contractsCount: contracts.length,
        totalSoldMeters: soldMeters,
        totalRevenue: totalRevenue,
        totalConvertedMeters: totalConvertedMeters,
        recentPayments: recentPayments,
      ));
    } catch (e) {
      // 8. في حال حدوث أي خطأ، نعرض رسالة الخطأ للمستخدم
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }
}
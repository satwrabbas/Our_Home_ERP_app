import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._erpRepository) : super(const HomeState());

  final ErpRepository _erpRepository;

  // ----------------- (الجزء الثاني سيبدأ من هنا) -----------------
  /// جلب وتحليل جميع بيانات الشركة لعرضها في لوحة القيادة (Dashboard)
  Future<void> fetchDashboardData() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      // 1. جلب العملاء والعقود الفعالة
      final clients = await _erpRepository.getClients();
      final contracts = await _erpRepository.getAllContracts();

      // 2. حساب إجمالي مساحات الشقق المباعة (المتعاقد عليها)
      double soldMeters = 0.0;
      for (final contract in contracts) {
        soldMeters += contract.totalArea;
      }

      // 3. تجميع كل الدفعات من كل العقود في قائمة واحدة
      List<PaymentsLedgerData> allPayments = [];
      for (final contract in contracts) {
        final payments = await _erpRepository.getContractLedger(contract.id);
        allPayments.addAll(payments);
      }

      // 4. حساب الإجماليات من قائمة الدفعات المجمعة
      double totalRevenue = 0.0;
      double totalConvertedMeters = 0.0;
      for (final payment in allPayments) {
        totalRevenue += payment.amountPaid;
        totalConvertedMeters += payment.convertedMeters;
      }

      // 5. فرز الدفعات حسب التاريخ (من الأحدث للأقدم) لجلب آخر 5 عمليات
      allPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
      final recentPayments = allPayments.take(5).toList();

      // 6. إرسال جميع البيانات النهائية إلى واجهة المستخدم
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
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }
}
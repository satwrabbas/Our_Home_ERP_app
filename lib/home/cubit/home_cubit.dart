// lib/home/cubit/home_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show PaymentsLedgerData;

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._erpRepository) : super(const HomeState());

  final ErpRepository _erpRepository;

  Future<void> fetchDashboardData() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final allContracts = await _erpRepository.getAllContracts();
      // هنا نفترض أنك أضفت دالة getAllPayments في الـ Repository
      final allPayments = await _erpRepository.getAllPayments(); 
      
      double totalRevenue = 0.0;
      double totalAreaSold = 0.0;
      
      // 🌟 1. تجهيز بيانات الإيرادات الشهرية (للعام الحالي فقط)
      final int currentYear = DateTime.now().year;
      Map<int, double> monthlyRev = {for (var i = 1; i <= 12; i++) i: 0.0};

      for (var p in allPayments) {
        totalRevenue += p.amountPaid;
        // إضافة الدفعة لشهرها المخصص إذا كانت في العام الحالي
        if (p.paymentDate.year == currentYear) {
          monthlyRev[p.paymentDate.month] = (monthlyRev[p.paymentDate.month] ?? 0) + p.amountPaid;
        }
      }

      // 🌟 2. تجهيز بيانات أنواع العقود والمساحات
      Map<String, int> byType = {};
      for (var c in allContracts) {
        totalAreaSold += c.totalArea;
        byType[c.contractType] = (byType[c.contractType] ?? 0) + 1;
      }
      
      // 3. آخر 5 حركات
      allPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
      final latestFive = allPayments.take(5).toList();

      emit(state.copyWith(
        status: HomeStatus.success,
        totalRevenue: totalRevenue,
        totalAreaSold: totalAreaSold,
        activeContractsCount: allContracts.length,
        latestPayments: latestFive,
        monthlyRevenue: monthlyRev, // إرسال الماب للواجهة
        contractsByType: byType,   // إرسال الماب للواجهة
      ));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }
}
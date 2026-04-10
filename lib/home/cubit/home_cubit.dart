// lib/home/cubit/home_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:intl/intl.dart';
import 'package:local_storage_api/local_storage_api.dart' show PaymentsLedgerData;

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._erpRepository) : super(const HomeState());

  final ErpRepository _erpRepository;

  // 🌟 دالة لتغيير الفلتر وإعادة الحساب فوراً
  void changeTimeFilter(TimeFilter newFilter) {
    emit(state.copyWith(timeFilter: newFilter));
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final allContracts = await _erpRepository.getAllContracts();
      final allPayments = await _erpRepository.getAllPayments(); 
      
      double totalRevenue = 0.0;
      double totalAreaSold = 0.0;
      
      Map<String, double> tempGroupedRev = {};
      Map<String, List<double>> tempPriceTrend = {}; // لجمع أسعار المتر ثم أخذ المتوسط

      // 🌟 1. تجميع الإيرادات حسب الفلتر الزمني المختار
      for (var p in allPayments) {
        totalRevenue += p.amountPaid;
        String key = _generateDateKey(p.paymentDate, state.timeFilter);
        tempGroupedRev[key] = (tempGroupedRev[key] ?? 0.0) + p.amountPaid;
      }

      // 🌟 2. تجميع العقود وحساب تطور الأسعار
      Map<String, int> byType = {};
      for (var c in allContracts) {
        totalAreaSold += c.totalArea;
        byType[c.contractType] = (byType[c.contractType] ?? 0) + 1;
        
        // تطور السعر حسب تاريخ العقد
        String key = _generateDateKey(c.contractDate, state.timeFilter);
        tempPriceTrend.putIfAbsent(key, () => []).add(c.baseMeterPriceAtSigning);
      }
      
      // حساب متوسط السعر لكل فترة زمنية
      Map<String, double> finalPriceTrend = {};
      tempPriceTrend.forEach((key, prices) {
        double sum = prices.fold(0, (a, b) => a + b);
        finalPriceTrend[key] = sum / prices.length;
      });

      // 3. آخر الحركات
      allPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
      final latestFive = allPayments.take(5).toList();

      // ترتيب الخرائط زمنياً (بشكل مبسط حسب النص)
      var sortedRev = Map.fromEntries(tempGroupedRev.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
      var sortedTrend = Map.fromEntries(finalPriceTrend.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));

      emit(state.copyWith(
        status: HomeStatus.success,
        totalRevenue: totalRevenue,
        totalAreaSold: totalAreaSold,
        activeContractsCount: allContracts.length,
        latestPayments: latestFive,
        groupedRevenue: sortedRev,
        priceTrend: sortedTrend,
        contractsByType: byType,
      ));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }

  // 🛠️ دالة مساعدة لتوليد مفتاح التجميع بناءً على الفلتر
  String _generateDateKey(DateTime date, TimeFilter filter) {
    switch (filter) {
      case TimeFilter.daily:
        return DateFormat('yyyy-MM-dd').format(date);
      case TimeFilter.weekly:
        // حساب مبسط للأسبوع (السنة-رقم الأسبوع)
        int weekOfYear = ((date.day - date.weekday + 10) / 7).floor();
        return '${date.year} - W$weekOfYear';
      case TimeFilter.monthly:
        return DateFormat('yyyy-MM').format(date);
      case TimeFilter.yearly:
        return DateFormat('yyyy').format(date);
    }
  }
}
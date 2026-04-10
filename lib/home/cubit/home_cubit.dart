// lib/home/cubit/home_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:intl/intl.dart';
import 'package:local_storage_api/local_storage_api.dart' show PaymentsLedgerData;

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._erpRepository) : super(HomeState(referenceDate: DateTime.now()));

  final ErpRepository _erpRepository;

  // 🌟 تغيير الفلتر الزمني (يرجع التاريخ لليوم الافتراضي)
  void changeTimeFilter(TimeFilter newFilter) {
    emit(state.copyWith(timeFilter: newFilter, referenceDate: DateTime.now()));
    fetchDashboardData();
  }

  // 🌟 سهم الرجوع للخلف (الماضي)
  void navigatePrevious() {
    DateTime newDate = state.referenceDate;
    switch (state.timeFilter) {
      case TimeFilter.daily: newDate = newDate.subtract(const Duration(days: 7)); break; // رجوع أسبوع
      case TimeFilter.weekly: newDate = DateTime(newDate.year, newDate.month - 1, 1); break; // رجوع شهر
      case TimeFilter.monthly: newDate = DateTime(newDate.year - 1, newDate.month, 1); break; // رجوع سنة
      case TimeFilter.yearly: newDate = DateTime(newDate.year - 5, newDate.month, 1); break; // رجوع 5 سنوات
    }
    emit(state.copyWith(referenceDate: newDate));
    fetchDashboardData();
  }

  // 🌟 سهم التقدم للأمام (المستقبل)
  void navigateNext() {
    DateTime newDate = state.referenceDate;
    switch (state.timeFilter) {
      case TimeFilter.daily: newDate = newDate.add(const Duration(days: 7)); break;
      case TimeFilter.weekly: newDate = DateTime(newDate.year, newDate.month + 1, 1); break;
      case TimeFilter.monthly: newDate = DateTime(newDate.year + 1, newDate.month, 1); break;
      case TimeFilter.yearly: newDate = DateTime(newDate.year + 5, newDate.month, 1); break;
    }
    // منع تجاوز تاريخ اليوم الحالي (لا يمكن التنبؤ بالمستقبل!)
    if (newDate.isAfter(DateTime.now())) newDate = DateTime.now();
    
    emit(state.copyWith(referenceDate: newDate));
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
      Map<String, List<double>> tempPriceTrend = {}; 

      // 🌟 1. تجهيز قالب المحور السيني (X-Axis) بناءً على النافذة الزمنية
      final refDate = state.referenceDate;
      
      if (state.timeFilter == TimeFilter.daily) {
        // عرض 7 أيام تنتهي بالتاريخ المرجعي
        for (int i = 6; i >= 0; i--) {
          String key = DateFormat('MM-dd').format(refDate.subtract(Duration(days: i)));
          tempGroupedRev[key] = 0.0;
          tempPriceTrend[key] =[];
        }
      } else if (state.timeFilter == TimeFilter.weekly) {
        // عرض 4 أسابيع للشهر المرجعي
        for (int i = 1; i <= 4; i++) {
          tempGroupedRev['الأسبوع $i'] = 0.0;
          tempPriceTrend['الأسبوع $i'] =[];
        }
      } else if (state.timeFilter == TimeFilter.monthly) {
        // عرض 12 شهراً للسنة المرجعية
        for (int i = 1; i <= 12; i++) {
          String key = '${refDate.year}-${i.toString().padLeft(2, '0')}';
          tempGroupedRev[key] = 0.0;
          tempPriceTrend[key] =[];
        }
      } else if (state.timeFilter == TimeFilter.yearly) {
        // عرض 5 سنوات تنتهي بالسنة المرجعية
        for (int i = 4; i >= 0; i--) {
          String key = '${refDate.year - i}';
          tempGroupedRev[key] = 0.0;
          tempPriceTrend[key] =[];
        }
      }

      // 🌟 2. إسقاط البيانات الحقيقية داخل القوالب الجاهزة
      for (var p in allPayments) {
        totalRevenue += p.amountPaid; // المجموع الكلي (دائماً يحسب كل شيء)
        
        // التحقق أين تقع هذه الدفعة في النافذة الزمنية
        if (state.timeFilter == TimeFilter.daily) {
          String key = DateFormat('MM-dd').format(p.paymentDate);
          if (tempGroupedRev.containsKey(key)) tempGroupedRev[key] = tempGroupedRev[key]! + p.amountPaid;
        } else if (state.timeFilter == TimeFilter.weekly && p.paymentDate.year == refDate.year && p.paymentDate.month == refDate.month) {
          int weekNum = ((p.paymentDate.day - 1) / 7).floor() + 1;
          if (weekNum > 4) weekNum = 4;
          tempGroupedRev['الأسبوع $weekNum'] = tempGroupedRev['الأسبوع $weekNum']! + p.amountPaid;
        } else if (state.timeFilter == TimeFilter.monthly && p.paymentDate.year == refDate.year) {
          String key = '${p.paymentDate.year}-${p.paymentDate.month.toString().padLeft(2, '0')}';
          if (tempGroupedRev.containsKey(key)) tempGroupedRev[key] = tempGroupedRev[key]! + p.amountPaid;
        } else if (state.timeFilter == TimeFilter.yearly) {
          String key = '${p.paymentDate.year}';
          if (tempGroupedRev.containsKey(key)) tempGroupedRev[key] = tempGroupedRev[key]! + p.amountPaid;
        }
      }

      // 🌟 3. إسقاط أسعار العقود في القوالب الجاهزة
      Map<String, int> byType = {};
      for (var c in allContracts) {
        totalAreaSold += c.totalArea;
        byType[c.contractType] = (byType[c.contractType] ?? 0) + 1;
        
        if (state.timeFilter == TimeFilter.daily) {
          String key = DateFormat('MM-dd').format(c.contractDate);
          if (tempPriceTrend.containsKey(key)) tempPriceTrend[key]!.add(c.baseMeterPriceAtSigning);
        } else if (state.timeFilter == TimeFilter.weekly && c.contractDate.year == refDate.year && c.contractDate.month == refDate.month) {
          int weekNum = ((c.contractDate.day - 1) / 7).floor() + 1;
          if (weekNum > 4) weekNum = 4;
          tempPriceTrend['الأسبوع $weekNum']!.add(c.baseMeterPriceAtSigning);
        } else if (state.timeFilter == TimeFilter.monthly && c.contractDate.year == refDate.year) {
          String key = '${c.contractDate.year}-${c.contractDate.month.toString().padLeft(2, '0')}';
          if (tempPriceTrend.containsKey(key)) tempPriceTrend[key]!.add(c.baseMeterPriceAtSigning);
        } else if (state.timeFilter == TimeFilter.yearly) {
          String key = '${c.contractDate.year}';
          if (tempPriceTrend.containsKey(key)) tempPriceTrend[key]!.add(c.baseMeterPriceAtSigning);
        }
      }
      
      // حساب متوسط السعر
      Map<String, double> finalPriceTrend = {};
      tempPriceTrend.forEach((key, prices) {
        if (prices.isEmpty) {
          finalPriceTrend[key] = 0.0;
        } else {
          double sum = prices.fold(0, (a, b) => a + b);
          finalPriceTrend[key] = sum / prices.length;
        }
      });

      allPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
      final latestFive = allPayments.take(5).toList();

      emit(state.copyWith(
        status: HomeStatus.success,
        totalRevenue: totalRevenue,
        totalAreaSold: totalAreaSold,
        activeContractsCount: allContracts.length,
        latestPayments: latestFive,
        groupedRevenue: tempGroupedRev, // 🌟 جاهزة ومرتبة ومعبأة بالأصفار!
        priceTrend: finalPriceTrend,
        contractsByType: byType,
      ));
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }
}
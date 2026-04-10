// lib/home/cubit/home_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:intl/intl.dart';
import 'package:local_storage_api/local_storage_api.dart' show PaymentsLedgerData, Contract;

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._erpRepository) : super(HomeState(referenceDate: DateTime.now()));

  final ErpRepository _erpRepository;

  // 🌟 ذاكرة التخزين المؤقت (Cache) لمنع استدعاء قاعدة البيانات مع كل ضغطة سهم
  List<Contract> _cachedContracts =[];
  List<PaymentsLedgerData> _cachedPayments =[];

  // =======================================================
  // 1. جلب البيانات من القاعدة (يُستدعى مرة واحدة فقط عند فتح الصفحة أو المزامنة)
  // =======================================================
  Future<void> fetchDashboardData() async {
    emit(state.copyWith(status: HomeStatus.loading)); // هنا فقط نظهر دائرة التحميل
    try {
      _cachedContracts = await _erpRepository.getAllContracts();
      _cachedPayments = await _erpRepository.getAllPayments(); 
      
      // بمجرد جلب البيانات، نقوم بمعالجتها وإرسالها للشاشة
      _processAndEmitData();
    } catch (e) {
      emit(state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()));
    }
  }

  // =======================================================
  // 2. دوال التنقل (لا تحتوي على Loading، بل تقوم بالحساب الفوري)
  // =======================================================
  void changeTimeFilter(TimeFilter newFilter) {
    emit(state.copyWith(timeFilter: newFilter, referenceDate: DateTime.now()));
    _processAndEmitData(); // 🌟 حساب فوري وبدون إعادة تحميل
  }

  void navigatePrevious() {
    DateTime newDate = state.referenceDate;
    switch (state.timeFilter) {
      case TimeFilter.daily: newDate = newDate.subtract(const Duration(days: 7)); break;
      case TimeFilter.weekly: newDate = DateTime(newDate.year, newDate.month - 1, 1); break;
      case TimeFilter.monthly: newDate = DateTime(newDate.year - 1, newDate.month, 1); break;
      case TimeFilter.yearly: newDate = DateTime(newDate.year - 5, newDate.month, 1); break;
    }
    emit(state.copyWith(referenceDate: newDate));
    _processAndEmitData(); // 🌟 حساب فوري وبدون إعادة تحميل
  }

  void navigateNext() {
    DateTime newDate = state.referenceDate;
    switch (state.timeFilter) {
      case TimeFilter.daily: newDate = newDate.add(const Duration(days: 7)); break;
      case TimeFilter.weekly: newDate = DateTime(newDate.year, newDate.month + 1, 1); break;
      case TimeFilter.monthly: newDate = DateTime(newDate.year + 1, newDate.month, 1); break;
      case TimeFilter.yearly: newDate = DateTime(newDate.year + 5, newDate.month, 1); break;
    }
    if (newDate.isAfter(DateTime.now())) newDate = DateTime.now();
    
    emit(state.copyWith(referenceDate: newDate));
    _processAndEmitData(); // 🌟 حساب فوري وبدون إعادة تحميل
  }

  // =======================================================
  // 3. المحرك الرياضي (يأخذ البيانات من الذاكرة ويعالجها في ميلي ثانية)
  // =======================================================
  void _processAndEmitData() {
    double totalRevenue = 0.0;
    double totalAreaSold = 0.0;
    
    Map<String, double> tempGroupedRev = {};
    Map<String, List<double>> tempPriceTrend = {}; 

    final refDate = state.referenceDate;
    
    // 1. تجهيز قالب المحور السيني
    if (state.timeFilter == TimeFilter.daily) {
      for (int i = 6; i >= 0; i--) {
        String key = DateFormat('MM-dd').format(refDate.subtract(Duration(days: i)));
        tempGroupedRev[key] = 0.0;
        tempPriceTrend[key] =[];
      }
    } else if (state.timeFilter == TimeFilter.weekly) {
      for (int i = 1; i <= 4; i++) {
        tempGroupedRev['الأسبوع $i'] = 0.0;
        tempPriceTrend['الأسبوع $i'] =[];
      }
    } else if (state.timeFilter == TimeFilter.monthly) {
      for (int i = 1; i <= 12; i++) {
        String key = '${refDate.year}-${i.toString().padLeft(2, '0')}';
        tempGroupedRev[key] = 0.0;
        tempPriceTrend[key] =[];
      }
    } else if (state.timeFilter == TimeFilter.yearly) {
      for (int i = 4; i >= 0; i--) {
        String key = '${refDate.year - i}';
        tempGroupedRev[key] = 0.0;
        tempPriceTrend[key] =[];
      }
    }

    // 2. حساب الإيرادات من الذاكرة المخبأة
    for (var p in _cachedPayments) {
      totalRevenue += p.amountPaid; 
      
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

    // 3. حساب العقود والأسعار من الذاكرة المخبأة
    Map<String, int> byType = {};
    for (var c in _cachedContracts) {
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
    
    Map<String, double> finalPriceTrend = {};
    tempPriceTrend.forEach((key, prices) {
      if (prices.isEmpty) {
        finalPriceTrend[key] = 0.0;
      } else {
        double sum = prices.fold(0, (a, b) => a + b);
        finalPriceTrend[key] = sum / prices.length;
      }
    });

    // آخر 5 حركات (نأخذ نسخة لنقوم بترتيبها دون التأثير على القائمة الأصلية)
    var sortedPayments = List<PaymentsLedgerData>.from(_cachedPayments);
    sortedPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
    final latestFive = sortedPayments.take(5).toList();

    // 4. إرسال الحالة النهائية للواجهة (ستقوم الواجهة بعمل Animation بدلاً من الوميض)
    emit(state.copyWith(
      status: HomeStatus.success,
      totalRevenue: totalRevenue,
      totalAreaSold: totalAreaSold,
      activeContractsCount: _cachedContracts.length,
      latestPayments: latestFive,
      groupedRevenue: tempGroupedRev, 
      priceTrend: finalPriceTrend,
      contractsByType: byType,
    ));
  }
}
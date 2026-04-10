// lib/home/cubit/home_state.dart
part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, failure }
enum TimeFilter { daily, weekly, monthly, yearly } // 🌟 الفلتر الزمني الجديد

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.timeFilter = TimeFilter.monthly, // الافتراضي: شهري
    this.totalRevenue = 0.0,
    this.totalAreaSold = 0.0,
    this.activeContractsCount = 0,
    this.latestPayments = const [],
    this.groupedRevenue = const {}, // 🌟 الإيرادات المجمعة حسب الفلتر
    this.priceTrend = const {},     // 🌟 تطور متوسط سعر المتر
    this.contractsByType = const {},
    this.errorMessage,
  });

  final HomeStatus status;
  final TimeFilter timeFilter;
  
  final double totalRevenue;
  final double totalAreaSold;
  final int activeContractsCount;
  final List<PaymentsLedgerData> latestPayments;
  
  final Map<String, double> groupedRevenue; 
  final Map<String, double> priceTrend; 
  final Map<String, int> contractsByType; 
  
  final String? errorMessage;
  
  double get averageSellPrice => totalAreaSold == 0 ? 0.0 : totalRevenue / totalAreaSold;

  HomeState copyWith({
    HomeStatus? status,
    TimeFilter? timeFilter,
    double? totalRevenue,
    double? totalAreaSold,
    int? activeContractsCount,
    List<PaymentsLedgerData>? latestPayments,
    Map<String, double>? groupedRevenue,
    Map<String, double>? priceTrend,
    Map<String, int>? contractsByType,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      timeFilter: timeFilter ?? this.timeFilter,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalAreaSold: totalAreaSold ?? this.totalAreaSold,
      activeContractsCount: activeContractsCount ?? this.activeContractsCount,
      latestPayments: latestPayments ?? this.latestPayments,
      groupedRevenue: groupedRevenue ?? this.groupedRevenue,
      priceTrend: priceTrend ?? this.priceTrend,
      contractsByType: contractsByType ?? this.contractsByType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status, timeFilter, totalRevenue, totalAreaSold, activeContractsCount,
        latestPayments, groupedRevenue, priceTrend, contractsByType, averageSellPrice,
      ];
}
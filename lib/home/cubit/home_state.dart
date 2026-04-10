// lib/home/cubit/home_state.dart
part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.totalRevenue = 0.0,
    this.totalAreaSold = 0.0,
    this.activeContractsCount = 0,
    this.latestPayments = const [],
    this.monthlyRevenue = const {}, // 🌟 التدفق النقدي الشهري
    this.contractsByType = const {}, // 🌟 توزيع أنواع العقود
    this.errorMessage,
  });

  final HomeStatus status;
  final double totalRevenue;
  final double totalAreaSold;
  final int activeContractsCount;
  final List<PaymentsLedgerData> latestPayments;
  
  final Map<int, double> monthlyRevenue; 
  final Map<String, int> contractsByType; 
  
  final String? errorMessage;
  
  double get averageSellPrice {
    if (totalAreaSold == 0) return 0.0;
    return totalRevenue / totalAreaSold;
  }

  HomeState copyWith({
    HomeStatus? status,
    double? totalRevenue,
    double? totalAreaSold,
    int? activeContractsCount,
    List<PaymentsLedgerData>? latestPayments,
    Map<int, double>? monthlyRevenue,
    Map<String, int>? contractsByType,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalAreaSold: totalAreaSold ?? this.totalAreaSold,
      activeContractsCount: activeContractsCount ?? this.activeContractsCount,
      latestPayments: latestPayments ?? this.latestPayments,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      contractsByType: contractsByType ?? this.contractsByType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status, totalRevenue, totalAreaSold, activeContractsCount,
        latestPayments, monthlyRevenue, contractsByType, averageSellPrice,
      ];
}
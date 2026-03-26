part of 'home_cubit.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.totalRevenue = 0.0,
    this.totalSoldMeters = 0.0,
    this.totalConvertedMeters = 0.0,
    this.clientsCount = 0,
    this.contractsCount = 0,
    this.recentPayments = const[],
    this.errorMessage,
  });

  final HomeStatus status;
  
  // 🌟 المؤشرات المالية والهندسية (KPIs)
  final double totalRevenue;          // إجمالي المبالغ المحصلة في الصندوق
  final double totalSoldMeters;       // إجمالي مساحات الشقق المباعة
  final double totalConvertedMeters;  // إجمالي الأمتار التي اشتراها العملاء فعلياً بدفعاتهم
  
  final int clientsCount;             // إجمالي عدد العملاء
  final int contractsCount;           // إجمالي عدد العقود الموقعة
  
  final List<PaymentsLedgerData> recentPayments; // آخر 5 حركات مالية لعرضها في الشاشة الرئيسية
  
  final String? errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    double? totalRevenue,
    double? totalSoldMeters,
    double? totalConvertedMeters,
    int? clientsCount,
    int? contractsCount,
    List<PaymentsLedgerData>? recentPayments,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalSoldMeters: totalSoldMeters ?? this.totalSoldMeters,
      totalConvertedMeters: totalConvertedMeters ?? this.totalConvertedMeters,
      clientsCount: clientsCount ?? this.clientsCount,
      contractsCount: contractsCount ?? this.contractsCount,
      recentPayments: recentPayments ?? this.recentPayments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>[
        status,
        totalRevenue,
        totalSoldMeters,
        totalConvertedMeters,
        clientsCount,
        contractsCount,
        recentPayments,
        errorMessage,
      ];
}
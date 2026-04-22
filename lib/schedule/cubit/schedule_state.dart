// lib/schedule/cubit/schedule_state.dart
part of 'schedule_cubit.dart';

enum ScheduleStatus { initial, loading, success, failure }

// 🌟 نموذج بيانات ذكي يجمع معلومات الرادار
class AllocationAlertData {
  final Contract contract;
  final Client client;
  final double accumulatedMeters; // الأمتار المجمعة
  final double averageMetersPerMonth; // سرعة الدفع
  final int estimatedMonthsLeft; // كم شهر باقي ليتخصص
  final String urgencyLevel; // high, medium, low

  AllocationAlertData({
    required this.contract,
    required this.client,
    required this.accumulatedMeters,
    required this.averageMetersPerMonth,
    required this.estimatedMonthsLeft,
    required this.urgencyLevel,
  });
}

class ScheduleState extends Equatable {
  const ScheduleState({
    this.status = ScheduleStatus.initial,
    this.clients = const[],
    this.contracts = const [],
    this.scheduleList = const[],
    this.allocationAlerts = const[], // 🌟 قائمة الرادار
    this.selectedContractId,
    this.errorMessage,
  });

  final ScheduleStatus status;
  final List<Client> clients;
  final List<Contract> contracts;
  final List<InstallmentsScheduleData> scheduleList;
  final List<AllocationAlertData> allocationAlerts; // 🌟
  final String? selectedContractId;
  final String? errorMessage;

  ScheduleState copyWith({
    ScheduleStatus? status,
    List<Client>? clients,
    List<Contract>? contracts,
    List<InstallmentsScheduleData>? scheduleList,
    List<AllocationAlertData>? allocationAlerts, // 🌟
    String? selectedContractId,
    String? errorMessage,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      clients: clients ?? this.clients,
      contracts: contracts ?? this.contracts,
      scheduleList: scheduleList ?? this.scheduleList,
      allocationAlerts: allocationAlerts ?? this.allocationAlerts, // 🌟
      selectedContractId: selectedContractId ?? this.selectedContractId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>[
        status, clients, contracts, scheduleList, allocationAlerts, selectedContractId, errorMessage
      ];
}
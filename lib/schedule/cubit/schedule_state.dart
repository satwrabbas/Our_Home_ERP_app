// lib/schedule/cubit/schedule_state.dart
part of 'schedule_cubit.dart';

enum ScheduleStatus { initial, loading, success, failure }

// نموذج رادار التخصص
class AllocationAlertData {
  final Contract contract;
  final Client client;
  final double accumulatedMeters; 
  final double averageMetersPerMonth; 
  final int estimatedMonthsLeft; 
  final String urgencyLevel; 

  AllocationAlertData({
    required this.contract, required this.client, required this.accumulatedMeters,
    required this.averageMetersPerMonth, required this.estimatedMonthsLeft, required this.urgencyLevel,
  });
}

// 🌟 نموذج رادار المتعثرين (الجديد)
class OverdueContractAlert {
  final Contract contract;
  final Client client;
  final List<InstallmentsScheduleData> overdueSchedules; // كل الأقساط المتراكمة
  final int maxDaysOverdue; // أقصى مدة تأخير لأقدم قسط
  final String severity; // critical, warning, notice

  OverdueContractAlert({
    required this.contract, required this.client, required this.overdueSchedules,
    required this.maxDaysOverdue, required this.severity,
  });
}

class ScheduleState extends Equatable {
  const ScheduleState({
    this.status = ScheduleStatus.initial,
    this.clients = const[],
    this.contracts = const [],
    this.scheduleList = const[],
    this.allocationAlerts = const[], 
    this.overdueAlerts = const[], // 🌟 قائمة المتعثرين
    this.selectedContractId,
    this.errorMessage,
  });

  final ScheduleStatus status;
  final List<Client> clients;
  final List<Contract> contracts;
  final List<InstallmentsScheduleData> scheduleList;
  final List<AllocationAlertData> allocationAlerts; 
  final List<OverdueContractAlert> overdueAlerts; // 🌟
  final String? selectedContractId;
  final String? errorMessage;

  ScheduleState copyWith({
    ScheduleStatus? status,
    List<Client>? clients,
    List<Contract>? contracts,
    List<InstallmentsScheduleData>? scheduleList,
    List<AllocationAlertData>? allocationAlerts, 
    List<OverdueContractAlert>? overdueAlerts, // 🌟
    String? selectedContractId,
    String? errorMessage,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      clients: clients ?? this.clients,
      contracts: contracts ?? this.contracts,
      scheduleList: scheduleList ?? this.scheduleList,
      allocationAlerts: allocationAlerts ?? this.allocationAlerts, 
      overdueAlerts: overdueAlerts ?? this.overdueAlerts, // 🌟
      selectedContractId: selectedContractId ?? this.selectedContractId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>[
    status, clients, contracts, scheduleList, allocationAlerts, overdueAlerts, selectedContractId, errorMessage
  ];
}
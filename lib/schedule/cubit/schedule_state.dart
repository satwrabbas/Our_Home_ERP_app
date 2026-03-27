part of 'schedule_cubit.dart';

enum ScheduleStatus { initial, loading, success, failure }

class ScheduleState extends Equatable {
  const ScheduleState({
    this.status = ScheduleStatus.initial,
    this.clients = const [],
    this.contracts = const [],
    this.scheduleList = const[],
    this.selectedContractId,
    this.errorMessage,
  });

  final ScheduleStatus status;
  final List<Client> clients;
  final List<Contract> contracts;
  
  // 🌟 القائمة التي ستحمل جدول الأقساط المجدولة آلياً
  final List<InstallmentsScheduleData> scheduleList; 
  
  final String? selectedContractId;
  final String? errorMessage;

  ScheduleState copyWith({
    ScheduleStatus? status,
    List<Client>? clients,
    List<Contract>? contracts,
    List<InstallmentsScheduleData>? scheduleList,
    String? selectedContractId,
    String? errorMessage,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      clients: clients ?? this.clients,
      contracts: contracts ?? this.contracts,
      scheduleList: scheduleList ?? this.scheduleList,
      selectedContractId: selectedContractId ?? this.selectedContractId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>[
        status,
        clients,
        contracts,
        scheduleList,
        selectedContractId,
        errorMessage,
      ];
}
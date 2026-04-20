//lib\contracts\cubit\contracts_state.dart
part of 'contracts_cubit.dart';

enum ContractsStatus { initial, loading, success, failure }

class ContractsState extends Equatable {
  const ContractsState({
    this.status = ContractsStatus.initial,
    this.contracts = const [],
    this.deletedContracts = const[], // 🌟 قائمة العقود المحذوفة
    this.clients = const[], 
    this.errorMessage,
  });

  final ContractsStatus status;
  final List<Contract> contracts;
  final List<Contract> deletedContracts; // 🌟 تمت الإضافة
  final List<Client> clients;
  final String? errorMessage;

  ContractsState copyWith({
    ContractsStatus? status,
    List<Contract>? contracts,
    List<Contract>? deletedContracts, // 🌟 تمت الإضافة
    List<Client>? clients,
    String? errorMessage,
  }) {
    return ContractsState(
      status: status ?? this.status,
      contracts: contracts ?? this.contracts,
      deletedContracts: deletedContracts ?? this.deletedContracts, // 🌟 تمت الإضافة
      clients: clients ?? this.clients,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>[status, contracts, deletedContracts, clients, errorMessage];
}
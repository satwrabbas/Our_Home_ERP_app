//contracts_state.dart
part of 'contracts_cubit.dart';

enum ContractsStatus { initial, loading, success, failure }

class ContractsState extends Equatable {
  const ContractsState({
    this.status = ContractsStatus.initial,
    this.contracts = const [],
    this.clients = const[], // نحتاج قائمة العملاء لاختيار العميل عند إضافة عقد
    this.errorMessage,
  });

  final ContractsStatus status;
  final List<Contract> contracts;
  final List<Client> clients;
  final String? errorMessage;

  ContractsState copyWith({
    ContractsStatus? status,
    List<Contract>? contracts,
    List<Client>? clients,
    String? errorMessage,
  }) {
    return ContractsState(
      status: status ?? this.status,
      contracts: contracts ?? this.contracts,
      clients: clients ?? this.clients,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, contracts, clients, errorMessage];
}
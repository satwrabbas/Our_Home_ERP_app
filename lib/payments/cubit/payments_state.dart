part of 'payments_cubit.dart';

enum PaymentsStatus { initial, loading, success, failure }

class PaymentsState extends Equatable {
  const PaymentsState({
    this.status = PaymentsStatus.initial,
    this.clients = const[],
    this.contracts = const [],
    this.payments = const[],
    this.selectedContractId,
    this.errorMessage,
  });

  final PaymentsStatus status;
  final List<Client> clients;
  final List<Contract> contracts;
  final List<Payment> payments;
  final int? selectedContractId;
  final String? errorMessage;

  PaymentsState copyWith({
    PaymentsStatus? status,
    List<Client>? clients,
    List<Contract>? contracts,
    List<Payment>? payments,
    int? selectedContractId,
    String? errorMessage,
  }) {
    return PaymentsState(
      status: status ?? this.status,
      clients: clients ?? this.clients,
      contracts: contracts ?? this.contracts,
      payments: payments ?? this.payments,
      selectedContractId: selectedContractId ?? this.selectedContractId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>[status, clients, contracts, payments, selectedContractId, errorMessage];
}
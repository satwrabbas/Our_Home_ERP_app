//lib\clients\cubit\clients_state.dart
part of 'clients_cubit.dart';

enum ClientsStatus { initial, loading, success, failure }

class ClientsState extends Equatable {
  const ClientsState({
    this.status = ClientsStatus.initial,
    this.clients = const[],
    this.errorMessage,
  });

  final ClientsStatus status;
  final List<Client> clients;
  final String? errorMessage;

  ClientsState copyWith({
    ClientsStatus? status,
    List<Client>? clients,
    String? errorMessage,
  }) {
    return ClientsState(
      status: status ?? this.status,
      clients: clients ?? this.clients,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>[status, clients, errorMessage];
}
part of 'clients_cubit.dart';

enum ClientsStatus { initial, loading, success, failure }

class ClientsState extends Equatable {
  const ClientsState({
    this.status = ClientsStatus.initial,
    this.clients = const[],
    this.deletedClients = const[], // 🌟 تمت الإضافة
    this.errorMessage,
  });

  final ClientsStatus status;
  final List<Client> clients;
  final List<Client> deletedClients; // 🌟 تمت الإضافة
  final String? errorMessage;

  ClientsState copyWith({
    ClientsStatus? status,
    List<Client>? clients,
    List<Client>? deletedClients, // 🌟 تمت الإضافة
    String? errorMessage,
  }) {
    return ClientsState(
      status: status ?? this.status,
      clients: clients ?? this.clients,
      deletedClients: deletedClients ?? this.deletedClients, // 🌟 تمت الإضافة
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, clients, deletedClients, errorMessage]; // 🌟 تحديث الـ props
}
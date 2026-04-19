// lib/payments/cubit/payments_state.dart
part of 'payments_cubit.dart';

enum PaymentsStatus { initial, loading, success, failure }

class PaymentsState extends Equatable {
  const PaymentsState({
    this.status = PaymentsStatus.initial,
    this.clients = const[],
    this.contracts = const [],
    this.apartments = const [], // 🌟 أضفنا الشقق
    this.buildings = const [],  // 🌟 أضفنا المحاضر
    this.ledgerEntries = const[], 
    this.selectedContractId,      
    this.errorMessage,
  });

  final PaymentsStatus status;
  final List<Client> clients;
  final List<Contract> contracts;
  final List<Apartment> apartments; // 🌟 
  final List<Building> buildings;   // 🌟 
  final List<PaymentsLedgerData> ledgerEntries; 
  final String? selectedContractId;             
  final String? errorMessage;

  PaymentsState copyWith({
    PaymentsStatus? status,
    List<Client>? clients,
    List<Contract>? contracts,
    List<Apartment>? apartments, // 🌟
    List<Building>? buildings,   // 🌟
    List<PaymentsLedgerData>? ledgerEntries,
    String? selectedContractId, 
    String? errorMessage,
  }) {
    return PaymentsState(
      status: status ?? this.status,
      clients: clients ?? this.clients,
      contracts: contracts ?? this.contracts,
      apartments: apartments ?? this.apartments, // 🌟
      buildings: buildings ?? this.buildings,    // 🌟
      ledgerEntries: ledgerEntries ?? this.ledgerEntries,
      selectedContractId: selectedContractId ?? this.selectedContractId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        clients,
        contracts,
        apartments, // 🌟
        buildings,  // 🌟
        ledgerEntries,
        selectedContractId,
        errorMessage
      ];
}
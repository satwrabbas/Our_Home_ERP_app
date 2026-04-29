// lib/recycle_bin/cubit/recycle_bin_state.dart
part of 'recycle_bin_cubit.dart';

enum RecycleBinStatus { initial, loading, success, failure }

class RecycleBinState extends Equatable {
  const RecycleBinState({
    this.status = RecycleBinStatus.initial,
    this.deletedBuildings = const [],
    this.deletedApartments = const[],
    this.deletedClients = const [],
    this.deletedContracts = const [],
    this.deletedPayments = const[],
    this.errorMessage,
  });

  final RecycleBinStatus status;
  final List<Building> deletedBuildings;
  final List<Apartment> deletedApartments;
  final List<Client> deletedClients;
  final List<Contract> deletedContracts;
  final List<PaymentsLedgerData> deletedPayments;
  final String? errorMessage;

  RecycleBinState copyWith({
    RecycleBinStatus? status,
    List<Building>? deletedBuildings,
    List<Apartment>? deletedApartments,
    List<Client>? deletedClients,
    List<Contract>? deletedContracts,
    List<PaymentsLedgerData>? deletedPayments,
    String? errorMessage,
  }) {
    return RecycleBinState(
      status: status ?? this.status,
      deletedBuildings: deletedBuildings ?? this.deletedBuildings,
      deletedApartments: deletedApartments ?? this.deletedApartments,
      deletedClients: deletedClients ?? this.deletedClients,
      deletedContracts: deletedContracts ?? this.deletedContracts,
      deletedPayments: deletedPayments ?? this.deletedPayments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>[
        status,
        deletedBuildings,
        deletedApartments,
        deletedClients,
        deletedContracts,
        deletedPayments,
        errorMessage,
      ];
}
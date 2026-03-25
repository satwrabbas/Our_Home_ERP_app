part of 'payments_cubit.dart';

enum PaymentsStatus { initial, loading, success, failure }

class PaymentsState extends Equatable {
  const PaymentsState({
    this.status = PaymentsStatus.initial,
    this.clients = const[],
    this.contracts = const [],
    this.ledgerEntries = const[], // ✅ استخدمنا الاسم الجديد لدفتر الأستاذ
    this.selectedContractId,
    this.errorMessage,
  });

  final PaymentsStatus status;
  final List<Client> clients;
  final List<Contract> contracts;
  final List<PaymentsLedgerData> ledgerEntries; // ✅ النوع الجديد الذي يمثل الدفعة
  final int? selectedContractId;
  final String? errorMessage;

  PaymentsState copyWith({
    PaymentsStatus? status,
    List<Client>? clients,
    List<Contract>? contracts,
    List<PaymentsLedgerData>? ledgerEntries,
    int? selectedContractId,
    String? errorMessage,
  }) {
    return PaymentsState(
      status: status ?? this.status,
      clients: clients ?? this.clients,
      contracts: contracts ?? this.contracts,
      ledgerEntries: ledgerEntries ?? this.ledgerEntries,
      selectedContractId: selectedContractId ?? this.selectedContractId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>[
        status,
        clients,
        contracts,
        ledgerEntries,
        selectedContractId,
        errorMessage
      ];
}
import 'database.dart';

/// الواجهة البرمجية التي تتحكم بالبيانات المحلية (Drift)
class LocalStorageApi {
  LocalStorageApi({AppDatabase? database}) : _db = database ?? AppDatabase();

  final AppDatabase _db;

  // جلب قاعدة البيانات للعمليات المتقدمة إن لزم الأمر
  AppDatabase get database => _db;

  // ---------------------------------------------------------------------------
  // العملاء (Clients)
  // ---------------------------------------------------------------------------
  Future<List<Client>> getClients() => _db.getAllClients();
  Future<int> addClient(ClientsCompanion client) => _db.insertClient(client);
  Future<bool> updateClient(Client client) => _db.updateClient(client);
  Future<int> deleteClient(Client client) => _db.deleteClient(client);

  // ---------------------------------------------------------------------------
  // العقود (Contracts)
  // ---------------------------------------------------------------------------
  Future<List<Contract>> getClientContracts(int clientId) => _db.getContractsForClient(clientId);
  Future<int> addContract(ContractsCompanion contract) => _db.insertContract(contract);
  Future<List<Contract>> getAllContracts() => _db.getAllContracts();
  
  // ---------------------------------------------------------------------------
  // الدفعات (Payments / Installments)
  // ---------------------------------------------------------------------------
  Future<List<Payment>> getContractPayments(int contractId) => _db.getPaymentsForContract(contractId);
  Future<int> addPayment(PaymentsCompanion payment) => _db.insertPayment(payment);
  Future<int> updateWhatsAppStatus(int paymentId) => _db.markWhatsAppAsSent(paymentId);

  // ---------------------------------------------------------------------------
  // الإعدادات المتقدمة
  // ---------------------------------------------------------------------------
  Future<void> formatDatabase() => _db.clearAllData();

  // الأسعار (Material Prices)
  Future<MaterialPrice?> getLatestPrices() => _db.getLatestPrices();
  Future<int> savePrices(MaterialPricesCompanion prices) => _db.insertPrices(prices);
}
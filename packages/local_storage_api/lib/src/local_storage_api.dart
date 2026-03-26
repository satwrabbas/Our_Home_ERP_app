import 'database.dart';

/// الواجهة البرمجية التي تتحكم بالبيانات المحلية (Drift) بناءً على الهيكل الهندسي الجديد (UUID)
class LocalStorageApi {
  LocalStorageApi({AppDatabase? database}) : _db = database ?? AppDatabase();

  final AppDatabase _db;

  AppDatabase get database => _db;

  // ==========================================
  // 👥 العملاء (Clients)
  // ==========================================
  Future<List<Client>> getClients() => _db.getActiveClients();
  Future<String> addClient(ClientsCompanion client) => _db.insertClient(client); // 🌟 يرجع String
  Future<bool> updateClient(Client client) => _db.updateClient(client);
  Future<int> deleteClient(String id) => _db.softDeleteClient(id); // 🌟 يستقبل String

  // ==========================================
  // 📄 العقود (Contracts)
  // ==========================================
  Future<List<Contract>> getAllContracts() => _db.getActiveContracts();
  Future<String> addContract(ContractsCompanion contract) => _db.insertContract(contract); // 🌟 String
  Future<int> deleteContract(String id) => _db.softDeleteContract(id); // 🌟 String

  // ==========================================
  // 💰 دفتر الأستاذ للمدفوعات (Payments Ledger)
  // ==========================================
  Future<List<PaymentsLedgerData>> getContractLedger(String contractId) => _db.getLedgerForContract(contractId); // 🌟 String
  Future<String> addLedgerEntry(PaymentsLedgerCompanion entry) => _db.insertLedgerEntry(entry); // 🌟 String
  Future<int> updateWhatsAppStatus(String entryId) => _db.markWhatsAppAsSent(entryId); // 🌟 String

  // ==========================================
  // ⚙️ الإعدادات (سجل أسعار المواد التاريخي)
  // ==========================================
  Future<MaterialPricesHistoryData?> getLatestPrices() => _db.getLatestPrices();
  Future<String> savePrices(MaterialPricesHistoryCompanion prices) => _db.insertMaterialPriceRecord(prices); // 🌟 String

  // ==========================================
  // 🧹 فرمتة القاعدة
  // ==========================================
  Future<void> formatDatabase() => _db.clearAllData();
}
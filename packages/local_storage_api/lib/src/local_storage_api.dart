import 'database.dart';

/// الواجهة البرمجية التي تتحكم بالبيانات المحلية (Drift) بناءً على الهيكل الهندسي الجديد
class LocalStorageApi {
  LocalStorageApi({AppDatabase? database}) : _db = database ?? AppDatabase();

  final AppDatabase _db;

  // جلب قاعدة البيانات للعمليات المتقدمة
  AppDatabase get database => _db;

  // ==========================================
  // 👥 العملاء (Clients)
  // ==========================================
  Future<List<Client>> getClients() => _db.getActiveClients();
  Future<int> addClient(ClientsCompanion client) => _db.insertClient(client);
  Future<bool> updateClient(Client client) => _db.updateClient(client);
  Future<int> deleteClient(int id) => _db.softDeleteClient(id);

  // ==========================================
  // 📄 العقود (Contracts) - ثابتة وقت التوقيع
  // ==========================================
  Future<List<Contract>> getAllContracts() => _db.getActiveContracts();
  Future<int> addContract(ContractsCompanion contract) => _db.insertContract(contract);
  Future<int> deleteContract(int id) => _db.softDeleteContract(id);

  // ==========================================
  // 💰 دفتر الأستاذ للمدفوعات (Payments Ledger)
  // ==========================================
  // نستخدم PaymentsLedgerData لأن Drift يقوم بتوليد هذا الاسم تلقائياً من جدول PaymentsLedger
  Future<List<PaymentsLedgerData>> getContractLedger(int contractId) => _db.getLedgerForContract(contractId);
  Future<int> addLedgerEntry(PaymentsLedgerCompanion entry) => _db.insertLedgerEntry(entry);
  Future<int> updateWhatsAppStatus(int entryId) => _db.markWhatsAppAsSent(entryId);

  // ==========================================
  // ⚙️ الإعدادات (سجل أسعار المواد التاريخي)
  // ==========================================
  // نستخدم MaterialPricesHistoryData للوصول إلى السجل الفعال
  Future<MaterialPricesHistoryData?> getLatestPrices() => _db.getLatestPrices();
  Future<int> savePrices(MaterialPricesHistoryCompanion prices) => _db.insertMaterialPriceRecord(prices);

  // ==========================================
  // 🧹 فرمتة القاعدة
  // ==========================================
  Future<void> formatDatabase() => _db.clearAllData();
}
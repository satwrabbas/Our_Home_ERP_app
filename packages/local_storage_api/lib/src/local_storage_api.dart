//local_storage_api.dart
import 'database.dart';

class LocalStorageApi {
  LocalStorageApi({AppDatabase? database}) : _db = database ?? AppDatabase();

  final AppDatabase _db;
  AppDatabase get database => _db;

  // العملاء
  Future<List<Client>> getClients() => _db.getActiveClients();
  Future<String> addClient(ClientsCompanion client) => _db.insertClient(client);
  Future<bool> updateClient(Client client) => _db.updateClient(client);
  
  // 🌟 تم التعديل إلى Future<void> لتتوافق مع الحذف التعاقبي (Cascading Soft Delete)
  Future<void> deleteClient(String id) => _db.softDeleteClient(id);

  // العقود
  Future<List<Contract>> getAllContracts() => _db.getActiveContracts();
  Future<String> addContract(ContractsCompanion contract) => _db.insertContract(contract);
  
  // 🌟 تم التعديل إلى Future<void> لتتوافق مع الحذف التعاقبي (Cascading Soft Delete)
  Future<void> deleteContract(String id) => _db.softDeleteContract(id);

  // دفتر الأستاذ
  Future<List<PaymentsLedgerData>> getContractLedger(String contractId) => _db.getLedgerForContract(contractId);
  Future<String> addLedgerEntry(PaymentsLedgerCompanion entry) => _db.insertLedgerEntry(entry);
  Future<int> updateWhatsAppStatus(String entryId) => _db.markWhatsAppAsSent(entryId);

  // الإعدادات
  Future<MaterialPricesHistoryData?> getLatestPrices() => _db.getLatestPrices();
  Future<String> savePrices(MaterialPricesHistoryCompanion prices) => _db.insertMaterialPriceRecord(prices);

  // ==========================================
  // 📅 جدول الاستحقاقات (Installments Schedule) 🌟 (هذا ما كان ينقصنا)
  // ==========================================
  Future<List<InstallmentsScheduleData>> getContractSchedule(String contractId) => _db.getScheduleForContract(contractId);
  Future<String> addScheduleEntry(InstallmentsScheduleCompanion entry) => _db.insertScheduleEntry(entry);
  Future<int> updateScheduleStatus(String id, String status) => _db.updateScheduleStatus(id, status);
  Future<int> deleteScheduleEntry(String id) => _db.softDeleteScheduleEntry(id);

  // فرمتة القاعدة
  Future<void> formatDatabase() => _db.clearAllData();

  // ==========================================
  // ☁️ دوال الحقن السحابي (Cloud Sync Upserts)
  // ==========================================
  Future<void> syncClient(ClientsCompanion c) => _db.into(_db.clients).insertOnConflictUpdate(c);
  Future<void> syncContract(ContractsCompanion c) => _db.into(_db.contracts).insertOnConflictUpdate(c);
  Future<void> syncPrice(MaterialPricesHistoryCompanion c) => _db.into(_db.materialPricesHistory).insertOnConflictUpdate(c);
  Future<void> syncSchedule(InstallmentsScheduleCompanion c) => _db.into(_db.installmentsSchedule).insertOnConflictUpdate(c);
  Future<void> syncPayment(PaymentsLedgerCompanion c) => _db.into(_db.paymentsLedger).insertOnConflictUpdate(c);


  // دالة ال  realtime
  Stream<MaterialPricesHistoryData?> watchLatestPrices() => _db.watchLatestPrices();
  
}
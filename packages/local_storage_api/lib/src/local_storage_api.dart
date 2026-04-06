//local_storage_api.dart
import 'database.dart';
export 'database.dart';


class LocalStorageApi {
  LocalStorageApi({AppDatabase? database}) : _db = database ?? AppDatabase();

  final AppDatabase _db;
  AppDatabase get database => _db;

  // ==========================================
  // 🏢 المحاضر (Buildings)
  // ==========================================
  Future<List<Building>> getBuildings() => _db.getActiveBuildings();
  Future<String> addBuilding(BuildingsCompanion building) => _db.insertBuilding(building);

  // ==========================================
  // 🚪 الشقق (Apartments)
  // ==========================================
  Future<List<Apartment>> getAllApartments() => _db.getAllActiveApartments();
  Future<List<Apartment>> getApartmentsByBuilding(String buildingId) => _db.getApartmentsForBuilding(buildingId);
  Future<String> addApartment(ApartmentsCompanion apartment) => _db.insertApartment(apartment);
  Future<int> changeApartmentStatus(String id, String status) => _db.updateApartmentStatus(id, status);

  // ==========================================
  // 👥 العملاء
  // ==========================================
  Future<List<Client>> getClients() => _db.getActiveClients();
  Future<String> addClient(ClientsCompanion client) => _db.insertClient(client);
  Future<bool> updateClient(Client client) => _db.updateClient(client);
  Future<void> deleteClient(String id) => _db.softDeleteClient(id);

  // ==========================================
  // 📄 العقود
  // ==========================================
  Future<List<Contract>> getAllContracts() => _db.getActiveContracts();
  Future<String> addContract(ContractsCompanion contract) => _db.insertContract(contract);
  Future<void> deleteContract(String id) => _db.softDeleteContract(id);

  // ==========================================
  // 💰 دفتر الأستاذ
  // ==========================================
  Future<List<PaymentsLedgerData>> getContractLedger(String contractId) => _db.getLedgerForContract(contractId);
  Future<String> addLedgerEntry(PaymentsLedgerCompanion entry) => _db.insertLedgerEntry(entry);
  Future<int> updateWhatsAppStatus(String entryId) => _db.markWhatsAppAsSent(entryId);

  // ==========================================
  // ⚙️ الإعدادات والأسعار
  // ==========================================
  Future<MaterialPricesHistoryData?> getLatestPrices() => _db.getLatestPrices();
  Future<String> savePrices(MaterialPricesHistoryCompanion prices) => _db.insertMaterialPriceRecord(prices);
  Stream<MaterialPricesHistoryData?> watchLatestPrices() => _db.watchLatestPrices();

  // ==========================================
  // 📅 جدول الاستحقاقات (Installments Schedule)
  // ==========================================
  Future<List<InstallmentsScheduleData>> getContractSchedule(String contractId) => _db.getScheduleForContract(contractId);
  Future<String> addScheduleEntry(InstallmentsScheduleCompanion entry) => _db.insertScheduleEntry(entry);
  Future<int> updateScheduleStatus(String id, String status) => _db.updateScheduleStatus(id, status);
  Future<int> deleteScheduleEntry(String id) => _db.softDeleteScheduleEntry(id);

  // ==========================================
  // 🧹 فرمتة القاعدة
  // ==========================================
  Future<void> formatDatabase() => _db.clearAllData();

  // ==========================================
  // ☁️ دوال الحقن السحابي (Cloud Sync Upserts)
  // ==========================================
  Future<void> syncClient(ClientsCompanion c) => _db.into(_db.clients).insertOnConflictUpdate(c);
  Future<void> syncContract(ContractsCompanion c) => _db.into(_db.contracts).insertOnConflictUpdate(c);
  Future<void> syncPrice(MaterialPricesHistoryCompanion c) => _db.into(_db.materialPricesHistory).insertOnConflictUpdate(c);
  Future<void> syncSchedule(InstallmentsScheduleCompanion c) => _db.into(_db.installmentsSchedule).insertOnConflictUpdate(c);
  Future<void> syncPayment(PaymentsLedgerCompanion c) => _db.into(_db.paymentsLedger).insertOnConflictUpdate(c);
  
  Future<void> syncBuilding(BuildingsCompanion c) => _db.into(_db.buildings).insertOnConflictUpdate(c);
  Future<void> syncApartment(ApartmentsCompanion c) => _db.into(_db.apartments).insertOnConflictUpdate(c);
}
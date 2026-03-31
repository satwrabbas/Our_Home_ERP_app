import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

part 'database.g.dart';

const _uuid = Uuid();

// ==========================================
// 1. جدول العملاء (الفريق الثاني)
// ==========================================
class Clients extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get name => text().withLength(min: 2, max: 100)();
  TextColumn get phone => text().unique()(); 
  TextColumn get nationalId => text().nullable()(); 
  
  // 🌟 من قام بإضافة هذا العميل؟ (حقل التدقيق المالي)
  TextColumn get userId => text()(); 

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 2. جدول العقود (Contracts) - ثابت لحظة التوقيع
// ==========================================
class Contracts extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get clientId => text().references(Clients, #id)(); 
  
  TextColumn get contractType => text().withDefault(const Constant('لاحق التخصص'))(); 
  TextColumn get apartmentDetails => text()(); 
  RealColumn get totalArea => real()(); 
  RealColumn get baseMeterPriceAtSigning => real()(); 
  IntColumn get installmentsCount => integer().withDefault(const Constant(48))(); 
  TextColumn get coefficients => text().withDefault(const Constant('{}'))(); 
  
  // 🌟 من المهندس/المحاسب الذي كتب هذا العقد؟
  TextColumn get userId => text()();

  DateTimeColumn get contractDate => dateTime()(); 
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))(); 

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 3. جدول سجل أسعار المواد (Material Prices History)
// ==========================================
class MaterialPricesHistory extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  
  DateTimeColumn get effectiveDate => dateTime().withDefault(currentDateAndTime)(); 
  
  RealColumn get ironPrice => real()(); 
  RealColumn get cementPrice => real()(); 
  RealColumn get block15Price => real()(); 
  RealColumn get formworkAndPouringWages => real()(); 
  RealColumn get aggregateMaterialsPrice => real()(); 
  RealColumn get ordinaryWorkerWage => real()(); 

  // 🌟 من المدير الذي عدل الأسعار في هذا اليوم؟
  TextColumn get userId => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 4. جدول الاستحقاقات (Installments Schedule) - ما يجب دفعه
// ==========================================
class InstallmentsSchedule extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get contractId => text().references(Contracts, #id)(); 
  
  IntColumn get installmentNumber => integer()(); 
  DateTimeColumn get dueDate => dateTime()(); 
  TextColumn get status => text().withDefault(const Constant('pending'))();
  
  // 🌟 تتبع من أدار هذا القسط
  TextColumn get userId => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 5. دفتر الأستاذ للمدفوعات (Payments Ledger) 🚨 الأهم!
// ==========================================
// هذا الجدول يسجل "الأموال الحقيقية" والأمتار التي اشترتها لحظة الدفع
class PaymentsLedger extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get contractId => text().references(Contracts, #id)(); 
  TextColumn get scheduleId => text().nullable().references(InstallmentsSchedule, #id)();
  
  DateTimeColumn get paymentDate => dateTime()(); 
  RealColumn get amountPaid => real()(); 
  
  // 🌟 جوهر النظام: تجميد السعر والأمتار في لحظة الدفع لكي لا تتغير لاحقاً
  RealColumn get meterPriceAtPayment => real()(); 
  RealColumn get convertedMeters => real()(); 

  RealColumn get fees => real().withDefault(const Constant(0))(); 
  BoolColumn get isWhatsAppSent => boolean().withDefault(const Constant(false))();
  
  // 🌟 من المحاسب الذي استلم هذا المبلغ وقبضه؟ (مهم جداً للتدقيق المالي)
  TextColumn get userId => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))(); 

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables:[Clients, Contracts, MaterialPricesHistory, InstallmentsSchedule, PaymentsLedger])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1; // سنبقيها 1 ونقوم بحذف القاعدة القديمة من الجهاز يدوياً

  // ==========================================
  // --- استعلامات العملاء ---
  // ==========================================
  Future<List<Client>> getActiveClients() => 
      (select(clients)..where((t) => t.isDeleted.equals(false))).get();
  
  Future<String> insertClient(ClientsCompanion client) async {
    final row = await into(clients).insertReturning(client);
    return row.id;
  }
  
  Future<bool> updateClient(Client client) => update(clients).replace(client);
  
  Future<int> softDeleteClient(String id) {
    return (update(clients)..where((t) => t.id.equals(id))).write(
      ClientsCompanion(isDeleted: const Value(true), updatedAt: Value(DateTime.now()), isSynced: const Value(false)),
    );
  }

  // ==========================================
  // --- استعلامات العقود ---
  // ==========================================
  Future<List<Contract>> getActiveContracts() => 
      (select(contracts)..where((t) => t.isDeleted.equals(false))).get();
  
  Future<String> insertContract(ContractsCompanion contract) async {
    final row = await into(contracts).insertReturning(contract);
    return row.id;
  }
  
  Future<int> softDeleteContract(String id) {
    return (update(contracts)..where((t) => t.id.equals(id))).write(
      ContractsCompanion(isDeleted: const Value(true), updatedAt: Value(DateTime.now()), isSynced: const Value(false)),
    );
  }

  // ==========================================
  // --- استعلامات دفتر المدفوعات (Ledger) ---
  // ==========================================
  Future<List<PaymentsLedgerData>> getLedgerForContract(String contractId) => 
      (select(paymentsLedger)
        ..where((t) => t.contractId.equals(contractId) & t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.paymentDate)])
      ).get();
      
  Future<String> insertLedgerEntry(PaymentsLedgerCompanion entry) async {
    final row = await into(paymentsLedger).insertReturning(entry);
    return row.id;
  }
  
  Future<int> markWhatsAppAsSent(String entryId) {
    return (update(paymentsLedger)..where((t) => t.id.equals(entryId))).write(
      PaymentsLedgerCompanion(isWhatsAppSent: const Value(true), updatedAt: Value(DateTime.now()), isSynced: const Value(false)),
    );
  }

  // ==========================================
  // --- استعلامات سجل أسعار المواد ---
  // ==========================================
  // جلب السعر الفعال في تاريخ معين (أو أحدث سعر إذا لم يمرر تاريخ)
  Future<MaterialPricesHistoryData?> getLatestPrices() {
    return (select(materialPricesHistory)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.effectiveDate)])
          ..limit(1))
        .getSingleOrNull();
  }
  
  // إضافة تسعيرة شهرية جديدة (بدلاً من تحديث القديمة)
  Future<String> insertMaterialPriceRecord(MaterialPricesHistoryCompanion prices) async {
    final row = await into(materialPricesHistory).insertReturning(prices);
    return row.id;
  }

  // ==========================================
  // --- استعلامات الأقساط (جدول الاستحقاقات) ---
  // ==========================================
  
  // جلب جميع الأقساط المجدولة لعقد معين مرتبة تصاعدياً حسب تاريخ الاستحقاق
  Future<List<InstallmentsScheduleData>> getScheduleForContract(String contractId) => 
      (select(installmentsSchedule)
        ..where((t) => t.contractId.equals(contractId) & t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.dueDate)])
      ).get();

  // إضافة قسط جديد للجدول
  Future<String> insertScheduleEntry(InstallmentsScheduleCompanion entry) async {
    final row = await into(installmentsSchedule).insertReturning(entry);
    return row.id;
  }

  // تحديث حالة القسط (مثلاً من pending إلى paid)
  Future<int> updateScheduleStatus(String id, String status) {
    return (update(installmentsSchedule)..where((t) => t.id.equals(id))).write(
      InstallmentsScheduleCompanion(
        status: Value(status), 
        updatedAt: Value(DateTime.now()), 
        isSynced: const Value(false)
      )
    );
  }

  // حذف قسط مجدول (Soft Delete)
  Future<int> softDeleteScheduleEntry(String id) {
    return (update(installmentsSchedule)..where((t) => t.id.equals(id))).write(
      InstallmentsScheduleCompanion(
        isDeleted: const Value(true), 
        updatedAt: Value(DateTime.now()), 
        isSynced: const Value(false)
      )
    );
  }
  
  // ==========================================
  // --- تفريغ القاعدة ---
  // ==========================================
  Future<void> clearAllData() {
    return transaction(() async {
      await delete(paymentsLedger).go();
      await delete(installmentsSchedule).go();
      await delete(materialPricesHistory).go();
      await delete(contracts).go();
      await delete(clients).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory(); 
    // 🌟 تغيير الاسم لإنشاء قاعدة جديدة نظيفة تماماً تحتوي على حقل userId
    final file = File(p.join(dbFolder.path, 'our_home_erp_v6_clean.sqlite')); 
    return NativeDatabase.createInBackground(file);
  });
}
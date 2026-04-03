//database.dart
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
  
  // ==========================================
  // --- استعلامات الحذف التعاقبي (Cascading Soft Delete) ---
  // ==========================================
  
  /// حذف عميل (يحذف معه آلياً: عقوده، أقساطه، ومدفوعاته)
  Future<void> softDeleteClient(String clientId) async {
    return transaction(() async {
      // 1. حذف العميل نفسه
      await (update(clients)..where((t) => t.id.equals(clientId))).write(
        ClientsCompanion(isDeleted: const Value(true), updatedAt: Value(DateTime.now()), isSynced: const Value(false)),
      );

      // 2. جلب كل عقود هذا العميل
      final clientContracts = await (select(contracts)..where((t) => t.clientId.equals(clientId))).get();

      for (final contract in clientContracts) {
        // أ. حذف العقد
        await (update(contracts)..where((t) => t.id.equals(contract.id))).write(
          ContractsCompanion(isDeleted: const Value(true), updatedAt: Value(DateTime.now()), isSynced: const Value(false)),
        );

        // ب. حذف جدول استحقاقات هذا العقد
        await (update(installmentsSchedule)..where((t) => t.contractId.equals(contract.id))).write(
          InstallmentsScheduleCompanion(isDeleted: const Value(true), updatedAt: Value(DateTime.now()), isSynced: const Value(false)),
        );

        // ج. حذف جميع مدفوعات هذا العقد (دفتر الأستاذ)
        await (update(paymentsLedger)..where((t) => t.contractId.equals(contract.id))).write(
          PaymentsLedgerCompanion(isDeleted: const Value(true), updatedAt: Value(DateTime.now()), isSynced: const Value(false)),
        );
      }
    });
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
  
  /// حذف عقد (يحذف معه آلياً: أقساطه ومدفوعاته)
  Future<void> softDeleteContract(String contractId) async {
    return transaction(() async {
      // 1. حذف العقد
      await (update(contracts)..where((t) => t.id.equals(contractId))).write(
        ContractsCompanion(isDeleted: const Value(true), updatedAt: Value(DateTime.now()), isSynced: const Value(false)),
      );

      // 2. حذف جدول استحقاقات العقد
      await (update(installmentsSchedule)..where((t) => t.contractId.equals(contractId))).write(
        InstallmentsScheduleCompanion(isDeleted: const Value(true), updatedAt: Value(DateTime.now()), isSynced: const Value(false)),
      );

      // 3. حذف جميع مدفوعات العقد
      await (update(paymentsLedger)..where((t) => t.contractId.equals(contractId))).write(
        PaymentsLedgerCompanion(isDeleted: const Value(true), updatedAt: Value(DateTime.now()), isSynced: const Value(false)),
      );
    });
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
  
  // جلب أحدث سعر (النسخة المحسنة المضادة لتضارب المزامنة)
  Future<MaterialPricesHistoryData?> getLatestPrices() {
    return (select(materialPricesHistory)
          // 🚨 تم إزالة شرط (isDeleted == false) لأننا نريد الأحدث زمنياً دائماً
          ..orderBy([(t) => OrderingTerm.desc(t.effectiveDate)])
          ..limit(1))
        .getSingleOrNull();
  }
  
  // 🌟 (الفكرة العبقرية) إلغاء القديم قبل إضافة الجديد
  Future<String> insertMaterialPriceRecord(MaterialPricesHistoryCompanion prices) async {
    return transaction(() async {
      // 1. ضربة استباقية: تحويل كل الأسعار القديمة إلى محذوفة
      await (update(materialPricesHistory)
            ..where((t) => t.isDeleted.equals(false)))
          .write(
            // 🌟 تم إزالة كلمة const من هنا
            MaterialPricesHistoryCompanion(
              isDeleted: const Value(true), // وضعناها هنا بشكل صحيح
              isSynced: const Value(false), 
            ),
          );

      // 2. إدخال التسعيرة الجديدة
      final row = await into(materialPricesHistory).insertReturning(prices);
      return row.id;
    });
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
  
  // ==========================================
  // ☁️ دوال الحقن السحابي (Aggressive Cloud Sync Upserts)
  // ==========================================
  
  // نستخدم insertOrReplace لضمان مسح السطر المحلي القديم واستبداله بالكامل بنسخة السحابة
  Future<void> syncClient(ClientsCompanion entity) => 
      into(clients).insert(entity, mode: InsertMode.insertOrReplace);
      
  Future<void> syncContract(ContractsCompanion entity) => 
      into(contracts).insert(entity, mode: InsertMode.insertOrReplace);
      
  Future<void> syncMaterialPrice(MaterialPricesHistoryCompanion entity) => 
      into(materialPricesHistory).insert(entity, mode: InsertMode.insertOrReplace);
      
  Future<void> syncSchedule(InstallmentsScheduleCompanion entity) => 
      into(installmentsSchedule).insert(entity, mode: InsertMode.insertOrReplace);
      
  Future<void> syncPayment(PaymentsLedgerCompanion entity) => 
      into(paymentsLedger).insert(entity, mode: InsertMode.insertOrReplace);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory(); 
    // 🌟 تغيير الاسم لإنشاء قاعدة جديدة نظيفة تماماً تحتوي على حقل userId
    final file = File(p.join(dbFolder.path, 'our_home_erp_v8_clean.sqlite')); 
    return NativeDatabase.createInBackground(file);
  });
}
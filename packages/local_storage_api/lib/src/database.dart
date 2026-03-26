import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ==========================================
// 1. جدول العملاء (الفريق الثاني)
// ==========================================
class Clients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 2, max: 100)();
  TextColumn get phone => text().unique()(); 
  TextColumn get nationalId => text().nullable()(); 
  
  // حقول النظام الاحترافي (Audit & Sync)
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

// ==========================================
// 2. جدول العقود (Contracts) - ثابت لحظة التوقيع
// ==========================================
class Contracts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clientId => integer().references(Clients, #id)();
  
  TextColumn get apartmentDetails => text()(); // وصف الشقة (أرضي، قبو، الخ)
  RealColumn get totalArea => real()(); // المساحة الكلية للشقة
  RealColumn get baseMeterPriceAtSigning => real()(); // سعر المتر المربع يوم التوقيع
  
  // حقل JSON لتخزين المعاملات (طابق، وجيبة، اتجاه) لمرونة إضافتها مستقبلاً
  TextColumn get coefficients => text().withDefault(const Constant('{}'))(); 
  
  DateTimeColumn get contractDate => dateTime()(); // تاريخ التوقيع
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))(); 

  // حقول النظام الاحترافي
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

// ==========================================
// 3. جدول سجل أسعار المواد (Material Prices History)
// ==========================================
class MaterialPricesHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  DateTimeColumn get effectiveDate => dateTime().withDefault(currentDateAndTime)(); 
  
  RealColumn get ironPrice => real()(); 
  RealColumn get cementPrice => real()(); 
  RealColumn get block15Price => real()(); 
  
  // 🌟 تم دمج الكوفراج والبيتون المسلح في هذا العمود
  RealColumn get formworkAndPouringWages => real()(); 
  
  RealColumn get aggregateMaterialsPrice => real()(); 
  RealColumn get ordinaryWorkerWage => real()(); 

  // حقول النظام الاحترافي
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

// ==========================================
// 4. جدول الاستحقاقات (Installments Schedule) - ما يجب دفعه
// ==========================================
class InstallmentsSchedule extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get contractId => integer().references(Contracts, #id)();
  
  IntColumn get installmentNumber => integer()(); 
  DateTimeColumn get dueDate => dateTime()(); // تاريخ الاستحقاق
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, partial, paid
  
  // حقول النظام الاحترافي
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

// ==========================================
// 5. دفتر الأستاذ للمدفوعات (Payments Ledger) 🚨 الأهم!
// ==========================================
// هذا الجدول يسجل "الأموال الحقيقية" والأمتار التي اشترتها لحظة الدفع
class PaymentsLedger extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get contractId => integer().references(Contracts, #id)();
  IntColumn get scheduleId => integer().nullable().references(InstallmentsSchedule, #id)(); // الربط بالاستحقاق إن وجد
  
  DateTimeColumn get paymentDate => dateTime()(); // تاريخ الدفع الفعلي
  RealColumn get amountPaid => real()(); // المبلغ المدفوع
  
  // 🌟 جوهر النظام: تجميد السعر والأمتار في لحظة الدفع لكي لا تتغير لاحقاً
  RealColumn get meterPriceAtPayment => real()(); // سعر المتر في ذلك الشهر
  RealColumn get convertedMeters => real()(); // الأمتار المحولة = المبلغ / سعر المتر

  RealColumn get fees => real().withDefault(const Constant(0))(); 
  BoolColumn get isWhatsAppSent => boolean().withDefault(const Constant(false))();
  
  // حقول النظام الاحترافي
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))(); 
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
  Future<int> insertClient(ClientsCompanion client) => into(clients).insert(client, mode: InsertMode.insertOrIgnore);
  Future<bool> updateClient(Client client) => update(clients).replace(client);
  Future<int> softDeleteClient(int id) {
    return (update(clients)..where((t) => t.id.equals(id))).write(
      ClientsCompanion(isDeleted: const Value(true), updatedAt: Value(DateTime.now()), isSynced: const Value(false)),
    );
  }

  // ==========================================
  // --- استعلامات العقود ---
  // ==========================================
  Future<List<Contract>> getActiveContracts() => 
      (select(contracts)..where((t) => t.isDeleted.equals(false))).get();
  Future<int> insertContract(ContractsCompanion contract) => into(contracts).insert(contract);
  Future<int> softDeleteContract(int id) {
    return (update(contracts)..where((t) => t.id.equals(id))).write(
      ContractsCompanion(isDeleted: const Value(true), updatedAt: Value(DateTime.now()), isSynced: const Value(false)),
    );
  }

  // ==========================================
  // --- استعلامات دفتر المدفوعات (Ledger) ---
  // ==========================================
  Future<List<PaymentsLedgerData>> getLedgerForContract(int contractId) => 
      (select(paymentsLedger)
        ..where((t) => t.contractId.equals(contractId) & t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.paymentDate)])
      ).get();
      
  Future<int> insertLedgerEntry(PaymentsLedgerCompanion entry) => into(paymentsLedger).insert(entry);
  
  Future<int> markWhatsAppAsSent(int entryId) {
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
  Future<int> insertMaterialPriceRecord(MaterialPricesHistoryCompanion prices) => 
      into(materialPricesHistory).insert(prices);


  // ==========================================
  // --- استعلامات الأقساط (جدول الاستحقاقات) ---
  // ==========================================
  
  // جلب جميع الأقساط المجدولة لعقد معين مرتبة تصاعدياً حسب تاريخ الاستحقاق
  Future<List<InstallmentsScheduleData>> getScheduleForContract(int contractId) => 
      (select(installmentsSchedule)
        ..where((t) => t.contractId.equals(contractId) & t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.dueDate)])
      ).get();

  // إضافة قسط جديد للجدول
  Future<int> insertScheduleEntry(InstallmentsScheduleCompanion entry) => 
      into(installmentsSchedule).insert(entry);

  // تحديث حالة القسط (مثلاً من pending إلى paid)
  Future<int> updateScheduleStatus(int id, String status) {
    return (update(installmentsSchedule)..where((t) => t.id.equals(id))).write(
      InstallmentsScheduleCompanion(
        status: Value(status), 
        updatedAt: Value(DateTime.now()), 
        isSynced: const Value(false)
      )
    );
  }

  // حذف قسط مجدول (Soft Delete)
  Future<int> softDeleteScheduleEntry(int id) {
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
    final file = File(p.join(dbFolder.path, 'our_home_erp_v2.sqlite')); // قمنا بتغيير الاسم لإنشاء ملف جديد تلقائياً!
    return NativeDatabase.createInBackground(file);
  });
}
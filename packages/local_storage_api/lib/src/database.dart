import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// ==========================================
// 1. جدول العملاء (الفريق الثاني - المشترين)
// ==========================================
class Clients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 2, max: 100)();
  TextColumn get phone => text().unique()(); 
  TextColumn get nationalId => text().nullable()(); 
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ==========================================
// 2. جدول العقود والشقق (مستوحى من الإكسل)
// ==========================================
class Contracts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clientId => integer().references(Clients, #id)();
  
  TextColumn get apartmentDescription => text()(); // مثل: شقة الطابق الأول
  RealColumn get apartmentArea => real()(); // مساحة الشقة
  RealColumn get pricePerSqmAtSigning => real()(); // سعر المتر المربع عند التوقيع
  RealColumn get totalContractValue => real()(); // القيمة الإجمالية
  RealColumn get monthlyInstallment => real()(); // القسط الشهري الثابت
  
  DateTimeColumn get signatureDate => dateTime()(); // تاريخ توقيع العقد
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))(); 
}

// ==========================================
// 3. جدول الدفعات والأقساط (للفواتير والواتساب)
// ==========================================
class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get contractId => integer().references(Contracts, #id)();
  
  IntColumn get installmentNumber => integer()(); // رقم القسط
  RealColumn get amountPaid => real()(); // إجمالي القسط المدفوع
  RealColumn get originalInstallment => real()(); // أصل القسط
  RealColumn get fees => real().withDefault(const Constant(0))(); // الرسوم إن وجدت
  
  DateTimeColumn get paymentDate => dateTime()(); 
  DateTimeColumn get dueDate => dateTime().nullable()(); 
  
  // حقول المزامنة والواتساب
  BoolColumn get isWhatsAppSent => boolean().withDefault(const Constant(false))();
  BoolColumn get isSyncedToCloud => boolean().withDefault(const Constant(false))(); 
}

// ==========================================
// 4. جدول أسعار المواد (المحرك الحسابي المتغير)
// ==========================================
class MaterialPrices extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get ironPrice => real()(); // حديد
  RealColumn get cementPrice => real()(); // أسمنت
  RealColumn get blockPrice => real()(); // بلوك
  RealColumn get workerDailyRate => real()(); // أجرة عامل
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Clients, Contracts, Payments, MaterialPrices])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // --- دوال العملاء ---
  Future<List<Client>> getAllClients() => select(clients).get();
  Future<int> insertClient(ClientsCompanion client) => into(clients).insert(client, mode: InsertMode.insertOrIgnore);
  Future<bool> updateClient(Client client) => update(clients).replace(client);
  Future<int> deleteClient(Client client) => delete(clients).delete(client);

  // --- دوال العقود ---
  Future<List<Contract>> getContractsForClient(int clientId) => 
      (select(contracts)..where((t) => t.clientId.equals(clientId))).get();
  Future<int> insertContract(ContractsCompanion contract) => into(contracts).insert(contract);
  Future<List<Contract>> getAllContracts() => select(contracts).get();
  // --- دوال الدفعات (الفواتير) ---
  Future<List<Payment>> getPaymentsForContract(int contractId) => 
      (select(payments)
        ..where((t) => t.contractId.equals(contractId))
        ..orderBy([(t) => OrderingTerm.desc(t.paymentDate)])
      ).get();
  Future<int> insertPayment(PaymentsCompanion payment) => into(payments).insert(payment);
  
  Future<int> markWhatsAppAsSent(int paymentId) {
    return (update(payments)..where((t) => t.id.equals(paymentId))).write(
      const PaymentsCompanion(isWhatsAppSent: Value(true)),
    );
  }

  // --- مسح شامل ---
  Future<void> clearAllData() {
    return transaction(() async {
      await delete(payments).go();
      await delete(contracts).go();
      await delete(clients).go();
      await delete(materialPrices).go();
    });
  }

  // --- دوال أسعار المواد (الإعدادات) ---
  Future<MaterialPrice?> getLatestPrices() {
    return (select(materialPrices)
          ..orderBy([(t) => OrderingTerm.desc(t.lastUpdated)])
          ..limit(1))
        .getSingleOrNull(); // نجلب أحدث سعر تم إدخاله
  }
  Future<int> insertPrices(MaterialPricesCompanion prices) => into(materialPrices).insert(prices);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // التخزين المحلي الآمن لويندوز
    final dbFolder = await getApplicationSupportDirectory(); 
    final file = File(p.join(dbFolder.path, 'our_home_erp.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
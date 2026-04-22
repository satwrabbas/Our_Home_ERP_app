//packages\local_storage_api\lib\src\database.dart
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
// =========================================
@TableIndex(name: 'idx_clients_sync', columns: {#isDeleted, #updatedAt})

class Clients extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get name => text().withLength(min: 2, max: 100)();
  TextColumn get phone => text().unique()(); 
  TextColumn get nationalId => text().nullable()(); 
  
  // 🌟 من قام بإضافة هذا العميل؟ (حقل التدقيق المالي)
  TextColumn get userId => text()(); 

  // 🌍[تعديل التوقيت]: تم استبدال currentDateAndTime (الذي يأخذ التوقيت المحلي)
  // بـ clientDefault(() => DateTime.now().toUtc()) لضمان حفظ الوقت بالتوقيت العالمي
  // لتجنب أي مشاكل عند المزامنة مع السحابة أو عند فتح التطبيق في دول مختلفة
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 🏢 2. جدول المحاضر (Buildings) - يحتوي على القوالب العامة
// ==========================================
@TableIndex(name: 'idx_buildings_sync', columns: {#isDeleted, #updatedAt})

class Buildings extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get name => text()(); // مثال: محضر النسيم
  TextColumn get location => text().nullable()(); // مثال: مشروع الأوقاف
  
  // 🌟 قوالب النسب المئوية العامة (تُحفظ كـ JSON)
  TextColumn get floorCoefficients => text().withDefault(const Constant('{}'))(); 
  TextColumn get directionCoefficients => text().withDefault(const Constant('{}'))(); 
  
  // حقول المزامنة (جاهزة للمستقبل، لكننا لن نستخدمها الآن)
  TextColumn get userId => text().withDefault(const Constant('offline_test'))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  // 🌍[تعديل التوقيت]: الحفظ بـ UTC لتوحيد الزمن في كامل النظام
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 🚪 3. جدول الشقق (Apartments) - يحتوي على الخصائص المحددة
// ==========================================
@TableIndex(name: 'idx_apartments_sync', columns: {#isDeleted, #updatedAt, #buildingId})
class Apartments extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get buildingId => text().references(Buildings, #id)(); // 🌟 الارتباط بالمحضر
  
  TextColumn get apartmentNumber => text()(); // مثال: 101 أو A1
  RealColumn get area => real()(); 
  
  // 🌟 الخصائص التي ستبحث في قوالب المحضر لمعرفة نسبتها
  TextColumn get floorName => text()(); // مثال: "الطابق الثاني"
  TextColumn get directionName => text()(); // مثال: "جنوبي"
  
  // 🌟 نسب مئوية خاصة بهذه الشقة فقط (تُحفظ كـ JSON)
  TextColumn get customCoefficients => text().withDefault(const Constant('{}'))(); 
  
  // حالة الشقة: متاحة، مباعة، محجوزة
  TextColumn get status => text().withDefault(const Constant('available'))(); 
  
  // حقول المزامنة
  TextColumn get userId => text().withDefault(const Constant('offline_test'))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  // 🌍[تعديل التوقيت]: حفظ التواريخ دائماً كـ UTC
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 4. جدول العقود (Contracts)
// ==========================================
@TableIndex(name: 'idx_contracts_sync', columns: {#isDeleted, #updatedAt, #clientId})
class Contracts extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get clientId => text().references(Clients, #id)(); 
  
  // 🌟 الارتباط الجديد بالشقة
  TextColumn get apartmentId => text().nullable().references(Apartments, #id)(); 
  TextColumn get apartmentDetails => text().withDefault(const Constant('أسهم/غير مخصص'))();

  TextColumn get contractType => text().withDefault(const Constant('لاحق التخصص'))(); 
  RealColumn get totalArea => real()(); 
  RealColumn get baseMeterPriceAtSigning => real()(); 
  IntColumn get installmentsCount => integer().withDefault(const Constant(48))(); 
  TextColumn get coefficients => text().withDefault(const Constant('{}'))(); 
  TextColumn get guarantorName => text()();
  TextColumn get contractFileUrl => text().nullable()();
  
  TextColumn get userId => text()();
  
  // 🌍 ملاحظة: هذا الحقل لا يحتاج لـ clientDefault لأنه يُدخل يدوياً عند توقيع العقد، 
  // لكن يجب أن نتأكد في واجهة المستخدم (UI) أو الـ Logic أن يتم تمريره كـ UTC.
  DateTimeColumn get contractDate => dateTime()(); 
  
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))(); 
  
  // 🌍 [تعديل التوقيت]: الحفظ بـ UTC
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 5. جدول سجل أسعار المواد (Material Prices History)
// ==========================================
@TableIndex(name: 'idx_prices_sync', columns: {#isDeleted, #updatedAt, #effectiveDate})
class MaterialPricesHistory extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  
  // 🌍 [تعديل التوقيت]: سريان مفعول السعر يجب أن يسجل كـ UTC
  DateTimeColumn get effectiveDate => dateTime().clientDefault(() => DateTime.now().toUtc())(); 
  
  RealColumn get ironPrice => real()(); 
  RealColumn get cementPrice => real()(); 
  RealColumn get block15Price => real()(); 
  RealColumn get formworkAndPouringWages => real()(); 
  RealColumn get aggregateMaterialsPrice => real()(); 
  RealColumn get ordinaryWorkerWage => real()(); 

  // 🌟 من المدير الذي عدل الأسعار في هذا اليوم؟
  TextColumn get userId => text()();

  // 🌍 [تعديل التوقيت]: الحفظ بـ UTC
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 6. جدول الاستحقاقات (Installments Schedule) - ما يجب دفعه
// ==========================================
@TableIndex(name: 'idx_schedules_sync', columns: {#isDeleted, #updatedAt, #contractId})

class InstallmentsSchedule extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get contractId => text().references(Contracts, #id)(); 
  
  IntColumn get installmentNumber => integer()(); 
  
  // 🌍 ملاحظة: الـ dueDate يتم إنشاؤه برمجياً (انظر دالة insertContractWithSchedules بالأسفل) 
  // وتم التعديل هناك ليتم توليده كـ UTC
  DateTimeColumn get dueDate => dateTime()(); 
  TextColumn get status => text().withDefault(const Constant('pending'))();
  
  // 🌟 تتبع من أدار هذا القسط
  TextColumn get userId => text()();

  // 🌍[تعديل التوقيت]: الحفظ بـ UTC
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// 7. دفتر الأستاذ للمدفوعات (Payments Ledger) 🚨 الأهم!
// ==========================================
// هذا الجدول يسجل "الأموال الحقيقية" والأمتار التي اشترتها لحظة الدفع
@TableIndex(name: 'idx_payments_sync', columns: {#isDeleted, #updatedAt, #contractId})

class PaymentsLedger extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v4())();
  TextColumn get contractId => text().references(Contracts, #id)(); 
  TextColumn get scheduleId => text().nullable().references(InstallmentsSchedule, #id)();
  
  // 🌍 ملاحظة: يجب تمريره من الـ Logic كـ UTC (مثلاً الدفع تم الآن، فنأخذ الآن بالتوقيت العالمي)
  DateTimeColumn get paymentDate => dateTime()(); 
  
  RealColumn get amountPaid => real()(); 
  
  // 🌟 جوهر النظام: تجميد السعر والأمتار في لحظة الدفع لكي لا تتغير لاحقاً
  RealColumn get meterPriceAtPayment => real()(); 
  RealColumn get convertedMeters => real()(); 

   // 🌟 [السطر الجديد]: لقطة الأسعار التاريخية لحظة الدفع (تُحفظ كـ JSON)
  TextColumn get pricesSnapshot => text().withDefault(const Constant('{}'))(); 

  RealColumn get fees => real().withDefault(const Constant(0))(); 
  BoolColumn get isWhatsAppSent => boolean().withDefault(const Constant(false))();
  
  // 🌟 من المحاسب الذي استلم هذا المبلغ وقبضه؟ (مهم جداً للتدقيق المالي)
  TextColumn get userId => text()();

  // 🌍 [تعديل التوقيت]: الحفظ بـ UTC
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  DateTimeColumn get updatedAt => dateTime().clientDefault(() => DateTime.now().toUtc())();
  
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))(); 

  @override
  Set<Column> get primaryKey => {id};
}

// ==========================================
// ==========================================
// التكوين الرئيسي لقاعدة البيانات
// ==========================================
// ==========================================

@DriftDatabase(tables:[
  Clients, 
  Contracts, 
  Buildings,      // 🌟 أضفناه
  Apartments,     // 🌟 أضفناه
  MaterialPricesHistory, 
  InstallmentsSchedule, 
  PaymentsLedger
])
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
      // 🌍 التوقيت الحالي بـ UTC لتسجيل متى تم الحذف بدقة عالمية
      final nowUtc = Value(DateTime.now().toUtc());

      // 1. حذف العميل نفسه
      await (update(clients)..where((t) => t.id.equals(clientId))).write(
        ClientsCompanion(isDeleted: const Value(true), updatedAt: nowUtc, isSynced: const Value(false)),
      );

      // 2. جلب كل عقود هذا العميل
      final clientContracts = await (select(contracts)..where((t) => t.clientId.equals(clientId))).get();

      for (final contract in clientContracts) {
        // أ. حذف العقد
        await (update(contracts)..where((t) => t.id.equals(contract.id))).write(
          ContractsCompanion(isDeleted: const Value(true), updatedAt: nowUtc, isSynced: const Value(false)),
        );

        // ب. حذف جدول استحقاقات هذا العقد
        await (update(installmentsSchedule)..where((t) => t.contractId.equals(contract.id))).write(
          InstallmentsScheduleCompanion(isDeleted: const Value(true), updatedAt: nowUtc, isSynced: const Value(false)),
        );

        // ج. حذف جميع مدفوعات هذا العقد (دفتر الأستاذ)
        await (update(paymentsLedger)..where((t) => t.contractId.equals(contract.id))).write(
          PaymentsLedgerCompanion(isDeleted: const Value(true), updatedAt: nowUtc, isSynced: const Value(false)),
        );
      }
    });
  }

  // ==========================================
  // --- استعلامات العقود ---
  // ==========================================
  // ==========================================
  // --- إضافة عقد مع أقساطه كعملية واحدة (Atomic Transaction) ---
  // ==========================================
  Future<void> insertContractWithSchedules(
    ContractsCompanion contract, 
    int installmentsCount, 
    DateTime startDate, 
    String userId
  ) async {
    return transaction(() async {
      // 1. إضافة العقد والحصول على الـ ID الخاص به
      final contractRow = await into(contracts).insertReturning(contract);
      final String newContractId = contractRow.id;

      // 2. توليد الأقساط وإضافتها فوراً داخل نفس العملية
      for (int i = 1; i <= installmentsCount; i++) {
        // 🌍[تعديل التوقيت]: استخدمنا DateTime.utc بدلاً من DateTime العادي
        // (Dart ذكية جداً: إذا كان الشهر 12 وزدنا عليه 1، ستقوم تلقائياً بتحويله لشهر 1 السنة القادمة)
        // هذا يضمن أن أيام الاستحقاق (dueDate) تُحفظ كـ UTC وتتطابق عند الاسترجاع أينما كان المستخدم
        final dueDate = DateTime.utc(startDate.year, startDate.month + i, startDate.day);
        
        final entry = InstallmentsScheduleCompanion.insert(
          contractId: newContractId, 
          installmentNumber: i, 
          dueDate: dueDate,
          status: const Value('pending'), 
          userId: userId, 
        );
        await into(installmentsSchedule).insert(entry);
      }
    });
  }
  
  Future<List<Contract>> getActiveContracts() => 
      (select(contracts)..where((t) => t.isDeleted.equals(false))).get();
  
  
  /// حذف عقد (يحذف معه آلياً: أقساطه ومدفوعاته)
  Future<void> softDeleteContract(String contractId) async {
    return transaction(() async {
      // 🌍 التوقيت الحالي بـ UTC
      final nowUtc = Value(DateTime.now().toUtc());

      // 1. حذف العقد
      await (update(contracts)..where((t) => t.id.equals(contractId))).write(
        ContractsCompanion(isDeleted: const Value(true), updatedAt: nowUtc, isSynced: const Value(false)),
      );

      // 2. حذف جدول استحقاقات العقد
      await (update(installmentsSchedule)..where((t) => t.contractId.equals(contractId))).write(
        InstallmentsScheduleCompanion(isDeleted: const Value(true), updatedAt: nowUtc, isSynced: const Value(false)),
      );

      // 3. حذف جميع مدفوعات العقد
      await (update(paymentsLedger)..where((t) => t.contractId.equals(contractId))).write(
        PaymentsLedgerCompanion(isDeleted: const Value(true), updatedAt: nowUtc, isSynced: const Value(false)),
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
      
  // 🌟 جلب كل الدفعات في النظام (للوحة التحكم)
  Future<List<PaymentsLedgerData>> getAllActivePayments() => 
      (select(paymentsLedger)..where((t) => t.isDeleted.equals(false))).get();


  Future<String> insertLedgerEntry(PaymentsLedgerCompanion entry) async {
    final row = await into(paymentsLedger).insertReturning(entry);
    return row.id;
  }
  
  Future<int> markWhatsAppAsSent(String entryId) {
    // 🌍 تسجيل وقت التحديث بصيغة UTC
    return (update(paymentsLedger)..where((t) => t.id.equals(entryId))).write(
      PaymentsLedgerCompanion(
        isWhatsAppSent: const Value(true), 
        updatedAt: Value(DateTime.now().toUtc()), 
        isSynced: const Value(false)
      ),
    );
  }

  // ==========================================
  // --- استعلامات سجل أسعار المواد ---
  // ==========================================
  // 🌟 جلب كل سجلات أسعار المواد للإحصائيات
  Future<List<MaterialPricesHistoryData>> getAllMaterialPricesHistory() => 
      (select(materialPricesHistory)..where((t) => t.isDeleted.equals(false))).get();
      
  // جلب أحدث سعر فعّال
  Future<MaterialPricesHistoryData?> getLatestPrices() {
    return (select(materialPricesHistory)
          ..where((t) => t.isDeleted.equals(false)) // 🌟 1. أعدنا شرط تجاهل المحذوف
          ..orderBy([
            (t) => OrderingTerm.desc(t.effectiveDate), // 🌟 2. الترتيب الأول حسب تاريخ السريان
            (t) => OrderingTerm.desc(t.createdAt),     // 🌟 3. كاسر التعادل: الترتيب الثاني حسب وقت الإضافة بالثانية
          ])
          ..limit(1))
        .getSingleOrNull();
  }
  
  // 🌟 (النسخة المعدلة) إضافة التسعيرة الجديدة فقط دون لمس السجل القديم
  Future<String> insertMaterialPriceRecord(MaterialPricesHistoryCompanion prices) async {
    // تم حذف الـ transaction والكود الذي يقوم بحذف الأسعار القديمة
    // الآن سيتم إضافة التسعيرة الجديدة فقط كسجل تاريخي جديد
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

  

  // تحديث حالة القسط (مثلاً من pending إلى paid)
  Future<int> updateScheduleStatus(String id, String status) {
    // 🌍 تسجيل وقت التحديث بصيغة UTC
    return (update(installmentsSchedule)..where((t) => t.id.equals(id))).write(
      InstallmentsScheduleCompanion(
        status: Value(status), 
        updatedAt: Value(DateTime.now().toUtc()), 
        isSynced: const Value(false)
      )
    );
  }

  // حذف قسط مجدول (Soft Delete)
  Future<int> softDeleteScheduleEntry(String id) {
    // 🌍 تسجيل وقت الحذف الوهمي بصيغة UTC
    return (update(installmentsSchedule)..where((t) => t.id.equals(id))).write(
      InstallmentsScheduleCompanion(
        isDeleted: const Value(true), 
        updatedAt: Value(DateTime.now().toUtc()), 
        isSynced: const Value(false)
      )
    );
  }
  

  // 🌟 جلب كل الأقساط المتأخرة في كامل النظام
  Future<List<InstallmentsScheduleData>> getAllOverdueSchedules() {
    final nowUtc = DateTime.now().toUtc();
    return (select(installmentsSchedule)
      ..where((t) => t.isDeleted.equals(false) & t.status.equals('pending') & t.dueDate.isSmallerThanValue(nowUtc))
      ..orderBy([(t) => OrderingTerm.asc(t.dueDate)])
    ).get();
  }

  
  // ==========================================
  // 🔄 إعادة الجدولة الذكية (Smart Restructuring)
  // ==========================================
  Future<void> restructureContractSchedule({
    required String contractId,
    required int newRemainingMonths,
    required DateTime newStartDate,
    required String userId,
  }) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());

      // 1. جلب جميع الأقساط المدفوعة لمعرفة أين توقفنا في الترقيم
      final paidSchedules = await (select(installmentsSchedule)
            ..where((t) => t.contractId.equals(contractId) & t.status.equals('paid') & t.isDeleted.equals(false)))
          .get();

      // إيجاد أعلى رقم قسط مدفوع (إذا لم يدفع شيئاً، سيكون 0)
      int lastPaidNumber = 0;
      for (var s in paidSchedules) {
        if (s.installmentNumber > lastPaidNumber) {
          lastPaidNumber = s.installmentNumber;
        }
      }

      // 2. الحذف الوهمي (Soft Delete) لجميع الأقساط "المعلقة" الحالية
      await (update(installmentsSchedule)
            ..where((t) => t.contractId.equals(contractId) & t.status.equals('pending') & t.isDeleted.equals(false)))
          .write(
        InstallmentsScheduleCompanion(
          isDeleted: const Value(true),
          updatedAt: nowUtc,
          isSynced: const Value(false), // إجبار السحابة على مسحهم
        ),
      );

      // 3. توليد الأقساط الجديدة المتبقية بالتاريخ الجديد
      for (int i = 1; i <= newRemainingMonths; i++) {
        // نستخدم DateTime.utc لضمان التوقيت العالمي، والـ Dart ذكية ستعالج زيادة الأشهر تلقائياً للسنوات القادمة
        final dueDate = DateTime.utc(newStartDate.year, newStartDate.month + (i - 1), newStartDate.day);

        final entry = InstallmentsScheduleCompanion.insert(
          contractId: contractId,
          installmentNumber: lastPaidNumber + i, // إكمال الترقيم من حيث انتهى
          dueDate: dueDate,
          status: const Value('pending'),
          userId: userId,
        );
        await into(installmentsSchedule).insert(entry);
      }

      // 4. تحديث مدة العقد الإجمالية في جدول العقود لتتوافق مع الجدولة الجديدة
      final int newTotalInstallments = lastPaidNumber + newRemainingMonths;
      await (update(contracts)..where((t) => t.id.equals(contractId))).write(
        ContractsCompanion(
          installmentsCount: Value(newTotalInstallments),
          updatedAt: nowUtc,
          isSynced: const Value(false), // إجبار المزامنة للعقد
        ),
      );
    });
  }
  


  // ==========================================
  // --- البث الحي للأسعار (Stream) ---
  // ==========================================
  Stream<MaterialPricesHistoryData?> watchLatestPrices() {
    return (select(materialPricesHistory)
          ..where((t) => t.isDeleted.equals(false)) // 🌟 نفس التعديل هنا مهم جداً للداشبورد
          ..orderBy([
            (t) => OrderingTerm.desc(t.effectiveDate),
            (t) => OrderingTerm.desc(t.createdAt), 
          ])
          ..limit(1))
        .watchSingleOrNull();
  }

  // ==========================================
  // --- 🏢 استعلامات المحاضر (Buildings) ---
  // ==========================================
  Future<List<Building>> getActiveBuildings() => 
      (select(buildings)..where((t) => t.isDeleted.equals(false))).get();
  
  Future<String> insertBuilding(BuildingsCompanion building) async {
    final row = await into(buildings).insertReturning(building);
    return row.id;
  }

  // ==========================================
  // --- 🚪 استعلامات الشقق (Apartments) ---
  // ==========================================
  // جلب كل الشقق المتاحة في النظام
  Future<List<Apartment>> getAllActiveApartments() => 
      (select(apartments)..where((t) => t.isDeleted.equals(false))).get();

  // جلب الشقق الخاصة بمحضر معين فقط
  Future<List<Apartment>> getApartmentsForBuilding(String buildingId) => 
      (select(apartments)
        ..where((t) => t.buildingId.equals(buildingId) & t.isDeleted.equals(false))
      ).get();

  Future<String> insertApartment(ApartmentsCompanion apartment) async {
    final row = await into(apartments).insertReturning(apartment);
    return row.id;
  }

  // 🌟 أهم دالة: تغيير حالة الشقة (مثلاً من available إلى sold عند توقيع العقد)
  Future<int> updateApartmentStatus(String apartmentId, String newStatus) {
    // 🌍 تسجيل وقت التحديث بصيغة UTC
    return (update(apartments)..where((t) => t.id.equals(apartmentId))).write(
      ApartmentsCompanion(
        status: Value(newStatus), 
        updatedAt: Value(DateTime.now().toUtc()), 
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
      await delete(apartments).go();
      await delete(buildings).go();
      await delete(clients).go();
    });
  }
  
  // ==========================================
  // ☁️ دوال الحقن السحابي (Aggressive Cloud Sync Upserts)
  // ==========================================
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

  Future<void> syncBuilding(BuildingsCompanion entity) => 
      into(buildings).insert(entity, mode: InsertMode.insertOrReplace);
      
  Future<void> syncApartment(ApartmentsCompanion entity) => 
      into(apartments).insert(entity, mode: InsertMode.insertOrReplace);


      // ==========================================
  // 🗑️ سلة المحذوفات (Recycle Bin) - العملاء
  // ==========================================
  
  // 1. جلب العملاء المحذوفين
  Future<List<Client>> getDeletedClients() => 
      (select(clients)..where((t) => t.isDeleted.equals(true))).get();

  // 2. استعادة عميل محذوف
  Future<void> restoreSoftDeletedClient(String clientId) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());
      await (update(clients)..where((t) => t.id.equals(clientId))).write(
        ClientsCompanion(
          isDeleted: const Value(false), // إرجاع للحياة
          updatedAt: nowUtc, // تحديث الوقت
          isSynced: const Value(false) // إجبار السحابة على المزامنة وإلغاء الحذف هناك
        ),
      );
    });
  }

  // 3. الحذف النهائي اليدوي (Hard Delete)
  Future<void> hardDeleteClient(String clientId) async {
    await (delete(clients)..where((t) => t.id.equals(clientId))).go();
  }

  // 4. التنظيف التلقائي (مسح أي عنصر محذوف مر عليه 7 أيام)
  Future<void> autoCleanOldDeletedClients() async {
    // تحديد نقطة الزمن (منذ 7 أيام)
    final sevenDaysAgo = DateTime.now().toUtc().subtract(const Duration(days: 7));
    
    await (delete(clients)..where((t) => 
      t.isDeleted.equals(true) & t.updatedAt.isSmallerThanValue(sevenDaysAgo)
    )).go();
  }
      


  // ==========================================
  // 🗑️ سلة المحذوفات (Recycle Bin) - العقود
  // ==========================================
  
  // 1. جلب العقود المحذوفة
  Future<List<Contract>> getDeletedContracts() => 
      (select(contracts)..where((t) => t.isDeleted.equals(true))).get();

  // 2. استعادة عقد (ويستعيد معه جداول الأقساط والمدفوعات الخاصة به)
  Future<void> restoreSoftDeletedContract(String contractId) async {
    return transaction(() async {
      final nowUtc = Value(DateTime.now().toUtc());

      // أ. استعادة العقد
      await (update(contracts)..where((t) => t.id.equals(contractId))).write(
        ContractsCompanion(isDeleted: const Value(false), updatedAt: nowUtc, isSynced: const Value(false)),
      );

      // ب. استعادة جدول الاستحقاقات التابع له
      await (update(installmentsSchedule)..where((t) => t.contractId.equals(contractId))).write(
        InstallmentsScheduleCompanion(isDeleted: const Value(false), updatedAt: nowUtc, isSynced: const Value(false)),
      );

      // ج. استعادة الدفعات (دفتر الأستاذ) التابعة له
      await (update(paymentsLedger)..where((t) => t.contractId.equals(contractId))).write(
        PaymentsLedgerCompanion(isDeleted: const Value(false), updatedAt: nowUtc, isSynced: const Value(false)),
      );
    });
  }

  // 3. الحذف النهائي اليدوي لعقد (Hard Delete)
  Future<void> hardDeleteContract(String contractId) async {
    return transaction(() async {
      // يجب حذف الأبناء أولاً (الأقساط والمدفوعات) لمنع الأخطاء
      await (delete(paymentsLedger)..where((t) => t.contractId.equals(contractId))).go();
      await (delete(installmentsSchedule)..where((t) => t.contractId.equals(contractId))).go();
      
      // ثم حذف الأب (العقد)
      await (delete(contracts)..where((t) => t.id.equals(contractId))).go();
    });
  }

  // 4. التنظيف التلقائي للعقود القديمة المحذوفة
  Future<void> autoCleanOldDeletedContracts() async {
    final sevenDaysAgo = DateTime.now().toUtc().subtract(const Duration(days: 7));
    
    // جلب العقود التي مر عليها 7 أيام في الحذف
    final oldContracts = await (select(contracts)..where((t) => t.isDeleted.equals(true) & t.updatedAt.isSmallerThanValue(sevenDaysAgo))).get();
    
    // حذفها نهائياً مع توابعها
    for (var c in oldContracts) {
      await hardDeleteContract(c.id);
    }
  }

  // ==========================================
  // 🗑️ سلة المحذوفات وتعديل المدفوعات (Ledger)
  // ==========================================

  // 1. تعديل دفعة قديمة (تحديث المبلغ والخصم والأمتار)
  Future<int> updateLedgerEntryAmount({
    required String entryId,
    required double newAmount,
    required double newDiscount,
    required double newConvertedMeters,
  }) {
    return (update(paymentsLedger)..where((t) => t.id.equals(entryId))).write(
      PaymentsLedgerCompanion(
        amountPaid: Value(newAmount),
        fees: Value(newDiscount),
        convertedMeters: Value(newConvertedMeters),
        updatedAt: Value(DateTime.now().toUtc()), 
        isSynced: const Value(false),
      ),
    );
  }

  // 2. الحذف الوهمي لدفعة (Soft Delete)
  Future<int> softDeleteLedgerEntry(String entryId) {
    return (update(paymentsLedger)..where((t) => t.id.equals(entryId))).write(
      PaymentsLedgerCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  // 3. جلب الدفعات المحذوفة
  Future<List<PaymentsLedgerData>> getDeletedLedgerEntries() => 
      (select(paymentsLedger)..where((t) => t.isDeleted.equals(true))).get();

  // 4. استعادة دفعة من المحذوفات
  Future<int> restoreLedgerEntry(String entryId) {
    return (update(paymentsLedger)..where((t) => t.id.equals(entryId))).write(
      PaymentsLedgerCompanion(
        isDeleted: const Value(false),
        updatedAt: Value(DateTime.now().toUtc()),
        isSynced: const Value(false),
      ),
    );
  }

  // 5. الحذف النهائي لدفعة (Hard Delete المدمر)
  Future<int> forceHardDeleteLedgerEntry(String entryId) {
    return (delete(paymentsLedger)..where((t) => t.id.equals(entryId))).go();
  }

  // 6. التنظيف التلقائي بعد 7 أيام (لتوفير المساحة)
  Future<void> autoCleanOldDeletedLedgerEntries() async {
    final sevenDaysAgo = DateTime.now().toUtc().subtract(const Duration(days: 7));
    await (delete(paymentsLedger)..where((t) => 
      t.isDeleted.equals(true) & t.updatedAt.isSmallerThanValue(sevenDaysAgo)
    )).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory(); 
    // 🌟 تغيير الاسم لإنشاء قاعدة جديدة نظيفة تماماً 
    final file = File(p.join(dbFolder.path, 'our_home_erp_v9_clean.sqlite')); 
    return NativeDatabase.createInBackground(file);
  });
}
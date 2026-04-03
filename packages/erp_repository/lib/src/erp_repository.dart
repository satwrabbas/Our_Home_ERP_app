import 'package:local_storage_api/local_storage_api.dart';
import 'package:cloud_storage_api/cloud_storage_api.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart'; 
/// المدير الذكي بنظام (Offline-First) والمزامنة الشبحية ثنائية الاتجاه (Push & Pull)
class ErpRepository {
  ErpRepository({
    required LocalStorageApi localStorageApi,
    required CloudStorageClient cloudStorageClient,
  })  : _localApi = localStorageApi,
        _cloudApi = cloudStorageClient;

  final LocalStorageApi _localApi;
  final CloudStorageClient _cloudApi;

  bool _isSyncing = false;

  // ==========================================
  // 🔐 المصادقة (Authentication)
  // ==========================================
  String? get currentUserId => _cloudApi.currentUserId;

  Future<void> signIn({required String email, required String password}) async {
    await _cloudApi.signIn(email: email, password: password);
    // 🌟 السحر: سحب كل بيانات الشركة فور تسجيل الدخول بنجاح!
    await pullDataFromCloud();
  }

  Future<void> signOut() async {
    await _cloudApi.signOut();
    // حماية قصوى: مسح قاعدة البيانات المحلية
    await _localApi.formatDatabase();
  }

  // ==========================================
  // 🔄 المزامنة اليدوية (زر المزامنة الأخضر في لوحة التحكم)
  // ==========================================
  Future<String> forceSyncWithCloud() async {
    try {
      await syncPendingData(); // 1. رفع أي تعديلات محلية أولاً
      await pullDataFromCloud(); // 2. سحب أي بيانات جديدة أضافها مدير آخر
      return 'تمت المزامنة مع السحابة بنجاح! ☁️✓';
    } catch (e) {
      return 'حدث خطأ أثناء المزامنة: $e';
    }
  }

  // ==========================================
  // 📥 محرك السحب الشبحي (Pull from Cloud) - النسخة المصححة
  // ==========================================
  Future<void> pullDataFromCloud() async {
    try {
      // 1. سحب العملاء
      final cloudClients = await _cloudApi.getClients();
      for (var c in cloudClients) {
        final client = ClientsCompanion.insert(
          id: drift.Value(c['id'].toString()), 
          name: c['name'].toString(), 
          phone: c['phone'].toString(), 
          nationalId: drift.Value(c['nationalId']?.toString()), 
          userId: c['userId']?.toString() ?? '',
          isDeleted: drift.Value(c['isDeleted'] == true), 
          // تأكد من استخدام updatedAt القادم من السحابة
          updatedAt: drift.Value(DateTime.tryParse(c['updatedAt']?.toString() ?? '') ?? DateTime.now()),
          isSynced: const drift.Value(true), 
        );
        // التغيير هنا: استخدم syncClient بدلاً من addClient
        await _localApi.syncClient(client); 
      }

      // 2. سحب العقود
      final cloudContracts = await _cloudApi.getContracts();
      for (var c in cloudContracts) {
        final contract = ContractsCompanion.insert(
          id: drift.Value(c['id'].toString()), 
          clientId: c['clientId'].toString(), 
          contractType: drift.Value(c['contractType']?.toString() ?? 'لاحق التخصص'),
          apartmentDetails: c['apartmentDetails'].toString(), 
          totalArea: double.tryParse(c['totalArea']?.toString() ?? '0') ?? 0.0,
          baseMeterPriceAtSigning: double.tryParse(c['baseMeterPriceAtSigning']?.toString() ?? '0') ?? 0.0,
          installmentsCount: drift.Value(int.tryParse(c['installmentsCount']?.toString() ?? '48') ?? 48),
          coefficients: drift.Value(c['coefficients']?.toString() ?? '{}'),
          contractDate: DateTime.tryParse(c['contractDate']?.toString() ?? '') ?? DateTime.now(),
          userId: c['userId']?.toString() ?? '',
          isCompleted: drift.Value(c['isCompleted'] == true),
          isDeleted: drift.Value(c['isDeleted'] == true),
          updatedAt: drift.Value(DateTime.tryParse(c['updatedAt']?.toString() ?? '') ?? DateTime.now()),
          isSynced: const drift.Value(true),
        );
        // التغيير هنا: استخدم syncContract
        await _localApi.syncContract(contract);
      }

      // 3. سحب أسعار المواد
      final cloudPrices = await _cloudApi.getMaterialPrices();
      for (var p in cloudPrices) {
        final price = MaterialPricesHistoryCompanion.insert(
          id: drift.Value(p['id'].toString()), 
          ironPrice: double.tryParse(p['ironPrice']?.toString() ?? '0') ?? 0.0, 
          cementPrice: double.tryParse(p['cementPrice']?.toString() ?? '0') ?? 0.0,
          block15Price: double.tryParse(p['block15Price']?.toString() ?? '0') ?? 0.0, 
          formworkAndPouringWages: double.tryParse(p['formworkAndPouringWages']?.toString() ?? '0') ?? 0.0,
          aggregateMaterialsPrice: double.tryParse(p['aggregateMaterialsPrice']?.toString() ?? '0') ?? 0.0, 
          ordinaryWorkerWage: double.tryParse(p['ordinaryWorkerWage']?.toString() ?? '0') ?? 0.0,
          effectiveDate: drift.Value(DateTime.tryParse(p['effectiveDate']?.toString() ?? '') ?? DateTime.now()),
          userId: p['userId']?.toString() ?? '',
          isDeleted: drift.Value(p['isDeleted'] == true),
          isSynced: const drift.Value(true),
        );
        // التغيير هنا: استخدم syncPrice
        await _localApi.syncPrice(price);
      }

      // 4. سحب جدول الاستحقاقات
      final cloudSchedules = await _cloudApi.getSchedules();
      for (var s in cloudSchedules) {
        final schedule = InstallmentsScheduleCompanion.insert(
          id: drift.Value(s['id'].toString()), 
          contractId: s['contractId'].toString(), 
          installmentNumber: int.tryParse(s['installmentNumber']?.toString() ?? '1') ?? 1,
          dueDate: DateTime.tryParse(s['dueDate']?.toString() ?? '') ?? DateTime.now(), 
          status: drift.Value(s['status']?.toString() ?? 'pending'),
          userId: s['userId']?.toString() ?? '',
          isDeleted: drift.Value(s['isDeleted'] == true),
          updatedAt: drift.Value(DateTime.tryParse(s['updatedAt']?.toString() ?? '') ?? DateTime.now()),
          isSynced: const drift.Value(true),
        );
        // التغيير هنا: استخدم syncSchedule
        await _localApi.syncSchedule(schedule);
      }

      // 5. سحب دفتر الأستاذ (الدفعات)
      final cloudPayments = await _cloudApi.getPayments();
      for (var p in cloudPayments) {
        final payment = PaymentsLedgerCompanion.insert(
          id: drift.Value(p['id'].toString()), 
          contractId: p['contractId'].toString(), 
          scheduleId: drift.Value(p['scheduleId']?.toString()),
          paymentDate: DateTime.tryParse(p['paymentDate']?.toString() ?? '') ?? DateTime.now(), 
          amountPaid: double.tryParse(p['amountPaid']?.toString() ?? '0') ?? 0.0, 
          meterPriceAtPayment: double.tryParse(p['meterPriceAtPayment']?.toString() ?? '0') ?? 0.0,
          convertedMeters: double.tryParse(p['convertedMeters']?.toString() ?? '0') ?? 0.0, 
          fees: drift.Value(double.tryParse(p['fees']?.toString() ?? '0') ?? 0.0),
          isWhatsAppSent: drift.Value(p['isWhatsAppSent'] == true),
          userId: p['userId']?.toString() ?? '',
          isDeleted: drift.Value(p['isDeleted'] == true),
          updatedAt: drift.Value(DateTime.tryParse(p['updatedAt']?.toString() ?? '') ?? DateTime.now()),
          isSynced: const drift.Value(true),
        );
        // التغيير هنا: استخدم syncPayment
        await _localApi.syncPayment(payment);
      }

      print('✅ تم تحديث كافة البيانات المحلية من السحابة بنجاح');
    } catch (e) {
      print('❌ Cloud Pull Failed: $e'); 
    }
  }

  // ==========================================
  // 📤 محرك الرفع الشبحي (Push to Cloud) - نسخة محمية ومحسنة 🛡️
  // ==========================================
  Future<void> syncPendingData() async {
    if (_isSyncing || currentUserId == null) return;
    _isSyncing = true;
    
    final db = _localApi.database;

    // 🛡️ دالة مساعدة لمنع خطأ الـ Infinity في تحويل الـ JSON
    double _safeNum(double? val) {
      if (val == null) return 0.0;
      if (val.isInfinite || val.isNaN) return 0.0;
      return val;
    }

    // 1. مزامنة العملاء
    try {
      final pendingClients = await (db.select(db.clients)..where((t) => t.isSynced.equals(false))).get();
      for (var c in pendingClients) {
        await _cloudApi.upsertClient({'id': c.id, 'name': c.name, 'phone': c.phone, 'nationalId': c.nationalId, 'userId': c.userId, 'isDeleted': c.isDeleted, 'updatedAt': c.updatedAt.toIso8601String()});
        await (db.update(db.clients)..where((t) => t.id.equals(c.id))).write(const ClientsCompanion(isSynced: drift.Value(true)));
      }
    } catch (e) { print('Sync Clients Failed: $e'); }

    // 2. مزامنة العقود
    try {
      final pendingContracts = await (db.select(db.contracts)..where((t) => t.isSynced.equals(false))).get();
      for (var c in pendingContracts) {
        await _cloudApi.upsertContract({'id': c.id, 'clientId': c.clientId, 'contractType': c.contractType, 'apartmentDetails': c.apartmentDetails, 'totalArea': _safeNum(c.totalArea), 'baseMeterPriceAtSigning': _safeNum(c.baseMeterPriceAtSigning), 'installmentsCount': c.installmentsCount, 'coefficients': c.coefficients, 'contractDate': c.contractDate.toIso8601String(), 'userId': c.userId, 'isCompleted': c.isCompleted, 'isDeleted': c.isDeleted, 'updatedAt': c.updatedAt.toIso8601String()});
        await (db.update(db.contracts)..where((t) => t.id.equals(c.id))).write(const ContractsCompanion(isSynced: drift.Value(true)));
      }
    } catch (e) { print('Sync Contracts Failed: $e'); }

    // 3. مزامنة جدول الاستحقاقات
    try {
      final pendingSchedules = await (db.select(db.installmentsSchedule)..where((t) => t.isSynced.equals(false))).get();
      if (pendingSchedules.isNotEmpty) {
        final cloudSchedules = pendingSchedules.map((s) => {'id': s.id, 'contractId': s.contractId, 'installmentNumber': s.installmentNumber, 'dueDate': s.dueDate.toIso8601String(), 'status': s.status, 'userId': s.userId, 'isDeleted': s.isDeleted, 'updatedAt': s.updatedAt.toIso8601String()}).toList();
        await _cloudApi.upsertSchedule(cloudSchedules); 
        for (var s in pendingSchedules) {
          await (db.update(db.installmentsSchedule)..where((t) => t.id.equals(s.id))).write(const InstallmentsScheduleCompanion(isSynced: drift.Value(true)));
        }
      }
    } catch (e) { print('Sync Schedules Failed: $e'); }

    // 4. مزامنة الدفعات (هنا كان يحدث خطأ الـ Infinity) 🚨
    try {
      final pendingPayments = await (db.select(db.paymentsLedger)..where((t) => t.isSynced.equals(false))).get();
      for (var p in pendingPayments) {
        await _cloudApi.upsertPayment({
          'id': p.id, 
          'contractId': p.contractId, 
          'scheduleId': p.scheduleId, 
          'paymentDate': p.paymentDate.toIso8601String(), 
          'amountPaid': _safeNum(p.amountPaid), 
          'meterPriceAtPayment': _safeNum(p.meterPriceAtPayment), 
          'convertedMeters': _safeNum(p.convertedMeters), // 🟢 تنظيف الـ Infinity هنا
          'fees': _safeNum(p.fees), 
          'isWhatsAppSent': p.isWhatsAppSent, 
          'userId': p.userId, 
          'isDeleted': p.isDeleted, 
          'updatedAt': p.updatedAt.toIso8601String()
        });
        await (db.update(db.paymentsLedger)..where((t) => t.id.equals(p.id))).write(const PaymentsLedgerCompanion(isSynced: drift.Value(true)));
      }
    } catch (e) { print('Sync Payments Failed: $e'); }
    
    // 5. مزامنة أسعار المواد (كانت معطلة بسبب خطأ الدفعات السابق) 🟢
    try {
      final pendingPrices = await (db.select(db.materialPricesHistory)..where((t) => t.isSynced.equals(false))).get();
      for (var p in pendingPrices) {
        await _cloudApi.upsertMaterialPrices({
          'id': p.id, 
          'effectiveDate': p.effectiveDate.toIso8601String(), 
          'ironPrice': _safeNum(p.ironPrice), 
          'cementPrice': _safeNum(p.cementPrice), 
          'block15Price': _safeNum(p.block15Price), 
          'formworkAndPouringWages': _safeNum(p.formworkAndPouringWages), 
          'aggregateMaterialsPrice': _safeNum(p.aggregateMaterialsPrice), 
          'ordinaryWorkerWage': _safeNum(p.ordinaryWorkerWage), 
          'userId': p.userId, 
          'isDeleted': p.isDeleted
          // تأكد من أن جدولك في Supabase لا يشترط حقل updatedAt هنا، وإلا أضفه!
        });
        await (db.update(db.materialPricesHistory)..where((t) => t.id.equals(p.id))).write(const MaterialPricesHistoryCompanion(isSynced: drift.Value(true)));
      }
    } catch (e) { print('Sync Prices Failed: $e'); }

    _isSyncing = false; 
  }

  // ==========================================
  // 👥 العملاء 
  // ==========================================
  Future<List<Client>> getClients() => _localApi.getClients();

  Future<void> addClient(ClientsCompanion clientCompanion) async {
    if (currentUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');
    final companionWithUser = clientCompanion.copyWith(userId: drift.Value(currentUserId!));
    await _localApi.addClient(companionWithUser); 
    syncPendingData(); 
  }

  Future<void> deleteClient(String clientId) async { 
    await _localApi.deleteClient(clientId);
    syncPendingData();
  }

  // ==========================================
  // 📄 العقود والتوليد الآلي للاستحقاقات
  // ==========================================
  Future<List<Contract>> getAllContracts() => _localApi.getAllContracts();

  Future<void> addContract(ContractsCompanion contractCompanion) async {
    if (currentUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');
    final companionWithUser = contractCompanion.copyWith(userId: drift.Value(currentUserId!));
    final localId = await _localApi.addContract(companionWithUser);
    
    final int months = contractCompanion.installmentsCount.present ? contractCompanion.installmentsCount.value : 48;
    final DateTime startDate = contractCompanion.contractDate.present ? contractCompanion.contractDate.value : DateTime.now();
    
    for (int i = 1; i <= months; i++) {
      final dueDate = DateTime(startDate.year, startDate.month + i, startDate.day);
      final entry = InstallmentsScheduleCompanion.insert(
        contractId: localId, installmentNumber: i, dueDate: dueDate,
        status: const drift.Value('pending'), userId: currentUserId!, 
      );
      await _localApi.addScheduleEntry(entry);
    }
    syncPendingData();
  }

  Future<void> deleteContract(String contractId) async {
    await _localApi.deleteContract(contractId);
    syncPendingData();
  }

  // ==========================================
  // 📅 جدول الاستحقاقات (المراقبة)
  // ==========================================
  Future<List<InstallmentsScheduleData>> getContractSchedule(String contractId) => _localApi.getContractSchedule(contractId);

  Future<void> updateScheduleStatus(String scheduleId, String status) async {
    await _localApi.updateScheduleStatus(scheduleId, status);
    syncPendingData();
  }

  // ==========================================
  // 💰 دفتر الأستاذ (Payments Ledger)
  // ==========================================
  Future<List<PaymentsLedgerData>> getContractLedger(String contractId) => _localApi.getContractLedger(contractId);

  Future<void> addLedgerEntry(PaymentsLedgerCompanion entryCompanion) async {
    if (currentUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');
    final companionWithUser = entryCompanion.copyWith(userId: drift.Value(currentUserId!));
    await _localApi.addLedgerEntry(companionWithUser);
    
    if (entryCompanion.scheduleId.present && entryCompanion.scheduleId.value != null) {
      await _localApi.updateScheduleStatus(entryCompanion.scheduleId.value!, 'paid');
    }
    syncPendingData();
  }

  Future<void> markWhatsAppAsSent(String entryId) async { 
    await _localApi.updateWhatsAppStatus(entryId);
    syncPendingData();
  }

  // ==========================================
  // ⚙️ الإعدادات (Material Prices)
  // ==========================================
  Future<MaterialPricesHistoryData?> getLatestPrices() => _localApi.getLatestPrices();

  Future<void> savePrices(MaterialPricesHistoryCompanion pricesCompanion) async {
    // 🌟 1. وضعنا معرّف وهمي في حال كنت تختبر التطبيق ولم تقم بتسجيل الدخول بعد
    final String safeUserId = currentUserId ?? 'test_offline_user';

    // 🌟 2. توليد ID فريد للسطر الجديد (هذا هو الذي كان يمنع الحفظ!)
    final String newId = const Uuid().v4();

    // 🌟 3. دمج الـ ID والـ UserId مع البيانات القادمة من الـ Cubit
    final companionReadyToSave = pricesCompanion.copyWith(
      id: drift.Value(newId),
      userId: drift.Value(safeUserId),
    );

    // 4. الحفظ في قاعدة البيانات المحلية
    await _localApi.savePrices(companionReadyToSave);
    
    // 5. المزامنة مع السحابة
    syncPendingData(); 
  }
}
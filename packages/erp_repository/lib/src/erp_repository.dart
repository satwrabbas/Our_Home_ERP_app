//erp_repository.dart
import 'dart:io';
import 'package:local_storage_api/local_storage_api.dart';
import 'package:cloud_storage_api/cloud_storage_api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart'; 
/// المدير الذكي بنظام (Offline-First) والمزامنة الشبحية ثنائية الاتجاه (Push & Pull)
class ErpRepository {
  ErpRepository({
    required LocalStorageApi localStorageApi,
    required CloudStorageClient cloudStorageClient,
  })  : _localApi = localStorageApi,
        _cloudApi = cloudStorageClient {
    // 🌟 السحر هنا: بمجرد بناء الـ Repository عند فتح التطبيق
    // نتحقق إذا كان المستخدم مسجلاً للدخول مسبقاً، نشغل الاستماع للسحابة فوراً!
    if (currentUserId != null) {
      _startCloudListener();
    }
  }


  // 🌟 فصلنا كود تشغيل المستمع في دالة خاصة لترتيب الكود
  void _startCloudListener() {
    _cloudApi.startListeningToCloudChanges(
      onDataChanged: () {
        print('🔄 جاري سحب الأسعار الجديدة من السحابة بسبب تحديث حي...');
        pullDataFromCloud(); 
      },
    );
  }

  RealtimeChannel? _pricesChannel;

  
  
  final LocalStorageApi _localApi;
  final CloudStorageClient _cloudApi;

  bool _isSyncing = false;

  // ==========================================
  // 🔐 المصادقة (Authentication)
  // ==========================================
  String? get currentUserId => _cloudApi.currentUserId;

  Future<void> signIn({required String email, required String password}) async {
    await _cloudApi.signIn(email: email, password: password);
     // 1. سحب كل بيانات الشركة فور تسجيل الدخول بنجاح!
    await pullDataFromCloud();
    
    // تشغيل المستمع بعد تسجيل الدخول لأول مرة
    _startCloudListener(); 
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
          
          // 🌟 السطر الجديد هنا: سحب معرف الشقة من السحابة 🌟
          apartmentId: drift.Value(c['apartment_id']?.toString()), 
          
          contractType: drift.Value(c['contractType']?.toString() ?? 'لاحق التخصص'),
          apartmentDetails: drift.Value(c['apartmentDetails'].toString()),
          totalArea: double.tryParse(c['totalArea']?.toString() ?? '0') ?? 0.0,
          baseMeterPriceAtSigning: double.tryParse(c['baseMeterPriceAtSigning']?.toString() ?? '0') ?? 0.0,
          installmentsCount: drift.Value(int.tryParse(c['installmentsCount']?.toString() ?? '48') ?? 48),
          coefficients: drift.Value(c['coefficients']?.toString() ?? '{}'),
          contractDate: DateTime.tryParse(c['contractDate']?.toString() ?? '') ?? DateTime.now(),
          guarantorName: c['guarantor_name']?.toString() ?? 'بدون كفيل', 
          contractFileUrl: drift.Value(c['contract_file_url']?.toString()), 
          userId: c['userId']?.toString() ?? '',
          isCompleted: drift.Value(c['isCompleted'] == true),
          isDeleted: drift.Value(c['isDeleted'] == true),
          updatedAt: drift.Value(DateTime.tryParse(c['updatedAt']?.toString() ?? '') ?? DateTime.now()),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncContract(contract);
      }

      // 3. سحب أسعار المواد (المعدل ليتوافق مع snake_case)
      final cloudPrices = await _cloudApi.getMaterialPrices();
      for (var p in cloudPrices) {
        final price = MaterialPricesHistoryCompanion.insert(
          id: drift.Value(p['id'].toString()), 
          ironPrice: double.tryParse(p['iron_price']?.toString() ?? '0') ?? 0.0, 
          cementPrice: double.tryParse(p['cement_price']?.toString() ?? '0') ?? 0.0,
          block15Price: double.tryParse(p['block15_price']?.toString() ?? '0') ?? 0.0, 
          formworkAndPouringWages: double.tryParse(p['formwork_and_pouring_wages']?.toString() ?? '0') ?? 0.0,
          aggregateMaterialsPrice: double.tryParse(p['aggregate_materials_price']?.toString() ?? '0') ?? 0.0, 
          ordinaryWorkerWage: double.tryParse(p['ordinary_worker_wage']?.toString() ?? '0') ?? 0.0,
          effectiveDate: drift.Value(DateTime.tryParse(p['effective_date']?.toString() ?? '') ?? DateTime.now()),
          userId: p['user_id']?.toString() ?? '',
          isDeleted: drift.Value(p['is_deleted'] == true),
          isSynced: const drift.Value(true),
        );
        // استخدام syncPrice بدلاً من savePrices لمنع تكرار الـ ID
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

      // 6. سحب المحاضر (Buildings)
      final cloudBuildings = await _cloudApi.getBuildings();
      for (var b in cloudBuildings) {
        final building = BuildingsCompanion.insert(
          id: drift.Value(b['id'].toString()),
          name: b['name'].toString(),
          location: drift.Value(b['location']?.toString()),
          floorCoefficients: drift.Value(b['floor_coefficients']?.toString() ?? '{}'),
          directionCoefficients: drift.Value(b['direction_coefficients']?.toString() ?? '{}'),
          userId: drift.Value(b['user_id']?.toString() ?? ''),
          isDeleted: drift.Value(b['is_deleted'] == true),
          updatedAt: drift.Value(DateTime.tryParse(b['updated_at']?.toString() ?? '') ?? DateTime.now()),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncBuilding(building);
      }

      // 7. سحب الشقق (Apartments)
      final cloudApartments = await _cloudApi.getApartments();
      for (var a in cloudApartments) {
        final apartment = ApartmentsCompanion.insert(
          id: drift.Value(a['id'].toString()),
          buildingId: a['building_id'].toString(),
          apartmentNumber: a['apartment_number'].toString(),
          area: double.tryParse(a['area']?.toString() ?? '0') ?? 0.0,
          floorName: a['floor_name'].toString(),
          
          // 🌟 تم تصحيح هذا السطر: تمرير String مباشر بدلاً من drift.Value
          directionName: a['direction_name']?.toString() ?? '-', 
          
          customCoefficients: drift.Value(a['custom_coefficients']?.toString() ?? '{}'),
          status: drift.Value(a['status']?.toString() ?? 'available'),
          userId: drift.Value(a['user_id']?.toString() ?? ''),
          isDeleted: drift.Value(a['is_deleted'] == true),
          updatedAt: drift.Value(DateTime.tryParse(a['updated_at']?.toString() ?? '') ?? DateTime.now()),
          isSynced: const drift.Value(true),
        );
        await _localApi.syncApartment(apartment);
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
        await _cloudApi.upsertContract({
          'id': c.id, 
          'clientId': c.clientId, 
          
          // 🌟 السطر الجديد هنا: رفع معرف الشقة للسحابة 🌟
          'apartment_id': c.apartmentId, 
          
          'contractType': c.contractType, 
          'apartmentDetails': c.apartmentDetails, 
          'totalArea': _safeNum(c.totalArea), 
          'baseMeterPriceAtSigning': _safeNum(c.baseMeterPriceAtSigning), 
          'installmentsCount': c.installmentsCount, 
          'coefficients': c.coefficients, 
          'contractDate': c.contractDate.toIso8601String(), 
          'guarantor_name': c.guarantorName,
          'contract_file_url': c.contractFileUrl,
          'userId': c.userId, 
          'isCompleted': c.isCompleted, 
          'isDeleted': c.isDeleted, 
          'updatedAt': c.updatedAt.toIso8601String()
        });
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
    
    // 5. مزامنة أسعار المواد (المعدل ليتوافق مع SQL)
    try {
      final pendingPrices = await (db.select(db.materialPricesHistory)..where((t) => t.isSynced.equals(false))).get();
      for (var p in pendingPrices) {
        await _cloudApi.upsertMaterialPrices({
          'id': p.id, 
          'effective_date': p.effectiveDate.toUtc().toIso8601String(),
          'iron_price': _safeNum(p.ironPrice), 
          'cement_price': _safeNum(p.cementPrice), 
          'block15_price': _safeNum(p.block15Price), 
          'formwork_and_pouring_wages': _safeNum(p.formworkAndPouringWages), 
          'aggregate_materials_price': _safeNum(p.aggregateMaterialsPrice), 
          'ordinary_worker_wage': _safeNum(p.ordinaryWorkerWage), 
          'user_id': p.userId, 
          'is_deleted': p.isDeleted,
          'updated_at': DateTime.now().toIso8601String(), // حقل الوقت الضروري
        });
        await (db.update(db.materialPricesHistory)..where((t) => t.id.equals(p.id))).write(const MaterialPricesHistoryCompanion(isSynced: drift.Value(true)));
      }
    } catch (e) { print('Sync Prices Failed: $e'); }
    
    // 6. مزامنة المحاضر
    try {
      final pendingBuildings = await (db.select(db.buildings)..where((t) => t.isSynced.equals(false))).get();
      for (var b in pendingBuildings) {
        await _cloudApi.upsertBuilding({
          'id': b.id,
          'name': b.name,
          'location': b.location,
          'floor_coefficients': b.floorCoefficients,
          'direction_coefficients': b.directionCoefficients,
          'user_id': b.userId,
          'is_deleted': b.isDeleted,
          'updated_at': b.updatedAt.toIso8601String()
        });
        await (db.update(db.buildings)..where((t) => t.id.equals(b.id))).write(const BuildingsCompanion(isSynced: drift.Value(true)));
      }
    } catch (e) { print('Sync Buildings Failed: $e'); }

    // 7. مزامنة الشقق
    try {
      final pendingApartments = await (db.select(db.apartments)..where((t) => t.isSynced.equals(false))).get();
      for (var a in pendingApartments) {
        await _cloudApi.upsertApartment({
          'id': a.id,
          'building_id': a.buildingId,
          'apartment_number': a.apartmentNumber,
          'area': _safeNum(a.area),
          'floor_name': a.floorName,
          'direction_name': a.directionName,
          'custom_coefficients': a.customCoefficients,
          'status': a.status,
          'user_id': a.userId,
          'is_deleted': a.isDeleted,
          'updated_at': a.updatedAt.toIso8601String()
        });
        await (db.update(db.apartments)..where((t) => t.id.equals(a.id))).write(const ApartmentsCompanion(isSynced: drift.Value(true)));
      }
    } catch (e) { print('Sync Apartments Failed: $e'); }


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

  

  // ==========================================
  // 💰 دفتر الأستاذ (Payments Ledger)
  // ==========================================
  Future<List<PaymentsLedgerData>> getContractLedger(String contractId) => _localApi.getContractLedger(contractId);
  // 🌟 جلب كل الدفعات لغرفة العمليات (الداشبورد)
  Future<List<PaymentsLedgerData>> getAllPayments() => _localApi.getAllPayments();
  // داخل ErpRepository
  Future<void> addLedgerEntry(PaymentsLedgerCompanion entryCompanion) async {
    if (currentUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');
    final companionWithUser = entryCompanion.copyWith(userId: drift.Value(currentUserId!));
    await _localApi.addLedgerEntry(companionWithUser);
    
    if (entryCompanion.scheduleId.present && entryCompanion.scheduleId.value != null) {
      await _localApi.updateScheduleStatus(entryCompanion.scheduleId.value!, 'paid');
    }
    // أضف await هنا 🚨
    await syncPendingData(); 
  }

  // وتأكد من إضافة await في updateScheduleStatus أيضاً
  Future<void> updateScheduleStatus(String scheduleId, String status) async {
    await _localApi.updateScheduleStatus(scheduleId, status);
    await syncPendingData(); // أضف await هنا 🚨
  }

  Future<void> markWhatsAppAsSent(String entryId) async { 
    await _localApi.updateWhatsAppStatus(entryId);
    syncPendingData();
  }

  // ==========================================
  // ⚙️ الإعدادات (Material Prices)
  // ==========================================
  Future<MaterialPricesHistoryData?> getLatestPrices() => _localApi.getLatestPrices();
  Stream<MaterialPricesHistoryData?> watchLatestPrices() => _localApi.watchLatestPrices();
  Future<void> savePrices(MaterialPricesHistoryCompanion pricesCompanion) async {
    final String? safeUserId = currentUserId;
    if (safeUserId == null) throw Exception('يجب تسجيل الدخول أولاً');

    final String newId = const Uuid().v4();

    final companionReadyToSave = pricesCompanion.copyWith(
      id: drift.Value(newId),
      userId: drift.Value(safeUserId),
      isSynced: const drift.Value(false),
    );

    // 1. الحفظ المحلي
    await _localApi.savePrices(companionReadyToSave);
    
    // 2. المزامنة والانتظار 🚨
    await syncPendingData(); 
  }
  Future<List<MaterialPricesHistoryData>> getAllMaterialPricesHistory() => _localApi.getAllMaterialPricesHistory();
  // أضف هذه الدالة في قسم الإعدادات داخل ErpRepository
  Future<void> softDeleteMaterialPrice(String priceId) async {
    final db = _localApi.database;
    // 1. نقوم بتحديث السطر ليصبح محذوفاً محلياً، ونجعله غير متزامن ليتم رفعه للسحابة
    await (db.update(db.materialPricesHistory)..where((t) => t.id.equals(priceId))).write(
      const MaterialPricesHistoryCompanion(
        isDeleted: drift.Value(true),
        isSynced: drift.Value(false), // إجبار محرك المزامنة على رفعه
      )
    );
    
    // 2. تفعيل محرك المزامنة لرفع التعديل للسحابة
    await syncPendingData();
  }

  // ==========================================
  // 🏢 إدارة المحاضر والشقق
  // ==========================================
  Future<List<Building>> getBuildings() => _localApi.getBuildings();
  Future<List<Apartment>> getAllApartments() => _localApi.getAllApartments();

  Future<void> changeApartmentStatus(String apartmentId, String status) async {
    await _localApi.changeApartmentStatus(apartmentId, status);
    await syncPendingData(); // 🌟 تفعيل الرفع السحابي الفوري
  }

  Future<void> addBuilding(BuildingsCompanion building) async {
    if (currentUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');
    final companionWithUser = building.copyWith(userId: drift.Value(currentUserId!));
    await _localApi.addBuilding(companionWithUser);
    await syncPendingData(); // 🌟 تفعيل الرفع السحابي الفوري
  }

  Future<void> addApartment(ApartmentsCompanion apartment) async {
    if (currentUserId == null) throw Exception('يجب تسجيل الدخول أولاً.');
    final companionWithUser = apartment.copyWith(userId: drift.Value(currentUserId!));
    await _localApi.addApartment(companionWithUser);
    await syncPendingData(); // 🌟 تفعيل الرفع السحابي الفوري
  }
  
  // ==========================================
  // 📡 محرك الاستماع السحابي الحي (Realtime Sync)
  // ==========================================
  void startListeningToCloudChanges() {
    _pricesChannel?.unsubscribe();

    _pricesChannel = Supabase.instance.client
        .channel('public:material_prices')
        .onPostgresChanges(
          event: PostgresChangeEvent.all, 
          schema: 'public',
          table: 'material_prices',
          callback: (payload) {
            print('🔥 السحابة تقول: تم تغيير الأسعار! جاري التحديث التلقائي...');
            pullDataFromCloud(); 
          },
        )
        .subscribe();
  }

  // ==========================================
  // 📎 إرفاق ملف Word للعقد (تحديث العقد)
  // ==========================================
  Future<void> attachFileToContract(String contractId, File file, String extension) async {
    try {
      print('🚀 [1] بدأ رفع الملف للعقد: $contractId');
      
      // 1. رفع الملف إلى السحابة وجلب الرابط
      final fileUrl = await _cloudApi.uploadContractFile(
        contractId: contractId, 
        file: file, 
        extension: extension
      );
      print('✅ [2] تم رفع الملف بنجاح! الرابط: $fileUrl');

      // 2. تحديث العقد محلياً ليحتوي على هذا الرابط
      final db = _localApi.database;
      await (db.update(db.contracts)..where((t) => t.id.equals(contractId))).write(
        ContractsCompanion(
          contractFileUrl: drift.Value(fileUrl),
          updatedAt: drift.Value(DateTime.now()),
          isSynced: const drift.Value(false), // إجبار المزامنة
        )
      );
      print('✅ [3] تم حفظ الرابط في قاعدة البيانات المحلية (Drift).');

      // 3. دفع التعديل الجديد للسحابة
      print('⏳ [4] جاري مزامنة التعديل مع جدول Supabase...');
      await syncPendingData();
      print('✅ [5] تمت المزامنة بنجاح وانتهت العملية.');

    } catch (e, stacktrace) {
      // 🚨 هذا سيمسك أي خطأ صامت ويطبعه لك!
      print('❌❌ خطأ فادح أثناء إرفاق الملف: $e');
      print('🔍 التفاصيل: $stacktrace');
      throw Exception('فشل الإرفاق: $e'); // لإجبار الـ UI على إظهار الخطأ
    }
  }

} 
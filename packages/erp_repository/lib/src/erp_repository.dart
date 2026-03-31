import 'package:local_storage_api/local_storage_api.dart';
import 'package:cloud_storage_api/cloud_storage_api.dart';
import 'package:drift/drift.dart' as drift;

/// المدير الذكي بنظام (Offline-First) والمزامنة الشبحية في الخلفية
class ErpRepository {
  ErpRepository({
    required LocalStorageApi localStorageApi,
    required CloudStorageClient cloudStorageClient,
  })  : _localApi = localStorageApi,
        _cloudApi = cloudStorageClient;

  final LocalStorageApi _localApi;
  final CloudStorageClient _cloudApi;

  bool _isSyncing = false;

  // 🌟 مستخدم وهمي مؤقت لربطه بالعمليات (لتسهيل التدقيق المالي لاحقاً)
  final String _currentUserId = 'admin_001';

  // ==========================================
  // 🔄 محرك المزامنة الشبحي (Background Sync Engine)
  // ==========================================
  Future<void> syncPendingData() async {
    if (_isSyncing) return;
    _isSyncing = true;
    
    try {
      final db = _localApi.database;

      // 1. مزامنة العملاء
      final pendingClients = await (db.select(db.clients)..where((t) => t.isSynced.equals(false))).get();
      for (var c in pendingClients) {
        await _cloudApi.upsertClient({
          'id': c.id, 'name': c.name, 'phone': c.phone, 'nationalId': c.nationalId,
          'userId': c.userId, // 🌟 رفع معرف المستخدم للسحابة
          'isDeleted': c.isDeleted, 'updatedAt': c.updatedAt.toIso8601String(),
        });
        // 🌟 التصحيح هنا: حذفنا كلمة drift. من ClientsCompanion
        await (db.update(db.clients)..where((t) => t.id.equals(c.id))).write(const ClientsCompanion(isSynced: drift.Value(true)));
      }

      // 2. مزامنة العقود
      final pendingContracts = await (db.select(db.contracts)..where((t) => t.isSynced.equals(false))).get();
      for (var c in pendingContracts) {
        await _cloudApi.upsertContract({
          'id': c.id, 'clientId': c.clientId, 'contractType': c.contractType,
          'apartmentDetails': c.apartmentDetails, 'totalArea': c.totalArea,
          'baseMeterPriceAtSigning': c.baseMeterPriceAtSigning, 'installmentsCount': c.installmentsCount,
          'coefficients': c.coefficients, 'contractDate': c.contractDate.toIso8601String(),
          'userId': c.userId, // 🌟 رفع معرف المستخدم للسحابة
          'isCompleted': c.isCompleted, 'isDeleted': c.isDeleted, 'updatedAt': c.updatedAt.toIso8601String(),
        });
        // 🌟 التصحيح هنا: حذفنا كلمة drift.
        await (db.update(db.contracts)..where((t) => t.id.equals(c.id))).write(const ContractsCompanion(isSynced: drift.Value(true)));
      }

      // 3. مزامنة جدول الاستحقاقات
      final pendingSchedules = await (db.select(db.installmentsSchedule)..where((t) => t.isSynced.equals(false))).get();
      if (pendingSchedules.isNotEmpty) {
        final cloudSchedules = pendingSchedules.map((s) => {
          'id': s.id, 'contractId': s.contractId, 'installmentNumber': s.installmentNumber,
          'dueDate': s.dueDate.toIso8601String(), 'status': s.status,
          'userId': s.userId, // 🌟 رفع معرف المستخدم للسحابة
          'isDeleted': s.isDeleted, 'updatedAt': s.updatedAt.toIso8601String(),
        }).toList();
        
        await _cloudApi.upsertSchedule(cloudSchedules); 
        for (var s in pendingSchedules) {
          // 🌟 التصحيح هنا: حذفنا كلمة drift.
          await (db.update(db.installmentsSchedule)..where((t) => t.id.equals(s.id))).write(const InstallmentsScheduleCompanion(isSynced: drift.Value(true)));
        }
      }

      // 4. مزامنة دفتر الأستاذ
      final pendingPayments = await (db.select(db.paymentsLedger)..where((t) => t.isSynced.equals(false))).get();
      for (var p in pendingPayments) {
        await _cloudApi.upsertPayment({
          'id': p.id, 'contractId': p.contractId, 'scheduleId': p.scheduleId,
          'paymentDate': p.paymentDate.toIso8601String(), 'amountPaid': p.amountPaid,
          'meterPriceAtPayment': p.meterPriceAtPayment, 'convertedMeters': p.convertedMeters,
          'fees': p.fees, 'isWhatsAppSent': p.isWhatsAppSent,
          'userId': p.userId, // 🌟 رفع معرف المستخدم للسحابة
          'isDeleted': p.isDeleted, 'updatedAt': p.updatedAt.toIso8601String(),
        });
        // 🌟 التصحيح هنا: حذفنا كلمة drift.
        await (db.update(db.paymentsLedger)..where((t) => t.id.equals(p.id))).write(const PaymentsLedgerCompanion(isSynced: drift.Value(true)));
      }
      
    } catch (e) {
      print('Background Sync Failed (Silently): $e');
    } finally {
      _isSyncing = false; 
    }
  }

  // ==========================================
  // 👥 العملاء (Clients)
  // ==========================================
  Future<List<Client>> getClients() => _localApi.getClients();

  Future<void> addClient(ClientsCompanion clientCompanion) async {
    // 🌟 حقن معرّف المستخدم، ثم الحفظ المحلي السريع جداً
    final companionWithUser = clientCompanion.copyWith(userId: drift.Value(_currentUserId));
    await _localApi.addClient(companionWithUser); 
    
    // 🌟 استدعاء المزامنة في الخلفية (تم حذف كود الرفع المباشر للسحابة من هنا)
    syncPendingData(); 
  }

  Future<void> deleteClient(String clientId) async { // String
    await _localApi.deleteClient(clientId);
    syncPendingData(); 
  }

  // ==========================================
  // 📄 العقود (Contracts)
  // ==========================================
  Future<List<Contract>> getAllContracts() => _localApi.getAllContracts();

  Future<void> addContract(ContractsCompanion contractCompanion) async {
    // 🌟 حقن معرّف المستخدم
    final companionWithUser = contractCompanion.copyWith(userId: drift.Value(_currentUserId));
    
    // 1. حفظ العقد محلياً بسرعة فائقة
    final localId = await _localApi.addContract(companionWithUser);
    
    // 🌟 3. السحر المالي: الجدولة الآلية للأقساط بناءً على عدد الأشهر
    final int months = contractCompanion.installmentsCount.present ? contractCompanion.installmentsCount.value : 48;
    final DateTime startDate = contractCompanion.contractDate.present ? contractCompanion.contractDate.value : DateTime.now();
    
    for (int i = 1; i <= months; i++) {
      final dueDate = DateTime(startDate.year, startDate.month + i, startDate.day);
      
      final entry = InstallmentsScheduleCompanion.insert(
        contractId: localId,
        installmentNumber: i,
        dueDate: dueDate,
        status: const drift.Value('pending'),
        userId: _currentUserId, // 🌟 إسناد معرف المستخدم للقسط المجدول
      );

      // إضافة القسط محلياً
      await _localApi.addScheduleEntry(entry);
    }

    // أمر المزامنة الشبحية (تم حذف كود الرفع المباشر)
    syncPendingData();
  }

  Future<void> deleteContract(String contractId) async {
    await _localApi.deleteContract(contractId);
    syncPendingData();
  }

  // ==========================================
  // 💰 دفتر الأستاذ (Payments Ledger)
  // ==========================================
  Future<List<PaymentsLedgerData>> getContractLedger(String contractId) => _localApi.getContractLedger(contractId); // String

  Future<void> addLedgerEntry(PaymentsLedgerCompanion entryCompanion) async {
    // 🌟 حقن معرّف المستخدم
    final companionWithUser = entryCompanion.copyWith(userId: drift.Value(_currentUserId));
    await _localApi.addLedgerEntry(companionWithUser); 
    
    // إغلاق القسط آلياً إذا جاء من صفحة المراقبة
    if (entryCompanion.scheduleId.present && entryCompanion.scheduleId.value != null) {
      await _localApi.updateScheduleStatus(entryCompanion.scheduleId.value!, 'paid');
    }
    
    syncPendingData();
  }

  Future<void> markWhatsAppAsSent(String entryId) async { // String
    await _localApi.updateWhatsAppStatus(entryId);
    syncPendingData();
  }

  // ==========================================
  // ⚙️ الإعدادات (سجل أسعار المواد)
  // ==========================================
  Future<MaterialPricesHistoryData?> getLatestPrices() => _localApi.getLatestPrices();

  Future<void> savePrices(MaterialPricesHistoryCompanion pricesCompanion) async {
    // 🌟 حقن معرّف المستخدم
    final companionWithUser = pricesCompanion.copyWith(userId: drift.Value(_currentUserId));
    await _localApi.savePrices(companionWithUser);
    syncPendingData(); // يمكن مزامنة الأسعار أيضاً إذا احتجنا
  }

  // ==========================================
  // 📅 جدول الاستحقاقات (Installments Schedule)
  // ==========================================
  Future<List<InstallmentsScheduleData>> getContractSchedule(String contractId) => 
      _localApi.getContractSchedule(contractId);

  // دالة لتحديث حالة القسط (مثلاً من pending إلى paid)
  Future<void> updateScheduleStatus(String scheduleId, String status) async {
    await _localApi.updateScheduleStatus(scheduleId, status);
    syncPendingData();
  }
}
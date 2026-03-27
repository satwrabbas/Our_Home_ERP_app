import 'package:local_storage_api/local_storage_api.dart';
import 'package:cloud_storage_api/cloud_storage_api.dart';
import 'package:drift/drift.dart' show Value; // 🌟 هذا هو السطر الجديد
import 'package:drift/drift.dart' as drift;

class ErpRepository {
  const ErpRepository({
    required LocalStorageApi localStorageApi,
    required CloudStorageClient cloudStorageClient,
  })  : _localApi = localStorageApi,
        _cloudApi = cloudStorageClient;

  final LocalStorageApi _localApi;
  final CloudStorageClient _cloudApi;

  // ==========================================
  // 👥 العملاء (Clients)
  // ==========================================
  Future<List<Client>> getClients() => _localApi.getClients();

  Future<void> addClient(ClientsCompanion clientCompanion) async {
    final localId = await _localApi.addClient(clientCompanion); // localId هنا هو String
    try {
      final cloudData = {
        'id': localId,
        'name': clientCompanion.name.value,
        'phone': clientCompanion.phone.value,
        'nationalId': clientCompanion.nationalId.present ? clientCompanion.nationalId.value : null,
        'isDeleted': false,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await _cloudApi.upsertClient(cloudData);
    } catch (e) {
      print('Cloud sync failed for Client: $e');
    }
  }

  Future<void> deleteClient(String clientId) async { // String
    await _localApi.deleteClient(clientId);
    try {
      await _cloudApi.upsertClient({'id': clientId, 'isDeleted': true, 'updatedAt': DateTime.now().toIso8601String()});
    } catch (e) {
      print('Cloud sync failed for Delete Client: $e');
    }
  }

  // ==========================================
  // 📄 العقود (Contracts)
  // ==========================================
  Future<List<Contract>> getAllContracts() => _localApi.getAllContracts();

  Future<void> addContract(ContractsCompanion contractCompanion) async {
    // 1. حفظ العقد محلياً
    final localId = await _localApi.addContract(contractCompanion);
    
    // 2. إرسال العقد للسحابة
    try {
      final cloudData = {
        'id': localId,
        'clientId': contractCompanion.clientId.value,
        'contractType': contractCompanion.contractType.present ? contractCompanion.contractType.value : 'لاحق التخصص',
        'apartmentDetails': contractCompanion.apartmentDetails.value,
        'totalArea': contractCompanion.totalArea.value,
        'baseMeterPriceAtSigning': contractCompanion.baseMeterPriceAtSigning.value,
        'installmentsCount': contractCompanion.installmentsCount.present ? contractCompanion.installmentsCount.value : 48,
        'coefficients': contractCompanion.coefficients.present ? contractCompanion.coefficients.value : '{}',
        'contractDate': contractCompanion.contractDate.present ? contractCompanion.contractDate.value.toIso8601String() : DateTime.now().toIso8601String(),
        'isCompleted': contractCompanion.isCompleted.present ? contractCompanion.isCompleted.value : false,
        'isDeleted': false,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await _cloudApi.upsertContract(cloudData);
    } catch (e) {
      print('Cloud sync failed for Contract: $e');
    }

    // 🌟 3. السحر المالي: الجدولة الآلية للأقساط بناءً على عدد الأشهر
    final int months = contractCompanion.installmentsCount.present ? contractCompanion.installmentsCount.value : 48;
    final DateTime startDate = contractCompanion.contractDate.present ? contractCompanion.contractDate.value : DateTime.now();
    
    List<Map<String, dynamic>> cloudSchedules = [];

    for (int i = 1; i <= months; i++) {
      final dueDate = DateTime(startDate.year, startDate.month + i, startDate.day);
      
      final entry = InstallmentsScheduleCompanion.insert(
        contractId: localId,
        installmentNumber: i,
        dueDate: dueDate,
        status: const drift.Value('pending'),
      );

      // إضافة القسط محلياً
      final scheduleId = await _localApi.addScheduleEntry(entry);
      
      // تجهيز القسط لإرساله للسحابة
      cloudSchedules.add({
        'id': scheduleId,
        'contractId': localId,
        'installmentNumber': i,
        'dueDate': dueDate.toIso8601String(),
        'status': 'pending',
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }

    // 4. إرسال جدول الاستحقاقات بالكامل (كل الأشهر) إلى السحابة في طلب واحد
    try {
      await _cloudApi.upsertSchedule(cloudSchedules);
    } catch(e) {
      print('Cloud sync failed for Installments Schedule: $e');
    }
  }

  Future<void> deleteContract(String contractId) async {
    await _localApi.deleteContract(contractId);
    try {
      await _cloudApi.upsertContract({
        'id': contractId, 
        'isDeleted': true, 
        'updatedAt': DateTime.now().toIso8601String()
      });
    } catch (e) {
      print('Cloud sync failed for Delete Contract: $e');
    }
  }

  // ==========================================
  // 💰 دفتر الأستاذ (Payments Ledger)
  // ==========================================
  Future<List<PaymentsLedgerData>> getContractLedger(String contractId) => _localApi.getContractLedger(contractId); // String

  Future<void> addLedgerEntry(PaymentsLedgerCompanion entryCompanion) async {
    final localId = await _localApi.addLedgerEntry(entryCompanion); // String
    try {
      final cloudData = {
        'id': localId,
        'contractId': entryCompanion.contractId.value,
        'scheduleId': entryCompanion.scheduleId.present ? entryCompanion.scheduleId.value : null,
        'paymentDate': entryCompanion.paymentDate.present ? entryCompanion.paymentDate.value.toIso8601String() : DateTime.now().toIso8601String(),
        'amountPaid': entryCompanion.amountPaid.value,
        'meterPriceAtPayment': entryCompanion.meterPriceAtPayment.value,
        'convertedMeters': entryCompanion.convertedMeters.value,
        'fees': entryCompanion.fees.present ? entryCompanion.fees.value : 0.0,
        'isWhatsAppSent': entryCompanion.isWhatsAppSent.present ? entryCompanion.isWhatsAppSent.value : false,
        'isDeleted': false,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await _cloudApi.upsertPayment(cloudData);
    } catch (e) {
      print('Cloud sync failed for Ledger Entry: $e');
    }
  }

  Future<void> markWhatsAppAsSent(String entryId) async { // String
    await _localApi.updateWhatsAppStatus(entryId);
    try {
      await _cloudApi.upsertPayment({'id': entryId, 'isWhatsAppSent': true, 'updatedAt': DateTime.now().toIso8601String()});
    } catch (e) {
      print('Cloud sync failed for WhatsApp Status: $e');
    }
  }

  // ==========================================
  // ⚙️ الإعدادات (سجل أسعار المواد)
  // ==========================================
  Future<MaterialPricesHistoryData?> getLatestPrices() => _localApi.getLatestPrices();

  Future<void> savePrices(MaterialPricesHistoryCompanion pricesCompanion) async {
    await _localApi.savePrices(pricesCompanion);

  }

  // ==========================================
  // 📅 جدول الاستحقاقات (Installments Schedule)
  // ==========================================
  Future<List<InstallmentsScheduleData>> getContractSchedule(String contractId) => 
      _localApi.getContractSchedule(contractId);

  // دالة لتحديث حالة القسط (مثلاً من pending إلى paid)
  Future<void> updateScheduleStatus(String scheduleId, String status) async {
    await _localApi.updateScheduleStatus(scheduleId, status);
    try {
      await _cloudApi.upsertSchedule([{
        'id': scheduleId,
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      }]);
    } catch(e) {
      print('Cloud sync failed for Schedule Status: $e');
    }
  }
}
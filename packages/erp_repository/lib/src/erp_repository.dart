import 'package:local_storage_api/local_storage_api.dart';
import 'package:cloud_storage_api/cloud_storage_api.dart';

/// المدير الذكي الذي يربط بين قاعدة البيانات المحلية (Drift) والسحابية (Supabase)
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
    final localId = await _localApi.addClient(clientCompanion);
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

  Future<void> deleteClient(int clientId) async {
    await _localApi.deleteClient(clientId);
    try {
      await _cloudApi.upsertClient({'id': clientId, 'isDeleted': true, 'updatedAt': DateTime.now().toIso8601String()});
    } catch (e) {
      print('Cloud sync failed for Delete Client: $e');
    }
  }

  // ==========================================
  // 📄 العقود (Contracts) - ثوابت الاتفاق
  // ==========================================
  Future<List<Contract>> getAllContracts() => _localApi.getAllContracts();

  Future<void> addContract(ContractsCompanion contractCompanion) async {
    final localId = await _localApi.addContract(contractCompanion);
    try {
      final cloudData = {
        'id': localId,
        'clientId': contractCompanion.clientId.value,
        'apartmentDetails': contractCompanion.apartmentDetails.value,
        'totalArea': contractCompanion.totalArea.value,
        'baseMeterPriceAtSigning': contractCompanion.baseMeterPriceAtSigning.value,
        'coefficients': contractCompanion.coefficients.present ? contractCompanion.coefficients.value : '{}',
        'contractDate': contractCompanion.contractDate.value.toIso8601String(),
        'isCompleted': contractCompanion.isCompleted.present ? contractCompanion.isCompleted.value : false,
        'isDeleted': false,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await _cloudApi.upsertContract(cloudData);
    } catch (e) {
      print('Cloud sync failed for Contract: $e');
    }
  }

  // ==========================================
  // 💰 دفتر الأستاذ (Payments Ledger) - الأمتار المحولة
  // ==========================================
  Future<List<PaymentsLedgerData>> getContractLedger(int contractId) => _localApi.getContractLedger(contractId);

  Future<void> addLedgerEntry(PaymentsLedgerCompanion entryCompanion) async {
    final localId = await _localApi.addLedgerEntry(entryCompanion);
    try {
      final cloudData = {
        'id': localId,
        'contractId': entryCompanion.contractId.value,
        // scheduleId قد يكون فارغاً إذا كان دفعاً غير مجدول
        'scheduleId': entryCompanion.scheduleId.present ? entryCompanion.scheduleId.value : null,
        'paymentDate': entryCompanion.paymentDate.value.toIso8601String(),
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

  Future<void> markWhatsAppAsSent(int entryId) async {
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
    // (يمكن إضافة دالة للرفع السحابي في CloudStorageClient لاحقاً إذا أردت مزامنة الأسعار)
  }
}
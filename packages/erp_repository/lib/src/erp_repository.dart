import 'package:drift/drift.dart' as drift;
import 'package:local_storage_api/local_storage_api.dart';
import 'package:cloud_storage_api/cloud_storage_api.dart';

/// المدير الذكي الذي يربط بين قاعدة البيانات المحلية (Offline) والسحابية (Online)
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
  
  /// جلب العملاء دائماً من القاعدة المحلية لضمان السرعة القصوى
  Future<List<Client>> getClients() => _localApi.getClients();

  /// إضافة عميل (Offline First)
  Future<void> addClient(ClientsCompanion clientCompanion) async {
    // 1. الحفظ المحلي فوراً (الـ UI سيستجيب هنا وتختفي شاشة التحميل)
    final localId = await _localApi.addClient(clientCompanion);

    // 2. المحاولة في الخلفية للرفع على السحابة
    try {
      final cloudData = {
        'id': localId,
        'name': clientCompanion.name.value,
        'phone': clientCompanion.phone.value,
        'nationalId': clientCompanion.nationalId.value,
      };
      await _cloudApi.upsertClient(cloudData);
    } catch (e) {
      // إذا انقطع الإنترنت، سيتم التجاهل حالياً (البيانات بأمان في المحلي)
      print('Cloud sync failed for Client: $e');
    }
  }

  // ==========================================
  // 📄 العقود والشقق (Contracts)
  // ==========================================
  
  Future<List<Contract>> getClientContracts(int clientId) => 
      _localApi.getClientContracts(clientId);

  Future<void> addContract(ContractsCompanion contractCompanion) async {
    final localId = await _localApi.addContract(contractCompanion);

    try {
      final cloudData = {
        'id': localId,
        'clientId': contractCompanion.clientId.value,
        'apartmentDescription': contractCompanion.apartmentDescription.value,
        'apartmentArea': contractCompanion.apartmentArea.value,
        'pricePerSqmAtSigning': contractCompanion.pricePerSqmAtSigning.value,
        'totalContractValue': contractCompanion.totalContractValue.value,
        'monthlyInstallment': contractCompanion.monthlyInstallment.value,
        'signatureDate': contractCompanion.signatureDate.value.toIso8601String(),
        // ✅ الحل السحري: إذا لم يكن الحقل موجوداً، اعتبره false بدلاً من Null
        'isCompleted': contractCompanion.isCompleted.present ? contractCompanion.isCompleted.value : false,
      };
      await _cloudApi.upsertContract(cloudData);
    } catch (e) {
      print('Cloud sync failed for Contract: $e');
    }
  }
  Future<List<Contract>> getAllContracts() => _localApi.getAllContracts();

  // ==========================================
  // 💰 الدفعات (الفواتير - Payments)
  // ==========================================

  Future<List<Payment>> getContractPayments(int contractId) => 
      _localApi.getContractPayments(contractId);

  Future<void> addPayment(PaymentsCompanion paymentCompanion) async {
    final localId = await _localApi.addPayment(paymentCompanion);

    try {
      final cloudData = {
        'id': localId,
        'contractId': paymentCompanion.contractId.value,
        'installmentNumber': paymentCompanion.installmentNumber.value,
        'amountPaid': paymentCompanion.amountPaid.value,
        'originalInstallment': paymentCompanion.originalInstallment.value,
        'fees': paymentCompanion.fees.value,
        'paymentDate': paymentCompanion.paymentDate.value.toIso8601String(),
        'isWhatsAppSent': paymentCompanion.isWhatsAppSent.value,
        'isSyncedToCloud': true, // تم الرفع بنجاح
      };
      await _cloudApi.upsertPayment(cloudData);
    } catch (e) {
      print('Cloud sync failed for Payment: $e');
    }
  }

  /// تحديث حالة إرسال الواتساب للفاتورة
  Future<void> markWhatsAppAsSent(int paymentId) async {
    await _localApi.updateWhatsAppStatus(paymentId);
    // يمكننا إضافة كود هنا لتحديث الحالة في السحابة أيضاً لاحقاً
  }

  // ==========================================
  // ⚙️ الإعدادات (أسعار المواد - Material Prices)
  // ==========================================
  Future<MaterialPrice?> getLatestPrices() => _localApi.getLatestPrices();
  
  Future<void> savePrices(MaterialPricesCompanion prices) async {
    await _localApi.savePrices(prices);
    // (يمكننا إضافة الرفع للسحابة هنا لاحقاً)
  }
}
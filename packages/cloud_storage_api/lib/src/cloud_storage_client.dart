import 'package:supabase_flutter/supabase_flutter.dart';

/// واجهة التخاطب مع قاعدة البيانات السحابية Supabase
/// تستقبل وتُرسل البيانات بصيغة Map<String, dynamic> (أي JSON)
class CloudStorageClient {
  // نقوم بحقن SupabaseClient، وإذا لم يُمرر، نستخدم النسخة الافتراضية
  CloudStorageClient({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  // ==========================================
  // العملاء (Clients)
  // ==========================================
  Future<List<Map<String, dynamic>>> getClients() async {
    return await _supabase.from('clients').select();
  }

  Future<void> upsertClient(Map<String, dynamic> clientData) async {
    // دالة upsert تقوم بالإضافة إذا كان جديداً، أو التحديث إذا كان موجوداً مسبقاً
    await _supabase.from('clients').upsert(clientData);
  }

  Future<void> deleteClient(int clientId) async {
    await _supabase.from('clients').delete().eq('id', clientId);
  }

  // ==========================================
  // العقود (Contracts)
  // ==========================================
  Future<List<Map<String, dynamic>>> getContracts() async {
    return await _supabase.from('contracts').select();
  }

  Future<void> upsertContract(Map<String, dynamic> contractData) async {
    await _supabase.from('contracts').upsert(contractData);
  }

  // ==========================================
  // الدفعات والفواتير (Payments)
  // ==========================================
  Future<List<Map<String, dynamic>>> getPayments() async {
    return await _supabase.from('payments').select();
  }

  Future<void> upsertPayment(Map<String, dynamic> paymentData) async {
    await _supabase.from('payments').upsert(paymentData);
  }

  // ==========================================
  // أسعار المواد (Material Prices)
  // ==========================================
  Future<Map<String, dynamic>?> getLatestMaterialPrices() async {
    final response = await _supabase
        .from('material_prices')
        .select()
        .order('lastUpdated', ascending: false) // جلب الأحدث
        .limit(1);
        
    if (response.isNotEmpty) return response.first;
    return null;
  }

  Future<void> updateMaterialPrices(Map<String, dynamic> pricesData) async {
    await _supabase.from('material_prices').insert(pricesData);
  }
}
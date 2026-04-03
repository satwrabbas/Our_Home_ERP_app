//cloud_storage_client.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class CloudStorageClient {
  CloudStorageClient({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  // ==========================================
  // 🔐 المصادقة (Authentication)
  // ==========================================
  String? get currentUserId => _supabase.auth.currentUser?.id;

  Future<void> signIn({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ==========================================
  // 📥 دوال سحب البيانات (PULL from Cloud)
  // ==========================================
  Future<List<Map<String, dynamic>>> getClients() async => await _supabase.from('clients').select();
  
  Future<List<Map<String, dynamic>>> getContracts() async => await _supabase.from('contracts').select();
  
  Future<List<Map<String, dynamic>>> getPayments() async => await _supabase.from('payments').select();
  
  // 🌟 (جديد) جلب جدول الاستحقاقات
  Future<List<Map<String, dynamic>>> getSchedules() async => await _supabase.from('installments_schedule').select();
  
  // 🌟 (جديد) جلب سجل أسعار المواد
  Future<List<Map<String, dynamic>>> getMaterialPrices() async => await _supabase.from('material_prices').select();

  // ==========================================
  // 📤 دوال رفع البيانات (PUSH to Cloud)
  // ==========================================
  Future<void> upsertClient(Map<String, dynamic> clientData) async => await _supabase.from('clients').upsert(clientData);

  Future<void> upsertContract(Map<String, dynamic> contractData) async => await _supabase.from('contracts').upsert(contractData);

  Future<void> upsertPayment(Map<String, dynamic> paymentData) async => await _supabase.from('payments').upsert(paymentData);

  Future<void> upsertSchedule(List<Map<String, dynamic>> scheduleData) async => await _supabase.from('installments_schedule').upsert(scheduleData);

  Future<void> upsertMaterialPrices(Map<String, dynamic> pricesData) async => await _supabase.from('material_prices').upsert(pricesData);
}
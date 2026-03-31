import 'package:supabase_flutter/supabase_flutter.dart';

class CloudStorageClient {
  CloudStorageClient({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  // ==========================================
  // 🔐 المصادقة (Authentication) - القسم الجديد
  // ==========================================
  
  /// جلب مُعرّف المستخدم (UUID) الذي سجل دخوله حالياً
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// دالة تسجيل الدخول بالإيميل وكلمة المرور
  Future<void> signIn({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// دالة تسجيل الخروج
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ==========================================
  // ☁️ دوال قواعد البيانات (كما هي بدون تغيير)
  // ==========================================

  // العملاء
  Future<List<Map<String, dynamic>>> getClients() async => await _supabase.from('clients').select();
  Future<void> upsertClient(Map<String, dynamic> clientData) async => await _supabase.from('clients').upsert(clientData);

  // العقود
  Future<List<Map<String, dynamic>>> getContracts() async => await _supabase.from('contracts').select();
  Future<void> upsertContract(Map<String, dynamic> contractData) async => await _supabase.from('contracts').upsert(contractData);

  // دفتر الأستاذ
  Future<List<Map<String, dynamic>>> getPayments() async => await _supabase.from('payments').select();
  Future<void> upsertPayment(Map<String, dynamic> paymentData) async => await _supabase.from('payments').upsert(paymentData);

  // الإعدادات (سجل الأسعار)
  Future<void> updateMaterialPrices(Map<String, dynamic> pricesData) async => await _supabase.from('material_prices').insert(pricesData);

  // جدول الاستحقاقات
  Future<void> upsertSchedule(List<Map<String, dynamic>> scheduleData) async {
    await _supabase.from('installments_schedule').upsert(scheduleData);
  }
}
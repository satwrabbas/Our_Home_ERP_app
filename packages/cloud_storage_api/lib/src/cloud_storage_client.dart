//cloud_storage_client.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class CloudStorageClient {
  CloudStorageClient({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

    // 🌟 هنا تعريف المتغير الذي كان يسبب الخطأ (يجب أن يكون داخل الكلاس)
  RealtimeChannel? _pricesChannel;
  // ==========================================
  // 🔐 المصادقة (Authentication)
  // ==========================================
  String? get currentUserId => _supabase.auth.currentUser?.id;

  Future<void> signIn({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);

  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _pricesChannel?.unsubscribe();
  }

    // ==========================================
  // 📡 محرك الاستماع السحابي الحي (Realtime Sync)
  // ==========================================
  void startListeningToCloudChanges({required Function() onDataChanged}) {
    print('🎧 جاري بدء الاستماع لقناة Supabase Realtime...');
    
    _pricesChannel?.unsubscribe();

    _pricesChannel = _supabase
        .channel('public:material_prices')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'material_prices',
          callback: (payload) {
            print('🔥 السحابة تتحدث! نوع التغيير: ${payload.eventType}');
            print('📦 البيانات: ${payload.newRecord}');
            
            // هنا نبلغ الـ Repository أن هناك تغييراً
            onDataChanged(); 
          },
        )
        .subscribe((status,[error]) {
           if (status == 'SUBSCRIBED') {
             print('✅ تم الاتصال بقناة Supabase بنجاح، التطبيق الآن يستمع للأسعار الحية.');
           } else {
             print('⚠️ حالة قناة Supabase: $status | خطأ: $error');
           }
        });
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


  // ==========================================
  // 📂 رفع الملفات إلى Supabase Storage
  // ==========================================
  Future<String> uploadContractFile({
    required String contractId, 
    required File file, 
    required String extension
  }) async {
    // 1. تحديد اسم الملف (مثلاً: contract_1234.docx)
    final fileName = 'contract_$contractId.$extension';
    
    // 2. رفع الملف إلى مجلد contracts_files
    await _supabase.storage.from('contracts_files').upload(
      fileName,
      file,
      fileOptions: const FileOptions(upsert: true), // upsert تعني: استبدل الملف إذا كان موجوداً مسبقاً
    );
    
    // 3. الحصول على الرابط العام (Public URL) للملف
    final publicUrl = _supabase.storage.from('contracts_files').getPublicUrl(fileName);
    return publicUrl;
  }
}
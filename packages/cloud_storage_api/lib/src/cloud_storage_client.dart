//cloud_storage_client.dart
import 'dart:io';
import 'package:http/http.dart' as http; // 🌟 استيراد مكتبة HTTP
import 'package:supabase_flutter/supabase_flutter.dart';

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
  // 📂 رفع الملفات إلى Supabase Storage (طريقة التجاوز المباشر HTTP)
  // ==========================================
  Future<String> uploadContractFile({
    required String contractId, 
    required File file, 
    required String extension
  }) async {
    const bucketName = 'erp_contracts'; // المجلد الناجح
    final fileName = 'contract_$contractId.$extension';

    // 1. جلب مفتاح الجلسة الحالي (JWT) للمصادقة
    final session = _supabase.auth.currentSession;
    if (session == null) throw Exception('يجب تسجيل الدخول لرفع الملفات.');
    final jwtToken = session.accessToken;

    // 2. قراءة الملف كبيانات خام (Bytes)
    final bytes = file.readAsBytesSync();

    // 3. تحديد نوع الملف
    String contentType = 'application/octet-stream';
    if (extension == 'pdf') contentType = 'application/pdf';
    if (extension == 'doc' || extension == 'docx') contentType = 'application/msword';

    // 4. 🌟 استخدام الرابط الثابت الذي نجحنا به في الاختبار
    const projectId = 'krdfrdzyfdcqjmnuzads';
    final uploadUrl = Uri.parse('https://$projectId.supabase.co/storage/v1/object/$bucketName/$fileName');

    // 5. إطلاق صاروخ الـ HTTP مباشرة للسيرفر
    final response = await http.post(
      uploadUrl,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': contentType,
        'x-upsert': 'true', // استبدال الملف لو تم رفعه سابقاً
      },
      body: bytes,
    );

    // 6. التحقق من الرد وإرجاع الرابط
    if (response.statusCode == 200) {
      final publicUrl = 'https://$projectId.supabase.co/storage/v1/object/public/$bucketName/$fileName';
      return publicUrl;
    } else {
      throw Exception('فشل الرفع من السيرفر: ${response.statusCode} - ${response.body}');
    }
  }
}
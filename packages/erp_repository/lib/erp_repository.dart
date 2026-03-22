/// حزمة مستودع النظام (ERP)
/// تقوم بتنسيق البيانات بين التخزين المحلي (Drift) والسحابي (Supabase)
library erp_repository;

export 'src/erp_repository.dart';

// نصدر الكائنات المحلية (Models) لكي تستخدمها واجهة المستخدم مباشرة
// دون الحاجة لاستدعاء مكتبة local_storage_api في التطبيق الرئيسي
export 'package:local_storage_api/local_storage_api.dart' show Client, Contract, Payment, MaterialPrice;
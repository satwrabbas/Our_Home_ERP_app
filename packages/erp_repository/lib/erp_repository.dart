/// حزمة مستودع النظام (ERP Repository)
/// تدير تدفق البيانات بين التخزين المحلي (Offline) والسحابي (Online)
library erp_repository;

export 'src/erp_repository.dart';

// 🌟 تصدير الكائنات الأساسية من قاعدة البيانات المحلية لكي تستخدمها واجهة المستخدم مباشرة
export 'package:local_storage_api/local_storage_api.dart' 
    show 
      Client, 
      Contract, 
      PaymentsLedgerData, 
      MaterialPricesHistoryData;
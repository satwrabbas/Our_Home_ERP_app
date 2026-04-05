//bootstrap.dart
import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

// استدعاء الحزم التي بنيناها
import 'package:cloud_storage_api/cloud_storage_api.dart';
import 'package:local_storage_api/local_storage_api.dart';
import 'package:erp_repository/erp_repository.dart';

/// مراقب حالة التطبيق (BlocObserver)
/// يقوم بطباعة أي تغيير في حالة الشاشات أو أي خطأ برمجي لتسهيل اكتشاف الأخطاء
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

/// دالة التشغيل الأساسية (Bootstrap)
/// تستقبل التطبيق (Widget) وتمرر له (ErpRepository) ليكون متاحاً في كل الشاشات
Future<void> bootstrap(FutureOr<Widget> Function(ErpRepository) builder) async {
  // التقاط أخطاء الفلاتر (UI)
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // تشغيل التطبيق في بيئة آمنة لالتقاط أي انهيار (Crash)
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // ==========================================
      // 1. تهيئة قاعدة البيانات السحابية (Supabase)
      // ==========================================
      // TODO: ضع الروابط الخاصة بمشروعك في Supabase هنا
      await Supabase.initialize(
        url: 'https://krdfrdzyfdcqjmnuzads.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtyZGZyZHp5ZmRjcWptbnV6YWRzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ1NTQzOTksImV4cCI6MjA5MDEzMDM5OX0.IzREUxh7vyCE3mBlVj79U6ED8ACOfORGND6YS4yPxgg',
      );

      // ==========================================
      // 2. تهيئة الحزم المحلية والسحابية والمستودع
      // ==========================================
      final cloudStorageClient = CloudStorageClient();
      final localStorageApi = LocalStorageApi();
      
      final erpRepository = ErpRepository(
        localStorageApi: localStorageApi,
        cloudStorageClient: cloudStorageClient,
      );

      // تشغيل واجهة المستخدم وتمرير المستودع لها
      runApp(await builder(erpRepository));
    },
    (error, stackTrace) => log(error.toString(), stackTrace: stackTrace),
  );
}
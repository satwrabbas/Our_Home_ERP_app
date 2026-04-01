import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'package:erp_repository/erp_repository.dart';

// 🌟 استدعاء مكتبة السحابة لكي نفحص الجلسة (Session)
import 'package:cloud_storage_api/cloud_storage_api.dart';

// استدعاء الشاشتين
import '../../login/view/login_page.dart';
import '../../dashboard/view/dashboard_page.dart';

class App extends StatelessWidget {
  const App({
    required this.erpRepository,
    super.key,
  });

  final ErpRepository erpRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: erpRepository,
      child: const AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    
    // ==========================================
    // 🌟 حارس البوابة التلقائي (Auto-Login Gate)
    // ==========================================
    // نسأل Supabase: هل يوجد مستخدم سجل دخوله سابقاً على هذا الكمبيوتر ولم يسجل خروجه؟
    final session = Supabase.instance.client.auth.currentSession;
    final bool isLoggedIn = session != null; // إذا لم تكن null، فهذا يعني أنه مسجل دخول!

    return MaterialApp(
      title: 'Our Home ERP',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const[
        Locale('ar', 'AE'), 
      ],
      locale: const Locale('ar', 'AE'), 
      theme: ThemeData(
        primaryColor: const Color(0xFF13B9FF),
        useMaterial3: true,
        fontFamily: 'Tahoma', 
      ),
      
      // 🌟 التوجيه الذكي (Smart Routing):
      // إذا كان مسجلاً للدخول، افتح لوحة التحكم مباشرة. 
      // إذا لم يكن كذلك، افتح شاشة تسجيل الدخول.
      home: isLoggedIn ? const DashboardPage() : const LoginPage(), 
    );
  }
}
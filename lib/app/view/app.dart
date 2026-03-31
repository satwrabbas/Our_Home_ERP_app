import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'package:erp_repository/erp_repository.dart';

// 🌟 استدعاء كلتا الشاشتين لكي نختار بينهما
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
    // 🌟 السحر هنا: نسأل المستودع هل يمتلك (ID) لمستخدم مسجل دخول حالياً؟
    final repo = context.read<ErpRepository>();
    final bool isLoggedIn = repo.currentUserId != null;

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
      // إذا كان مسجلاً الدخول -> افتح الإحصائيات مباشرة.
      // إذا لم يكن مسجلاً (أو قام بتسجيل الخروج) -> افتح شاشة الدخول.
      home: isLoggedIn ? const DashboardPage() : const LoginPage(), 
    );
  }
}
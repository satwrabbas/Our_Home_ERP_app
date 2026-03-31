import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // دعم العربية
import 'package:erp_repository/erp_repository.dart';

// 🌟 استدعاء شاشة تسجيل الدخول لتكون الواجهة الأولى
import '../../login/view/login_page.dart';

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
    return MaterialApp(
      title: 'Our Home ERP',
      debugShowCheckedModeBanner: false,
      // تفعيل دعم اللغة العربية من اليمين لليسار (RTL)
      localizationsDelegates: const[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const[
        Locale('ar', 'AE'), // اللغة العربية مدعومة
      ],
      locale: const Locale('ar', 'AE'), // إجبار التطبيق على العربية
      theme: ThemeData(
        primaryColor: const Color(0xFF13B9FF),
        useMaterial3: true,
        fontFamily: 'Tahoma', // خط ممتاز للويندوز
      ),
      
      // 🌟 التعديل السحري: الواجهة الأولى هي شاشة تسجيل الدخول!
      home: const LoginPage(), 
    );
  }
}
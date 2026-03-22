import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:our_home_erp_app/contracts/view/contracts_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // مهم جداً لدعم العربية
import 'package:our_home_erp_app/dashboard/view/dashboard_page.dart';

import 'package:our_home_erp_app/contracts/view/contracts_page.dart';
// بدلاً من: import 'package:our_home_erp_app/clients/view/clients_page.dart';

class App extends StatelessWidget {
  const App({
    required this.erpRepository,
    super.key,
  });

  // نستقبل المستودع من ملف main
  final ErpRepository erpRepository;

  @override
  Widget build(BuildContext context) {
    // RepositoryProvider يضمن أن المستودع متاح لجميع شاشات التطبيق
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
      supportedLocales: const [
        Locale('ar', 'AE'), // اللغة العربية مدعومة
      ],
      locale: const Locale('ar', 'AE'), // إجبار التطبيق على العربية
      theme: ThemeData(
        primaryColor: const Color(0xFF13B9FF),
        useMaterial3: true,
        fontFamily: 'Tahoma', // خط ممتاز للويندوز
      ),
      home: const DashboardPage(), // <-- ديدة هنا
    );
  }
}
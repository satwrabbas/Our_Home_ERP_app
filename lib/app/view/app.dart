import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'package:erp_repository/erp_repository.dart';

// 🌟 الاستيرادات بالمسارات النسبية الصحيحة
import '../../auth/cubit/auth_cubit.dart'; 
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
    // 🌟 السحر هنا: توفير Repository و AuthCubit لكامل التطبيق
    return MultiBlocProvider(
      providers:[
        RepositoryProvider.value(value: erpRepository),
        BlocProvider(
          create: (context) => AuthCubit(erpRepository), // سيبدأ بالتحقق تلقائياً عند التشغيل
        ),
      ],
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
      
      // 🌟 التوجيه الذكي المربوط بـ AuthCubit
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          // 1. شاشة تحميل (Splash) أثناء فحص الصلاحيات
          if (state.status == AuthStatus.initial || state.status == AuthStatus.loading) {
            return const Scaffold(
              backgroundColor: Colors.blueGrey,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }
          
          // 2. تم التأكد من الجلسة والصلاحيات -> افتح لوحة التحكم
          if (state.status == AuthStatus.authenticated) {
            return const DashboardPage();
          }

          // 3. غير مسجل دخول أو حدث خطأ -> افتح شاشة تسجيل الدخول
          return const LoginPage();
        },
      ), 
    );
  }
}
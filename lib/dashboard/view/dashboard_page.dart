import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';

// استدعاء الشاشات
import '../../home/view/home_page.dart';
import '../../clients/view/clients_page.dart';
import '../../contracts/view/contracts_page.dart';
import '../../payments/view/payments_page.dart';
import '../../schedule/view/schedule_page.dart';
import '../../settings/view/settings_page.dart';
import '../../login/view/login_page.dart'; // 🌟 شاشة تسجيل الدخول للعودة إليها

// استدعاء المتحكمات
import '../../clients/cubit/clients_cubit.dart';
import '../../contracts/cubit/contracts_cubit.dart';
import '../../payments/cubit/payments_cubit.dart';
import '../../schedule/cubit/schedule_cubit.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../home/cubit/home_cubit.dart';
import '../cubit/dashboard_cubit.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ErpRepository>();
    
    return MultiBlocProvider(
      providers:[
        BlocProvider(create: (_) => DashboardCubit()),
        BlocProvider(create: (_) => HomeCubit(repo)..fetchDashboardData()),
        BlocProvider(create: (_) => ClientsCubit(repo)..fetchClients()),
        BlocProvider(create: (_) => ContractsCubit(repo)..fetchData()),
        BlocProvider(create: (_) => PaymentsCubit(repo)..fetchInitialData()),
        BlocProvider(create: (_) => ScheduleCubit(repo)..fetchInitialData()),
        BlocProvider(create: (_) => SettingsCubit(repo)..fetchPrices()),
      ],
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<DashboardCubit>().state;

    return Scaffold(
      body: Row(
        children:[
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              context.read<DashboardCubit>().changeTab(index);
              
              // التحديث التلقائي الذكي
              if (index == 0) context.read<HomeCubit>().fetchDashboardData();
              if (index == 1) context.read<ClientsCubit>().fetchClients();
              if (index == 2) context.read<ContractsCubit>().fetchData();
              if (index == 3) context.read<PaymentsCubit>().fetchInitialData();
              if (index == 4) context.read<ScheduleCubit>().fetchInitialData();
              if (index == 5) context.read<SettingsCubit>().fetchPrices();
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.blue.shade900,
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
            selectedIconTheme: const IconThemeData(color: Colors.white, size: 30),
            selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            
            destinations: const[
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('الرئيسية')),
              NavigationRailDestination(icon: Icon(Icons.people_alt_outlined), selectedIcon: Icon(Icons.people_alt), label: Text('العملاء')),
              NavigationRailDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description), label: Text('العقود')),
              NavigationRailDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: Text('الأقساط')),
              NavigationRailDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: Text('المراقبة')),
              NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('الإعدادات')),
            ],
            
            // 🌟 تعديل الـ trailing ليحتوي على زرين (المزامنة + تسجيل الخروج)
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      // ☁️ زر المزامنة اليدوية مع السحابة
                      IconButton(
                        icon: const Icon(Icons.sync, color: Colors.greenAccent, size: 28),
                        tooltip: 'مزامنة يدوية مع السحابة (Pull & Push)',
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('جاري المزامنة مع السحابة... ☁️🔄')),
                          );
                          
                          // استدعاء دالة المزامنة الشاملة المضادة للرصاص
                          final resultMessage = await context.read<ErpRepository>().forceSyncWithCloud();
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(resultMessage), 
                                backgroundColor: resultMessage.contains('بنجاح') ? Colors.green : Colors.red,
                              ),
                            );

                            // تحديث الشاشة الحالية فوراً لتعرض البيانات الجديدة المسحوبة
                            if (selectedIndex == 0) context.read<HomeCubit>().fetchDashboardData();
                            if (selectedIndex == 1) context.read<ClientsCubit>().fetchClients();
                            if (selectedIndex == 2) context.read<ContractsCubit>().fetchData();
                            if (selectedIndex == 3) context.read<PaymentsCubit>().fetchInitialData();
                            if (selectedIndex == 4) context.read<ScheduleCubit>().fetchInitialData();
                            if (selectedIndex == 5) context.read<SettingsCubit>().fetchPrices();
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // 🌟 زر تسجيل الخروج في أسفل القائمة الجانبية
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.redAccent, size: 28),
                        tooltip: 'تسجيل الخروج (وإقفال النظام)',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
                              content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟ سيتم إقفال ومسح البيانات المؤقتة من هذا الجهاز لحمايتها.'),
                              actions:[
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                  onPressed: () async {
                                    Navigator.pop(ctx); // إغلاق النافذة
                                    
                                    // 1. تسجيل الخروج ومسح قاعدة البيانات المحلية
                                    await context.read<ErpRepository>().signOut();
                                    
                                    // 2. العودة لشاشة تسجيل الدخول وتدمير لوحة التحكم من الذاكرة
                                    if (context.mounted) {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(builder: (_) => const LoginPage()),
                                      );
                                    }
                                  },
                                  child: const Text('تأكيد الخروج'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const VerticalDivider(thickness: 1, width: 1),
          
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: const[
                HomePage(),     // Index 0
                ClientsPage(),  // Index 1
                ContractsPage(),// Index 2
                PaymentsPage(), // Index 3
                SchedulePage(), // Index 4
                SettingsPage(), // Index 5
              ],
            ),
          ),
        ],
      ),
    );
  }
}
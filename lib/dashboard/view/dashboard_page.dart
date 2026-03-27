import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';

// استدعاء جميع الشاشات
import '../../clients/view/clients_page.dart';
import '../../contracts/view/contracts_page.dart';
import '../../payments/view/payments_page.dart';
import '../../settings/view/settings_page.dart';

// استدعاء جميع المتحكمات (Cubits)
import '../../clients/cubit/clients_cubit.dart';
import '../../contracts/cubit/contracts_cubit.dart';
import '../../payments/cubit/payments_cubit.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../cubit/dashboard_cubit.dart';

import '../../home/view/home_page.dart'; // 🌟 إضافة
import '../../home/cubit/home_cubit.dart'; // 🌟 إضافة

import '../../schedule/view/schedule_page.dart';
import '../../schedule/cubit/schedule_cubit.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<ErpRepository>();
    
    // 🌟 السحر هنا: توفير جميع المتحكمات على مستوى لوحة التحكم لتظل حية وتتحدث مع بعضها
    return MultiBlocProvider(
      providers:[
        BlocProvider(create: (_) => DashboardCubit()),
        BlocProvider(create: (_) => HomeCubit(repo)..fetchDashboardData()), // 🌟 إضافة
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
              // 1. تغيير الشاشة
              context.read<DashboardCubit>().changeTab(index);
              
// يجب تعديل الأرقام لأننا أضفنا شاشة جديدة في البداية
              if (index == 0) context.read<HomeCubit>().fetchDashboardData();
              if (index == 1) context.read<ClientsCubit>().fetchClients();
              if (index == 2) context.read<ContractsCubit>().fetchData();
              if (index == 3) context.read<PaymentsCubit>().fetchInitialData();
              if (index == 4) context.read<ScheduleCubit>().fetchInitialData(); // 🌟 إضافة التحديث
              if (index == 5) context.read<SettingsCubit>().fetchPrices();
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.blue.shade900,
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
            selectedIconTheme: const IconThemeData(color: Colors.white, size: 30),
            selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            destinations: const[
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: Text('الرئيسية')), // 🌟 الشاشة الجديدة
              NavigationRailDestination(icon: Icon(Icons.people_alt_outlined), selectedIcon: Icon(Icons.people_alt), label: Text('العملاء')),
              NavigationRailDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description), label: Text('العقود')),
              NavigationRailDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: Text('الأقساط')),
              NavigationRailDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: Text('المراقبة')), // 🌟 إضافة الزر
              NavigationRailDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: Text('الإعدادات')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: const[
                HomePage(),     // 🌟 أصبحت هي Index 0
                ClientsPage(),  // Index 1
                ContractsPage(),// Index 2
                PaymentsPage(), // Index 3
                SchedulePage(),
                SettingsPage(), // Index 4
              ],
            ),
          ),
        ],
      ),
    );
  }
}
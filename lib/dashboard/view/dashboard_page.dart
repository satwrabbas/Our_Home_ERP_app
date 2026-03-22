import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// استدعاء الشاشات التي بنيناها
import '../../clients/view/clients_page.dart';
import '../../contracts/view/contracts_page.dart';
import '../cubit/dashboard_cubit.dart';
import '../../payments/view/payments_page.dart';
import '../../settings/view/settings_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit(),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // نستمع لرقم الشاشة المحددة من الـ Cubit
    final selectedIndex = context.watch<DashboardCubit>().state;

    return Scaffold(
      body: Row(
        children:[
          // 1. القائمة الجانبية (Sidebar)
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              context.read<DashboardCubit>().changeTab(index);
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.blue.shade900,
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
            selectedIconTheme: const IconThemeData(color: Colors.white, size: 30),
            selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            destinations: const[
              NavigationRailDestination(
                icon: Icon(Icons.people_alt_outlined),
                selectedIcon: Icon(Icons.people_alt),
                label: Text('العملاء'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.description_outlined),
                selectedIcon: Icon(Icons.description),
                label: Text('العقود'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: Text('الأقساط'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('الإعدادات'),
              ),
            ],
          ),
          
          // خط فاصل جمالي
          const VerticalDivider(thickness: 1, width: 1),
          
          // 2. محتوى الشاشة (المساحة المتبقية من الشاشة)
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children:[
                const ClientsPage(),   // Index 0
                const ContractsPage(), // Index 1
                
                const PaymentsPage(),
                
                // Index 3 (مؤقت حتى نبني شاشة الإعدادات وحساب الأسعار)
                const SettingsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
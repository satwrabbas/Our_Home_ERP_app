// lib/schedule/view/schedule_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/schedule_cubit.dart';

// 🌟 استيراد التبويبات المفصولة
import 'tabs/radar_tab.dart';
import 'tabs/traditional_schedule_tab.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScheduleView();
  }
}

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المراقبة والتحليل المالي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.indigo,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.orange,
            indicatorWeight: 4,
            tabs:[
              Tab(icon: Icon(Icons.radar), text: 'رادار التخصص (ذكاء مالي)'),
              Tab(icon: Icon(Icons.table_chart), text: 'جدول الأقساط التقليدي'),
            ],
          ),
        ),
        body: BlocBuilder<ScheduleCubit, ScheduleState>(
          builder: (context, state) {
            if (state.status == ScheduleStatus.loading && state.contracts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.clients.isEmpty || state.contracts.isEmpty) {
              return const Center(child: Text('لا يوجد بيانات كافية.', style: TextStyle(fontSize: 18, color: Colors.grey)));
            }

            return TabBarView(
              children:[
                // 🌟 استدعاء التبويبة الأولى وتمرير الحالة (State) لها
                RadarTab(state: state),
                
                // 🌟 استدعاء التبويبة الثانية وتمرير الحالة (State) لها
                TraditionalScheduleTab(state: state),
              ],
            );
          },
        ),
      ),
    );
  }
}
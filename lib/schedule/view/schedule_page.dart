// lib/schedule/view/schedule_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/schedule_cubit.dart';

import 'tabs/radar_tab.dart';
import 'tabs/traditional_schedule_tab.dart';
import 'tabs/overdue_radar_tab.dart'; 

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
      length: 3, 
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          elevation: 0,
          toolbarHeight: 70, // مساحة مريحة للسطر الواحد
          // 🌟 وضعنا التبويبات في الـ title لدمجهم في سطر واحد احترافي
          title: Container(
            height: 45, 
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15), // خلفية شفافة أنيقة للتبويبات
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              dividerColor: Colors.transparent, // إزالة الخط السفلي الافتراضي
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(25), // مؤشر بشكل زر (Pill)
                boxShadow: const[
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelPadding: EdgeInsets.zero, // لمنع تجاوز النصوص للشاشة
              tabs:[
                _buildCompactTab(Icons.warning_amber_rounded, 'المتعثرين'),
                _buildCompactTab(Icons.radar, 'الرادار'), // تم الاختصار لجمالية السطر الواحد
                _buildCompactTab(Icons.table_chart, 'الجدول'), 
              ],
            ),
          ),
        ),
        body: BlocBuilder<ScheduleCubit, ScheduleState>(
          builder: (context, state) {
            if (state.status == ScheduleStatus.loading && state.contracts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.clients.isEmpty || state.contracts.isEmpty) {
              return const Center(
                child: Text(
                  'لا يوجد بيانات كافية.', 
                  style: TextStyle(fontSize: 18, color: Colors.grey)
                )
              );
            }

            return TabBarView(
              children:[
                OverdueRadarTab(state: state),
                RadarTab(state: state),
                TraditionalScheduleTab(state: state),
              ],
            );
          },
        ),
      ),
    );
  }

  // 🌟 دالة مساعدة لإنشاء التبويبات (أيقونة ونص) في سطر واحد وبشكل متناسق
  Widget _buildCompactTab(IconData icon, String title) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
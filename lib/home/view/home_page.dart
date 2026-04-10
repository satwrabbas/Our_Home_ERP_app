// lib/home/view/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import 'widgets/kpi_section.dart';
import 'widgets/charts_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم الاستراتيجية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading) return const Center(child: CircularProgressIndicator());
          if (state.status == HomeStatus.failure) return const Center(child: Text('حدث خطأ في جلب البيانات'));

          return RefreshIndicator(
            onRefresh: () => context.read<HomeCubit>().fetchDashboardData(),
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                KpiSection(state: state),
                const SizedBox(height: 32),
                ChartsSection(state: state),
                // إذا أردت قسم "آخر الحركات" يمكنك إضافته هنا كـ Widget منفصل لاحقاً
              ],
            ),
          );
        },
      ),
    );
  }
}
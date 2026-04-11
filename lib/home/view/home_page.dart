// lib/home/view/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import 'widgets/kpi_section.dart';
import 'widgets/charts_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // ✅ جلب البيانات فور فتح الصفحة
    context.read<HomeCubit>().fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: CustomScrollView(
        slivers: [
          // ✅ SliverAppBar بتأثير انكماش احترافي
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF1A237E),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(start: 24, bottom: 16),
              title: const Text(
                'لوحة التحكم الاستراتيجية',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF283593)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Opacity(
                  opacity: 0.08,
                  child: Image.asset(
                    'assets/images/grid_pattern.png', // اختياري - تجاهله إن لم يوجد
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                tooltip: 'تحديث البيانات',
                onPressed: () => context.read<HomeCubit>().fetchDashboardData(),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // ✅ المحتوى الرئيسي
          BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.status == HomeStatus.loading) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF1A237E)),
                        SizedBox(height: 16),
                        Text('جارٍ تحميل البيانات...', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }

              if (state.status == HomeStatus.failure) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(
                          state.errorMessage ?? 'حدث خطأ غير متوقع',
                          style: const TextStyle(color: Colors.grey, fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => context.read<HomeCubit>().fetchDashboardData(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('إعادة المحاولة'),
                          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1A237E)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ✅ قسم مؤشرات الأداء
                    KpiSection(state: state),
                    const SizedBox(height: 28),

                    // ✅ قسم المخططات
                    ChartsSection(state: state),
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: CustomScrollView(
        slivers: [
          // ✅ شريط علوي أنيق بمساحة أقل
          SliverAppBar(
            pinned: true,
            floating: false,
            elevation: 0,
            toolbarHeight: 60, // 👈 1. تقليل ارتفاع الشريط من 75 إلى 60
            backgroundColor: const Color(0xFF1A237E),
            
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'لوحة التحكم',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // 👈 تصغير بسيط ليتناسب مع الارتفاع الجديد
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                
                Material(
                  color: Colors.white.withOpacity(0.15),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: () => context.read<HomeCubit>().fetchDashboardData(),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0), // 👈 تقليل مساحة الزر قليلاً
                      child: Icon(
                        Icons.refresh_rounded, 
                        color: Colors.white, 
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            flexibleSpace: FlexibleSpaceBar(
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
                    'assets/images/grid_pattern.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
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
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            minimumSize: const Size(160, 48),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                // 👈 2. تقليل المساحة العلوية لتصبح 16 والسفلية لتصبح 24
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    KpiSection(state: state),
                    
                    // 👈 3. تقليل المساحة الفاصلة بين المؤشرات والمخططات من 28 إلى 20
                    const SizedBox(height: 20), 
                    
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
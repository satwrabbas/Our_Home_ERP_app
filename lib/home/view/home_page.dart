// lib/home/view/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // ستحتاج لإضافة intl: ^0.18.1 في pubspec.yaml
import '../cubit/home_cubit.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم الاستراتيجية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == HomeStatus.failure) {
            return const Center(child: Text('حدث خطأ في جلب البيانات'));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<HomeCubit>().fetchDashboardData(),
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              // داخل ListView في home_page.dart
              children: [
                // 1. قسم المؤشرات الحيوية (KPIs)
                _buildKpiSection(context, state),
                const SizedBox(height: 32),

                // 🌟 2. قسم المخططات البيانية 🌟
                _buildChartsSection(context, state),
                const SizedBox(height: 32),

                // 3. قسم آخر الحركات المالية
                _buildLatestTransactions(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🌟 ويدجت خاصة بقسم المؤشرات الحيوية
  Widget _buildKpiSection(BuildContext context, HomeState state) {
    final numberFormatter = NumberFormat.decimalPattern('ar_AR');

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        KpiCard(
          icon: Icons.attach_money,
          color: Colors.green,
          title: 'إجمالي المبالغ المحصلة',
          value: '${numberFormatter.format(state.totalRevenue.toInt())} ل.س',
        ),
        KpiCard(
          icon: Icons.area_chart,
          color: Colors.blue,
          title: 'إجمالي المساحات المباعة',
          value: '${numberFormatter.format(state.totalAreaSold)} م²',
        ),
        KpiCard(
          icon: Icons.price_check,
          color: Colors.orange,
          title: 'متوسط سعر المتر المباع',
          value: '${numberFormatter.format(state.averageSellPrice.toInt())} ل.س',
        ),
        KpiCard(
          icon: Icons.description,
          color: Colors.purple,
          title: 'عدد العقود الفعالة',
          value: numberFormatter.format(state.activeContractsCount),
        ),
      ],
    );
  }
  
  // 🌟 ويدجت خاصة بآخر الحركات
  Widget _buildLatestTransactions(BuildContext context, HomeState state) {
    final currencyFormatter = NumberFormat.currency(locale: 'ar_SY', symbol: 'ل.س');
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'آخر 5 حركات مالية في الصندوق',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const Divider(height: 24),
            if (state.latestPayments.isEmpty)
              const Center(child: Text('لا توجد أي حركات مالية مسجلة بعد.'))
            else
              ...state.latestPayments.map((payment) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: const Icon(Icons.payment, color: Colors.teal),
                  ),
                  title: Text(
                    'دفعة من العقد #${payment.contractId.split('-').first}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(DateFormat('yyyy/MM/dd – hh:mm a').format(payment.paymentDate)),
                  trailing: Text(
                    currencyFormatter.format(payment.amountPaid),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

// ==========================================
  // 📊 قسم المخططات البيانية
  // ==========================================
  Widget _buildChartsSection(BuildContext context, HomeState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📈 مخطط الإيرادات الشهرية (Bar Chart)
        Expanded(
          flex: 2,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('التدفق النقدي الشهري (للعام الحالي)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxRevenue(state.monthlyRevenue) * 1.2, // ترك مسافة بالأعلى
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem('${NumberFormat.compact().format(rod.toY)} ل.س', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(months[value.toInt() - 1], style: const TextStyle(fontSize: 12)),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 60,
                              getTitlesWidget: (value, meta) {
                                if (value == 0) return const SizedBox.shrink();
                                // اختصار الأرقام الكبيرة (مثلاً 1M بدلاً من 1000000)
                                return Text(NumberFormat.compact().format(value), style: const TextStyle(fontSize: 12, color: Colors.grey));
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                        barGroups: state.monthlyRevenue.entries.map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value,
                                color: Colors.teal,
                                width: 20,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              )
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 24),
        
        // 🥧 المخطط الدائري لتوزيع العقود
        Expanded(
          flex: 1,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('توزيع العقود (حسب النوع)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 300,
                    child: state.contractsByType.isEmpty
                        ? const Center(child: Text('لا توجد عقود بعد'))
                        : PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 50,
                              sections: _generatePieSections(state.contractsByType),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 🛠️ دالة مساعدة لحساب أعلى قيمة للمحور الصادي
  double _getMaxRevenue(Map<int, double> monthlyRevenue) {
    if (monthlyRevenue.isEmpty) return 100000;
    double max = 0;
    for (var val in monthlyRevenue.values) {
      if (val > max) max = val;
    }
    return max == 0 ? 100000 : max;
  }

  // 🛠️ دالة مساعدة لتوليد أجزاء المخطط الدائري
  List<PieChartSectionData> _generatePieSections(Map<String, int> data) {
    final colors = [Colors.blue, Colors.orange, Colors.purple, Colors.green, Colors.red];
    int colorIndex = 0;
    
    return data.entries.map((e) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;
      return PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
        title: '${e.key}\n(${e.value})',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

// 🌟 ويدجت كرت المؤشرات الحيوية (لإعادة الاستخدام)
class KpiCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const KpiCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 250, minHeight: 120),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
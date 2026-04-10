// lib/home/view/widgets/charts_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../cubit/home_cubit.dart';

class ChartsSection extends StatelessWidget {
  final HomeState state;
  const ChartsSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🌟 شريط التحكم بالفلتر الزمني
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('التحليلات الاستراتيجية المتقدمة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
            SegmentedButton<TimeFilter>(
              segments: const [
                ButtonSegment(value: TimeFilter.daily, label: Text('يومي')),
                ButtonSegment(value: TimeFilter.weekly, label: Text('أسبوعي')),
                ButtonSegment(value: TimeFilter.monthly, label: Text('شهري')),
                ButtonSegment(value: TimeFilter.yearly, label: Text('سنوي')),
              ],
              selected: {state.timeFilter},
              onSelectionChanged: (Set<TimeFilter> newSelection) {
                context.read<HomeCubit>().changeTimeFilter(newSelection.first);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 🌟 المخططات البيانية + التفاصيل التحليلية
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📈 التدفق النقدي (أعمدة)
            Expanded(flex: 2, child: _buildRevenueAnalysisCard('التدفق النقدي والتحصيل', state.groupedRevenue, Colors.teal)),
            const SizedBox(width: 16),
            // 📈 تطور الأسعار (خط متصل)
            Expanded(flex: 2, child: _buildPriceTrendAnalysisCard('تطور متوسط سعر المبيع', state.priceTrend)),
          ],
        ),
        const SizedBox(height: 16),
        
        // 🥧 توزيع العقود
        SizedBox(
          width: 500,
          child: _buildContractsAnalysisCard('تحليل محفظة العقود (حسب النوع)', state.contractsByType),
        ),
      ],
    );
  }

  // ===============================================
  // 1. كرت تحليل الإيرادات (التدفق النقدي)
  // ===============================================
  Widget _buildRevenueAnalysisCard(String title, Map<String, double> data, Color color) {
    final currencyFormatter = NumberFormat.compact(locale: 'ar_SY');
    
    // 🧠 التحليل الذكي للبيانات
    String bestPeriod = 'لا يوجد';
    double maxRevenue = 0;
    double totalRevenue = 0;
    
    if (data.isNotEmpty) {
      data.forEach((key, value) {
        totalRevenue += value;
        if (value > maxRevenue) {
          maxRevenue = value;
          bestPeriod = key;
        }
      });
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueGrey)),
            const SizedBox(height: 24),
            SizedBox(
              height: 220, // تقليل الارتفاع قليلاً لإفساح مجال للتفاصيل
              child: data.isEmpty ? const Center(child: Text('لا بيانات متاحة للفترة المحددة')) : BarChart(
                BarChartData(
                  barGroups: data.entries.toList().asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [BarChartRodData(toY: e.value.value, color: color, width: 16, borderRadius: BorderRadius.circular(4))],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(data.keys.elementAt(v.toInt()), style: const TextStyle(fontSize: 10)))),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                )
              ),
            ),
            const Divider(height: 30, thickness: 1),
            // 📊 عرض التفاصيل الذكية
            _buildDetailRow(Icons.star, Colors.amber, 'أعلى فترة تحصيل:', '$bestPeriod (${currencyFormatter.format(maxRevenue)})'),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.functions, Colors.blue, 'إجمالي الإيرادات للفترة:', currencyFormatter.format(totalRevenue)),
          ],
        ),
      ),
    );
  }

  // ===============================================
  // 2. كرت تحليل تطور الأسعار
  // ===============================================
  Widget _buildPriceTrendAnalysisCard(String title, Map<String, double> data) {
    final currencyFormatter = NumberFormat.compact(locale: 'ar_SY');
    
    // 🧠 التحليل الذكي
    String highestPricePeriod = 'لا يوجد';
    double maxPrice = 0;
    
    if (data.isNotEmpty) {
      data.forEach((key, value) {
        if (value > maxPrice) {
          maxPrice = value;
          highestPricePeriod = key;
        }
      });
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueGrey)),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: data.isEmpty ? const Center(child: Text('لا توجد عقود لتتبع أسعارها')) : LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.entries.toList().asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                      isCurved: true, color: Colors.orange, barWidth: 4, dotData: const FlDotData(show: true),
                    )
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                      if(v.toInt() >= 0 && v.toInt() < data.length) return Text(data.keys.elementAt(v.toInt()), style: const TextStyle(fontSize: 10));
                      return const SizedBox.shrink();
                    })),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                )
              ),
            ),
            const Divider(height: 30, thickness: 1),
            // 📊 عرض التفاصيل الذكية
            _buildDetailRow(Icons.trending_up, Colors.orange, 'الفترة الأعلى سعراً للمتر:', '$highestPricePeriod (${currencyFormatter.format(maxPrice)})'),
            const SizedBox(height: 8),
            _buildDetailRow(Icons.analytics, Colors.teal, 'عدد الفترات الزمنية المدروسة:', '${data.length} فترات'),
          ],
        ),
      ),
    );
  }

  // ===============================================
  // 3. كرت تحليل أنواع العقود
  // ===============================================
  Widget _buildContractsAnalysisCard(String title, Map<String, int> data) {
    // 🧠 التحليل الذكي
    String mostPopularType = 'لا يوجد';
    int maxCount = 0;
    int totalContracts = 0;
    
    if (data.isNotEmpty) {
      data.forEach((key, value) {
        totalContracts += value;
        if (value > maxCount) {
          maxCount = value;
          mostPopularType = key;
        }
      });
    }

    final colors = [Colors.blue, Colors.red, Colors.green, Colors.purple];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueGrey)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 200,
                    child: data.isEmpty ? const Center(child: Text('لا توجد عقود بعد')) : PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: data.entries.toList().asMap().entries.map((e) {
                          return PieChartSectionData(
                            color: colors[e.key % colors.length], 
                            value: e.value.value.toDouble(), 
                            title: '${e.value.value}', 
                            radius: 50, 
                            titleStyle: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)
                          );
                        }).toList(),
                      )
                    ),
                  ),
                ),
                // 📊 عرض التفاصيل بجانب المخطط الدائري
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDetailRow(Icons.pie_chart, Colors.purple, 'النوع الأكثر مبيعاً:', '$mostPopularType ($maxCount عقد)'),
                      const SizedBox(height: 12),
                      _buildDetailRow(Icons.format_list_numbered, Colors.blueGrey, 'إجمالي العقود الموقعة:', '$totalContracts عقود'),
                      const SizedBox(height: 12),
                      const Text('مفتاح الألوان:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      ...data.entries.toList().asMap().entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            children: [
                              Container(width: 12, height: 12, color: colors[e.key % colors.length]),
                              const SizedBox(width: 8),
                              Text('${e.value.key} (${((e.value.value / totalContracts) * 100).toStringAsFixed(1)}%)', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🛠️ ويدجت مساعدة لسطور التفاصيل
  Widget _buildDetailRow(IconData icon, Color iconColor, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
      ],
    );
  }
}
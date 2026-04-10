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
            const Text('التحليلات الاستراتيجية', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
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

        // 🌟 المخططات البيانية
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📈 التدفق النقدي (أعمدة)
            Expanded(flex: 2, child: _buildBarChart('التدفق النقدي', state.groupedRevenue, Colors.teal)),
            const SizedBox(width: 16),
            // 📈 تطور الأسعار (خط متصل)
            Expanded(flex: 2, child: _buildLineChart('متوسط سعر المبيع', state.priceTrend)),
          ],
        ),
        const SizedBox(height: 16),
        // 🥧 توزيع العقود
        SizedBox(
          width: 400,
          child: _buildPieChart('توزيع العقود', state.contractsByType),
        ),
      ],
    );
  }

  Widget _buildBarChart(String title, Map<String, double> data, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: data.isEmpty ? const Center(child: Text('لا بيانات')) : BarChart(
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
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(String title, Map<String, double> data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: data.isEmpty ? const Center(child: Text('لا بيانات')) : LineChart(
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
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(String title, Map<String, int> data) {
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.purple];
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: data.isEmpty ? const Center(child: Text('لا بيانات')) : PieChart(
                PieChartData(
                  sections: data.entries.toList().asMap().entries.map((e) {
                    return PieChartSectionData(color: colors[e.key % colors.length], value: e.value.value.toDouble(), title: '${e.value.key}\n${e.value.value}', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold));
                  }).toList(),
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
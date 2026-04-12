//lib\home\view\widgets\charts\revenue_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'chart_colors.dart';
import 'chart_shared_widgets.dart';

class RevenueChart extends StatelessWidget {
  final String title;
  final Map<String, double> data;

  const RevenueChart({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    final axisFormatter = NumberFormat.compact(locale: 'en_US');
    final textFormatter = NumberFormat.currency(locale: 'ar_SY', symbol: 'ل.س');

    String bestPeriod = '—';
    double maxRevenue = 0;
    double totalRevenue = 0;

    for (final e in data.entries) {
      totalRevenue += e.value;
      if (e.value > maxRevenue) {
        maxRevenue = e.value;
        bestPeriod = e.key;
      }
    }

    final maxY = maxRevenue <= 0 ? 1000.0 : maxRevenue * 1.25;
    final yInterval = maxY / 5;

    return ChartCard(
      title: title,
      titleIcon: Icons.account_balance_wallet_rounded,
      iconColor: ChartColors.teal,
      chart: SizedBox(
        height: 230,
        child: data.isEmpty
            ? const EmptyChart()
            : BarChart(
                BarChartData(
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, _, rod, __) {
                        final period = data.keys.elementAt(group.x);
                        return BarTooltipItem(
                          '$period\n',
                          const TextStyle(color: Colors.white70, fontSize: 11),
                          children:[
                            TextSpan(
                              text: textFormatter.format(rod.toY),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  barGroups: data.entries.toList().asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods:[
                        BarChartRodData(
                          toY: e.value.value,
                          width: 14,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          gradient: LinearGradient(
                            colors: [ChartColors.teal.withOpacity(0.7), ChartColors.teal],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, _) {
                          final i = value.toInt();
                          if (i < 0 || i >= data.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              data.keys.elementAt(i),
                              style: const TextStyle(fontSize: 9, color: ChartColors.axisLabel),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 52,
                        interval: yInterval,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == maxY) return const SizedBox.shrink();
                          return Text(
                            axisFormatter.format(value),
                            style: const TextStyle(fontSize: 10, color: ChartColors.axisLabel),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: yInterval,
                    getDrawingHorizontalLine: (_) => const FlLine(color: ChartColors.gridLine, strokeWidth: 1),
                  ),
                ),
                duration: Duration.zero, // 👈 تم إلغاء الأنميشن
              ),
      ),
      footerRows:[
        FooterRow(
          icon: Icons.star_rounded,
          iconColor: Colors.amber,
          label: 'أعلى فترة تحصيل:',
          value: '$bestPeriod (${textFormatter.format(maxRevenue)})',
        ),
        FooterRow(
          icon: Icons.functions_rounded,
          iconColor: ChartColors.teal,
          label: 'الإجمالي:',
          value: textFormatter.format(totalRevenue),
        ),
      ],
    );
  }
}
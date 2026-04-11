import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../cubit/home_cubit.dart';

// استيراد المكونات المقسمة
import 'charts/chart_colors.dart';
import 'charts/chart_shared_widgets.dart';
import 'charts/section_header.dart';
import 'charts/revenue_chart.dart';
import 'charts/trend_line_chart.dart';
import 'charts/contracts_pie_chart.dart';

class ChartsSection extends StatelessWidget {
  final HomeState state;
  const ChartsSection({super.key, required this.state});

  String _getPeriodLabel() {
    final ref = state.referenceDate;
    switch (state.timeFilter) {
      case TimeFilter.daily:
        final start = ref.subtract(const Duration(days: 6));
        return '${DateFormat('MM/dd').format(start)} – ${DateFormat('MM/dd').format(ref)}';
      case TimeFilter.weekly:
        return 'أسابيع: ${DateFormat('MMM yyyy', 'ar').format(ref)}';
      case TimeFilter.monthly:
        return 'أشهر عام ${ref.year}';
      case TimeFilter.yearly:
        return '${ref.year - 4} – ${ref.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        SectionHeader(
          periodLabel: _getPeriodLabel(),
          timeFilter: state.timeFilter,
          onPrevious: cubit.navigatePrevious,
          onNext: cubit.navigateNext,
          onFilterChanged: cubit.changeTimeFilter,
        ),
        const SizedBox(height: 24),

        ChartRow(children:[
          Expanded(
            flex: 2,
            child: RevenueChart(
              title: 'التدفق النقدي والتحصيل',
              data: state.groupedRevenue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: TrendLineChart(
              title: 'تطور متوسط سعر المبيع',
              data: state.priceTrend,
              color: ChartColors.orange,
              icon: Icons.trending_up_rounded,
              peakLabel: 'أعلى فترة سعراً:',
            ),
          ),
        ]),
        const SizedBox(height: 16),

        ChartRow(children:[
          Expanded(
            flex: 1,
            child: ContractsPieChart(
              title: 'محفظة العقود حسب النوع',
              data: state.contractsByType,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: TrendLineChart(
              title: 'تطور التكلفة الخام للبناء',
              data: state.costTrend,
              color: ChartColors.red,
              icon: Icons.warning_amber_rounded,
              peakLabel: 'أعلى فترة تكلفةً:',
              isCost: true,
            ),
          ),
        ]),
      ],
    );
  }
}
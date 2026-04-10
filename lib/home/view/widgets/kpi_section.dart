// lib/home/view/widgets/kpi_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../cubit/home_cubit.dart';

class KpiSection extends StatelessWidget {
  final HomeState state;
  const KpiSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final numberFormatter = NumberFormat.decimalPattern('ar_AR');
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        _KpiCard(icon: Icons.attach_money, color: Colors.green, title: 'إجمالي المحصل', value: '${numberFormatter.format(state.totalRevenue.toInt())} ل.س'),
        _KpiCard(icon: Icons.area_chart, color: Colors.blue, title: 'إجمالي المباع', value: '${numberFormatter.format(state.totalAreaSold)} م²'),
        _KpiCard(icon: Icons.price_check, color: Colors.orange, title: 'متوسط السعر', value: '${numberFormatter.format(state.averageSellPrice.toInt())} ل.س'),
        _KpiCard(icon: Icons.description, color: Colors.purple, title: 'العقود الفعالة', value: numberFormatter.format(state.activeContractsCount)),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon; final Color color; final String title; final String value;
  const _KpiCard({required this.icon, required this.color, required this.title, required this.value});

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
              CircleAvatar(radius: 28, backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 28)),
              const SizedBox(width: 16),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22), overflow: TextOverflow.ellipsis),
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
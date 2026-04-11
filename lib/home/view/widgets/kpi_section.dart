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

    final kpis = [
      _KpiData(
        icon: Icons.account_balance_wallet_rounded,
        gradient: const LinearGradient(colors: [Color(0xFF11998e), Color(0xFF38ef7d)]),
        title: 'إجمالي المحصّل',
        value: '${numberFormatter.format(state.totalRevenue.toInt())} ل.س',
        subtitle: 'إجمالي المدفوعات المسجلة',
        iconBg: const Color(0xFF11998e),
      ),
      _KpiData(
        icon: Icons.square_foot_rounded,
        gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF3949AB)]),
        title: 'إجمالي المباع',
        // ✅ صحيح

        value: '${numberFormatter.format(state.totalAreaSold)} م²',
        subtitle: 'المساحة الكلية للعقود',
        iconBg: const Color(0xFF1A237E),
      ),
      _KpiData(
        icon: Icons.trending_up_rounded,
        gradient: const LinearGradient(colors: [Color(0xFFf7971e), Color(0xFFffd200)]),
        title: 'متوسط سعر المتر',
        value: '${numberFormatter.format(state.averageSellPrice.toInt())} ل.س',
        subtitle: 'متوسط سعر البيع للمتر المربع',
        iconBg: const Color(0xFFf7971e),
      ),
      _KpiData(
        icon: Icons.description_rounded,
        gradient: const LinearGradient(colors: [Color(0xFF7b4397), Color(0xFFdc2430)]),
        title: 'العقود الفعّالة',
        value: numberFormatter.format(state.activeContractsCount),
        subtitle: 'إجمالي العقود المبرمة',
        iconBg: const Color(0xFF7b4397),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // ✅ شبكة تكيّفية: عمودان على الشاشات الصغيرة، أربعة على الكبيرة
        final crossAxisCount = constraints.maxWidth < 700 ? 2 : 4;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) => _KpiCard(data: kpis[index]),
        );
      },
    );
  }
}

// ✅ نموذج بيانات الكرت
class _KpiData {
  final IconData icon;
  final LinearGradient gradient;
  final String title;
  final String value;
  final String subtitle;
  final Color iconBg;

  const _KpiData({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.iconBg,
  });
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: data.gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: data.iconBg.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ✅ الصف العلوي: الأيقونة والعنوان
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    data.title,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(data.icon, color: Colors.white, size: 20),
                ),
              ],
            ),

            // ✅ القيمة الرئيسية
            Text(
              data.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),

            // ✅ الوصف السفلي
            Text(
              data.subtitle,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
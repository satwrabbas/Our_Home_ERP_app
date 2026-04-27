//lib\profile\view\contract_details_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract, Client;
import 'package:url_launcher/url_launcher.dart'; // تأكد من وجود هذه المكتبة لفتح رابط العقد

import '../../dashboard/cubit/dashboard_cubit.dart';
import '../cubit/client_profile_cubit.dart';
// 🌟 استدعاء الكيوبتات للقفز السريع (تأكد من مساراتها في مشروعك)
import '../../payments/cubit/payments_cubit.dart';
import '../../schedule/cubit/schedule_cubit.dart';


String formatWithCommas(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
}

class ContractDetailsPage extends StatelessWidget {
  final Contract contract;
  final Client client;
  final ContractProfileSummary? summary;

  const ContractDetailsPage({
    super.key,
    required this.contract,
    required this.client,
    this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAllocated = contract.contractType == 'متخصص';

    // 🌟 فك تشفير المعاملات بأمان
    Map<String, dynamic> coefficientsMap = {};
    if (contract.coefficients.isNotEmpty && contract.coefficients != '{}') {
      try {
        coefficientsMap = jsonDecode(contract.coefficients);
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('تفاصيل العقد', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: isAllocated ? Colors.amber.shade800 : Colors.blue.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children:[
          // ==========================================
          // 1. بطاقة المعلومات الأساسية
          // ==========================================
          _buildSectionCard(
            title: 'المعلومات الأساسية للعقد',
            icon: Icons.info_outline,
            color: Colors.indigo,
            child: Column(
              children:[
                _buildInfoRow('نوع العقد:', contract.contractType, isBold: true),
                const Divider(),
                _buildInfoRow('تاريخ التوقيع:', '${contract.contractDate.year}/${contract.contractDate.month}/${contract.contractDate.day}'),
                const Divider(),
                _buildInfoRow('المدة الشكلية المسجلة:', '${contract.installmentsCount} أشهر'),
                const Divider(),
                _buildInfoRow('اسم الكفيل:', contract.guarantorName),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ==========================================
          // 2. التفاصيل العقارية (للمتخصص فقط)
          // ==========================================
          if (isAllocated) ...[
            _buildSectionCard(
              title: 'التفاصيل العقارية',
              icon: Icons.apartment,
              color: Colors.amber.shade800,
              child: Column(
                children:[
                  _buildInfoRow('الوصف:', contract.apartmentDetails),
                  const Divider(),
                  _buildInfoRow('المساحة الإجمالية:', '${contract.totalArea.toStringAsFixed(2)} م²'),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ==========================================
          // 3. التحليل المالي (فك تشفير JSON)
          // ==========================================
          _buildSectionCard(
            title: 'التحليل المالي والمعاملات',
            icon: Icons.analytics,
            color: Colors.teal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                _buildInfoRow('المبلغ المطلوب شهرياً:', '${formatWithCommas(contract.agreedMonthlyAmount)} ل.س', isBold: true, valueColor: Colors.teal.shade700),
                const Divider(),
                if (isAllocated) ...[
                  _buildInfoRow('السعر الأساسي لحظة التوقيع:', '${formatWithCommas(contract.baseMeterPriceAtSigning)} ل.س / م²'),
                  const SizedBox(height: 16),
                  const Text('الزيادات والتجهيزات (المعاملات):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 8),
                  if (coefficientsMap.isEmpty)
                    const Text('لا يوجد معاملات إضافية مسجلة.', style: TextStyle(color: Colors.grey, fontSize: 13))
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.teal.shade100)),
                      child: Column(
                        children: coefficientsMap.entries.map((entry) {
                          // تحويل القيمة العشرية إلى نسبة مئوية (0.05 -> 5%)
                          double percentage = (entry.value as num).toDouble() * 100;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:[
                                Text('• ${entry.key}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                Text('${percentage.toStringAsFixed(1)} %', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ] else ...[
                  const Text('لا يوجد معاملات لتسعير المتر (المحفظة الاستثمارية تحسب السعر آلياً لحظة كل دفعة بناءً على أسعار اليوم).', style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5)),
                ]
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ==========================================
          // 4. أزرار الإجراءات السريعة (Quick Actions)
          // ==========================================
          const Text('إجراءات سريعة:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 12),
          Row(
            children:[
              Expanded(
                child: _buildActionButton(
                  icon: Icons.account_balance_wallet,
                  label: 'دفتر الأستاذ',
                  color: Colors.deepOrange,
                  onTap: () {
                    // 1. تحديد العقد في صفحة الدفعات
                    context.read<PaymentsCubit>().selectContract(contract.id);
                    
                    // 2. تغيير التبويب الرئيسي إلى 4 (الأقساط/دفتر الأستاذ)
                    context.read<DashboardCubit>().changeTab(4);
                    
                    // 3. إغلاق الصفحات المنبثقة والعودة للرئيسية
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحويلك لدفتر الأستاذ الخاص بهذا العقد!')));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.radar,
                  label: 'جدول المراقبة',
                  color: Colors.indigo,
                  onTap: () {
                    // 1. تحديد العقد في صفحة المراقبة
                    context.read<ScheduleCubit>().selectContract(contract.id);
                    
                    // 2. تغيير التبويب الرئيسي إلى 5 (الجدولة والمراقبة)
                    context.read<DashboardCubit>().changeTab(5);
                    
                    // 3. إغلاق الصفحات المنبثقة
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحويلك لجدول المراقبة الخاص بهذا العقد!')));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty)
            _buildActionButton(
              icon: Icons.attachment,
              label: 'عرض المرفق (PDF/Word)',
              color: Colors.green.shade700,
              onTap: () async {
                final Uri url = Uri.parse(contract.contractFileUrl!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن فتح الرابط.'), backgroundColor: Colors.red));
                }
              },
            ),
        ],
      ),
    );
  }

  // 🌟 دالة مساعدة لبناء البطاقات
  Widget _buildSectionCard({required String title, required IconData icon, required Color color, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow:[BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: color.withOpacity(0.1))),
            ),
            child: Row(
              children:[
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  // 🌟 دالة مساعدة لصفوف المعلومات
  Widget _buildInfoRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        Expanded(flex: 2, child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14))),
        Expanded(flex: 3, child: Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 14, color: valueColor ?? Colors.black87), textAlign: TextAlign.left)),
      ],
    );
  }

  // 🌟 دالة مساعدة للأزرار السريعة
  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      onPressed: onTap,
    );
  }
}
// lib/schedule/view/tabs/overdue_radar_tab.dart
import 'package:flutter/material.dart';
import '../../cubit/schedule_cubit.dart';
import '../../../core/utils/whatsapp_helper.dart';

class OverdueRadarTab extends StatelessWidget {
  final ScheduleState state;

  const OverdueRadarTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.overdueAlerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            Text('الوضع ممتاز! لا يوجد أي عميل متأخر حالياً.', style: TextStyle(fontSize: 20, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.overdueAlerts.length,
      itemBuilder: (context, index) {
        final alert = state.overdueAlerts[index];
        
        Color borderColor;
        Color bgColor;
        IconData icon;
        String warningTitle;

        // التصميم حسب الخطورة
        if (alert.severity == 'critical') {
          borderColor = Colors.red;
          bgColor = Colors.red.shade50;
          icon = Icons.cancel;
          warningTitle = 'حالة حرجة جداً 🔴';
        } else if (alert.severity == 'warning') {
          borderColor = Colors.orange;
          bgColor = Colors.orange.shade50;
          icon = Icons.warning_amber;
          warningTitle = 'إنذار متقدم 🟠';
        } else {
          borderColor = Colors.amber.shade700;
          bgColor = Colors.amber.shade50;
          icon = Icons.notifications_active;
          warningTitle = 'فترة سماح (تأخير بسيط) 🟡';
        }

        return Card(
          elevation: 5,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor, width: 2),
          ),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: bgColor),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Row(
                      children:[
                        Icon(icon, color: borderColor, size: 28),
                        const SizedBox(width: 8),
                        Text(warningTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: borderColor)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: borderColor, borderRadius: BorderRadius.circular(20)),
                      child: Text('متأخر ${alert.maxDaysOverdue} يوماً', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const Divider(),
                Text('العميل: ${alert.client.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('عقد: ${alert.contract.apartmentDetails} | الهاتف: ${alert.client.phone}', style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 12),
                
                // 🌟 عرض تفاصيل الأقساط المتراكمة
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text('عليه ${alert.overdueSchedules.length} أقساط متراكمة غير مسددة!', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                      const SizedBox(height: 8),
                      // نعرض أول قسط مستحق (أقدم قسط لم يدفع)
                      Text('👈 أقدم قسط مطلوب: القسط رقم (${alert.overdueSchedules.first.installmentNumber})', style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      Text('تاريخ الاستحقاق: ${alert.overdueSchedules.first.dueDate.year}/${alert.overdueSchedules.first.dueDate.month}/${alert.overdueSchedules.first.dueDate.day}'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: borderColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                    icon: const Icon(Icons.chat),
                    label: const Text('إرسال مطالبة عبر واتساب'),
                    onPressed: () async {
                      // 🌟 يرسل مطالبة بناءً على أقدم قسط متأخر
                      final success = await WhatsAppHelper.sendReminderMessage(
                        schedule: alert.overdueSchedules.first,
                        contract: alert.contract,
                        client: alert.client,
                      );

                      if (context.mounted) {
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم فتح الواتساب للمطالبة!'), backgroundColor: Colors.green));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل فتح الواتساب.'), backgroundColor: Colors.red));
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
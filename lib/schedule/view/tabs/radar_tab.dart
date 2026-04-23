// lib/schedule/view/tabs/radar_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/schedule_cubit.dart';

// 🌟 استدعاء النافذة الجديدة
import '../dialogs/take_action_dialog.dart';

class RadarTab extends StatelessWidget {
  final ScheduleState state;
  
  const RadarTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.allocationAlerts.isEmpty) {
      return const Center(
        child: Text('لا يوجد عقود "لاحق التخصص" حالياً لمراقبتها.', style: TextStyle(fontSize: 18, color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.allocationAlerts.length,
      itemBuilder: (context, index) {
        final alert = state.allocationAlerts[index];
        final target = context.read<ScheduleCubit>().targetAllocationMeters;
        
        double progress = alert.accumulatedMeters / target;
        if (progress > 1.0) progress = 1.0;

        Color cardBorderColor;
        Color progressColor;
        IconData urgencyIcon;
        String urgencyText;

        // 🌟 التعامل مع حالة "تم اتخاذ إجراء"
        if (alert.urgencyLevel == 'action_taken') {
          cardBorderColor = Colors.grey.shade400;
          progressColor = Colors.grey;
          urgencyIcon = Icons.done_all;
          urgencyText = 'تم اتخاذ إجراء مؤخراً (في الانتظار)';
        } else if (alert.urgencyLevel == 'high') {
          cardBorderColor = Colors.red;
          progressColor = Colors.redAccent;
          urgencyIcon = Icons.local_fire_department;
          urgencyText = alert.accumulatedMeters >= target 
              ? 'تجاوز نسبة التخصص! يتطلب إجراء فوراً' 
              : 'خطر! سيتخصص خلال ${alert.estimatedMonthsLeft} شهر';
        } else if (alert.urgencyLevel == 'medium') {
          cardBorderColor = Colors.orange;
          progressColor = Colors.orange;
          urgencyIcon = Icons.warning_amber_rounded;
          urgencyText = 'يقترب. متبقي ${alert.estimatedMonthsLeft} أشهر تقريباً';
        } else {
          cardBorderColor = Colors.green;
          progressColor = Colors.green;
          urgencyIcon = Icons.shield;
          urgencyText = alert.estimatedMonthsLeft == 999 
              ? 'لا توجد دفعات حالية (آمن)' 
              : 'آمن. متبقي أكثر من ${alert.estimatedMonthsLeft} أشهر ببطء';
        }

        return Card(
          elevation: alert.urgencyLevel == 'action_taken' ? 1 : 4, // تخفيف الظل للمُسكتة
          margin: const EdgeInsets.only(bottom: 16),
          color: alert.urgencyLevel == 'action_taken' ? Colors.grey.shade50 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: cardBorderColor.withOpacity(0.5), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Text('العميل: ${alert.client.name}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: alert.urgencyLevel == 'action_taken' ? Colors.grey : Colors.black)),
                    Chip(
                      avatar: Icon(urgencyIcon, color: Colors.white, size: 18),
                      label: Text(urgencyText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: progressColor,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('الوصف: ${alert.contract.apartmentDetails}', style: const TextStyle(color: Colors.blueGrey)),
                const Divider(),
                
                // شريط التقدم
                Row(
                  children:[
                    const Text('مستوى التخصص: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade200,
                          color: progressColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${alert.accumulatedMeters.toStringAsFixed(1)} / $target م²', style: TextStyle(fontWeight: FontWeight.bold, color: progressColor)),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 🌟 عرض الملاحظة إذا كان تم اتخاذ إجراء
                if (alert.lastActionNote != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Row(
                          children:[
                            const Icon(Icons.history_edu, color: Colors.teal, size: 18),
                            const SizedBox(width: 6),
                            Text('آخر إجراء (في ${alert.lastActionDate?.year}/${alert.lastActionDate?.month}/${alert.lastActionDate?.day}):', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(alert.lastActionNote!, style: const TextStyle(color: Colors.blueGrey, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ],

                // قسم التحليل والأزرار
                Row(
                  children:[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children:[
                            Column(
                              children:[
                                Icon(Icons.speed, color: alert.urgencyLevel == 'action_taken' ? Colors.grey : Colors.blue),
                                const SizedBox(height: 4),
                                const Text('سرعة الدفع', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                Text('${alert.averageMetersPerMonth.toStringAsFixed(1)} م²/ش', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              children:[
                                Icon(Icons.timelapse, color: alert.urgencyLevel == 'action_taken' ? Colors.grey : Colors.purple),
                                const SizedBox(height: 4),
                                const Text('عمر العقد', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                Text('${DateTime.now().difference(alert.contract.contractDate).inDays ~/ 30} شهر', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              children:[
                                Icon(Icons.flag, color: progressColor),
                                const SizedBox(height: 4),
                                const Text('المتبقي', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                Text(alert.estimatedMonthsLeft == 999 ? 'غير محدد' : '${alert.estimatedMonthsLeft} أشهر', style: TextStyle(fontWeight: FontWeight.bold, color: progressColor)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // 🌟 زر "اتخاذ إجراء" الجديد (يظهر باللون الأخضر إذا لم يتم اتخاذ إجراء، وبالرمادي كتحديث إذا وجد)
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: alert.urgencyLevel == 'action_taken' ? Colors.grey.shade300 : Colors.teal,
                        foregroundColor: alert.urgencyLevel == 'action_taken' ? Colors.black87 : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      ),
                      icon: const Icon(Icons.handshake),
                      label: Text(alert.urgencyLevel == 'action_taken' ? 'تحديث الإجراء' : 'تسجيل إجراء'),
                      onPressed: () => showTakeActionDialog(context, alert.contract),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
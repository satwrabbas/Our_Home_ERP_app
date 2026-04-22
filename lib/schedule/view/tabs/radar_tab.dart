// lib/schedule/view/tabs/radar_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/schedule_cubit.dart';

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
        
        // حساب النسبة المئوية لشريط التقدم
        double progress = alert.accumulatedMeters / target;
        if (progress > 1.0) progress = 1.0;

        // تحديد الألوان حسب الخطورة
        Color cardBorderColor;
        Color progressColor;
        IconData urgencyIcon;
        String urgencyText;

        if (alert.urgencyLevel == 'high') {
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
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
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
                    Text('العميل: ${alert.client.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                
                // شريط التقدم (Progress Bar)
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
                
                // قسم التحليل
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:[
                      Column(
                        children:[
                          const Icon(Icons.speed, color: Colors.blue),
                          const SizedBox(height: 4),
                          const Text('سرعة الدفع', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text('${alert.averageMetersPerMonth.toStringAsFixed(1)} م²/شهر', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children:[
                          const Icon(Icons.timelapse, color: Colors.purple),
                          const SizedBox(height: 4),
                          const Text('عمر العقد', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text('${DateTime.now().difference(alert.contract.contractDate).inDays ~/ 30} شهر', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children:[
                          Icon(Icons.flag, color: progressColor),
                          const SizedBox(height: 4),
                          const Text('المدة المتبقية', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(alert.estimatedMonthsLeft == 999 ? 'غير محدد' : '${alert.estimatedMonthsLeft} أشهر', style: TextStyle(fontWeight: FontWeight.bold, color: progressColor)),
                        ],
                      ),
                    ],
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
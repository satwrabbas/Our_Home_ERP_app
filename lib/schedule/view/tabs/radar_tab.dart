// lib/schedule/view/tabs/radar_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/schedule_cubit.dart';
import '../dialogs/take_action_dialog.dart';

class RadarTab extends StatelessWidget {
  final ScheduleState state;

  const RadarTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.allocationAlerts.isEmpty) {
      return const Center(
        child: Text('لا يوجد عقود "لاحق التخصص" حالياً لمراقبتها.', 
          style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: state.allocationAlerts.length,
      itemBuilder: (context, index) {
        final alert = state.allocationAlerts[index];
        final target = context.read<ScheduleCubit>().targetAllocationMeters;

        double progress = alert.accumulatedMeters / target;
        if (progress > 1.0) progress = 1.0;

        Color cardColor;
        Color progressColor;
        IconData urgencyIcon;
        String urgencyText;

        if (alert.urgencyLevel == 'action_taken') {
          cardColor = Colors.grey;
          progressColor = Colors.grey.shade500;
          urgencyIcon = Icons.done_all;
          urgencyText = 'تم إجراء';
        } else if (alert.urgencyLevel == 'high') {
          cardColor = Colors.redAccent;
          progressColor = Colors.redAccent;
          urgencyIcon = Icons.local_fire_department;
          urgencyText = alert.accumulatedMeters >= target ? 'تجاوز!' : 'خطر (${alert.estimatedMonthsLeft} ش)';
        } else if (alert.urgencyLevel == 'medium') {
          cardColor = Colors.orange;
          progressColor = Colors.orange;
          urgencyIcon = Icons.warning_amber_rounded;
          urgencyText = 'متوسط (${alert.estimatedMonthsLeft} ش)';
        } else {
          cardColor = Colors.green;
          progressColor = Colors.green;
          urgencyIcon = Icons.shield;
          urgencyText = alert.estimatedMonthsLeft == 999 ? 'لا دفعات' : 'آمن (${alert.estimatedMonthsLeft} ش)';
        }

        final bool isActionTaken = alert.urgencyLevel == 'action_taken';

        return Card(
          elevation: isActionTaken ? 0 : 2,
          margin: const EdgeInsets.only(bottom: 8), // 🌟 تقليل المساحة العمودية بين البطاقات
          color: isActionTaken ? Colors.grey.shade50 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // 🌟 حواف أصغر تناسب الديسكتوب
            side: BorderSide(color: isActionTaken ? Colors.grey.shade300 : cardColor.withOpacity(0.4), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // 🌟 تقليل الحشوة العمودية
            child: Row( // 🌟 استخدام Row كحاوية رئيسية بدلاً من Column
              crossAxisAlignment: CrossAxisAlignment.center,
              children:[
                // 🌟 العمود الأول: بيانات العميل والحالة (يأخذ 20% من العرض)
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // للحفاظ على أقل مساحة طولية
                    children:[
                      Row(
                        children:[
                          Flexible(
                            child: Text(
                              alert.client.name,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isActionTaken ? Colors.grey.shade700 : Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // بادج الحالة مصغر بجانب الاسم مباشرة
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: cardColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: cardColor.withOpacity(0.5))),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children:[
                                Icon(urgencyIcon, size: 12, color: cardColor),
                                const SizedBox(width: 4),
                                Text(urgencyText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: cardColor)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.contract.apartmentDetails,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),

                // 🌟 العمود الثاني: شريط التقدم والملاحظات (يأخذ 30% من العرض)
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Row(
                        children:[
                          const Text('التخصص: ', style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                color: progressColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${alert.accumulatedMeters.toStringAsFixed(1)} / $target م²',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: progressColor),
                          ),
                        ],
                      ),
                      // 🌟 دمج الملاحظة كسطر واحد أسفل الشريط مباشرة بدلاً من صندوق كامل
                      if (alert.lastActionNote != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children:[
                            const Icon(Icons.history_edu, size: 12, color: Colors.teal),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'إجراء سابق (${alert.lastActionDate?.year}/${alert.lastActionDate?.month}/${alert.lastActionDate?.day}): ${alert.lastActionNote}',
                                style: const TextStyle(fontSize: 11, color: Colors.teal),
                                maxLines: 1, // 🌟 يمنع التمدد الطولي تماماً
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // 🌟 العمود الثالث: الإحصائيات معروضة أفقياً (يأخذ 30% من العرض)
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:[
                      _buildDesktopMetric(Icons.speed, 'السرعة', '${alert.averageMetersPerMonth.toStringAsFixed(1)} م²/ش', isActionTaken ? Colors.grey : Colors.blue),
                      _buildDesktopMetric(Icons.timelapse, 'العمر', '${DateTime.now().difference(alert.contract.contractDate).inDays ~/ 30} ش', isActionTaken ? Colors.grey : Colors.purple),
                      _buildDesktopMetric(Icons.flag, 'المتبقي', alert.estimatedMonthsLeft == 999 ? '∞' : '${alert.estimatedMonthsLeft} ش', progressColor),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // 🌟 العمود الرابع: الزر بحجم مضغوط وثابت (لا يأخذ مساحة مرنة)
                SizedBox(
                  width: 110, // عرض ثابت للزر
                  height: 36, // ارتفاع مضغوط
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActionTaken ? Colors.grey.shade300 : Colors.teal,
                      foregroundColor: isActionTaken ? Colors.black87 : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: Icon(isActionTaken ? Icons.edit : Icons.handshake, size: 14),
                    label: Text(
                      isActionTaken ? 'تحديث' : 'إجراء',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => showTakeActionDialog(context, alert.contract),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🌟 دالة الإحصائيات محسنة للشاشات العريضة (أفقية بدلاً من عمودية)
  Widget _buildDesktopMetric(IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children:[
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // 🌟 مهم جداً لمنع التمدد الطولي
          children:[
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ],
    );
  }
}
// lib/schedule/view/tabs/radar_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/schedule_cubit.dart';
import '../dialogs/take_action_dialog.dart';

class RadarTab extends StatefulWidget {
  final ScheduleState state;

  const RadarTab({super.key, required this.state});

  @override
  State<RadarTab> createState() => _RadarTabState();
}

class _RadarTabState extends State<RadarTab> {
  // 🌟 متغير حفظ حالة الفلتر الحالي (الافتراضي: عرض الكل)
  String _currentFilter = 'all'; // 'all', 'high', 'medium', 'low', 'action_taken'

  @override
  Widget build(BuildContext context) {
    if (widget.state.allocationAlerts.isEmpty) {
      return const Center(
        child: Text('لا يوجد عقود "لاحق التخصص" حالياً لمراقبتها.', 
          style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    // 🌟 تطبيق الفلترة على القائمة قبل عرضها
    final filteredAlerts = widget.state.allocationAlerts.where((alert) {
      if (_currentFilter == 'all') return true;
      return alert.urgencyLevel == _currentFilter;
    }).toList();

    // 🌟 استخدام Scaffold داخلي لعرض الزر العائم بسهولة
    return Scaffold(
      backgroundColor: Colors.transparent, // لكي لا يغطي على خلفية التبويبة الأصلية
      
      // 🌟 الزر العائم للفلترة
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showFilterBottomSheet,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.filter_alt),
        label: Text(_getFilterName(_currentFilter), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      
      body: Column(
        children:[
          // 🌟 إظهار شريط تنبيه صغير إذا كان هناك فلتر نشط
          if (_currentFilter != 'all')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.indigo.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  const Icon(Icons.info_outline, color: Colors.indigo, size: 16),
                  const SizedBox(width: 8),
                  Text('يتم الآن عرض: ${_getFilterName(_currentFilter)} فقط', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () => setState(() => _currentFilter = 'all'),
                    child: const Text('إلغاء الفلتر', style: TextStyle(color: Colors.red, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),

          Expanded(
            child: filteredAlerts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('لا يوجد نتائج تطابق الفلتر الحالي (${_getFilterName(_currentFilter)})', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12).copyWith(bottom: 80), // ترك مساحة للزر العائم
                    itemCount: filteredAlerts.length,
                    itemBuilder: (context, index) {
                      final alert = filteredAlerts[index];
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
                        margin: const EdgeInsets.only(bottom: 8), 
                        color: isActionTaken ? Colors.grey.shade50 : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), 
                          side: BorderSide(color: isActionTaken ? Colors.grey.shade300 : cardColor.withOpacity(0.4), width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), 
                          child: Row( 
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children:[
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min, 
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
                                              maxLines: 1, 
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

                              SizedBox(
                                width: 110, 
                                height: 36, 
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
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopMetric(IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children:[
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, 
          children:[
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // 🌟 نافذة الفلترة السفلية (Bottom Sheet)
  // ==========================================
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children:[
                  Icon(Icons.filter_list, color: Colors.indigo, size: 28),
                  SizedBox(width: 8),
                  Text('تصفية رادار التخصص', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('اختر مستوى الخطورة الذي تود التركيز عليه:', style: TextStyle(color: Colors.grey)),
              const Divider(height: 32, thickness: 1.5),

              _buildFilterOption('all', '🌐 عرض جميع العقود', Colors.indigo),
              _buildFilterOption('high', '🔴 الحالات الحرجة (تجاوز أو وشيك جداً)', Colors.red),
              _buildFilterOption('medium', '🟠 الحالات المتوسطة (في منتصف الطريق)', Colors.orange),
              _buildFilterOption('low', '🟢 الحالات الآمنة (وتيرة بطيئة)', Colors.green),
              _buildFilterOption('action_taken', '⚪ تم اتخاذ إجراء (في الانتظار)', Colors.grey.shade700),
              
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  // دالة بناء خيار الفلتر داخل النافذة المنبثقة
  Widget _buildFilterOption(String value, String title, Color color) {
    final isSelected = _currentFilter == value;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 2 : 1),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: _currentFilter,
        activeColor: color,
        title: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? color : Colors.black87)),
        onChanged: (val) {
          setState(() => _currentFilter = val!);
          Navigator.pop(context); // إغلاق النافذة فور الاختيار
        },
      ),
    );
  }

  // دالة مساعدة لترجمة مفتاح الفلتر إلى نص مقروء ليُعرض على الزر
  String _getFilterName(String filter) {
    switch (filter) {
      case 'high': return 'الحالات الحرجة';
      case 'medium': return 'الحالات المتوسطة';
      case 'low': return 'الحالات الآمنة';
      case 'action_taken': return 'مؤجلة (تم إجراء)';
      default: return 'تصفية الرادار';
    }
  }
}
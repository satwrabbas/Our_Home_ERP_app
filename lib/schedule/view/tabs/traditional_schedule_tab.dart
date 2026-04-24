// lib/schedule/view/tabs/traditional_schedule_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract; 
import '../../cubit/schedule_cubit.dart';
import '../../../core/utils/whatsapp_helper.dart';

import '../dialogs/edit_schedule_dialog.dart';
import '../dialogs/reschedule_dialog.dart';
import '../dialogs/edit_single_schedule_dialog.dart';

class TraditionalScheduleTab extends StatelessWidget {
  final ScheduleState state;

  const TraditionalScheduleTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    int totalInstallments = 0;
    int paidInstallments = 0;
    int pendingInstallments = 0;
    int overdueInstallments = 0;
    
    Contract? currentContract;
    double metersPerInstallment = 0.0;

    if (state.selectedContractId != null && state.scheduleList.isNotEmpty) {
      totalInstallments = state.scheduleList.length;
      paidInstallments = state.scheduleList.where((s) => s.status == 'paid').length;
      pendingInstallments = state.scheduleList.where((s) => s.status != 'paid').length;
      overdueInstallments = state.scheduleList.where((s) => s.status != 'paid' && s.dueDate.isBefore(DateTime.now())).length;
      
      final idx = state.contracts.indexWhere((c) => c.id == state.selectedContractId);
      if (idx != -1) {
        currentContract = state.contracts[idx];
        if (currentContract.installmentsCount > 0) {
          metersPerInstallment = currentContract.totalArea / currentContract.installmentsCount;
        }
      }
    }

    return Column(
      children:[
        // ==========================================
        // 1. القسم العلوي: شريط أدوات مضغوط (Toolbar)
        // ==========================================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0), // 🌟 تقليل الحشوة العمودية
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            border: Border(bottom: BorderSide(color: Colors.indigo.shade100, width: 1)),
          ),
          child: Row(
            children:[
              const Icon(Icons.person_search, color: Colors.indigo, size: 24),
              const SizedBox(width: 12),
              
              // محرك البحث
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return DropdownMenu<String>(
                      width: constraints.maxWidth,
                      enableSearch: true,
                      enableFilter: true,
                      hintText: '🔍 اكتب اسم العميل أو العقار...',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), // 🌟 تصغير الخط
                      inputDecorationTheme: InputDecorationTheme(
                        isDense: true, // 🌟 يضغط حقل الإدخال عمودياً
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 🌟 تصغير الحشوة
                      ),
                      initialSelection: state.contracts.any((c) => c.id == state.selectedContractId) ? state.selectedContractId : null,
                      onSelected: (val) {
                        if (val != null) context.read<ScheduleCubit>().selectContract(val);
                      },
                      dropdownMenuEntries: state.contracts.map((contract) {
                        final clientIdx = state.clients.indexWhere((c) => c.id == contract.clientId);
                        final clientName = clientIdx >= 0 ? state.clients[clientIdx].name : 'عميل غير معروف';
                        return DropdownMenuEntry<String>(
                          value: contract.id, 
                          label: '$clientName (${contract.apartmentDetails})',
                        );
                      }).toList(),
                    );
                  }
                ),
              ),
              
              // أزرار التحكم
              if (state.selectedContractId != null) ...[
                const SizedBox(width: 16),
                SizedBox(
                  height: 36, // 🌟 زر مضغوط
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.indigo,
                      side: const BorderSide(color: Colors.indigo, width: 1),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('الخصائص', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () {
                      if (currentContract != null) showEditScheduleDialog(context, currentContract);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 36, // 🌟 زر مضغوط
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    icon: const Icon(Icons.autorenew, size: 16),
                    label: const Text('إعادة جدولة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () {
                      if (currentContract != null) showRescheduleDialog(context, currentContract);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),

        // ==========================================
        // 2. القسم السفلي: الإحصائيات الأفقية والجدول
        // ==========================================
        Expanded(
          child: state.selectedContractId == null
              ? _buildEmptyState() 
              : state.scheduleList.isEmpty
                  ? const Center(child: Text('لم يتم توليد أي جدول أقساط لهذا العقد.', style: TextStyle(fontSize: 16, color: Colors.grey)))
                  : ListView(
                      padding: const EdgeInsets.all(16.0), // 🌟 تقليل الحشوة الخارجية
                      children:[
                        
                        // 🌟 شريط الإحصائيات الأفقي (Dashboard Ribbon)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow:[BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: Row(
                            children:[
                              // الإحصائيات (مصغرة وأفقية)
                              Expanded(
                                child: Wrap(
                                  spacing: 24, // المسافة الأفقية بين العناصر
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children:[
                                    _buildDesktopStatItem('إجمالي الأقساط', totalInstallments.toString(), Colors.indigo),
                                    _buildDesktopStatItem('تم السداد', paidInstallments.toString(), Colors.green),
                                    _buildDesktopStatItem('المتبقي', pendingInstallments.toString(), Colors.orange),
                                    _buildDesktopStatItem('المتأخر', overdueInstallments.toString(), Colors.red, isAlert: overdueInstallments > 0),
                                    _buildDesktopStatItem('متوسط القسط', '~ ${metersPerInstallment.toStringAsFixed(1)} م²', Colors.teal),
                                  ],
                                ),
                              ),
                              // خط فاصل ودليل الألوان
                              Container(height: 20, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 12)),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children:[
                                  _buildLegendItem(Colors.green, 'مُسدد'),
                                  const SizedBox(width: 12),
                                  _buildLegendItem(Colors.orange, 'معلق'),
                                  const SizedBox(width: 12),
                                  _buildLegendItem(Colors.red, 'متأخر'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 12), // 🌟 مسافة صغيرة بين الإحصائيات والجدول

                        // 🌟 جدول الاستحقاقات (مضغوط وعريض)
                        Card(
                          elevation: 1,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32), // التمدد لملء الشاشة
                              child: DataTable(
                                headingRowHeight: 40, // 🌟 رأس جدول نحيف
                                dataRowMinHeight: 35, 
                                dataRowMaxHeight: 48, // 🌟 أسطر بيانات نحيفة ومناسبة للماوس
                                headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50),
                                horizontalMargin: 16,
                                columnSpacing: 24,
                                columns: const[
                                  DataColumn(label: Text('القسط', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  DataColumn(label: Text('تاريخ الاستحقاق', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  DataColumn(label: Text('الكمية (م²)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))), 
                                  DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  DataColumn(label: Text('الإجراءات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))), 
                                ],
                                rows: state.scheduleList.map((schedule) {
                                  final isPaid = schedule.status == 'paid';
                                  final isOverdue = !isPaid && schedule.dueDate.isBefore(DateTime.now());

                                  String statusText = 'قادم / معلق';
                                  Color statusColor = Colors.orange;

                                  if (isPaid) {
                                    statusText = 'مسدد ✓';
                                    statusColor = Colors.green;
                                  } else if (isOverdue) {
                                    statusText = 'متأخر 🚨';
                                    statusColor = Colors.red;
                                  }

                                  return DataRow(
                                    color: WidgetStateProperty.all(isOverdue ? Colors.red.shade50.withOpacity(0.5) : Colors.transparent),
                                    cells:[
                                      // 1. رقم القسط
                                      DataCell(Text('#${schedule.installmentNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                      
                                      // 2. التاريخ + الملاحظات (أفقياً)
                                      DataCell(
                                        Row(
                                          children:[
                                            Text('${schedule.dueDate.year}/${schedule.dueDate.month}/${schedule.dueDate.day}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                            // 🌟 إظهار الملاحظة كـ Tooltip عند التمرير بالماوس بدلاً من سطر جديد
                                            if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
                                              const SizedBox(width: 8),
                                              Tooltip(
                                                message: schedule.notes!,
                                                textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                                                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                                                child: const Icon(Icons.info_outline, size: 16, color: Colors.blueGrey),
                                              ),
                                            ],
                                          ],
                                        )
                                      ),

                                      // 3. الكمية
                                      DataCell(
                                        isPaid 
                                          ? const Text('مُثبتة 🔒', style: TextStyle(color: Colors.grey, fontSize: 12))
                                          : Text('~ ${metersPerInstallment.toStringAsFixed(1)} م²', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13))
                                      ),

                                      // 4. الحالة
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.1), 
                                            borderRadius: BorderRadius.circular(4), 
                                            border: Border.all(color: statusColor.withOpacity(0.5))
                                          ),
                                          child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                                        )
                                      ),

                                      // 5. الإجراءات (مضغوطة)
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children:[
                                            if (isPaid) 
                                              const Text('سُددت عبر الإيصالات', style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic))
                                            else ...[
                                              // زر الواتساب (صغير جداً)
                                              SizedBox(
                                                height: 28,
                                                child: ElevatedButton.icon(
                                                  onPressed: () async {
                                                    final contractIdx = state.contracts.indexWhere((c) => c.id == schedule.contractId);
                                                    if(contractIdx == -1) return;
                                                    final success = await WhatsAppHelper.sendReminderMessage(
                                                      schedule: schedule, 
                                                      contract: state.contracts[contractIdx], 
                                                      client: state.clients.firstWhere((c) => c.id == state.contracts[contractIdx].clientId),
                                                    );
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                        content: Text(success ? 'تم الفتح!' : 'فشل الفتح.'), 
                                                        backgroundColor: success ? Colors.green : Colors.red,
                                                        behavior: SnackBarBehavior.floating,
                                                      ));
                                                    }
                                                  },
                                                  icon: const Icon(Icons.chat, size: 14),
                                                  label: const Text('تذكير', style: TextStyle(fontSize: 11)),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8)),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // زر التعديل (أيقونة فقط)
                                              SizedBox(
                                                width: 28, height: 28,
                                                child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  icon: const Icon(Icons.edit_calendar, color: Colors.indigo, size: 18),
                                                  tooltip: 'تأجيل أو تعديل الاستحقاق',
                                                  onPressed: () => showEditSingleScheduleDialog(context, schedule),
                                                ),
                                              ),
                                            ]
                                          ],
                                        )
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }

  // ==========================================
  // 🛠️ دوال مساعدة لرسم الواجهة الأفقية
  // ==========================================
  
  // 🌟 دالة الإحصائيات أصبحت أفقية (الاسم والقيمة بجانب بعض)
  Widget _buildDesktopStatItem(String title, String value, Color color, {bool isAlert = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children:[
        Text('$title: ', style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.w600)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: isAlert ? Border.all(color: Colors.red.withOpacity(0.5)) : null,
          ),
          child: Text(
            value, 
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children:[
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 11)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Row( // 🌟 تم تحويلها لـ Row لتبدو كبانر (Banner) على الشاشات العريضة
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Icon(Icons.query_stats, size: 80, color: Colors.indigo.shade100),
          const SizedBox(width: 24),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              const Text('الجدولة والمتابعة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 8),
              Text(
                'استخدم محرك البحث بالأعلى لاختيار عميل.\nيمكنك مراقبة الدفعات، إعادة الجدولة، أو إرسال مطالبات واتساب.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// lib/schedule/view/tabs/traditional_schedule_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract; 
import '../../cubit/schedule_cubit.dart';
import '../../../core/utils/whatsapp_helper.dart';

import '../dialogs/edit_schedule_dialog.dart';
import '../dialogs/reschedule_dialog.dart';
import '../dialogs/edit_single_schedule_dialog.dart';

// ==========================================
// 🌟 دالة مساعدة لتنسيق الأرقام بالفواصل
// ==========================================
String formatNumberWithCommas(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
}

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
    bool isPostAllocation = false; 

    if (state.selectedContractId != null && state.scheduleList.isNotEmpty) {
      totalInstallments = state.scheduleList.length;
      paidInstallments = state.scheduleList.where((s) => s.status == 'paid').length;
      pendingInstallments = state.scheduleList.where((s) => s.status != 'paid' && s.status != 'missed').length;
      overdueInstallments = state.scheduleList.where((s) => s.status == 'pending' && s.dueDate.isBefore(DateTime.now())).length;
      
      final idx = state.contracts.indexWhere((c) => c.id == state.selectedContractId);
      if (idx != -1) {
        currentContract = state.contracts[idx];
        isPostAllocation = currentContract.contractType == 'لاحق التخصص'; 
        if (!isPostAllocation && currentContract.installmentsCount > 0) {
          metersPerInstallment = currentContract.totalArea / currentContract.installmentsCount;
        }
      }
    }

    return Column(
      children:[
        // ==========================================
        // 1. القسم العلوي: شريط أدوات مضغوط
        // ==========================================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            border: Border(bottom: BorderSide(color: Colors.indigo.shade100, width: 1)),
          ),
          child: Row(
            children:[
              const Icon(Icons.person_search, color: Colors.indigo, size: 24),
              const SizedBox(width: 12),
              
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return DropdownMenu<String>(
                      width: constraints.maxWidth,
                      enableSearch: true,
                      enableFilter: true,
                      hintText: '🔍 اكتب اسم العميل أو العقار...',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), 
                      inputDecorationTheme: InputDecorationTheme(
                        isDense: true, 
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
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
              
              if (state.selectedContractId != null && !isPostAllocation) ...[
                const SizedBox(width: 16),
                SizedBox(
                  height: 36, 
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
                  height: 36, 
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
        // 2. القسم السفلي: الإحصائيات والجدول
        // ==========================================
        Expanded(
          child: state.selectedContractId == null
              ? _buildEmptyState() 
              : state.scheduleList.isEmpty
                  ? const Center(child: Text('لم يتم توليد أي جدول أقساط لهذا العقد.', style: TextStyle(fontSize: 16, color: Colors.grey)))
                  : ListView(
                      padding: const EdgeInsets.all(16.0), 
                      children:[
                        
                        // 🌟 شريط الإحصائيات الأفقي
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
                              Expanded(
                                child: Wrap(
                                  spacing: 24, 
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children:[
                                    _buildDesktopStatItem(isPostAllocation ? 'نقاط التفاعل' : 'إجمالي الأقساط', totalInstallments.toString(), Colors.indigo),
                                    _buildDesktopStatItem('تم السداد', paidInstallments.toString(), Colors.green),
                                    _buildDesktopStatItem('المتبقي/المعلق', pendingInstallments.toString(), Colors.orange),
                                    _buildDesktopStatItem('المتأخر', overdueInstallments.toString(), Colors.red, isAlert: overdueInstallments > 0),
                                    
                                    // 🌟 الدالة الآن موجودة وتعمل بنجاح
                                    if (isPostAllocation)
                                      _buildDesktopStatItem('المطلوب شهرياً', '${formatNumberWithCommas(currentContract!.agreedMonthlyAmount)} ل.س', Colors.teal)
                                    else
                                      _buildDesktopStatItem('متوسط القسط', '~ ${metersPerInstallment.toStringAsFixed(1)} م²', Colors.teal),
                                  ],
                                ),
                              ),
                              Container(height: 20, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 12)),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children:[
                                  _buildLegendItem(Colors.green, 'مُسدد'),
                                  const SizedBox(width: 12),
                                  _buildLegendItem(Colors.orange, 'معلق'),
                                  const SizedBox(width: 12),
                                  _buildLegendItem(Colors.red, 'متأخر'),
                                  if (isPostAllocation) ...[
                                    const SizedBox(width: 12),
                                    _buildLegendItem(Colors.grey.shade800, 'ضائع'),
                                  ]
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 12), 

                        // 🌟 جدول الاستحقاقات
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
                              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32), 
                              child: DataTable(
                                headingRowHeight: 40, 
                                dataRowMinHeight: 35, 
                                dataRowMaxHeight: 48, 
                                headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50),
                                horizontalMargin: 16,
                                columnSpacing: 24,
                                columns:[
                                  const DataColumn(label: Text('النقطة/القسط', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  const DataColumn(label: Text('تاريخ الاستحقاق', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  DataColumn(label: Text(isPostAllocation ? 'المطلوب (ل.س)' : 'الكمية (م²)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))), 
                                  const DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                                  const DataColumn(label: Text('الإجراءات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))), 
                                ],
                                rows: state.scheduleList.map((schedule) {
                                  final isPaid = schedule.status == 'paid';
                                  final isMissed = schedule.status == 'missed'; 
                                  final isOverdue = !isPaid && !isMissed && schedule.dueDate.isBefore(DateTime.now());

                                  String statusText = 'قادم / معلق';
                                  Color statusColor = Colors.orange;

                                  if (isPaid) {
                                    statusText = 'مسدد ✓';
                                    statusColor = Colors.green;
                                  } else if (isMissed) {
                                    statusText = 'شهر ضائع ❌';
                                    statusColor = Colors.grey.shade800;
                                  } else if (isOverdue) {
                                    statusText = 'متأخر 🚨';
                                    statusColor = Colors.red;
                                  }

                                  return DataRow(
                                    color: WidgetStateProperty.all(isOverdue ? Colors.red.shade50.withOpacity(0.5) : Colors.transparent),
                                    cells:[
                                      DataCell(Text('#${schedule.installmentNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                      
                                      DataCell(
                                        Row(
                                          children:[
                                            Text('${schedule.dueDate.year}/${schedule.dueDate.month}/${schedule.dueDate.day}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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

                                      // 🌟 الدالة الآن موجودة وتعمل بنجاح
                                      DataCell(
                                        isPaid || isMissed
                                          ? const Text('مُغلق 🔒', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))
                                          : isPostAllocation 
                                              ? Text('${formatNumberWithCommas(currentContract!.agreedMonthlyAmount)} ل.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13))
                                              : Text('~ ${metersPerInstallment.toStringAsFixed(1)} م²', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13))
                                      ),

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

                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children:[
                                            if (isPaid || isMissed) 
                                              Text(isPaid ? 'سُددت عبر الإيصالات' : 'تخلف عن الدفع', style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic))
                                            else if (!isPostAllocation) ...[
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
                                              SizedBox(
                                                width: 28, height: 28,
                                                child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  icon: const Icon(Icons.edit_calendar, color: Colors.indigo, size: 18),
                                                  tooltip: 'تأجيل أو تعديل الاستحقاق',
                                                  onPressed: () => showEditSingleScheduleDialog(context, schedule),
                                                ),
                                              ),
                                            ] else ...[
                                              // أزرار العقد "لاحق التخصص" 
                                              SizedBox(
                                                height: 28,
                                                child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    context.read<ScheduleCubit>().handleRollingCheckpoint(
                                                      contractId: currentContract!.id,
                                                      scheduleId: schedule.id,
                                                      actionType: 'paid',
                                                      nextDueDate: DateTime(schedule.dueDate.year, schedule.dueDate.month + 1, schedule.dueDate.day),
                                                    );
                                                  },
                                                  icon: const Icon(Icons.check, size: 14),
                                                  label: const Text('تسديد', style: TextStyle(fontSize: 11)),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8)),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              SizedBox(
                                                height: 28,
                                                child: ElevatedButton.icon(
                                                  onPressed: () async {
                                                    final pickedDate = await showDatePicker(
                                                      context: context, initialDate: DateTime.now().add(const Duration(days: 30)),
                                                      firstDate: DateTime.now(), lastDate: DateTime(2100),
                                                    );
                                                    if (pickedDate != null && context.mounted) {
                                                      context.read<ScheduleCubit>().handleRollingCheckpoint(
                                                        contractId: currentContract!.id,
                                                        scheduleId: schedule.id,
                                                        actionType: 'paid',
                                                        nextDueDate: pickedDate,
                                                      );
                                                    }
                                                  },
                                                  icon: const Icon(Icons.fast_forward, size: 14),
                                                  label: const Text('قفزة', style: TextStyle(fontSize: 11)),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8)),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              SizedBox(
                                                height: 28,
                                                child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    context.read<ScheduleCubit>().handleRollingCheckpoint(
                                                      contractId: currentContract!.id,
                                                      scheduleId: schedule.id,
                                                      actionType: 'missed',
                                                      nextDueDate: DateTime(schedule.dueDate.year, schedule.dueDate.month + 1, schedule.dueDate.day),
                                                    );
                                                  },
                                                  icon: const Icon(Icons.close, size: 14),
                                                  label: const Text('ضائع', style: TextStyle(fontSize: 11)),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 8)),
                                                ),
                                              ),
                                            ],
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
      child: Row(
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
                'استخدم محرك البحث بالأعلى لاختيار عميل.\nيمكنك مراقبة الدفعات، وتحديد نقاط التفاعل للمستثمرين.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
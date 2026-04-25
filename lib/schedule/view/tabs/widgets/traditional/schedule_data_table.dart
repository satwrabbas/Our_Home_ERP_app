// lib/schedule/view/tabs/widgets/traditional/schedule_data_table.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract;
import '../../../../cubit/schedule_cubit.dart';
import '../../../../../core/utils/whatsapp_helper.dart';
import '../../../dialogs/edit_single_schedule_dialog.dart';

class ScheduleDataTable extends StatelessWidget {
  final ScheduleState state;
  final Contract currentContract;
  final bool isPostAllocation;
  final String formattedAgreedAmount;
  final double metersPerInstallment;

  const ScheduleDataTable({
    super.key,
    required this.state,
    required this.currentContract,
    required this.isPostAllocation,
    required this.formattedAgreedAmount,
    required this.metersPerInstallment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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

                  DataCell(
                    isPaid || isMissed
                      ? const Text('مُغلق 🔒', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))
                      : isPostAllocation 
                          ? Text('$formattedAgreedAmount ل.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13))
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
                                final client = state.clients.firstWhere((c) => c.id == currentContract.clientId);
                                final success = await WhatsAppHelper.sendReminderMessage(
                                  schedule: schedule, contract: currentContract, client: client,
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
                          SizedBox(
                            height: 28,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<ScheduleCubit>().handleRollingCheckpoint(
                                  contractId: currentContract.id, scheduleId: schedule.id, actionType: 'paid',
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
                                    contractId: currentContract.id, scheduleId: schedule.id, actionType: 'paid',
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
                                  contractId: currentContract.id, scheduleId: schedule.id, actionType: 'missed',
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
    );
  }
}
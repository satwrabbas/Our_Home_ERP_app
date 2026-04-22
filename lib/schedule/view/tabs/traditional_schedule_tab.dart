// lib/schedule/view/tabs/traditional_schedule_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return Column(
      children:[
        Container(
          padding: const EdgeInsets.all(24.0),
          color: Colors.indigo.shade50,
          child: Row(
            children:[
              const Icon(Icons.calendar_month, color: Colors.indigo, size: 30),
              const SizedBox(width: 16),
              const Text('متابعة أقساط العميل: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: state.contracts.any((c) => c.id == state.selectedContractId) ? state.selectedContractId : null,
                  decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                  items: state.contracts.map((contract) {
                    final clientIdx = state.clients.indexWhere((c) => c.id == contract.clientId);
                    final clientName = clientIdx >= 0 ? state.clients[clientIdx].name : 'عميل غير معروف (محذوف)';
                    return DropdownMenuItem(
                      value: contract.id, 
                      child: Text('العميل: $clientName (${contract.apartmentDetails})')
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) context.read<ScheduleCubit>().selectContract(val);
                  },
                ),
              ),
              
              if (state.selectedContractId != null) ...[
                const SizedBox(width: 16),
                
                // 1. زر إعادة الجدولة
                Container(
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.blue.shade300), borderRadius: BorderRadius.circular(8)),
                  child: IconButton(
                    icon: const Icon(Icons.autorenew, color: Colors.blue, size: 28),
                    tooltip: 'إعادة جدولة الأقساط المتبقية (تغيير الخطة)',
                    onPressed: () {
                      final contract = state.contracts.firstWhere((c) => c.id == state.selectedContractId);
                      showRescheduleDialog(context, contract);
                    },
                  ),
                ),

                const SizedBox(width: 12),
                
                // 2. زر الإعدادات القديم
                Container(
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.indigo.shade200), borderRadius: BorderRadius.circular(8)),
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: Colors.indigo, size: 28),
                    tooltip: 'تعديل خصائص العقد (للمدير)',
                    onPressed: () {
                      final contract = state.contracts.firstWhere((c) => c.id == state.selectedContractId);
                      showEditScheduleDialog(context, contract);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: state.selectedContractId == null
              ? const Center(child: Text('يرجى اختيار عقد من القائمة بالأعلى لعرض جدول الأقساط.', style: TextStyle(fontSize: 18, color: Colors.grey)))
              : state.scheduleList.isEmpty
                  ? const Center(child: Text('لم يتم توليد أي جدول أقساط لهذا العقد.', style: TextStyle(fontSize: 18)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(Colors.indigo.shade100),
                          columns: const[
                            DataColumn(label: Text('رقم القسط', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('تاريخ الاستحقاق', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('إجراءات (تواصل وتعديل)', style: TextStyle(fontWeight: FontWeight.bold))), 
                          ],
                          rows: state.scheduleList.map((schedule) {
                            final isPaid = schedule.status == 'paid';
                            final isOverdue = !isPaid && schedule.dueDate.isBefore(DateTime.now());

                            String statusText = 'قادم / معلق';
                            Color statusColor = Colors.orange;

                            if (isPaid) {
                              statusText = 'تم التسديد ✓';
                              statusColor = Colors.green;
                            } else if (isOverdue) {
                              statusText = 'متأخر جداً 🚨';
                              statusColor = Colors.red;
                            }

                            return DataRow(
                              color: WidgetStateProperty.all(isOverdue ? Colors.red.shade50 : Colors.transparent),
                              cells:[
                                DataCell(Text(schedule.installmentNumber.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children:[
                                      Text('${schedule.dueDate.year}/${schedule.dueDate.month}/${schedule.dueDate.day}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      if (schedule.notes != null && schedule.notes!.isNotEmpty)
                                        Text(schedule.notes!, style: const TextStyle(color: Colors.blueGrey, fontSize: 11, fontStyle: FontStyle.italic)),
                                    ],
                                  )
                                ),

                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor)),
                                    child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                                  )
                                ),

                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children:[
                                      isPaid
                                        ? const Text('مُسددة في الدفتر', style: TextStyle(color: Colors.grey))
                                        : ElevatedButton.icon(
                                            onPressed: () async {
                                              final contractIdx = state.contracts.indexWhere((c) => c.id == schedule.contractId);
                                              if(contractIdx == -1) return;
                                              final contract = state.contracts[contractIdx];

                                              final clientIdx = state.clients.indexWhere((c) => c.id == contract.clientId);
                                              if(clientIdx == -1) return;
                                              final client = state.clients[clientIdx];
                                              
                                              final success = await WhatsAppHelper.sendReminderMessage(
                                                schedule: schedule,
                                                contract: contract,
                                                client: client,
                                              );

                                              if (context.mounted) {
                                                if (success) {
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم فتح الواتساب لإرسال التذكير!'), backgroundColor: Colors.green));
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل فتح الواتساب.'), backgroundColor: Colors.red));
                                                }
                                              }
                                            },
                                            icon: const Icon(Icons.chat),
                                            label: const Text('تذكير'),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                          ),
                                          
                                      if (!isPaid) ...[
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.edit_calendar, color: Colors.indigo),
                                          tooltip: 'تأجيل أو تعديل هذا القسط',
                                          onPressed: () => showEditSingleScheduleDialog(context, schedule),
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
    );
  }
}
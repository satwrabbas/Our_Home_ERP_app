import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import '../cubit/schedule_cubit.dart';

// 🌟 استدعاء مساعد الواتساب الجديد (للتذكير)
import '../../core/utils/whatsapp_helper.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScheduleView();
  }
}

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مراقبة الأقساط (جدول الاستحقاقات)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          if (state.status == ScheduleStatus.loading && state.contracts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.contracts.isEmpty) {
            return const Center(child: Text('لا يوجد عقود مسجلة في النظام لتوليد جداول استحقاق.', style: TextStyle(fontSize: 18)));
          }

          return Column(
            children:[
              // ==========================================
              // --- القسم العلوي: فلترة حسب العقد ---
              // ==========================================
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
                        // فحص أمان لضمان عدم انهيار القائمة
                        value: state.contracts.any((c) => c.id == state.selectedContractId) ? state.selectedContractId : null,
                        decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                        items: state.contracts.map((contract) {
                          final clientName = state.clients.firstWhere((c) => c.id == contract.clientId, orElse: () => state.clients.first).name;
                          return DropdownMenuItem(value: contract.id, child: Text('العميل: $clientName (${contract.apartmentDetails})'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) context.read<ScheduleCubit>().selectContract(val);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ==========================================
              // --- القسم السفلي: جدول المراقبة والتنبيه ---
              // ==========================================
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
                                  DataColumn(label: Text('إجراءات (تواصل)', style: TextStyle(fontWeight: FontWeight.bold))), // 🌟 تم تعديل العنوان
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
                                      DataCell(Text('${schedule.dueDate.year}/${schedule.dueDate.month}/${schedule.dueDate.day}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor)),
                                          child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                                        )
                                      ),
                                      DataCell(
                                        isPaid
                                          ? const Text('مُسددة في دفتر الأستاذ', style: TextStyle(color: Colors.grey))
                                          : ElevatedButton.icon(
                                              onPressed: () async {
                                                // 🌟 1. جلب البيانات المطلوبة للتذكير
                                                final contract = state.contracts.firstWhere((c) => c.id == schedule.contractId);
                                                final client = state.clients.firstWhere((c) => c.id == contract.clientId);
                                                
                                                // 🌟 2. إرسال تذكير واتساب
                                                final success = await WhatsAppHelper.sendReminderMessage(
                                                  schedule: schedule,
                                                  contract: contract,
                                                  client: client,
                                                );

                                                if (context.mounted) {
                                                  if (success) {
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم فتح الواتساب لإرسال التذكير!'), backgroundColor: Colors.green));
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل فتح الواتساب. تأكد من اتصالك بالإنترنت.'), backgroundColor: Colors.red));
                                                  }
                                                }
                                              },
                                              icon: const Icon(Icons.chat),
                                              label: const Text('تذكير (واتساب)'),
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                            ),
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
        },
      ),
    );
  }
}
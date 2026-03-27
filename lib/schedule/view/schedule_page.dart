import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import '../cubit/schedule_cubit.dart';
import '../../payments/cubit/payments_cubit.dart'; // 🌟 جلبنا محاسب دفتر الأستاذ للعمل هنا

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
        title: const Text('مراقبة الأقساط (تسديد مرن)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                        // 🌟 الحل السحري: فحص أمان للتأكد أن العقد ما زال موجوداً في القائمة!
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
                                  DataColumn(label: Text('إجراءات (دفع مرن)', style: TextStyle(fontWeight: FontWeight.bold))),
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
                                          ? const Text('مُسددة بالكامل في دفتر الأستاذ', style: TextStyle(color: Colors.grey))
                                          : ElevatedButton(
                                         style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                                         // 🌟 1. أضفنا كلمة async هنا
                                         onPressed: () async { 
                                           if (amountController.text.isNotEmpty) {
                                             
                                             // 🌟 2. أضفنا كلمة await لكي ننتظر قاعدة البيانات حتى تنتهي تماماً
                                             await parentContext.read<PaymentsCubit>().addLedgerEntry(
                                               contractId: contractId,
                                               amountPaid: double.parse(amountController.text),
                                               scheduleId: schedule.id, 
                                             );
                                             
                                             // 3. نتأكد أن الشاشة ما زالت مفتوحة قبل تحديثها
                                             if (parentContext.mounted) {
                                               // الآن نقوم بتحديث الشاشة، وستظهر النتيجة "مدفوع" فوراً من المرة الأولى!
                                               parentContext.read<ScheduleCubit>().selectContract(contractId);
                                               Navigator.pop(dialogContext);
                                               ScaffoldMessenger.of(parentContext).showSnackBar(
                                                 const SnackBar(content: Text('تم تسجيل الدفعة وحساب الأمتار بنجاح!'), backgroundColor: Colors.green)
                                               );
                                             }
                                           }
                                         },
                                         child: const Text('تأكيد الدفع وإغلاق القسط'),
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

  // 🌟 النافذة السحرية: تطلب المبلغ الفعلي وترسله لدفتر الأستاذ
  void _showFlexiblePaymentDialog(BuildContext parentContext, InstallmentsScheduleData schedule, String contractId) {
    final amountController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('تسديد القسط رقم (${schedule.installmentNumber})', style: const TextStyle(color: Colors.indigo)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:[
                const Text('أدخل المبلغ الفعلي الذي أحضره العميل. سيقوم النظام بحساب "الأمتار المحولة" تلقائياً بناءً على تسعيرة اليوم وإضافتها لدفتر الأستاذ.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'المبلغ المدفوع الفعلي (ل.س)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions:[
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              onPressed: () {
                if (amountController.text.isNotEmpty) {
                  // 1. نرسل المبلغ لدفتر الأستاذ ليحسب الأمتار ويحفظها
                  parentContext.read<PaymentsCubit>().addLedgerEntry(
                    contractId: contractId,
                    amountPaid: double.parse(amountController.text),
                    scheduleId: schedule.id, // 🌟 نرسل رقم القسط ليتم إغلاقه آلياً
                  );
                  
                  // 2. نقوم بتحديث شاشة المراقبة لكي نرى القسط يتحول للأخضر فوراً
                  parentContext.read<ScheduleCubit>().selectContract(contractId);
                  
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('تم تسجيل الدفعة وحساب الأمتار بنجاح!'), backgroundColor: Colors.green));
                }
              },
              child: const Text('تأكيد الدفع وإغلاق القسط'),
            ),
          ],
        );
      },
    );
  }
}
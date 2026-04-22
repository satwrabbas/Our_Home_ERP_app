// lib/schedule/view/dialogs/add_exceptional_installment_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract;
import '../../cubit/schedule_cubit.dart';
import '../../../contracts/view/dialogs/verify_pin_dialog.dart';

void showAddExceptionalInstallmentDialog(BuildContext parentContext, Contract contract) {
  final notesController = TextEditingController(text: 'دفعة استثنائية (موسمية / بالونية)');
  DateTime selectedDate = DateTime.now();

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Row(
              children:[
                Icon(Icons.add_task, color: Colors.purple),
                SizedBox(width: 8),
                Text('إضافة قسط استثنائي', style: TextStyle(color: Colors.purple)),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Text(
                      'سيتم إضافة قسط جديد منفصل للجدول في التاريخ الذي تحدده ليتم تذكيرك بمطالبة العميل به.',
                      style: TextStyle(color: Colors.purple, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 📅 تاريخ الاستحقاق
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(border: Border.all(color: Colors.purple.shade300, width: 2), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:[
                        const Text('📅 تاريخ استحقاق الدفعة:', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          icon: const Icon(Icons.edit_calendar, color: Colors.purple),
                          label: Text(
                            '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}', 
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)
                          ),
                          onPressed: () async {
                            final pickedDate = await showDatePicker(
                              context: dialogContext,
                              initialDate: selectedDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 30)),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() => selectedDate = pickedDate);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 📝 الملاحظات
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'الوصف / الملاحظات',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions:[
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                icon: const Icon(Icons.library_add),
                label: const Text('إضافة القسط للجدول'),
                onPressed: () async {
                  if (notesController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('الرجاء كتابة وصف للدفعة!'), backgroundColor: Colors.red));
                    return;
                  }

                  Navigator.pop(dialogContext); // إغلاق النافذة

                  bool isAuthorized = await showVerifyPinDialog(parentContext);
                  
                  if (isAuthorized && parentContext.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('جاري إنشاء القسط الاستثنائي... ⏳')));

                    await parentContext.read<ScheduleCubit>().addExceptionalInstallment(
                      contractId: contract.id,
                      dueDate: selectedDate,
                      note: notesController.text.trim(),
                    );

                    if (parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('تمت الإضافة بنجاح! ✅'), backgroundColor: Colors.green));
                    }
                  }
                },
              ),
            ],
          );
        }
      );
    },
  );
}
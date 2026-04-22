// lib/schedule/view/dialogs/edit_schedule_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract;
import '../../cubit/schedule_cubit.dart';
// 🌟 نستخدم نفس ديالوج التحقق من الـ PIN الموجود في العقود
import '../../../contracts/view/dialogs/verify_pin_dialog.dart';

void showEditScheduleDialog(BuildContext parentContext, Contract contract) {
  final detailsController = TextEditingController(text: contract.apartmentDetails);
  final guarantorController = TextEditingController(text: contract.guarantorName);
  final monthsController = TextEditingController(text: contract.installmentsCount.toString());

  DateTime selectedDate = contract.contractDate.toLocal();

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Row(
              children:[
                Icon(Icons.settings, color: Colors.indigo),
                SizedBox(width: 8),
                Text('تعديل خصائص العقد والجدول', style: TextStyle(color: Colors.indigo)),
              ],
            ),
            content: SizedBox(
              width: 400, 
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        children:[
                          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'تعديل "المدة" سيقوم آلياً بتسوية جدول الاستحقاقات (حذف الأقساط الزائدة إذا قمت بتقليل المدة).',
                              style: TextStyle(color: Colors.brown, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 📅 تعديل التاريخ
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          const Text('📅 تاريخ التوقيع:', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextButton.icon(
                            icon: const Icon(Icons.edit_calendar, color: Colors.indigo),
                            label: Text(
                              '${selectedDate.year}/${selectedDate.month}/${selectedDate.day}', 
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)
                            ),
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: dialogContext,
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
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
                    
                    TextField(controller: detailsController, decoration: const InputDecoration(labelText: 'الوصف / التفاصيل', border: OutlineInputBorder()), maxLines: 2),
                    const SizedBox(height: 16),
                    
                    Row(
                      children:[
                        Expanded(flex: 2, child: TextField(controller: guarantorController, decoration: const InputDecoration(labelText: 'اسم الكفيل', border: OutlineInputBorder()))),
                        const SizedBox(width: 12),
                        Expanded(flex: 1, child: TextField(controller: monthsController, decoration: const InputDecoration(labelText: 'المدة (أشهر)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions:[
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                onPressed: () async {
                  if (monthsController.text.isNotEmpty) {
                    Navigator.pop(dialogContext); 

                    // 🌟 حماية العملية برمز الإدارة
                    bool isAuthorized = await showVerifyPinDialog(parentContext);
                    
                    if (isAuthorized && parentContext.mounted) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('جاري تعديل الخصائص وتسوية الجدول... ⏳')));
                      
                      parentContext.read<ScheduleCubit>().updateContractSettings(
                        id: contract.id,
                        details: detailsController.text,
                        guarantorName: guarantorController.text.isEmpty ? 'بدون كفيل' : guarantorController.text,
                        installmentsCount: int.parse(monthsController.text),
                        contractDate: selectedDate,
                      );
                    }
                  }
                },
                child: const Text('حفظ وتسوية الجدول'),
              ),
            ],
          );
        }
      );
    },
  );
}
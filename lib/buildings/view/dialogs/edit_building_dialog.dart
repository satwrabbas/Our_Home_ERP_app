// lib/buildings/view/dialogs/edit_building_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Building;
import '../../cubit/buildings_cubit.dart';

void showEditBuildingDialog(BuildContext parentContext, Building building) {
  final nameController = TextEditingController(text: building.name);
  final locationController = TextEditingController(text: building.location ?? '');

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[
            const Text('تعديل بيانات المحضر', style: TextStyle(color: Colors.indigo, fontSize: 18)),
            
            // 🌟 أيقونة الحذف مع التأكيد
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              tooltip: 'حذف المحضر',
              onPressed: () {
                // إظهار نافذة تأكيد قبل الحذف
                showDialog(
                  context: dialogContext,
                  builder: (confirmCtx) => AlertDialog(
                    title: const Row(
                      children:[
                        Icon(Icons.warning_amber_rounded, color: Colors.red),
                        SizedBox(width: 8),
                        Text('تأكيد الحذف'),
                      ],
                    ),
                    content: const Text('هل أنت متأكد من رغبتك في حذف هذا المحضر ونقله إلى سلة المحذوفات؟\n(سيتم حذف جميع الوحدات المتاحة داخله آلياً)'),
                    actions:[
                      TextButton(onPressed: () => Navigator.pop(confirmCtx), child: const Text('إلغاء')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () {
                          parentContext.read<BuildingsCubit>().deleteBuilding(building.id);
                          Navigator.pop(confirmCtx); // إغلاق رسالة التأكيد
                          Navigator.pop(dialogContext); // إغلاق نافذة التعديل
                        },
                        child: const Text('نعم، احذف المحضر'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              TextField(
                controller: nameController, 
                decoration: const InputDecoration(labelText: 'اسم المحضر', border: OutlineInputBorder())
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController, 
                decoration: const InputDecoration(labelText: 'الموقع / العنوان', border: OutlineInputBorder())
              ),
            ],
          ),
        ),
        actions:[
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                parentContext.read<BuildingsCubit>().updateBuilding(
                  id: building.id,
                  name: nameController.text.trim(),
                  location: locationController.text.trim(),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('حفظ التعديلات'),
          ),
        ],
      );
    },
  );
}
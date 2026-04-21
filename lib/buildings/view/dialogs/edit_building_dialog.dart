// lib/buildings/view/dialogs/edit_building_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Building;
import '../../cubit/buildings_cubit.dart';

void showEditBuildingDialog(BuildContext parentContext, Building building) {
  // تعبئة البيانات مسبقاً
  final nameController = TextEditingController(text: building.name);
  final locationController = TextEditingController(text: building.location ?? '');

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('تعديل بيانات المحضر', style: TextStyle(color: Colors.indigo)),
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
// lib/buildings/view/dialogs/edit_apartment_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Apartment;
import '../../cubit/buildings_cubit.dart';

void showEditApartmentDialog(BuildContext parentContext, Apartment apt) {
  // تعبئة البيانات مسبقاً
  final numberController = TextEditingController(text: apt.apartmentNumber);
  final areaController = TextEditingController(text: apt.area.toString());
  
  // حفظ الاتجاه الحالي
  String selectedDirection = apt.directionName ?? 'شمالي';
  
  // قائمة الاتجاهات المسموح بها لتجنب الأخطاء الإملائية
  final List<String> directions =['شمالي', 'جنوبي', 'شرقي', 'غربي', 'شمالي شرقي', 'شمالي غربي', 'جنوبي شرقي', 'جنوبي غربي'];
  
  // التأكد من أن الاتجاه الموجود في القاعدة موجود في القائمة، وإلا نختار أول عنصر
  if (!directions.contains(selectedDirection)) {
    selectedDirection = directions.first;
  }

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('تعديل الشقة ( ${apt.apartmentNumber} )', style: const TextStyle(color: Colors.indigo)),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:[
                  // تنبيه هندسي
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.amber.shade50,
                    child: const Row(
                      children:[
                        Icon(Icons.warning_amber_rounded, color: Colors.brown, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'لا يمكن تعديل معاملات التميز أو الطابق حفاظاً على سلامة الحسابات. لتغييرها يجب حذف الشقة وإضافتها من جديد.',
                            style: TextStyle(color: Colors.brown, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children:[
                      Expanded(
                        child: TextField(
                          controller: numberController, 
                          decoration: const InputDecoration(labelText: 'رقم الشقة', border: OutlineInputBorder())
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: areaController, 
                          decoration: const InputDecoration(labelText: 'المساحة (م²)', border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: selectedDirection,
                    decoration: const InputDecoration(labelText: 'الاتجاه', border: OutlineInputBorder()),
                    items: directions.map((dir) => DropdownMenuItem(value: dir, child: Text(dir))).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedDirection = val!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions:[
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                onPressed: () {
                  if (numberController.text.trim().isNotEmpty && areaController.text.trim().isNotEmpty) {
                    parentContext.read<BuildingsCubit>().updateApartment(
                      id: apt.id,
                      apartmentNumber: numberController.text.trim(),
                      area: double.tryParse(areaController.text.trim()) ?? apt.area,
                      directionName: selectedDirection,
                    );
                    Navigator.pop(dialogContext);
                  }
                },
                child: const Text('حفظ التعديلات'),
              ),
            ],
          );
        }
      );
    },
  );
}
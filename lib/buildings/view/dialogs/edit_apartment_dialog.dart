// lib/buildings/view/dialogs/edit_apartment_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Apartment;
import '../../cubit/buildings_cubit.dart';

void showEditApartmentDialog(BuildContext parentContext, Apartment apt) {
  final numberController = TextEditingController(text: apt.apartmentNumber);
  final areaController = TextEditingController(text: apt.area.toString());
  
  String selectedDirection = apt.directionName ?? 'شمالي';
  final List<String> directions =['شمالي', 'جنوبي', 'شرقي', 'غربي', 'شمالي شرقي', 'شمالي غربي', 'جنوبي شرقي', 'جنوبي غربي'];
  if (!directions.contains(selectedDirection)) {
    selectedDirection = directions.first;
  }

  // 🌟 حماية الواجهة: التحقق هل الوحدة متاحة أم مباعة؟
  final bool isAvailable = apt.status == 'available';

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Text('تعديل الوحدة ( ${apt.apartmentNumber} )', style: const TextStyle(color: Colors.indigo, fontSize: 18)),
                
                // 🌟 عرض زر الحذف فقط إذا كانت الوحدة متاحة
                if (isAvailable)
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    tooltip: 'حذف الوحدة',
                    onPressed: () {
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
                          content: const Text('هل أنت متأكد من رغبتك في حذف هذه الوحدة ونقلها إلى سلة المحذوفات؟'),
                          actions:[
                            TextButton(onPressed: () => Navigator.pop(confirmCtx), child: const Text('إلغاء')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                              onPressed: () {
                                parentContext.read<BuildingsCubit>().deleteApartment(apt.id);
                                Navigator.pop(confirmCtx);
                                Navigator.pop(dialogContext);
                              },
                              child: const Text('نعم، احذف'),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                else
                  const Tooltip(
                    message: 'لا يمكن حذف وحدة مباعة أو محجوزة',
                    child: Icon(Icons.lock, color: Colors.grey),
                  )
              ],
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:[
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.amber.shade50,
                    child: const Row(
                      children:[
                        Icon(Icons.warning_amber_rounded, color: Colors.brown, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'لا يمكن تعديل معاملات التميز أو الطابق حفاظاً على سلامة الحسابات. لتغييرها يجب حذف الوحدة وإضافتها من جديد.',
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
                          decoration: const InputDecoration(labelText: 'الرقم/الرمز', border: OutlineInputBorder())
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
                    decoration: const InputDecoration(labelText: 'الاتجاه/الواجهة', border: OutlineInputBorder()),
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
// lib/buildings/view/dialogs/copy_floor_dialog.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Building, Apartment;
import '../../cubit/buildings_cubit.dart';

// 🌟 حولنا الدالة إلى عامة
void showCopyFloorDialog(
  BuildContext parentContext, 
  Building building, 
  String sourceFloorName, 
  List<Apartment> sourceApartments, 
  List<String> allFloors
) {
  List<String> targetFloors = allFloors.where((f) => f != sourceFloorName).toList();
  if (targetFloors.isEmpty) {
    ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('لا توجد طوابق أخرى للنسخ إليها!')));
    return;
  }

  String? selectedTargetFloor = targetFloors.first;
  
  Map<String, TextEditingController> newNumberControllers = {};
  for (var apt in sourceApartments) {
    newNumberControllers[apt.id] = TextEditingController(text: '${apt.apartmentNumber}*');
  }

  showDialog(
    context: parentContext,
    builder: (dialogCtx) => StatefulBuilder(
      builder: (ctx, setState) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.copy, color: Colors.orange),
              const SizedBox(width: 8),
              Text('استنساخ شقق $sourceFloorName', style: const TextStyle(color: Colors.orange)),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('سيتم نسخ المساحات، الاتجاهات، ومعاملات الربح والوجيبة بدقة تامة.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedTargetFloor,
                    decoration: const InputDecoration(labelText: 'اختر الطابق الوجهة (الهدف)', border: OutlineInputBorder(), filled: true, fillColor: Colors.orangeAccent),
                    items: targetFloors.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (val) => setState(() => selectedTargetFloor = val),
                  ),
                  const Divider(height: 30, thickness: 2),
                  const Text('يرجى تحديد أرقام الشقق الجديدة لمنع التكرار:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  ...sourceApartments.map((apt) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(child: Text('نسخة من (${apt.apartmentNumber}): \n مساحة ${apt.area}م2', style: const TextStyle(fontSize: 12))),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: newNumberControllers[apt.id],
                              decoration: const InputDecoration(labelText: 'رقم الشقة الجديد', border: OutlineInputBorder(), isDense: true),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              onPressed: () async {
                bool hasEmpty = newNumberControllers.values.any((c) => c.text.trim().isEmpty);
                if (hasEmpty || selectedTargetFloor == null) {
                  ScaffoldMessenger.of(dialogCtx).showSnackBar(const SnackBar(content: Text('يرجى تعبئة أرقام جميع الشقق!')));
                  return;
                }

                Map<String, dynamic> availableFloors = jsonDecode(building.floorCoefficients);
                final targetFloorPercentage = (availableFloors[selectedTargetFloor] as num).toDouble();

                final cubit = parentContext.read<BuildingsCubit>();
                
                for (var apt in sourceApartments) {
                  Map<String, dynamic> copiedCoeffs = jsonDecode(apt.customCoefficients);
                  
                  copiedCoeffs.removeWhere((key, value) => key.startsWith('الطابق'));
                  if (targetFloorPercentage != 0.0) {
                    copiedCoeffs['الطابق ($selectedTargetFloor)'] = targetFloorPercentage;
                  }

                  Map<String, double> finalCoeffs = {};
                  copiedCoeffs.forEach((k, v) => finalCoeffs[k] = (v as num).toDouble());

                  await cubit.addApartment(
                    buildingId: building.id,
                    aptNumber: newNumberControllers[apt.id]!.text.trim(),
                    area: apt.area,
                    floorName: selectedTargetFloor!,
                    directionName: apt.directionName ?? '',
                    customCoeffs: finalCoeffs,
                  );
                }

                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(content: Text('تم استنساخ الشقق إلى $selectedTargetFloor بنجاح! ✅'), backgroundColor: Colors.green));
              },
              child: const Text('حفظ الشقق المستنسخة'),
            )
          ],
        );
      }
    ),
  );
}
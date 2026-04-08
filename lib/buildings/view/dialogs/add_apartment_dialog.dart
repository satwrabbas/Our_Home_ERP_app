// lib/buildings/view/dialogs/add_apartment_dialog.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Building;
import '../../cubit/buildings_cubit.dart';

// 🌟 حولنا الدالة إلى عامة (بدون شرطة سفلية)
void showAddApartmentDialog(BuildContext parentContext, Building building, {String? preSelectedFloor}) {
  final numCtrl = TextEditingController();
  final areaCtrl = TextEditingController();
  final dirNameCtrl = TextEditingController();

  final directionCoeffCtrl = TextEditingController(text: '0');
  final yardCoeffCtrl = TextEditingController(text: '0');
  final profitCoeffCtrl = TextEditingController(text: '0'); 

  Map<String, dynamic> availableFloors = {};
  try {
    availableFloors = jsonDecode(building.floorCoefficients);
  } catch (e) {
    print('Error decoding floor coeffs: $e');
  }

  String? selectedFloorName = preSelectedFloor ?? (availableFloors.keys.isNotEmpty ? availableFloors.keys.first : null);

  showDialog(
    context: parentContext,
    builder: (dialogCtx) => StatefulBuilder(
      builder: (statefulCtx, setState) {
        return AlertDialog(
          title: const Text('إضافة شقة للكتالوج'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: TextField(controller: numCtrl, decoration: const InputDecoration(labelText: 'رقم الشقة', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: areaCtrl, decoration: const InputDecoration(labelText: 'المساحة (م2)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                
                DropdownButtonFormField<String>(
                  value: selectedFloorName,
                  decoration: const InputDecoration(labelText: 'اختر الطابق (يحدد النسبة آلياً)', border: OutlineInputBorder()),
                  items: availableFloors.keys.map((floorName) {
                    final percentage = availableFloors[floorName];
                    return DropdownMenuItem(value: floorName, child: Text('$floorName (نسبة: $percentage%)'));
                  }).toList(),
                  onChanged: (val) => setState(() => selectedFloorName = val),
                ),
                const SizedBox(height: 12),

                TextField(controller: dirNameCtrl, decoration: const InputDecoration(labelText: 'الاتجاه (مثال: قبلي/شمالي)', border: OutlineInputBorder())),
                
                const Divider(height: 30, thickness: 2),
                const Text('معاملات خاصة بهذه الشقة فقط (%)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: directionCoeffCtrl, decoration: const InputDecoration(labelText: 'نسبة الاتجاه %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: yardCoeffCtrl, decoration: const InputDecoration(labelText: 'نسبة الوجيبة %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                
                TextField(
                  controller: profitCoeffCtrl, 
                  decoration: const InputDecoration(
                    labelText: 'نسبة الربح المستهدفة (هامش الربح) %', 
                    border: OutlineInputBorder(), 
                    filled: true, 
                    fillColor: Color(0xFFE8F5E9)
                  ), 
                  keyboardType: TextInputType.number
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (numCtrl.text.isNotEmpty && areaCtrl.text.isNotEmpty && selectedFloorName != null) {
                  Map<String, double> aptCoeffs = {};
                  
                  final floorPercentage = (availableFloors[selectedFloorName] as num).toDouble();
                  if (floorPercentage != 0.0) aptCoeffs['الطابق ($selectedFloorName)'] = floorPercentage;

                  void addVal(String key, String val) {
                    final parsed = double.tryParse(val);
                    if (parsed != null && parsed != 0.0) aptCoeffs[key] = parsed;
                  }
                  addVal('الاتجاه', directionCoeffCtrl.text);
                  addVal('الوجيبة', yardCoeffCtrl.text);
                  addVal('هامش الربح', profitCoeffCtrl.text);

                  parentContext.read<BuildingsCubit>().addApartment(
                    buildingId: building.id,
                    aptNumber: numCtrl.text,
                    area: double.parse(areaCtrl.text),
                    floorName: selectedFloorName!, 
                    directionName: dirNameCtrl.text,
                    customCoeffs: aptCoeffs, 
                  );
                  Navigator.pop(dialogCtx);
                }
              },
              child: const Text('حفظ الشقة'),
            )
          ],
        );
      }
    ),
  );
}
// lib/buildings/view/dialogs/add_apartment_dialog.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Building;
import '../../cubit/buildings_cubit.dart';

void showAddApartmentDialog(BuildContext parentContext, Building building, {String? preSelectedFloor}) {
  final numCtrl = TextEditingController();
  final areaCtrl = TextEditingController();
  
  // أزلنا directionCoeffCtrl اليدوي
  final yardCoeffCtrl = TextEditingController(text: '0');
  final profitCoeffCtrl = TextEditingController(text: '0'); 

  Map<String, dynamic> availableFloors = {};
  Map<String, dynamic> generalCoeffs = {}; // 🌟 لقراءة قيم الجهات من المحضر

  try {
    availableFloors = jsonDecode(building.floorCoefficients);
    generalCoeffs = jsonDecode(building.directionCoefficients);
  } catch (e) {
    print('Error decoding coeffs: $e');
  }

  String? selectedFloorName = preSelectedFloor ?? (availableFloors.keys.isNotEmpty ? availableFloors.keys.first : null);

  // 🌟 متغيرات تتبع الجهات المختارة (Checkboxes)
  final List<String> mainDirections = ['شمالي', 'جنوبي', 'شرقي', 'غربي'];
  Map<String, bool> selectedDirections = {
    'شمالي': false, 'جنوبي': false, 'شرقي': false, 'غربي': false
  };

  showDialog(
    context: parentContext,
    builder: (dialogCtx) => StatefulBuilder(
      builder: (statefulCtx, setState) {
        return AlertDialog(
          title: const Text('إضافة شقة للكتالوج'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                
                const Divider(height: 30, thickness: 2),
                const Text('اختيار اتجاهات الشقة (يحسب النسبة آلياً):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                const SizedBox(height: 8),
                
                // 🌟 عرض الجهات كأزرار اختيار (Chips)
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: mainDirections.map((dir) {
                    // جلب النسبة الخاصة بهذا الاتجاه من المحضر (إن وجدت)
                    final double dirPercentage = (generalCoeffs[dir] as num?)?.toDouble() ?? 0.0;
                    
                    return FilterChip(
                      label: Text('$dir ($dirPercentage%)'),
                      selected: selectedDirections[dir]!,
                      selectedColor: Colors.teal.shade200,
                      checkmarkColor: Colors.teal.shade900,
                      onSelected: (bool selected) {
                        setState(() {
                          selectedDirections[dir] = selected;
                        });
                      },
                    );
                  }).toList(),
                ),

                const Divider(height: 30, thickness: 2),
                const Text('معاملات أخرى خاصة بالشقة:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 12),
                
                TextField(controller: yardCoeffCtrl, decoration: const InputDecoration(labelText: 'نسبة الوجيبة المستقلة %', border: OutlineInputBorder()), keyboardType: TextInputType.number),
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
                  
                  // 1. نسبة الطابق
                  final floorPercentage = (availableFloors[selectedFloorName] as num).toDouble();
                  if (floorPercentage != 0.0) aptCoeffs['الطابق ($selectedFloorName)'] = floorPercentage;

                  // 2. 🌟 تجميع وتوليد الاتجاه آلياً
                  List<String> chosenNames = [];
                  double totalDirPercentage = 0.0;
                  
                  selectedDirections.forEach((dirName, isSelected) {
                    if (isSelected) {
                      chosenNames.add(dirName);
                      totalDirPercentage += (generalCoeffs[dirName] as num?)?.toDouble() ?? 0.0;
                    }
                  });
                  
                  // إنشاء الاسم المدمج (مثال: شمالي - شرقي)
                  String finalDirectionName = chosenNames.isEmpty ? 'غير محدد' : chosenNames.join(' - ');
                  
                  // حفظ نسبة الاتجاه الإجمالية داخل معاملات الشقة
                  if (totalDirPercentage != 0.0) {
                    aptCoeffs['الاتجاه ($finalDirectionName)'] = totalDirPercentage;
                  }

                  // 3. إضافة الوجيبة والربح
                  void addVal(String key, String val) {
                    final parsed = double.tryParse(val);
                    if (parsed != null && parsed != 0.0) aptCoeffs[key] = parsed;
                  }
                  addVal('الوجيبة', yardCoeffCtrl.text);
                  addVal('هامش الربح', profitCoeffCtrl.text);

                  // الإرسال لقاعدة البيانات
                  parentContext.read<BuildingsCubit>().addApartment(
                    buildingId: building.id,
                    aptNumber: numCtrl.text,
                    area: double.parse(areaCtrl.text),
                    floorName: selectedFloorName!, 
                    directionName: finalDirectionName, // 🌟 نحفظ الاسم المدمج ليعرض في الجدول بوضوح
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
// lib/buildings/view/dialogs/add_apartment_dialog.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Building;
import '../../cubit/buildings_cubit.dart';

void showAddApartmentDialog(BuildContext parentContext, Building building, {String? preSelectedFloor}) {
  final numCtrl = TextEditingController();
  
  // 🌟 متحكمات المساحة الهندسية
  final slabAreaCtrl = TextEditingController(); // مساحة البلاطة (المسقوفة)
  final terraceAreaCtrl = TextEditingController(text: '0'); // مساحة التراس
  final physicalYardAreaCtrl = TextEditingController(text: '0'); // مساحة الوجيبة الفيزيائية (بالمتر المربع)

  // متحكمات المعاملات المالية
  final yardCoeffCtrl = TextEditingController(text: '0'); // نسبة تميز الوجيبة (مالياً)
  final profitCoeffCtrl = TextEditingController(text: '0'); 

  Map<String, dynamic> availableFloors = {};
  Map<String, dynamic> generalCoeffs = {}; 

  try {
    availableFloors = jsonDecode(building.floorCoefficients);
    generalCoeffs = jsonDecode(building.directionCoefficients);
  } catch (e) {
    print('Error decoding coeffs: $e');
  }

  String? selectedFloorName = preSelectedFloor ?? (availableFloors.keys.isNotEmpty ? availableFloors.keys.first : null);

  final List<String> mainDirections = ['شمالي', 'جنوبي', 'شرقي', 'غربي'];
  Map<String, bool> selectedDirections = {
    'شمالي': false, 'جنوبي': false, 'شرقي': false, 'غربي': false
  };

  // 🌟 متغير لحفظ المساحة البيعية النهائية
  double calculatedTotalArea = 0.0;

  showDialog(
    context: parentContext,
    builder: (dialogCtx) => StatefulBuilder(
      builder: (statefulCtx, setState) {
        
        // 🌟 دالة الحساب اللحظي للمساحة
        void updateCalculatedArea() {
          double slab = double.tryParse(slabAreaCtrl.text) ?? 0.0;
          double terrace = double.tryParse(terraceAreaCtrl.text) ?? 0.0;
          double yard = double.tryParse(physicalYardAreaCtrl.text) ?? 0.0;

          setState(() {
            // المعادلة: البلاطة + (التراس * 40%) + (الوجيبة / 8)
            calculatedTotalArea = slab + (terrace * 0.40) + (yard / 8.0);
          });
        }

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
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedFloorName,
                        decoration: const InputDecoration(labelText: 'اختر الطابق (يحدد النسبة آلياً)', border: OutlineInputBorder()),
                        items: availableFloors.keys.map((floorName) {
                          final percentage = availableFloors[floorName];
                          return DropdownMenuItem(value: floorName, child: Text('$floorName ($percentage%)'));
                        }).toList(),
                        onChanged: (val) => setState(() => selectedFloorName = val),
                      ),
                    ),
                  ],
                ),
                
                const Divider(height: 30, thickness: 2),
                const Text('📐 حساب المساحة البيعية (م2):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 12),
                
                // 🌟 حقول المساحات الهندسية
                TextField(
                  controller: slabAreaCtrl, 
                  decoration: const InputDecoration(labelText: 'مساحة البلاطة (المسقوفة) م2', border: OutlineInputBorder(), filled: true, fillColor: Colors.white), 
                  keyboardType: TextInputType.number,
                  onChanged: (_) => updateCalculatedArea(), // التحديث اللحظي
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: terraceAreaCtrl, 
                        decoration: const InputDecoration(labelText: 'مساحة التراس م2', border: OutlineInputBorder()), 
                        keyboardType: TextInputType.number,
                        onChanged: (_) => updateCalculatedArea(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: physicalYardAreaCtrl, 
                        decoration: const InputDecoration(labelText: 'مساحة الوجيبة م2', border: OutlineInputBorder()), 
                        keyboardType: TextInputType.number,
                        onChanged: (_) => updateCalculatedArea(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 🌟 عرض المساحة النهائية المحسوبة
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.indigo.shade200)),
                  child: Text(
                    'المساحة البيعية المعتمدة للعقد: ${calculatedTotalArea.toStringAsFixed(2)} م2', 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const Divider(height: 30, thickness: 2),
                const Text('🧭 اختيار اتجاهات الشقة:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: mainDirections.map((dir) {
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
                const Text('💰 المعاملات المالية الخاصة بالشقة:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: yardCoeffCtrl, 
                        decoration: const InputDecoration(labelText: 'معامل الوجيبة المالي %', border: OutlineInputBorder()), 
                        keyboardType: TextInputType.number
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: profitCoeffCtrl, 
                        decoration: const InputDecoration(labelText: 'هامش الربح %', border: OutlineInputBorder(), filled: true, fillColor: Color(0xFFE8F5E9)), 
                        keyboardType: TextInputType.number
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (numCtrl.text.isNotEmpty && slabAreaCtrl.text.isNotEmpty && selectedFloorName != null) {
                  
                  // تحديث أخير للمساحة للتأكد
                  updateCalculatedArea();
                  
                  if (calculatedTotalArea <= 0) {
                    ScaffoldMessenger.of(dialogCtx).showSnackBar(const SnackBar(content: Text('المساحة غير صالحة!')));
                    return;
                  }

                  Map<String, double> aptCoeffs = {};
                  
                  // 🌟 1. حفظ تفاصيل المساحة الهندسية في الـ JSON للشفافية
                  double slab = double.tryParse(slabAreaCtrl.text) ?? 0.0;
                  double terrace = double.tryParse(terraceAreaCtrl.text) ?? 0.0;
                  double yard = double.tryParse(physicalYardAreaCtrl.text) ?? 0.0;
                  
                  if(slab > 0) aptCoeffs['مساحة البلاطة (م2)'] = slab;
                  if(terrace > 0) aptCoeffs['مساحة التراس (م2)'] = terrace;
                  if(yard > 0) aptCoeffs['مساحة الوجيبة (م2)'] = yard;

                  // 2. نسبة الطابق
                  final floorPercentage = (availableFloors[selectedFloorName] as num).toDouble();
                  if (floorPercentage != 0.0) aptCoeffs['الطابق ($selectedFloorName)'] = floorPercentage;

                  // 3. تجميع الاتجاه
                  List<String> chosenNames = [];
                  double totalDirPercentage = 0.0;
                  selectedDirections.forEach((dirName, isSelected) {
                    if (isSelected) {
                      chosenNames.add(dirName);
                      totalDirPercentage += (generalCoeffs[dirName] as num?)?.toDouble() ?? 0.0;
                    }
                  });
                  String finalDirectionName = chosenNames.isEmpty ? 'غير محدد' : chosenNames.join(' - ');
                  if (totalDirPercentage != 0.0) {
                    aptCoeffs['الاتجاه ($finalDirectionName)'] = totalDirPercentage;
                  }

                  // 4. إضافة معامل الوجيبة والربح
                  void addVal(String key, String val) {
                    final parsed = double.tryParse(val);
                    if (parsed != null && parsed != 0.0) aptCoeffs[key] = parsed;
                  }
                  addVal('معامل التميز للوجيبة', yardCoeffCtrl.text);
                  addVal('هامش الربح', profitCoeffCtrl.text);

                  // الإرسال لقاعدة البيانات
                  parentContext.read<BuildingsCubit>().addApartment(
                    buildingId: building.id,
                    aptNumber: numCtrl.text,
                    
                    // 🌟 نرسل المساحة البيعية النهائية للحفظ الرسمي
                    area: calculatedTotalArea, 
                    
                    floorName: selectedFloorName!, 
                    directionName: finalDirectionName,
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
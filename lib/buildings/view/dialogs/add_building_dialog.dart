// lib/buildings/view/dialogs/add_building_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/buildings_cubit.dart';

String _getArabicFloorName(int floorNumber) {
  if (floorNumber == 0) return 'الطابق الأرضي';
  if (floorNumber > 0) {
    const names = ['الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس', 'السادس'];
    return 'الطابق ${names[floorNumber - 1]}';
  } else {
    const names = ['الأول', 'الثاني', 'الثالث'];
    return 'القبو ${names[floorNumber.abs() - 1]}';
  }
}

void showAddBuildingDialog(BuildContext parentContext) {
  final nameCtrl = TextEditingController();
  final locCtrl = TextEditingController();
  
  final locationCoeffCtrl = TextEditingController(text: '0');
  final streetCoeffCtrl = TextEditingController(text: '0');
  final elevatorCoeffCtrl = TextEditingController(text: '0');

  // 🌟 حقول الجهات الأربعة
  final northCtrl = TextEditingController(text: '0');
  final southCtrl = TextEditingController(text: '0');
  final eastCtrl = TextEditingController(text: '0');
  final westCtrl = TextEditingController(text: '0');

  int basementsCount = 0; 
  int floorsCount = 1;    
  Map<int, TextEditingController> floorControllers = {};

  showDialog(
    context: parentContext,
    builder: (dialogCtx) => StatefulBuilder(
      builder: (statefulCtx, setState) {
        
        List<Widget> buildFloorInputs() {
          List<Widget> widgets = [];
          for (int i = -basementsCount; i <= floorsCount; i++) {
            floorControllers.putIfAbsent(i, () => TextEditingController(text: '0'));
            widgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    SizedBox(width: 120, child: Text(_getArabicFloorName(i), style: const TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(
                      child: TextField(
                        controller: floorControllers[i],
                        decoration: const InputDecoration(labelText: 'نسبة التمييز %', border: OutlineInputBorder(), isDense: true),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              )
            );
          }
          return widgets;
        }

        return AlertDialog(
          title: const Text('إضافة محضر جديد (إعداد الهيكل)'),
          content: SizedBox(
            width: 550,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المحضر', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'الموقع', border: OutlineInputBorder())),
                  
                  const Divider(height: 30, thickness: 2),
                  const Text('معاملات المحضر العامة (%)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: locationCoeffCtrl, decoration: const InputDecoration(labelText: 'الموقع %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: streetCoeffCtrl, decoration: const InputDecoration(labelText: 'الشارع %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: elevatorCoeffCtrl, decoration: const InputDecoration(labelText: 'المصعد %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                    ],
                  ),

                  // 🌟 قسم الجهات الأربعة
                  const Divider(height: 30, thickness: 2),
                  const Text('معاملات الجهات الجغرافية للمحضر (%)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: northCtrl, decoration: const InputDecoration(labelText: 'شمالي %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: southCtrl, decoration: const InputDecoration(labelText: 'جنوبي %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: eastCtrl, decoration: const InputDecoration(labelText: 'شرقي %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: westCtrl, decoration: const InputDecoration(labelText: 'غربي %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                    ],
                  ),

                  const Divider(height: 30, thickness: 2),
                  const Text('هيكل الطوابق ونسب التمييز لكل طابق', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.indigo.shade50,
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: basementsCount,
                            decoration: const InputDecoration(labelText: 'عدد الأقبية (تحت الأرض)'),
                            items: [0, 1, 2, 3].map((e) => DropdownMenuItem(value: e, child: Text('$e قبو'))).toList(),
                            onChanged: (val) => setState(() => basementsCount = val!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: floorsCount,
                            decoration: const InputDecoration(labelText: 'عدد الطوابق (فوق الأرضي)'),
                            items: [0, 1, 2, 3, 4].map((e) => DropdownMenuItem(value: e, child: Text('$e طابق'))).toList(),
                            onChanged: (val) => setState(() => floorsCount = val!),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...buildFloorInputs(),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  Map<String, double> finalFloorCoeffs = {};
                  floorControllers.forEach((floorNum, ctrl) {
                    final val = double.tryParse(ctrl.text);
                    if (val != null) finalFloorCoeffs[_getArabicFloorName(floorNum)] = val;
                  });

                  Map<String, double> finalDirCoeffs = {};
                  void addGeneralVal(String key, String val) {
                    final parsed = double.tryParse(val);
                    if (parsed != null && parsed != 0.0) finalDirCoeffs[key] = parsed;
                  }
                  
                  addGeneralVal('الموقع', locationCoeffCtrl.text);
                  addGeneralVal('الشارع', streetCoeffCtrl.text);
                  addGeneralVal('المصعد', elevatorCoeffCtrl.text);
                  
                  // 🌟 حفظ قيم الجهات
                  addGeneralVal('شمالي', northCtrl.text);
                  addGeneralVal('جنوبي', southCtrl.text);
                  addGeneralVal('شرقي', eastCtrl.text);
                  addGeneralVal('غربي', westCtrl.text);

                  parentContext.read<BuildingsCubit>().addBuilding(
                    name: nameCtrl.text, 
                    location: locCtrl.text,
                    floorCoeffs: finalFloorCoeffs,
                    dirCoeffs: finalDirCoeffs,
                  );
                  Navigator.pop(dialogCtx);
                }
              },
              child: const Text('اعتماد وحفظ المحضر'),
            )
          ],
        );
      }
    ),
  );
}
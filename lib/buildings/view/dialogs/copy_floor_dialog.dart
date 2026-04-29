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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.all(24),
          title: Row(
            children:[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.copy_all, color: Colors.orange.shade700, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text('استنساخ شقق $sourceFloorName', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22)),
              ),
            ],
          ),
          content: SizedBox(
            width: 600, // 🌟 عرض احترافي 600 بكسل
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  
                  // 🌟 1. رسالة توضيحية (Info Banner)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100, width: 1.5),
                    ),
                    child: Row(
                      children:[
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'سيتم نسخ المساحات، الاتجاهات، ومعاملات الربح والوجيبة بدقة تامة. (سيتم تحديث النسبة المالية للطابق الجديد آلياً).', 
                            style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🌟 2. اختيار الطابق الهدف
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.shade200, width: 1.5),
                      boxShadow:[BoxShadow(color: Colors.orange.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children:[
                            Icon(Icons.arrow_downward, color: Colors.orange.shade600),
                            const SizedBox(width: 8),
                            const Text('الطابق الوجهة (الهدف)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedTargetFloor,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'اختر الطابق المراد النسخ إليه',
                            prefixIcon: Icon(Icons.layers, size: 20, color: Colors.grey.shade600),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.orange.shade400, width: 2)),
                          ),
                          items: targetFloors.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                          onChanged: (val) => setState(() => selectedTargetFloor = val),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🌟 3. قائمة الشقق وإعادة التسمية
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.indigo.shade100, width: 1.5),
                      boxShadow:[BoxShadow(color: Colors.indigo.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Row(
                          children:[
                            Icon(Icons.edit_document, color: Colors.indigo.shade400),
                            const SizedBox(width: 8),
                            const Text('يرجى تحديد أرقام الشقق الجديدة لمنع التكرار', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        ...sourceApartments.map((apt) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.indigo.shade100),
                            ),
                            child: Row(
                              children:[
                                // معلومات الشقة الأصلية
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children:[
                                      Icon(Icons.door_front_door, color: Colors.indigo.shade300, size: 24),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children:[
                                            Text('نسخة عن الشقة: ${apt.apartmentNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                                            const SizedBox(height: 2),
                                            Text('المساحة البيعية: ${apt.area} م²', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.indigo.shade700)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // حقل إدخال الاسم الجديد
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: newNumberControllers[apt.id],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      labelText: 'الرقم الجديد',
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.indigo.shade200)),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.indigo.shade200)),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.indigo.shade500, width: 2)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions:[
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx), 
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              child: const Text('إلغاء', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey))
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600, 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              onPressed: () async {
                bool hasEmpty = newNumberControllers.values.any((c) => c.text.trim().isEmpty);
                if (hasEmpty || selectedTargetFloor == null) {
                  ScaffoldMessenger.of(dialogCtx).showSnackBar(const SnackBar(content: Text('يرجى تعبئة أرقام جميع الشقق!'), backgroundColor: Colors.red));
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
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('اعتماد وحفظ النسخ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ],
        );
      }
    ),
  );
}
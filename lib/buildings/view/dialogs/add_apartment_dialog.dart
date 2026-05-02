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

  final List<String> mainDirections =['شمالي', 'جنوبي', 'شرقي', 'غربي'];
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

        // 🌟 دالة مساعدة لتوحيد تصميم حقول الإدخال
        Widget buildField({
          required TextEditingController controller, 
          required String label, 
          required IconData icon, 
          Color? fillColor, 
          TextInputType keyboardType = TextInputType.number,
          void Function(String)? onChanged
        }) {
          return TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade600),
              filled: true,
              fillColor: fillColor ?? Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.indigo.shade400, width: 2)),
            ),
          );
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.all(24),
          title: Row(
            children:[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.apartment, color: Colors.indigo.shade700, size: 28),
              ),
              const SizedBox(width: 16),
              const Text('إضافة شقة للكتالوج', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22)),
            ],
          ),
          content: SizedBox(
            width: 600, // 🌟 عرض احترافي
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  // ==========================================
                  // 🌟 1. المعلومات الأساسية
                  // ==========================================
                  Row(
                    children:[
                      Expanded(
                        child: buildField(
                          controller: numCtrl, 
                          label: 'رقم الشقة / الرمز', 
                          icon: Icons.tag,
                          keyboardType: TextInputType.text,
                          fillColor: Colors.white,
                        )
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedFloorName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                          decoration: InputDecoration(
                            labelText: 'اختر الطابق (يحدد النسبة آلياً)',
                            prefixIcon: Icon(Icons.layers, size: 20, color: Colors.grey.shade600),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.indigo.shade400, width: 2)),
                          ),
                          items: availableFloors.keys.map((floorName) {
                            final percentage = availableFloors[floorName];
                            return DropdownMenuItem(value: floorName, child: Text('$floorName ($percentage%)'));
                          }).toList(),
                          onChanged: (val) => setState(() => selectedFloorName = val),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // ==========================================
                  // 📐 2. البيانات الهندسية وحساب المساحة
                  // ==========================================
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
                            Icon(Icons.architecture, color: Colors.indigo.shade400),
                            const SizedBox(width: 8),
                            const Text('حساب المساحة البيعية (م²)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // 🌟 حقول المساحات الهندسية
                        buildField(
                          controller: slabAreaCtrl, 
                          label: 'مساحة البلاطة (المسقوفة) م²', 
                          icon: Icons.crop_square,
                          fillColor: Colors.white,
                          onChanged: (_) => updateCalculatedArea(), // التحديث اللحظي
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children:[
                            Expanded(
                              child: buildField(
                                controller: terraceAreaCtrl, 
                                label: 'مساحة التراس م²', 
                                icon: Icons.balcony,
                                fillColor: Colors.white,
                                onChanged: (_) => updateCalculatedArea(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildField(
                                controller: physicalYardAreaCtrl, 
                                label: 'مساحة الوجيبة م²', 
                                icon: Icons.grass,
                                fillColor: Colors.white,
                                onChanged: (_) => updateCalculatedArea(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // 🌟 عرض المساحة النهائية المحسوبة (Dashboard Banner)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors:[Colors.indigo.shade400, Colors.indigo.shade600]),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow:[BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            children:[
                              const Text('المساحة البيعية المعتمدة للعقد', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                '${calculatedTotalArea.toStringAsFixed(2)} م²', 
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // ==========================================
                  // 🧭 3. الاتجاهات
                  // ==========================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.teal.shade200, width: 1.5),
                      boxShadow:[BoxShadow(color: Colors.teal.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Row(
                          children:[
                            Icon(Icons.explore, color: Colors.teal.shade600),
                            const SizedBox(width: 8),
                            const Text('اختيار اتجاهات الشقة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10.0,
                          runSpacing: 10.0,
                          children: mainDirections.map((dir) {
                            final double dirPercentage = (generalCoeffs[dir] as num?)?.toDouble() ?? 0.0;
                            return FilterChip(
                              label: Text('$dir ($dirPercentage%)', style: const TextStyle(fontWeight: FontWeight.bold)),
                              selected: selectedDirections[dir]!,
                              backgroundColor: Colors.teal.shade50,
                              selectedColor: Colors.teal.shade200,
                              checkmarkColor: Colors.teal.shade900,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.teal.shade100)),
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedDirections[dir] = selected;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ]
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==========================================
                  // 💰 4. المعاملات المالية
                  // ==========================================
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade200, width: 1.5),
                      boxShadow:[BoxShadow(color: Colors.green.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        Row(
                          children:[
                            Icon(Icons.percent, color: Colors.green.shade600),
                            const SizedBox(width: 8),
                            const Text('المعاملات المالية الخاصة بالشقة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children:[
                            Expanded(
                              child: buildField(
                                controller: yardCoeffCtrl, 
                                label: 'معامل الوجيبة  %', 
                                icon: Icons.yard_outlined,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildField(
                                controller: profitCoeffCtrl, 
                                label: 'هامش الربح %', 
                                icon: Icons.trending_up,
                                fillColor: const Color(0xFFE8F5E9),
                              ),
                            ),
                          ],
                        ),
                      ]
                    )
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions:[
            TextButton(
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('إلغاء', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey))),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade600, 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              onPressed: () {
                // 🌟 1. التحقق من رقم الشقة
                if (numCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('⚠️ الرجاء إدخال رقم الشقة!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return; // إيقاف إكمال الكود
                }

                // 🌟 2. التحقق من اختيار الطابق
                if (selectedFloorName == null) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('⚠️ الرجاء تحديد الطابق!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // 🌟 3. التحقق من إدخال المساحة
                if (slabAreaCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('⚠️ الرجاء إدخال مساحة البلاطة (المسقوفة)!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // تحديث أخير للمساحة للتأكد
                updateCalculatedArea();

                // 🌟 4. التحقق من أن المساحة صالحة (أكبر من صفر)
                if (calculatedTotalArea <= 0) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('⚠️ المساحة المحسوبة غير صالحة!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // إذا اجتاز الكود كل الفحوصات السابقة، نقوم بتجهيز البيانات والحفظ:
                Map<String, double> aptCoeffs = {};

                // حفظ تفاصيل المساحة الهندسية في الـ JSON للشفافية
                double slab = double.tryParse(slabAreaCtrl.text) ?? 0.0;
                double terrace = double.tryParse(terraceAreaCtrl.text) ?? 0.0;
                double yard = double.tryParse(physicalYardAreaCtrl.text) ?? 0.0;

                if (slab > 0) aptCoeffs['مساحة البلاطة (م2)'] = slab;
                if (terrace > 0) aptCoeffs['مساحة التراس (م2)'] = terrace;
                if (yard > 0) aptCoeffs['مساحة الوجيبة (م2)'] = yard;

                // نسبة الطابق
                final floorPercentage =
                    (availableFloors[selectedFloorName] as num).toDouble();
                if (floorPercentage != 0.0) {
                  aptCoeffs['الطابق ($selectedFloorName)'] = floorPercentage;
                }

                // تجميع الاتجاه
                List<String> chosenNames =[];
                double totalDirPercentage = 0.0;
                selectedDirections.forEach((dirName, isSelected) {
                  if (isSelected) {
                    chosenNames.add(dirName);
                    totalDirPercentage +=
                        (generalCoeffs[dirName] as num?)?.toDouble() ?? 0.0;
                  }
                });
                String finalDirectionName =
                    chosenNames.isEmpty ? 'غير محدد' : chosenNames.join(' - ');
                if (totalDirPercentage != 0.0) {
                  aptCoeffs['الاتجاه ($finalDirectionName)'] =
                      totalDirPercentage;
                }

                // إضافة معامل الوجيبة والربح
                void addVal(String key, String val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null && parsed != 0.0) aptCoeffs[key] = parsed;
                }

                addVal('معامل التميز للوجيبة', yardCoeffCtrl.text);
                addVal('هامش الربح', profitCoeffCtrl.text);

                // الإرسال لقاعدة البيانات
                parentContext.read<BuildingsCubit>().addApartment(
                      buildingId: building.id,
                      aptNumber: numCtrl.text.trim(), // استخدمنا trim لحذف الفراغات
                      area: calculatedTotalArea,
                      floorName: selectedFloorName!,
                      directionName: finalDirectionName,
                      customCoeffs: aptCoeffs,
                    );
                    
                Navigator.pop(dialogCtx);
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('حفظ الشقة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ],
        );
      }
    ),
  );
}
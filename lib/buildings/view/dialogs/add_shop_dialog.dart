// lib/buildings/view/dialogs/add_shop_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Building;
import '../../cubit/buildings_cubit.dart';

void showAddShopDialog(BuildContext parentContext, Building building) {
  final numCtrl = TextEditingController();
  
  // متحكمات المساحة الهندسية
  final slabAreaCtrl = TextEditingController(); 
  final terraceAreaCtrl = TextEditingController(text: '0'); 
  final physicalYardAreaCtrl = TextEditingController(text: '0'); 

  // 🌟 متحكمات المعاملات المالية الخاصة بالمحل
  final locationCoeffCtrl = TextEditingController(text: '0'); // نسبة الموقع
  final streetCoeffCtrl = TextEditingController(text: '0');   // نسبة الشارع
  final facadeCoeffCtrl = TextEditingController(text: '0');   // 🌟 السطر الجديد: نسبة عرض الواجهة
  final yardCoeffCtrl = TextEditingController(text: '0');     // معامل الوجيبة
  final profitCoeffCtrl = TextEditingController(text: '0');   // هامش الربح

  double calculatedTotalArea = 0.0;

  showDialog(
    context: parentContext,
    builder: (dialogCtx) => StatefulBuilder(
      builder: (statefulCtx, setState) {
        
        void updateCalculatedArea() {
          double slab = double.tryParse(slabAreaCtrl.text) ?? 0.0;
          double terrace = double.tryParse(terraceAreaCtrl.text) ?? 0.0;
          double yard = double.tryParse(physicalYardAreaCtrl.text) ?? 0.0;
          setState(() {
            calculatedTotalArea = slab + (terrace * 0.40) + (yard / 8.0);
          });
        }

        return AlertDialog(
          title: const Row(
            children:[
              Icon(Icons.storefront, color: Colors.orange),
              SizedBox(width: 8),
              Text('إضافة محل تجاري', style: TextStyle(color: Colors.orange)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                TextField(
                  controller: numCtrl, 
                  decoration: const InputDecoration(labelText: 'رقم المحل / الرمز', border: OutlineInputBorder())
                ),
                
                const Divider(height: 30, thickness: 2),
                const Text('📐 حساب المساحة البيعية (م2):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 12),
                
                TextField(
                  controller: slabAreaCtrl, 
                  decoration: const InputDecoration(labelText: 'مساحة الأرضي (المسقوفة) م2', border: OutlineInputBorder(), filled: true, fillColor: Colors.white), 
                  keyboardType: TextInputType.number,
                  onChanged: (_) => updateCalculatedArea(),
                ),
                const SizedBox(height: 8),
                Row(
                  children:[
                    Expanded(
                      child: TextField(
                        controller: terraceAreaCtrl, 
                        decoration: const InputDecoration(labelText: 'مساحة السدة (التراس) م2', border: OutlineInputBorder()), 
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
                  child: Text(
                    'المساحة البيعية للمحل: ${calculatedTotalArea.toStringAsFixed(2)} م2', 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const Divider(height: 30, thickness: 2),
                const Text('💰 المعاملات المالية الخاصة بالمحل:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 12),
                Row(
                  children:[
                    Expanded(
                      child: TextField(
                        controller: locationCoeffCtrl, 
                        decoration: const InputDecoration(labelText: 'نسبة الموقع %', border: OutlineInputBorder()), 
                        keyboardType: TextInputType.number
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: streetCoeffCtrl, 
                        decoration: const InputDecoration(labelText: 'نسبة الشارع %', border: OutlineInputBorder()), 
                        keyboardType: TextInputType.number
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children:[
                    // 🌟 الحقل الجديد هنا!
                    Expanded(
                      child: TextField(
                        controller: facadeCoeffCtrl, 
                        decoration: const InputDecoration(labelText: 'نسبة عرض الواجهة %', border: OutlineInputBorder(), filled: true, fillColor: Color(0xFFFFF3E0)), 
                        keyboardType: TextInputType.number
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: yardCoeffCtrl, 
                        decoration: const InputDecoration(labelText: 'معامل الوجيبة %', border: OutlineInputBorder()), 
                        keyboardType: TextInputType.number
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: profitCoeffCtrl, 
                  decoration: const InputDecoration(labelText: 'هامش الربح %', border: OutlineInputBorder(), filled: true, fillColor: Color(0xFFE8F5E9)), 
                  keyboardType: TextInputType.number
                ),
              ],
            ),
          ),
          actions:[
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              onPressed: () {
                if (numCtrl.text.trim().isEmpty || calculatedTotalArea <= 0) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('⚠️ بيانات غير مكتملة أو مساحة غير صالحة!'), backgroundColor: Colors.red));
                  return;
                }

                Map<String, double> aptCoeffs = {};

                double slab = double.tryParse(slabAreaCtrl.text) ?? 0.0;
                double terrace = double.tryParse(terraceAreaCtrl.text) ?? 0.0;
                double yard = double.tryParse(physicalYardAreaCtrl.text) ?? 0.0;

                if (slab > 0) aptCoeffs['مساحة البلاطة (م2)'] = slab;
                if (terrace > 0) aptCoeffs['مساحة التراس (م2)'] = terrace;
                if (yard > 0) aptCoeffs['مساحة الوجيبة (م2)'] = yard;

                void addVal(String key, String val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null && parsed != 0.0) aptCoeffs[key] = parsed; 
                }

                addVal('الموقع', locationCoeffCtrl.text);
                addVal('الشارع', streetCoeffCtrl.text);
                // 🌟 حفظ نسبة الواجهة في قاعدة البيانات ليراها العقد
                addVal('عرض الواجهة', facadeCoeffCtrl.text); 
                addVal('معامل التميز للوجيبة', yardCoeffCtrl.text);
                addVal('هامش الربح', profitCoeffCtrl.text);

                parentContext.read<BuildingsCubit>().addApartment(
                      buildingId: building.id,
                      unitType: 'shop', 
                      aptNumber: numCtrl.text.trim(),
                      area: calculatedTotalArea,
                      floorName: 'تجاري', 
                      directionName: 'واجهة تجارية',
                      customCoeffs: aptCoeffs,
                    );
                    
                Navigator.pop(dialogCtx);
              },
              child: const Text('حفظ المحل'),
            )
          ],
        );
      }
    ),
  );
}
// lib/buildings/view/dialogs/add_shop_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Building;
import '../../cubit/buildings_cubit.dart';

void showAddShopDialog(BuildContext parentContext, Building building) {
  final numCtrl = TextEditingController();
  
  // متحكمات المساحة الهندسية (البيانات الوصفية)
  final slabAreaCtrl = TextEditingController(); 
  final terraceAreaCtrl = TextEditingController(text: '0'); 
  final physicalYardAreaCtrl = TextEditingController(text: '0'); 
  final facadeLengthCtrl = TextEditingController(); // 🌟 الحقل الجديد: عرض الواجهة بالمتر

  // متحكمات المعاملات المالية (%)
  final locationCoeffCtrl = TextEditingController(text: '0'); 
  final streetCoeffCtrl = TextEditingController(text: '0');   
  final facadeCoeffCtrl = TextEditingController(text: '0');   // نسبة تميز الواجهة مالياً
  final yardCoeffCtrl = TextEditingController(text: '0');     
  final profitCoeffCtrl = TextEditingController(text: '0');   

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

        // 🌟 دالة مساعدة داخلية لبناء حقول إدخال احترافية وموحدة
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
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.orange.shade400, width: 2)),
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
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.storefront, color: Colors.orange.shade700, size: 28),
              ),
              const SizedBox(width: 16),
              const Text('إضافة محل تجاري', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22)),
            ],
          ),
          content: SizedBox(
            width: 600, // 🌟 عرض احترافي يناسب الأنظمة المحاسبية المتطورة
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  // ==========================================
                  // 🌟 1. المعلومات الأساسية
                  // ==========================================
                  buildField(
                    controller: numCtrl, 
                    label: 'رقم المحل / الرمز', 
                    icon: Icons.tag,
                    keyboardType: TextInputType.text,
                    fillColor: Colors.white,
                  ),
                  
                  const SizedBox(height: 24),

                  // ==========================================
                  // 📐 2. البيانات الهندسية والمساحات
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
                            const Text('البيانات الهندسية (المساحات والأبعاد)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children:[
                            Expanded(
                              child: buildField(
                                controller: slabAreaCtrl, 
                                label: 'مساحة الأرضي م²', 
                                icon: Icons.crop_square,
                                fillColor: Colors.white,
                                onChanged: (_) => updateCalculatedArea(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildField(
                                controller: facadeLengthCtrl, 
                                label: 'عرض الواجهة (متر)', 
                                icon: Icons.straighten,
                                fillColor: const Color(0xFFF3E5F5), // لون مميز كما طلبت
                              ),
                            ),
                          ],
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
                        
                        // 🌟 لوحة إبراز النتيجة الحسابية (Dashboard Banner)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors:[Colors.orange.shade400, Colors.orange.shade600]),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow:[BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            children:[
                              const Text('المساحة البيعية الإجمالية للمحل', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
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
                  // 💰 3. المعاملات المالية
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
                            const Text('المعاملات المالية المئوية (تؤثر على السعر)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children:[
                            Expanded(
                              child: buildField(
                                controller: locationCoeffCtrl, 
                                label: 'نسبة الموقع %', 
                                icon: Icons.location_on_outlined,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildField(
                                controller: streetCoeffCtrl, 
                                label: 'نسبة الشارع %', 
                                icon: Icons.add_road,
                                fillColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children:[
                            Expanded(
                              child: buildField(
                                controller: facadeCoeffCtrl, 
                                label: 'نسبة التميز للواجهة %', 
                                icon: Icons.star_border,
                                fillColor: const Color(0xFFFFF3E0), // لون مميز كما طلبت
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: buildField(
                                controller: yardCoeffCtrl, 
                                label: 'معامل الوجيبة %', 
                                icon: Icons.yard_outlined,
                                fillColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        buildField(
                          controller: profitCoeffCtrl, 
                          label: 'هامش الربح %', 
                          icon: Icons.trending_up,
                          fillColor: const Color(0xFFE8F5E9), // لون مميز كما طلبت
                        ),
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
              child: const Text('إلغاء', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600, 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              onPressed: () {
                if (numCtrl.text.trim().isEmpty || calculatedTotalArea <= 0) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('⚠️ بيانات غير مكتملة أو مساحة غير صالحة!'), backgroundColor: Colors.red));
                  return;
                }

                Map<String, double> aptCoeffs = {};

                // 1. البيانات الهندسية (لن تدخل في الحسابات المالية بفضل الفلتر)
                double slab = double.tryParse(slabAreaCtrl.text) ?? 0.0;
                double terrace = double.tryParse(terraceAreaCtrl.text) ?? 0.0;
                double yard = double.tryParse(physicalYardAreaCtrl.text) ?? 0.0;
                double facadeLen = double.tryParse(facadeLengthCtrl.text) ?? 0.0;

                if (slab > 0) aptCoeffs['مساحة البلاطة (م2)'] = slab;
                if (terrace > 0) aptCoeffs['مساحة التراس (م2)'] = terrace;
                if (yard > 0) aptCoeffs['مساحة الوجيبة (م2)'] = yard;
                if (facadeLen > 0) aptCoeffs['عرض الواجهة الفعلي (متر)'] = facadeLen; // 🌟 سيتم حفظها للعرض في التفاصيل فقط

                // 2. البيانات المالية المئوية (ستدخل في الحسابات)
                void addVal(String key, String val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null && parsed != 0.0) aptCoeffs[key] = parsed; 
                }

                addVal('الموقع', locationCoeffCtrl.text);
                addVal('الشارع', streetCoeffCtrl.text);
                addVal('تميز الواجهة', facadeCoeffCtrl.text); // النسبة المالية للواجهة
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
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('حفظ المحل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ],
        );
      }
    ),
  );
}
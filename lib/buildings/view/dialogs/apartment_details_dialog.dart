// lib/buildings/view/dialogs/apartment_details_dialog.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:local_storage_api/local_storage_api.dart' show Apartment;

void showApartmentDetailsDialog(BuildContext context, Apartment apt) {
  // 🌟 فصلنا الـ JSON إلى خريطتين مختلفتين
  Map<String, dynamic> physicalAreas = {};  // للمساحات الهندسية
  Map<String, dynamic> financialCoeffs = {}; // للمعاملات المالية

  try {
    Map<String, dynamic> allData = jsonDecode(apt.customCoefficients);
    
    allData.forEach((key, value) {
      if (key.startsWith('مساحة') || key.startsWith('عرض')) { // تمت إضافة 'عرض' لدعم المحلات أيضاً
        physicalAreas[key] = value; // نضع المساحات هنا
      } else {
        financialCoeffs[key] = value; // نضع المعاملات المالية (الربح، الطابق..) هنا
      }
    });
  } catch (e) {
    print('Error decoding: $e');
  }

  final bool isAvailable = apt.status == 'available';

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.all(24),
      title: Row(
        children:[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.info_outline, color: Colors.indigo.shade700, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'تفاصيل الوحدة رقم: ${apt.apartmentNumber}', 
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22)
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isAvailable ? Colors.green.shade200 : Colors.red.shade200, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children:[
                Icon(isAvailable ? Icons.check_circle : Icons.lock, size: 16, color: isAvailable ? Colors.green.shade700 : Colors.red.shade700),
                const SizedBox(width: 6),
                Text(
                  isAvailable ? 'متاحة للبيع' : 'مباعة / محجوزة', 
                  style: TextStyle(color: isAvailable ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 600, // 🌟 إعطاء عرض احترافي متناسق مع باقي النظام
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              // رسالة توضيحية إضافية للحالة
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isAvailable ? Colors.green.shade50.withOpacity(0.5) : Colors.red.shade50.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'الحالة الحالية: ${isAvailable ? "لم يتم توقيع أي عقد عليها بعد وهي متاحة للتعاقد." : "تم توقيع عقد ومربوطة بملف عميل مسبقاً."}', 
                  style: TextStyle(color: isAvailable ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================
              // ℹ️ قسم المعلومات الأساسية
              // ==========================================
              Row(
                children:[
                  Expanded(
                    child: _buildInfoCard('الطابق / المنسوب', apt.floorName, Icons.layers, Colors.blue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoCard('الاتجاه / الواجهة', apt.directionName ?? "-", Icons.explore, Colors.teal),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // ==========================================
              // 📐 🌟 قسم تفاصيل المساحة الهندسية
              // ==========================================
              Container(
                width: double.infinity,
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
                        const Text('تفاصيل الحساب الهندسي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // لوحة المساحة الإجمالية المعتمدة
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors:[Colors.indigo.shade400, Colors.indigo.shade600]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children:[
                          const Text('المساحة البيعية المعتمدة', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            '${apt.area} م²', 
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    
                    if (physicalAreas.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('البيانات المُدخلة للحساب:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      const SizedBox(height: 8),
                      // عرض المساحات كنقاط توضيحية بتصميم أنيق
                      ...physicalAreas.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          children:[
                            const Icon(Icons.check_circle_outline, size: 16, color: Colors.indigo),
                            const SizedBox(width: 8),
                            Expanded(child: Text(e.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                            Text(e.value.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo)),
                          ],
                        ),
                      )),
                    ]
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // ==========================================
              // 💰 🌟 قسم المعاملات المالية (بعد استبعاد المساحات)
              // ==========================================
              Container(
                width: double.infinity,
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
                        const Text('المعاملات المالية المطبقة على هذه الوحدة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (financialCoeffs.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                        child: const Center(child: Text('لا توجد معاملات مالية خاصة مسجلة لهذه الوحدة.', style: TextStyle(color: Colors.grey))),
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: financialCoeffs.entries.map((e) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children:[
                                Text(e.key, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                                  // 🌟 هنا نضع الـ % بكل أمان
                                  child: Text('${e.value}%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                                )
                              ],
                            ),
                          );
                        }).toList(),
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
        SizedBox(
          width: double.infinity, // زر بعرض كامل لإغلاق النافذة
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('إغلاق التفاصيل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    ),
  );
}

// 🌟 دالة مساعدة لإنشاء بطاقات المعلومات الصغيرة
Widget _buildInfoCard(String title, String value, IconData icon, MaterialColor color) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.shade100, width: 1.5),
    ),
    child: Row(
      children:[
        Icon(icon, color: color.shade600, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Text(title, style: TextStyle(fontSize: 12, color: color.shade800, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color.shade900)),
            ],
          ),
        ),
      ],
    ),
  );
}
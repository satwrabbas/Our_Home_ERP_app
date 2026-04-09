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
      if (key.startsWith('مساحة')) {
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('تفاصيل الشقة ${apt.apartmentNumber}', style: const TextStyle(color: Colors.indigo)),
          Chip(
            label: Text(isAvailable ? 'متاحة للبيع' : 'مباعة', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: isAvailable ? Colors.green : Colors.red,
          ),
        ],
      ),
      content: SizedBox(
        width: 400, // إعطاء عرض مناسب للنافذة
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الطابق: ${apt.floorName}', style: const TextStyle(fontSize: 16)),
              Text('الاتجاه: ${apt.directionName ?? "-"}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              
              // 🌟 قسم تفاصيل المساحة الهندسية
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50, 
                  borderRadius: BorderRadius.circular(8), 
                  border: Border.all(color: Colors.indigo.shade200)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('المساحة البيعية المعتمدة: ${apt.area} م2', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    
                    if (physicalAreas.isNotEmpty) ...[
                      const Divider(color: Colors.indigo),
                      const Text('تفاصيل الحساب الهندسي:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      const SizedBox(height: 8),
                      // عرض المساحات كنقاط توضيحية
                      ...physicalAreas.entries.map((e) => Text('• ${e.key} = ${e.value}', style: const TextStyle(fontSize: 14))),
                    ]
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              Text('الحالة الحالية: ${isAvailable ? "لم يتم توقيع عقد عليها بعد" : "تم توقيع عقد ومربوطة بعميل"}', 
                   style: TextStyle(color: isAvailable ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold)),
              
              const Divider(height: 30, thickness: 2),
              const Text('المعاملات المالية المطبقة على هذه الشقة:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 12),
              
              // 🌟 قسم المعاملات المالية (بعد استبعاد المساحات)
              if (financialCoeffs.isEmpty)
                const Text('لا توجد معاملات خاصة مسجلة.')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: financialCoeffs.entries.map((e) {
                    return Chip(
                      label: Text('${e.key}: ${e.value}%'), // 🌟 هنا نضع الـ % بكل أمان
                      backgroundColor: Colors.teal.shade50,
                      side: BorderSide(color: Colors.teal.shade200),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
      ],
    ),
  );
}
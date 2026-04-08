// lib/buildings/view/dialogs/apartment_details_dialog.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:local_storage_api/local_storage_api.dart' show Apartment;

// 🌟 حولنا الدالة إلى عامة
void showApartmentDetailsDialog(BuildContext context, Apartment apt) {
  Map<String, dynamic> aptCoeffs = {};
  try {
    aptCoeffs = jsonDecode(apt.customCoefficients);
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الطابق: ${apt.floorName}', style: const TextStyle(fontSize: 16)),
          Text('الاتجاه: ${apt.directionName ?? "-"}', style: const TextStyle(fontSize: 16)),
          Text('المساحة: ${apt.area} م2', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('الحالة الحالية: ${isAvailable ? "لم يتم توقيع عقد عليها بعد" : "تم توقيع عقد ومربوطة بعميل"}', 
               style: TextStyle(color: isAvailable ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold)),
          
          const Divider(height: 30, thickness: 2),
          const Text('المعاملات المطبقة على هذه الشقة:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
          const SizedBox(height: 12),
          if (aptCoeffs.isEmpty)
            const Text('لا توجد معاملات خاصة مسجلة.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: aptCoeffs.entries.map((e) {
                return Chip(
                  label: Text('${e.key}: ${e.value}%'),
                  backgroundColor: Colors.teal.shade50,
                  side: BorderSide(color: Colors.teal.shade200),
                );
              }).toList(),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
      ],
    ),
  );
}
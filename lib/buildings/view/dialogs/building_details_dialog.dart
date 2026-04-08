// lib/buildings/view/dialogs/building_details_dialog.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:local_storage_api/local_storage_api.dart' show Building;

// 🌟 حولنا الدالة إلى عامة
void showBuildingDetailsDialog(BuildContext context, Building building) {
  Map<String, dynamic> floorCoeffs = {};
  Map<String, dynamic> generalCoeffs = {};

  try {
    floorCoeffs = jsonDecode(building.floorCoefficients);
    generalCoeffs = jsonDecode(building.directionCoefficients);
  } catch (e) {
    print('Error decoding building coeffs: $e');
  }

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('تفاصيل محضر: ${building.name}', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الموقع الجغرافي: ${building.location ?? "غير محدد"}', style: const TextStyle(fontSize: 16)),
            
            const Divider(height: 30, thickness: 2),
            
            const Text('المعاملات العامة للمحضر:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 12),
            if (generalCoeffs.isEmpty)
              const Text('لا توجد معاملات عامة مسجلة.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: generalCoeffs.entries.map((e) {
                  return Chip(
                    label: Text('${e.key}: ${e.value}%'),
                    backgroundColor: Colors.amber.shade50,
                    side: BorderSide(color: Colors.amber.shade200),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            const Text('هيكل الطوابق ونسب التمييز:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 12),
            if (floorCoeffs.isEmpty)
              const Text('لم يتم إعداد هيكل طوابق لهذا المحضر.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: floorCoeffs.entries.map((e) {
                  return Chip(
                    label: Text('${e.key}  [ ${e.value}% ]'),
                    backgroundColor: Colors.indigo.shade50,
                    side: BorderSide(color: Colors.indigo.shade200),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
      ],
    ),
  );
}
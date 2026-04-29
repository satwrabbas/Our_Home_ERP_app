// lib/buildings/view/dialogs/edit_building_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Building;
import '../../cubit/buildings_cubit.dart';

void showEditBuildingDialog(BuildContext parentContext, Building building) {
  final nameController = TextEditingController(text: building.name);
  final locationController = TextEditingController(text: building.location ?? '');

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.all(24),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[
            Row(
              children:[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.edit_location_alt, color: Colors.indigo.shade700, size: 28),
                ),
                const SizedBox(width: 16),
                const Text('تعديل بيانات المحضر', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22)),
              ],
            ),
            
            // 🌟 أيقونة الحذف مع التأكيد بتصميم جديد
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red, size: 28),
              tooltip: 'حذف المحضر',
              onPressed: () {
                // إظهار نافذة تأكيد قبل الحذف
                showDialog(
                  context: dialogContext,
                  builder: (confirmCtx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Row(
                      children:[
                        Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                        SizedBox(width: 8),
                        Text('تأكيد الحذف', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    content: const Text(
                      'هل أنت متأكد من رغبتك في حذف هذا المحضر ونقله إلى سلة المحذوفات؟\n\n(سيتم حذف جميع الوحدات المتاحة داخله آلياً. ولن تتمكن من حذفه إذا كان يحتوي على وحدات مباعة)', 
                      style: TextStyle(fontSize: 15, height: 1.5)
                    ),
                    actions:[
                      TextButton(
                        onPressed: () => Navigator.pop(confirmCtx), 
                        child: const Text('إلغاء', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () {
                          // إرسال أمر الحذف للـ Cubit (الذي بدوره سيتأكد إذا كان الحذف مسموحاً)
                          parentContext.read<BuildingsCubit>().deleteBuilding(building.id);
                          Navigator.pop(confirmCtx); // إغلاق رسالة التأكيد
                          Navigator.pop(dialogContext); // إغلاق نافذة التعديل
                        },
                        child: const Text('نعم، احذف المحضر', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        content: SizedBox(
          width: 600, // 🌟 عرض احترافي متناسق مع النظام
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                // 🌟 رسالة توضيحية (Info Banner)
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
                          'يمكنك تعديل اسم المحضر وموقعه بحرية. لن يؤثر ذلك على العقود أو الحسابات المالية المرتبطة به.', 
                          style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 🌟 حقل الاسم
                TextField(
                  controller: nameController, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'اسم المحضر / المشروع', 
                    prefixIcon: const Icon(Icons.business, color: Colors.indigo),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.indigo.shade400, width: 2)),
                  )
                ),
                
                const SizedBox(height: 16),
                
                // 🌟 حقل الموقع
                TextField(
                  controller: locationController, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'الموقع / العنوان', 
                    prefixIcon: const Icon(Icons.location_on, color: Colors.indigo),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.indigo.shade400, width: 2)),
                  )
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions:[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
            child: const Text('إلغاء', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey))
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600, 
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
            ),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                parentContext.read<BuildingsCubit>().updateBuilding(
                  id: building.id,
                  name: nameController.text.trim(),
                  location: locationController.text.trim(),
                );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('تم حفظ التعديلات بنجاح ✅'), backgroundColor: Colors.green));
              } else {
                ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('اسم المحضر مطلوب!'), backgroundColor: Colors.red));
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('حفظ التعديلات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );
}
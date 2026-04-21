// lib/clients/view/dialogs/edit_client_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Client; // استيراد نوع العميل بآمان
import '../../cubit/clients_cubit.dart';
import 'verify_pin_dialog.dart';

void showEditClientDialog(BuildContext parentContext, Client client) {
  final nameController = TextEditingController(text: client.name);
  final phoneController = TextEditingController(text: client.phone);
  final nationalIdController = TextEditingController(text: client.nationalId ?? '');

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('تعديل بيانات العميل', style: TextStyle(color: Colors.blue)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم الرباعي', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'رقم الهاتف (للواتساب)', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              TextField(controller: nationalIdController, decoration: const InputDecoration(labelText: 'الرقم الوطني (اختياري)', border: OutlineInputBorder())),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween, 
        actions:[
          // 🗑️ زر الحذف
          TextButton.icon(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            label: const Text('حذف مؤقت', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(dialogContext); // إغلاق النافذة
              bool isAuthorized = await showVerifyPinDialog(parentContext); 
              if (isAuthorized && parentContext.mounted) {
                parentContext.read<ClientsCubit>().deleteClient(client.id);
              }
            },
          ),
          
          // ✏️ أزرار الحفظ والإلغاء
          Row(
            mainAxisSize: MainAxisSize.min,
            children:[
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                onPressed: () async {
                  if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                    Navigator.pop(dialogContext);
                    bool isAuthorized = await showVerifyPinDialog(parentContext);
                    if (isAuthorized && parentContext.mounted) {
                      parentContext.read<ClientsCubit>().updateClient(
                        id: client.id, 
                        name: nameController.text,
                        phone: phoneController.text,
                        nationalId: nationalIdController.text.isEmpty ? null : nationalIdController.text,
                      );
                    }
                  }
                },
                child: const Text('حفظ التعديلات'),
              ),
            ],
          )
        ],
      );
    },
  );
}
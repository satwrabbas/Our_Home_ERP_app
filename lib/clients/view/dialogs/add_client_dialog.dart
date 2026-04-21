// lib/clients/view/dialogs/add_client_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/clients_cubit.dart';

void showAddClientDialog(BuildContext parentContext) {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final nationalIdController = TextEditingController();

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('إضافة عميل جديد'),
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
        actions:[
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                parentContext.read<ClientsCubit>().addClient(
                  name: nameController.text,
                  phone: phoneController.text,
                  nationalId: nationalIdController.text.isEmpty ? null : nationalIdController.text,
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('حفظ العميل'),
          ),
        ],
      );
    },
  );
}
// lib/clients/view/dialogs/confirm_hard_delete_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Client;
import '../../cubit/clients_cubit.dart';

void showConfirmHardDeleteDialog(BuildContext context, Client client) {
  final pinController = TextEditingController();
  const String correctPin = '0938457732'; // 🌟 رمز الأمان المخصص للحذف النهائي

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Row(
        children:[
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text('تحذير نهائي', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children:[
          Text('هل أنت متأكد من حذف العميل "${client.name}" نهائياً؟ هذا الإجراء لا يمكن التراجع عنه.\n\nيرجى إدخال رمز المدير للتأكيد:'),
          const SizedBox(height: 16),
          TextField(
            controller: pinController,
            obscureText: true, 
            keyboardType: TextInputType.number, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, letterSpacing: 4),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'رمز الأمان',
            ),
          ),
        ],
      ),
      actions:[
        TextButton(
          onPressed: () => Navigator.pop(ctx), 
          child: const Text('إلغاء', style: TextStyle(color: Colors.grey))
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: () {
            if (pinController.text == correctPin) {
              context.read<ClientsCubit>().forceHardDelete(client.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم الحذف النهائي بنجاح.'), backgroundColor: Colors.green)
              );
            } else {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('رمز الأمان غير صحيح! ❌'), backgroundColor: Colors.red)
              );
              pinController.clear();
            }
          },
          child: const Text('حذف نهائي'),
        ),
      ],
    ),
  );
}
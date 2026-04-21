// lib/contracts/view/dialogs/confirm_hard_delete_contract_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract;
import '../../cubit/contracts_cubit.dart';

void showConfirmHardDeleteDialog(BuildContext context, Contract contract, String clientName) {
  final pinController = TextEditingController();
  const String correctPin = '0938457732'; 

  showDialog(
    context: context,
    barrierDismissible: false, 
    builder: (ctx) => AlertDialog(
      title: const Row(
        children:[
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text('تحذير مالي نهائي!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children:[
          Text('أنت على وشك حذف عقد العميل "$clientName" نهائياً!\n\nسيؤدي هذا إلى حذف كل سجلات مدفوعاته وأقساطه المرتبطة به. الإجراء مدمر ولا يمكن التراجع عنه.\n\nيرجى إدخال رمز المدير للتأكيد:'),
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
              context.read<ContractsCubit>().forceHardDelete(contract.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم محو العقد وسجلاته المالية بنجاح.'), backgroundColor: Colors.green)
              );
            } else {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('رمز الأمان غير صحيح! ❌'), backgroundColor: Colors.red)
              );
              pinController.clear();
            }
          },
          child: const Text('حذف نهائي مدمر'),
        ),
      ],
    ),
  );
}
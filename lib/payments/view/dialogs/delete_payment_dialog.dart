// lib/payments/view/dialogs/delete_payment_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart';
import '../../cubit/payments_cubit.dart';
import 'pin_verify_dialog.dart';

Future<void> showDeletePaymentDialog(BuildContext parentContext, PaymentsLedgerData entry) async {
  // 1. طلب الرمز العادي
  bool isAuthorized = await verifyPinCode(parentContext, '0000', 'حذف الإيصال الأخير يتطلب رمز المحاسب');
  if (!isAuthorized) return;

  if (!parentContext.mounted) return;

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('تأكيد إلغاء الإيصال', style: TextStyle(color: Colors.red)),
        content: const Text('إلغاء هذا الإيصال سيؤدي إلى خصم الأمتار المحولة الخاصة به وإعادة فتح الأقساط التي سُددت بسببه.\nهل أنت متأكد؟'),
        actions:[
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('تراجع')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('جاري إلغاء الإيصال وإعادة ضبط الأقساط... ⏳')));
              parentContext.read<PaymentsCubit>().softDeleteLastEntry(entry);
            }, 
            child: const Text('نعم، قم بالإلغاء'),
          ),
        ],
      );
    },
  );
}
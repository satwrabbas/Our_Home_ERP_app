// lib/contracts/view/dialogs/verify_pin_dialog.dart
import 'package:flutter/material.dart';

Future<bool> showVerifyPinDialog(BuildContext context) async {
  final pinController = TextEditingController();
  bool isAuthorized = false;
  const String correctPin = '0000'; // 🌟 الرمز الافتراضي للإدارة

  await showDialog(
    context: context,
    barrierDismissible: false, 
    builder: (ctx) {
      return AlertDialog(
        title: const Row(
          children:[
            Icon(Icons.lock_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('تأكيد الصلاحية', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            const Text('هذه العملية حساسة مالياً. يرجى إدخال رمز الأمان:'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              obscureText: true, 
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 4,
              style: const TextStyle(fontSize: 24, letterSpacing: 12),
              decoration: const InputDecoration(border: OutlineInputBorder(), counterText: ''),
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
                isAuthorized = true;
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('الرمز غير صحيح! ❌'), backgroundColor: Colors.red)
                );
                pinController.clear();
              }
            },
            child: const Text('تأكيد'),
          ),
        ],
      );
    },
  );

  return isAuthorized;
}
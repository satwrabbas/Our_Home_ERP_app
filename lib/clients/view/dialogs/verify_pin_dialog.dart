// lib/clients/view/dialogs/verify_pin_dialog.dart
import 'package:flutter/material.dart';

Future<bool> showVerifyPinDialog(BuildContext context) async {
  final pinController = TextEditingController();
  bool isAuthorized = false;
  const String correctPin = '0000'; // 🌟 الرمز الافتراضي (يمكنك تغييره)

  await showDialog(
    context: context,
    barrierDismissible: false, // لا يمكن إغلاقها بالنقر خارجها
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.all(24),
        title: Row(
          children:[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.security, color: Colors.red.shade700, size: 28),
            ),
            const SizedBox(width: 16),
            const Text('تأكيد الصلاحية', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        content: SizedBox(
          width: 450, // 🌟 عرض مركّز يناسب إدخال الرموز
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              const Text('هذه العملية حساسة ومراقبة. يرجى إدخال رمز الأمان (PIN) الخاص بالإدارة للمتابعة.', style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
              const SizedBox(height: 24),
              TextField(
                controller: pinController,
                obscureText: true, // إخفاء الأرقام ككلمة سر
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 4,
                autofocus: true, // لفتح لوحة المفاتيح تلقائياً
                style: const TextStyle(fontSize: 32, letterSpacing: 24, fontWeight: FontWeight.bold), // تصميم احترافي للرمز
                decoration: InputDecoration(
                  hintText: '----',
                  hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 32, letterSpacing: 24),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.red.shade400, width: 2)),
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actions:[
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
            child: const Text('إلغاء', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey))
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700, 
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (pinController.text == correctPin) {
                isAuthorized = true;
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                    content: Text('الرمز غير صحيح! ❌', style: TextStyle(fontWeight: FontWeight.bold)), 
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  )
                );
                pinController.clear();
              }
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('تأكيد الصلاحية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      );
    },
  );

  return isAuthorized;
}
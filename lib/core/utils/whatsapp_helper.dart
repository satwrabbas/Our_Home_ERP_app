import 'package:url_launcher/url_launcher.dart';
import 'package:erp_repository/erp_repository.dart';

class WhatsAppHelper {
  /// دالة لتجهيز الرسالة وإرسالها عبر واتساب
  static Future<bool> sendReceiptMessage({
    required Payment payment,
    required Contract contract,
    required Client client,
  }) async {
    // 1. تنظيف رقم الهاتف (إزالة المسافات، وتعديل الصفر إلى مفتاح سوريا 963 كمثال)
    // يمكنك تعديل مفتاح الدولة حسب بلدك.
    String phone = client.phone.replaceAll(RegExp(r'\D'), ''); // إزالة أي رموز غير رقمية
    if (phone.startsWith('0')) {
      phone = '963${phone.substring(1)}'; // تحويل 09.. إلى 9639..
    } else if (!phone.startsWith('963')) {
      phone = '963$phone'; // احتياطاً إذا أدخل الرقم بدون صفر أو مفتاح
    }

    // 2. صياغة الرسالة الاحترافية المعتمدة
    final String message = '''
مرحباً أستاذ ${client.name}،
تم استلام مبلغ قدره *${payment.amountPaid.toStringAsFixed(0)} ل.س* بنجاح.
وذلك عن القسط رقم (${payment.installmentNumber}) لشقة (${contract.apartmentDescription}).

رقم الإيصال: ${payment.id}
تاريخ الدفع: ${payment.paymentDate.year}/${payment.paymentDate.month}/${payment.paymentDate.day}

شكراً لثقتكم بنا. 🏢
''';

    // 3. تحويل النص إلى صيغة تقبلها الروابط (URL Encoding)
    final String encodedMessage = Uri.encodeComponent(message);

    // 4. إنشاء رابط واتساب المباشر
    final Uri whatsappUrl = Uri.parse('https://wa.me/$phone?text=$encodedMessage');

    // 5. محاولة فتح الرابط (سيفتح تطبيق واتساب للويندوز أو المتصفح)
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      return true; // نجح الفتح
    } else {
      return false; // فشل (الواتساب غير مثبت أو لا يوجد متصفح)
    }
  }
}
import 'package:url_launcher/url_launcher.dart';
import 'package:erp_repository/erp_repository.dart';

class WhatsAppHelper {
  static Future<bool> sendReceiptMessage({
    required PaymentsLedgerData entry, // ✅ تم التحديث إلى النوع الجديد
    required Contract contract,
    required Client client,
  }) async {
    String phone = client.phone.replaceAll(RegExp(r'\D'), '');
    if (phone.startsWith('0')) {
      phone = '963${phone.substring(1)}';
    } else if (!phone.startsWith('963')) {
      phone = '963$phone';
    }

    // صياغة رسالة احترافية تعتمد على تفاصيل الأمتار المحولة
    final String message = '''
مرحباً أستاذ/ة ${client.name}،
تم استلام الدفعة الخاصة بكم بنجاح بمبلغ قدره *${entry.amountPaid.toStringAsFixed(0)} ل.س*.
وذلك عن شقة (${contract.apartmentDetails}).

*تفاصيل الدفعة:*
- رقم الإيصال: ${entry.id}
- تاريخ الدفع: ${entry.paymentDate.year}/${entry.paymentDate.month}/${entry.paymentDate.day}
- سعر المتر المعتمد وقت الدفع: ${entry.meterPriceAtPayment.toStringAsFixed(0)} ل.س
- الأمتار المحولة بهذه الدفعة: ${entry.convertedMeters.toStringAsFixed(3)} م2

شكراً لثقتكم بنا في "بيتنا Our Home". 🏢
''';

    final String encodedMessage = Uri.encodeComponent(message);
    final Uri whatsappUrl = Uri.parse('https://wa.me/$phone?text=$encodedMessage');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      return true;
    } else {
      return false;
    }
  }
}
import 'dart:typed_data'; // ضروري للتعامل مع الـ Bytes
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:erp_repository/erp_repository.dart';

class PdfGenerator {
  /// دالة تقوم بتوليد الفاتورة وإرجاعها كملف بايتات (Uint8List) لعرضها في شاشة المعاينة
  static Future<Uint8List> generateReceiptPdf({
    required Payment payment,
    required Contract contract,
    required Client client,
  }) async {
    final pdf = pw.Document();

    // جلب خطوط تدعم اللغة العربية
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5, // حجم A5
        textDirection: pw.TextDirection.rtl, // دعم العربي
        theme: pw.ThemeData.withFont(
          base: arabicFont,
          bold: arabicBoldFont,
        ),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.teal, width: 2),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children:[
                pw.Center(
                  child: pw.Text('وصل استلام قسط', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
                ),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 16),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children:[
                    pw.Text('رقم الإيصال: ${payment.id}', style: const pw.TextStyle(fontSize: 14)),
                    pw.Text('التاريخ: ${payment.paymentDate.year}/${payment.paymentDate.month}/${payment.paymentDate.day}', style: const pw.TextStyle(fontSize: 14)),
                  ]
                ),
                pw.SizedBox(height: 24),
                pw.Text('استلمنا من الفريق الثاني السيد/ة: ${client.name}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),
                pw.Text('مبلغاً وقدره: ${payment.amountPaid.toStringAsFixed(0)} ل.س', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),
                pw.Text('وذلك عن: القسط رقم (${payment.installmentNumber}) لشقة (${contract.apartmentDescription})', style: const pw.TextStyle(fontSize: 16)),
                pw.SizedBox(height: 32),
                pw.Container(
                  color: PdfColors.grey200,
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children:[
                      pw.Text('أصل القسط المتفق عليه في العقد:', style: const pw.TextStyle(fontSize: 14)),
                      pw.Text('${payment.originalInstallment.toStringAsFixed(0)} ل.س', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ]
                  )
                ),
                pw.Spacer(),
                pw.Divider(),
                pw.SizedBox(height: 16),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children:[
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children:[
                        pw.Text('توقيع المستلم (الفريق الأول)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 40),
                        pw.Text('.............................'),
                      ]
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children:[
                        pw.Text('توقيع الدافع (الفريق الثاني)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 40),
                        pw.Text('.............................'),
                      ]
                    ),
                  ]
                ),
              ],
            ),
          );
        },
      ),
    );

    // بدلاً من الطباعة المباشرة، نُعيد الملف كـ Bytes
    return pdf.save();
  }
}
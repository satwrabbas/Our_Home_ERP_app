import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:erp_repository/erp_repository.dart';

class PdfGenerator {
  static String numberToArabicWords(double number) {
    return "${number.toStringAsFixed(0)} ليرة سورية فقط لا غير"; 
  }

  static Future<Uint8List> generateReceiptPdf({
    required PaymentsLedgerData entry, // ✅ تم التحديث إلى النوع الجديد
    required Contract contract,
    required Client client,
  }) async {
    final pdf = pw.Document();

    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();

    pw.Widget buildReceipt(String copyType) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.black, width: 1.5),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children:[
            // --- الترويسة العليا ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children:[
                pw.Text('بيتنا  our home', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text('وصل استلام دفعة', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                pw.Text(copyType, style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
              ]
            ),
            pw.SizedBox(height: 16),

            // --- معلومات الدفع ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children:[
                pw.Text('اسم الفريق الثاني: ${client.name}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text('تاريخ الدفع: ${entry.paymentDate.year}/${entry.paymentDate.month}/${entry.paymentDate.day}', style: const pw.TextStyle(fontSize: 14)),
              ]
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children:[
                pw.Text('رقم الإيصال: ${entry.id}', style: const pw.TextStyle(fontSize: 14)),
                pw.Text('مساحة الشقة: ${contract.totalArea} م2', style: const pw.TextStyle(fontSize: 14)),
              ]
            ),
            pw.SizedBox(height: 16),

            // --- المبالغ والتفقيط ---
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              color: PdfColors.grey200,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children:[
                  pw.Text('إجمالي المبلغ المدفوع: ${entry.amountPaid.toStringAsFixed(0)} ل.س', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('فقط: ${numberToArabicWords(entry.amountPaid)}', style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic)),
                ]
              )
            ),
            pw.SizedBox(height: 16),

            // --- تفاصيل الأمتار المحولة ---
            pw.Text('تفاصيل الدفعة والأمتار المحولة:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children:[
                pw.Text('سعر المتر المربع وقت الدفع: ${entry.meterPriceAtPayment.toStringAsFixed(0)} ل.س', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('الأمتار المحولة بهذه الدفعة: ${entry.convertedMeters.toStringAsFixed(3)} م2', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              ]
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children:[
                pw.Text('الرسوم: ${entry.fees.toStringAsFixed(0)} ل.س', style: const pw.TextStyle(fontSize: 12)),
              ]
            ),
            
            pw.Spacer(),
            pw.Divider(),
            pw.SizedBox(height: 8),

            // --- التواقيع ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children:[
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children:[
                    pw.Text('توقيع الفريق الأول :', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 30),
                    pw.Text('م.محمد كامل علي', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ]
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children:[
                    pw.Text('توقيع الفريق الثاني :', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 30),
                    pw.Text(client.name, style: pw.TextStyle(fontSize: 12)),
                  ]
                ),
              ]
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text('انشاء المستخدم: م.محمد كامل علي', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey)),
            ),
          ],
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicBoldFont),
        build: (pw.Context context) {
          return pw.Column(
            children:[
              pw.Expanded(child: buildReceipt('نسخة الفريق الاول')),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 16),
                child: pw.Row(
                  children:[
                    pw.Expanded(child: pw.Divider(borderStyle: pw.BorderStyle.dashed)),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8),
                      child: pw.Text('✂️ قص هنا', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                    ),
                    pw.Expanded(child: pw.Divider(borderStyle: pw.BorderStyle.dashed)),
                  ]
                ),
              ),
              pw.Expanded(child: buildReceipt('نسخة الفريق الثاني')),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
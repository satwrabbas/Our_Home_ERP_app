// lib/core/utils/pdf_generator.dart
import 'dart:convert'; 
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart'; // 🌟 أضفناه ليتعرف على البيانات

class PdfGenerator {
  // دالة التفقيط
  static String numberToArabicWords(double number) {
    return "${number.toStringAsFixed(0)} ليرة سورية فقط لا غير"; 
  }

  static Future<Uint8List> generateReceiptPdf({
    required PaymentsLedgerData entry,
    required Contract contract,
    required Client client,
  }) async {
    final pdf = pw.Document();

    // 🌟 جلب الخطوط
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();

    // 🌟 الألوان المؤسسية الموحدة
    const primaryColor = PdfColor.fromInt(0xFF1A2B3D); // Navy Blue
    const accentColor = PdfColor.fromInt(0xFFE64A19); // Deep Orange

    // تصميم الوصل الواحد (نصف صفحة)
    pw.Widget buildReceipt(String copyType) {
      
      // ========================================================
      // 🌟 السحر المحاسبي: استخراج لقطة الأسعار التاريخية (Snapshot)
      // ========================================================
      Map<String, dynamic> snapshot = {};
      try {
        if (entry.pricesSnapshot.isNotEmpty && entry.pricesSnapshot != '{}') {
          snapshot = jsonDecode(entry.pricesSnapshot);
        }
      } catch (e) {
        print('Error decoding prices snapshot: $e');
      }

      String getPrice(String key) {
        if (snapshot.containsKey(key) && snapshot[key] != null) {
          return (snapshot[key] as num).toStringAsFixed(0);
        }
        return 'غير متوفر'; 
      }

      String getTotal(String key, double quantity) {
        if (snapshot.containsKey(key) && snapshot[key] != null) {
          return ((snapshot[key] as num) * quantity).toStringAsFixed(0);
        }
        return '-';
      }
      // ========================================================

      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: primaryColor, width: 1.0), // إطار بلون الشركة
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // --- الترويسة العليا ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('بيتنا العقارية', style: pw.TextStyle(font: arabicBoldFont, fontSize: 14, color: primaryColor)),
                    pw.Text('تاريخ الدفع: ${entry.paymentDate.year}/${entry.paymentDate.month}/${entry.paymentDate.day}', style: pw.TextStyle(font: arabicFont, fontSize: 9)),
                    pw.Text('رقم الإيصال: ${entry.id.split('-').first.toUpperCase()}', style: pw.TextStyle(font: arabicFont, fontSize: 9)),
                  ]
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('وصل استلام قسط مالي', style: pw.TextStyle(font: arabicBoldFont, fontSize: 12, color: accentColor)),
                    pw.SizedBox(height: 4),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200, 
                        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                        borderRadius: pw.BorderRadius.circular(4)
                      ),
                      child: pw.Text(copyType, style: pw.TextStyle(font: arabicBoldFont, fontSize: 9, color: primaryColor)),
                    ),
                  ]
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('العميل: ${client.name}', style: pw.TextStyle(font: arabicBoldFont, fontSize: 10, color: primaryColor)),
                    pw.Text('الشقة: ${contract.apartmentDetails}', style: pw.TextStyle(font: arabicFont, fontSize: 9)),
                    pw.Text('المساحة: ${contract.totalArea} م2', style: pw.TextStyle(font: arabicFont, fontSize: 9)),
                  ]
                ),
              ]
            ),
            
            pw.SizedBox(height: 10),

            // --- النص التوضيحي الموحد ---
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                border: pw.Border.all(color: primaryColor, width: 0.5),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                'المعيار الدائم لحساب القسط الشهري بدلالة قيمة البنود التالية وفق السعر المتفق عليه بتاريخ دفع القسط:',
                style: pw.TextStyle(font: arabicBoldFont, fontSize: 8, color: primaryColor),
                textAlign: pw.TextAlign.center,
              ),
            ),
            
            pw.SizedBox(height: 8),

            // --- جدول تفاصيل المواد ---
            pw.TableHelper.fromTextArray(
              context: null,
              cellAlignment: pw.Alignment.center,
              // رأس الجدول بخط عريض ولون كحلي
              headerStyle: pw.TextStyle(font: arabicBoldFont, fontSize: 8, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: primaryColor),
              // خلايا الجدول بخط عادي
              cellStyle: pw.TextStyle(font: arabicFont, fontSize: 8),
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1), 
                1: const pw.FlexColumnWidth(4), 
                2: const pw.FlexColumnWidth(1), 
                3: const pw.FlexColumnWidth(1.5), 
                4: const pw.FlexColumnWidth(2), 
                5: const pw.FlexColumnWidth(2), 
              },
              headers: ['م', 'نوع العمل', 'الوحدة', 'الكمية', 'السعر الإفرادي', 'السعر الإجمالي'],
              data: [
                ['1', 'ثمن حديد مبروم واصل الى موقع العمل', 'كغ', '48', getPrice('iron'), getTotal('iron', 48.0)],
                ['2', 'ثمن اسمنت واصل الى موقع العمل', 'كيس', '1.6', getPrice('cement'), getTotal('cement', 1.6)],
                ['3', 'ثمن بلوك اسمنتي سماكة 15 سم واصل', 'بلوكة', '17', getPrice('block'), getTotal('block', 17.0)],
                ['4', 'اجور كوفراج و صب حديد وتحديد بيتون', 'م3', '1.35', getPrice('formwork'), getTotal('formwork', 1.35)],
                ['5', 'ثمن مواد حصوية جرجرة (بحص+نحاته) واصل', 'م3', '7', getPrice('aggregates'), getTotal('aggregates', 7.0)],
                ['6', 'اجور عمل لعامل عادي  7 ساعات', 'يوم', '0.25', getPrice('worker'), getTotal('worker', 0.25)],
              ],
            ),

            pw.SizedBox(height: 10),

            // --- الخلاصة المالية والامتار (بنفس استايل كشف الحساب) ---
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: pw.BoxDecoration(
                border: pw.Border(left: pw.BorderSide(color: accentColor, width: 4)), // خط برتقالي جانبي
                color: PdfColors.grey100,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('سعر المتر المربع بتاريخه:', style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColors.grey700)),
                      pw.Text('${entry.meterPriceAtPayment.toStringAsFixed(0)} ل.س', style: pw.TextStyle(font: arabicBoldFont, fontSize: 11, color: primaryColor)),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('القسط المدفوع:', style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColors.grey700)),
                      pw.Text('${entry.amountPaid.toStringAsFixed(0)} ل.س', style: pw.TextStyle(font: arabicBoldFont, fontSize: 11, color: primaryColor)),
                      pw.Text('(${numberToArabicWords(entry.amountPaid)})', style: pw.TextStyle(font: arabicFont, fontSize: 7, color: PdfColors.grey600)),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('إجمالي الأمتار المحولة:', style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColors.grey700)),
                      pw.Text('${entry.convertedMeters.toStringAsFixed(3)} م2', style: pw.TextStyle(font: arabicBoldFont, fontSize: 12, color: PdfColors.green700)),
                    ]
                  ),
                ]
              )
            ),

            pw.Spacer(),

            // --- التواقيع ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('توقيع الفريق الأول', style: pw.TextStyle(font: arabicBoldFont, fontSize: 9, color: primaryColor)),
                    pw.SizedBox(height: 25),
                    pw.Text('م.محمد كامل علي', style: pw.TextStyle(font: arabicBoldFont, fontSize: 9)),
                  ]
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('المستلم / المدقق', style: pw.TextStyle(font: arabicBoldFont, fontSize: 9, color: primaryColor)),
                    pw.SizedBox(height: 25),
                    pw.Text('.......................', style: pw.TextStyle(font: arabicFont, fontSize: 9)),
                  ]
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('توقيع الفريق الثاني', style: pw.TextStyle(font: arabicBoldFont, fontSize: 9, color: primaryColor)),
                    pw.SizedBox(height: 25),
                    pw.Text(client.name, style: pw.TextStyle(font: arabicBoldFont, fontSize: 9)),
                  ]
                ),
              ]
            ),
            
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text('Our Home ERP System', style: pw.TextStyle(font: arabicFont, fontSize: 7, color: PdfColors.grey500)),
            ),
          ],
        ),
      );
    }

    // بناء الصفحة وتقسيمها لنصفين
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicBoldFont),
        margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Expanded(child: buildReceipt('نسخة الشركة / الإدارة')), // تم تعديل النص ليصبح أكثر احترافية
              
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 12),
                child: pw.Row(
                  children: [
                    pw.Expanded(child: pw.Divider(borderStyle: pw.BorderStyle.dashed, color: PdfColors.grey500)),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8),
                      child: pw.Text('✂️ قص هنا', style: pw.TextStyle(font: arabicFont, fontSize: 9, color: PdfColors.grey600)),
                    ),
                    pw.Expanded(child: pw.Divider(borderStyle: pw.BorderStyle.dashed, color: PdfColors.grey500)),
                  ]
                ),
              ),
              
              pw.Expanded(child: buildReceipt('نسخة العميل')), // تم تعديل النص
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
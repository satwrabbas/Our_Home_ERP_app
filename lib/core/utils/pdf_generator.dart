// lib/core/utils/pdf_generator.dart
import 'dart:convert'; // 🌟 السطر الجديد لفك تشفير الـ JSON
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:erp_repository/erp_repository.dart';

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

    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();

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

      // دوال مساعدة لطباعة السعر وتجنب الأخطاء للبيانات القديمة
      String getPrice(String key) {
        if (snapshot.containsKey(key) && snapshot[key] != null) {
          return (snapshot[key] as num).toStringAsFixed(0);
        }
        return 'غير متوفر'; // للبيانات القديمة التي لم تحفظ بصيغة Snapshot
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
          border: pw.Border.all(color: PdfColors.black, width: 1.5),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
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
                    pw.Text('بيتنا - Our Home', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('تاريخ الدفع: ${entry.paymentDate.year}/${entry.paymentDate.month}/${entry.paymentDate.day}', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('رقم الإيصال: ${entry.id.split('-').first}', style: const pw.TextStyle(fontSize: 9)),
                  ]
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('وصل استلام قسط وفق معادل التغير السعري', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline)),
                    pw.SizedBox(height: 4),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: pw.BoxDecoration(color: PdfColors.grey300, borderRadius: pw.BorderRadius.circular(4)),
                      child: pw.Text(copyType, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ),
                  ]
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('اسم الفريق الثاني: ${client.name}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text('الشقة: ${contract.apartmentDetails}', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('المساحة: ${contract.totalArea} م2', style: const pw.TextStyle(fontSize: 9)),
                  ]
                ),
              ]
            ),
            
            pw.SizedBox(height: 8),

            // --- النص التوضيحي ---
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(4),
              color: PdfColors.orange50,
              child: pw.Text(
                'المعيار الدائم لحساب القسط الشهري بدلالة قيمة البنود التالية وفق السعر المتفق عليه بتاريخ دفع القسط:',
                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.deepOrange700),
                textAlign: pw.TextAlign.center,
              ),
            ),
            
            pw.SizedBox(height: 6),

            // --- جدول تفاصيل المواد (ديناميكي يسحب الأسعار التاريخية) ---
            pw.TableHelper.fromTextArray(
              context: null,
              cellAlignment: pw.Alignment.center,
              headerStyle: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey700),
              cellStyle: const pw.TextStyle(fontSize: 8),
              border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1), // مسلسل
                1: const pw.FlexColumnWidth(4), // نوع العمل
                2: const pw.FlexColumnWidth(1), // الوحدة
                3: const pw.FlexColumnWidth(1.5), // الكمية
                4: const pw.FlexColumnWidth(2), // السعر الافرادي
                5: const pw.FlexColumnWidth(2), // الاجمالي
              },
              headers: ['م', 'نوع العمل', 'الوحدة', 'الكمية', 'السعر الإفرادي', 'السعر الإجمالي'],
              // 🌟 تعبئة البيانات بالاستعانة بالدوال المساعدة التي صممناها
              data: [
                ['1', 'ثمن حديد مبروم واصل الى موقع العمل', 'كغ', '48', getPrice('iron'), getTotal('iron', 48.0)],
                ['2', 'ثمن اسمنت واصل الى موقع العمل', 'كيس', '1.6', getPrice('cement'), getTotal('cement', 1.6)],
                ['3', 'ثمن بلوك اسمنتي سماكة 15 سم واصل', 'بلوكة', '17', getPrice('block'), getTotal('block', 17.0)],
                ['4', 'اجور كوفراج و صب حديد وتحديد بيتون', 'م3', '1.35', getPrice('formwork'), getTotal('formwork', 1.35)],
                ['5', 'ثمن مواد حصوية جرجرة (بحص+نحاته) واصل', 'م3', '7', getPrice('aggregates'), getTotal('aggregates', 7.0)],
                ['6', 'اجور عمل لعامل عادي 7 ساعات', 'يوم', '0.25', getPrice('worker'), getTotal('worker', 0.25)],
              ],
            ),

            pw.SizedBox(height: 6),

            // --- الخلاصة المالية والامتار ---
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1),
                color: PdfColors.grey100,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('سعر المتر المربع بتاريخه:', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('${entry.meterPriceAtPayment.toStringAsFixed(0)} ل.س', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.deepOrange)),
                    ]
                  ),
                  pw.Container(width: 1, height: 30, color: PdfColors.grey400),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('القسط المدفوع:', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('${entry.amountPaid.toStringAsFixed(0)} ل.س', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('(${numberToArabicWords(entry.amountPaid)})', style: pw.TextStyle(fontSize: 7, fontStyle: pw.FontStyle.italic)),
                    ]
                  ),
                  pw.Container(width: 1, height: 30, color: PdfColors.grey400),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('إجمالي الأمتار المحولة:', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('${entry.convertedMeters.toStringAsFixed(3)} م2', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
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
                    pw.Text('توقيع الفريق الأول', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 25),
                    pw.Text('م.محمد كامل علي', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ]
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('المستلم', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 25),
                    pw.Text('.......................', style: const pw.TextStyle(fontSize: 10)),
                  ]
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('توقيع الفريق الثاني', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 25),
                    pw.Text(client.name, style: pw.TextStyle(fontSize: 10)),
                  ]
                ),
              ]
            ),
            
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text('انشاء المستخدم: م.محمد كامل علي - نظام بيتنا ERP', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
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
              pw.Expanded(child: buildReceipt('نسخة الفريق الأول')),
              
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 12),
                child: pw.Row(
                  children: [
                    pw.Expanded(child: pw.Divider(borderStyle: pw.BorderStyle.dashed, color: PdfColors.grey600)),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8),
                      child: pw.Text('✂️ قص هنا', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    ),
                    pw.Expanded(child: pw.Divider(borderStyle: pw.BorderStyle.dashed, color: PdfColors.grey600)),
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
// lib/core/utils/ledger_pdf_helper.dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:erp_repository/erp_repository.dart';

class LedgerPdfHelper {
  static Future<Uint8List> generateLedgerReportPdf({
    required List<PaymentsLedgerData> ledgerEntries,
    required Contract contract,
    required Client client,
    Apartment? apartment, // 🌟 إضافة الشقة (اختياري للعقود غير المتخصصة)
    Building? building,   // 🌟 إضافة المحضر
  }) async {
    final pdf = pw.Document();

    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();

    const primaryColor = PdfColor.fromInt(0xFF1A2B3D); 
    const accentColor = PdfColor.fromInt(0xFFE64A19); 

    double totalPaid = ledgerEntries.fold(0, (sum, item) => sum + item.amountPaid);
    double totalMeters = ledgerEntries.fold(0, (sum, item) => sum + item.convertedMeters);
    double remainingMeters = contract.totalArea - totalMeters;

    String formatDate(DateTime date) => '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicBoldFont),
        
        header: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('بيتنا العقارية', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: primaryColor)), // صغرنا الخط
                      pw.Text('Our Home Real Estate ERP', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('كشف حساب العميل', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: accentColor)),
                      pw.SizedBox(height: 4),
                      pw.Text('تاريخ الإصدار: ${formatDate(DateTime.now())}', style: const pw.TextStyle(fontSize: 9)),
                    ]
                  ),
                ]
              ),
              pw.SizedBox(height: 12), // مساحة أوسع
              pw.Divider(color: primaryColor, thickness: 1.5),
              pw.SizedBox(height: 16), // مساحة أوسع
            ]
          );
        },

        build: (pw.Context context) {
          return [
            
            // --- هوية العميل ---
            pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              padding: const pw.EdgeInsets.all(16), // Padding أوسع
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('👤 هوية الفريق الثاني (العميل)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor, fontSize: 12)),
                  pw.SizedBox(height: 12), // مساحة
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.Text('الاسم: ${client.name}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.SizedBox(height: 4),
                        pw.Text('رقم الهاتف: ${client.phone}', style: const pw.TextStyle(fontSize: 9)),
                      ]),
                      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.Text('الرقم الوطني: ${client.nationalId ?? 'غير مدون'}', style: const pw.TextStyle(fontSize: 9)),
                        pw.SizedBox(height: 4),
                        pw.Text('كود العميل: ${client.id.split('-').first.toUpperCase()}', style: const pw.TextStyle(fontSize: 9)),
                      ]),
                    ]
                  ),
                ]
              )
            ),
            pw.SizedBox(height: 16), // مساحة أوسع

            // --- هوية العقد والشقة التفصيلية 🌟 ---
            pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                border: pw.Border.all(color: primaryColor, width: 0.5),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              padding: const pw.EdgeInsets.all(16), // Padding أوسع
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('📄 تفاصيل العقد والمواصفات', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor, fontSize: 12)),
                  pw.SizedBox(height: 12),
                  
                  // معلومات المحضر والشقة
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.Text('نوع العقد: ${contract.contractType}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: accentColor)),
                        pw.SizedBox(height: 4),
                        pw.Text('المحضر (البناء): ${building?.name ?? "غير محدد"}', style: const pw.TextStyle(fontSize: 9)),
                        pw.SizedBox(height: 4),
                        pw.Text('الموقع: ${building?.location ?? "غير محدد"}', style: const pw.TextStyle(fontSize: 9)),
                      ]),
                      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.Text('رقم الشقة: ${apartment?.apartmentNumber ?? "-"}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.SizedBox(height: 4),
                        pw.Text('الطابق: ${apartment?.floorName ?? "-"}', style: const pw.TextStyle(fontSize: 9)),
                        pw.SizedBox(height: 4),
                        pw.Text('الاتجاه: ${apartment?.directionName ?? "-"}', style: const pw.TextStyle(fontSize: 9)),
                      ]),
                    ]
                  ),
                  pw.SizedBox(height: 8),
                  pw.Divider(color: PdfColors.grey400, thickness: 0.5),
                  pw.SizedBox(height: 8),
                  
                  // معلومات العقد المالية
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.Text('المساحة الإجمالية: ${contract.totalArea} م2', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.SizedBox(height: 4),
                        pw.Text('تاريخ التوقيع: ${formatDate(contract.contractDate)}', style: const pw.TextStyle(fontSize: 9)),
                        pw.SizedBox(height: 4),
                        pw.Text('الكفيل: ${contract.guarantorName}', style: const pw.TextStyle(fontSize: 9)),
                      ]),
                      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                        pw.Text('مدة الأقساط: ${contract.installmentsCount} شهراً', style: const pw.TextStyle(fontSize: 9)),
                        pw.SizedBox(height: 4),
                        pw.Text('سعر الأساس وقت التوقيع: ${contract.baseMeterPriceAtSigning.toStringAsFixed(0)} ل.س', style: const pw.TextStyle(fontSize: 9)),
                        pw.SizedBox(height: 4),
                        pw.Text('ملاحظات: ${contract.apartmentDetails}', style: const pw.TextStyle(fontSize: 9)),
                      ]),
                    ]
                  ),
                ]
              )
            ),
            pw.SizedBox(height: 24), // مساحة كبيرة قبل الخلاصة

            // --- الخلاصة المالية ---
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: pw.BoxDecoration(
                border: pw.Border(left: pw.BorderSide(color: accentColor, width: 4)),
                color: PdfColors.grey100,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text('إجمالي المبالغ المسددة', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    pw.SizedBox(height: 4),
                    pw.Text('${totalPaid.toStringAsFixed(0)} ل.س', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                  ]),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text('مجموع الأمتار المملوكة', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    pw.SizedBox(height: 4),
                    pw.Text('${totalMeters.toStringAsFixed(3)} م2', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
                  ]),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                    pw.Text('الأمتار المتبقية للشركة', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    pw.SizedBox(height: 4),
                    pw.Text('${remainingMeters > 0 ? remainingMeters.toStringAsFixed(3) : "0 (مكتمل)"} م2', 
                      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: remainingMeters > 0 ? PdfColors.red700 : PdfColors.green700)),
                  ]),
                ]
              ),
            ),
            pw.SizedBox(height: 24),

            // --- جدول الحركات ---
            pw.Text('📊 السجل المالي المفصل (دفتر الأستاذ)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: primaryColor)),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(
              context: context,
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9), // خط رأس الجدول
              headerDecoration: const pw.BoxDecoration(color: primaryColor),
              cellAlignment: pw.Alignment.center,
              cellStyle: const pw.TextStyle(fontSize: 9), // خط خلايا الجدول
              headers: ['الإيصال', 'التاريخ', 'المبلغ المدفوع (ل.س)', 'سعر المتر', 'نسبة البونص', 'الأمتار المشتراة'],
              data: ledgerEntries.map((entry) {
                return [
                  entry.id.split('-').first.toUpperCase(), 
                  formatDate(entry.paymentDate),
                  entry.amountPaid.toStringAsFixed(0),
                  entry.meterPriceAtPayment.toStringAsFixed(0),
                  '${entry.fees.toStringAsFixed(1)} %', 
                  '${entry.convertedMeters.toStringAsFixed(3)} م2',
                ];
              }).toList(),
            ),
            
            pw.SizedBox(height: 16),
            
            pw.Text(
              '* ملاحظة: عدد الأمتار المشتراة يعتبر حقاً مكتسباً للعميل، وهو محمي ضد التضخم ولا يتأثر بتقلبات أسعار المواد المستقبلية.',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ];
        },
        
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Our Home ERP System', style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 8)),
                  pw.Text('صفحة ${context.pageNumber} من ${context.pagesCount}', style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9)),
                  pw.Text('المدقق المالي: _______________', style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9)),
                ]
              ),
            ]
          );
        },
      ),
    );

    return pdf.save();
  }
}
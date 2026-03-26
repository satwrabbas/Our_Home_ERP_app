import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import '../cubit/payments_cubit.dart';

import '../../core/utils/pdf_generator.dart';
import '../../core/utils/pdf_preview_page.dart';
import '../../core/utils/whatsapp_helper.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PaymentsView();
  }
}

class PaymentsView extends StatelessWidget {
  const PaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دفتر الأستاذ (الأمتار المحولة)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: BlocBuilder<PaymentsCubit, PaymentsState>(
        builder: (context, state) {
          if (state.status == PaymentsStatus.loading && state.contracts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.contracts.isEmpty) {
            return const Center(child: Text('لا يوجد عقود مسجلة. يرجى إضافة عقد أولاً.', style: TextStyle(fontSize: 18)));
          }

          return Column(
            children:[
              // ==========================================
              // --- القسم العلوي: اختيار العقد (الفلترة) ---
              // ==========================================
              Container(
                padding: const EdgeInsets.all(24.0),
                color: Colors.orange.shade50,
                child: Row(
                  children:[
                    const Text('اختر العقد المطلوب: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Expanded(
                      // 🌟 القائمة المنسدلة أصبحت تدعم String UUID
                      child: DropdownButtonFormField<String>(
                        value: state.selectedContractId,
                        decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                        items: state.contracts.map((contract) {
                          // البحث عن اسم العميل بأمان
                          final clientName = state.clients.firstWhere((c) => c.id == contract.clientId, orElse: () => state.clients.first).name;
                          return DropdownMenuItem(
                            value: contract.id,
                            // إظهار اسم العميل ووصف الشقة لسهولة البحث للمحاسب
                            child: Text('العميل: $clientName (${contract.apartmentDetails})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) context.read<PaymentsCubit>().selectContract(val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // زر إضافة دفعة (يظهر فقط إذا تم اختيار عقد)
                    if (state.selectedContractId != null)
                      ElevatedButton.icon(
                        onPressed: () => _showAddPaymentDialog(context, state.selectedContractId!),
                        icon: const Icon(Icons.payment),
                        label: const Text('إدخال دفعة جديدة', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18)),
                      ),
                  ],
                ),
              ),

              // ==========================================
              // --- القسم السفلي: جدول الحركات للعقد المحدد ---
              // ==========================================
              Expanded(
                child: state.selectedContractId == null
                    ? const Center(child: Text('يرجى اختيار عقد من القائمة بالأعلى لعرض الدفعات.', style: TextStyle(fontSize: 18, color: Colors.grey)))
                    : state.ledgerEntries.isEmpty
                        ? const Center(child: Text('لم يتم إدخال أي دفعة لهذا العقد حتى الآن.', style: TextStyle(fontSize: 18)))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(24.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(Colors.orange.shade100),
                                columns: const[
                                  DataColumn(label: Text('رقم الإيصال', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('المبلغ المدفوع', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('سعر المتر', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('الأمتار المحولة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                                  DataColumn(label: Text('تاريخ الدفع', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: state.ledgerEntries.map((entry) {
                                  return DataRow(cells:[
                                    // 🌟 عرض أول 8 أحرف من الـ UUID فقط لجمالية الجدول وعدم تشوهه
                                    DataCell(Text(entry.id.split('-').first, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                    
                                    // تنسيق مالي جميل (إضافة فاصلة عشرية إذا لزم الأمر، وإخفاء الأصفار الزائدة)
                                    DataCell(Text('${entry.amountPaid.toStringAsFixed(0)} ل.س', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                                    DataCell(Text('${entry.meterPriceAtPayment.toStringAsFixed(0)} ل.س')),
                                    DataCell(Text('${entry.convertedMeters.toStringAsFixed(3)} م2', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                                    
                                    DataCell(Text('${entry.paymentDate.year}/${entry.paymentDate.month}/${entry.paymentDate.day}')),
                                    
                                    // 🌟 أزرار الإجراءات (الطباعة والواتساب)
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children:[
                                        IconButton(
                                          icon: const Icon(Icons.print, color: Colors.blue),
                                          tooltip: 'معاينة وطباعة الفاتورة',
                                          onPressed: () async {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري تجهيز الفاتورة...')));
                                            final contract = state.contracts.firstWhere((c) => c.id == entry.contractId);
                                            final client = state.clients.firstWhere((c) => c.id == contract.clientId);
                                            
                                            // توليد الـ PDF من بيانات دفتر الأستاذ
                                            final pdfBytes = await PdfGenerator.generateReceiptPdf(
                                              entry: entry,
                                              contract: contract,
                                              client: client,
                                            );

                                            if (context.mounted) {
                                              // عرض المعاينة
                                              Navigator.push(context, MaterialPageRoute(builder: (_) => PdfPreviewPage(pdfBytes: pdfBytes, title: 'فاتورة_${entry.id.split('-').first}_${client.name}')));
                                            }
                                          },
                                        ),
                                        IconButton(
                                          // إذا تم الإرسال سابقاً، يصبح اللون رمادي
                                          icon: Icon(Icons.chat, color: entry.isWhatsAppSent ? Colors.grey : Colors.green),
                                          tooltip: entry.isWhatsAppSent ? 'تم الإرسال (إعادة إرسال)' : 'إرسال الفاتورة عبر واتساب',
                                          onPressed: () async {
                                            final contract = state.contracts.firstWhere((c) => c.id == entry.contractId);
                                            final client = state.clients.firstWhere((c) => c.id == contract.clientId);
                                            
                                            // إرسال رسالة الواتساب وفتح التطبيق الخارجي
                                            final success = await WhatsAppHelper.sendReceiptMessage(
                                              entry: entry,
                                              contract: contract,
                                              client: client,
                                            );

                                            if (context.mounted && success) {
                                              // تحديث حالة الفاتورة في قاعدة البيانات لتسجيل الإرسال
                                              context.read<PaymentsCubit>().markAsSent(entry.id, contract.id);
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم فتح الواتساب!'), backgroundColor: Colors.green));
                                            }
                                          },
                                        ),
                                      ],
                                    )),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // --- النافذة المنبثقة: إدخال الدفعة ---
  // ==========================================
  // 🌟 contractId أصبح String
  void _showAddPaymentDialog(BuildContext parentContext, String contractId) {
    final amountController = TextEditingController();
    final feesController = TextEditingController(text: '0');

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إدخال دفعة جديدة (دفتر الأستاذ)', style: TextStyle(color: Colors.deepOrange)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:[
                const Text('سيقوم النظام تلقائياً بحساب "الأمتار المحولة" بناءً على أحدث أسعار للمواد (الأسعار الفعالة اليوم).', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'المبلغ المدفوع الفعلي (ل.س)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: feesController,
                  decoration: const InputDecoration(labelText: 'الرسوم الإضافية (إن وجدت)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions:[
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
              onPressed: () {
                if (amountController.text.isNotEmpty) {
                  // استدعاء دالة الإضافة في الـ Cubit التي تتكفل بكل العمليات الحسابية والتجميد
                  parentContext.read<PaymentsCubit>().addLedgerEntry(
                    contractId: contractId,
                    amountPaid: double.parse(amountController.text),
                    fees: double.parse(feesController.text.isEmpty ? "0" : feesController.text),
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('حفظ الدفعة وحساب الأمتار آلياً'),
            ),
          ],
        );
      },
    );
  }
}
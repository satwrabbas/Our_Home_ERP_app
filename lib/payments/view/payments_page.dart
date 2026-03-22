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
        title: const Text('استلام الأقساط (الفواتير)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: BlocBuilder<PaymentsCubit, PaymentsState>(
        builder: (context, state) {
          if (state.status == PaymentsStatus.loading && state.contracts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.contracts.isEmpty) {
            return const Center(
              child: Text('لا يوجد عقود مسجلة. يرجى إضافة عقد أولاً.', style: TextStyle(fontSize: 18)),
            );
          }

          return Column(
            children:[
              // --- القسم العلوي: اختيار العقد ---
              Container(
                padding: const EdgeInsets.all(24.0),
                color: Colors.orange.shade50,
                child: Row(
                  children:[
                    const Text('اختر العقد المطلوب: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: state.selectedContractId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: state.contracts.map((contract) {
                          // نبحث عن اسم العميل لكي نعرضه في القائمة
                          final clientName = state.clients.firstWhere((c) => c.id == contract.clientId).name;
                          return DropdownMenuItem(
                            value: contract.id,
                            child: Text('عقد رقم ${contract.id} - العميل: $clientName (${contract.apartmentDescription})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            context.read<PaymentsCubit>().selectContract(val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // زر إضافة دفعة يظهر فقط إذا تم اختيار عقد
                    if (state.selectedContractId != null)
                      ElevatedButton.icon(
                        onPressed: () => _showAddPaymentDialog(context, state.selectedContractId!),
                        icon: const Icon(Icons.payment),
                        label: const Text('وصل استلام جديد', style: TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        ),
                      ),
                  ],
                ),
              ),

              // --- القسم السفلي: جدول الفواتير للعقد المحدد ---
              Expanded(
                child: state.selectedContractId == null
                    ? const Center(child: Text('يرجى اختيار عقد من القائمة بالأعلى لعرض الأقساط.', style: TextStyle(fontSize: 18, color: Colors.grey)))
                    : state.payments.isEmpty
                        ? const Center(child: Text('لم يتم تسديد أي قسط لهذا العقد حتى الآن.', style: TextStyle(fontSize: 18)))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(24.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(Colors.orange.shade100),
                                columns: const[
                                  DataColumn(label: Text('رقم الفاتورة', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('رقم القسط', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('المبلغ المدفوع', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('تاريخ الدفع', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('إجراءات (طباعة / واتساب)', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: state.payments.map((payment) {
                                  return DataRow(cells:[
                                    DataCell(Text(payment.id.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(Text(payment.installmentNumber.toString())),
                                    DataCell(Text(payment.amountPaid.toStringAsFixed(0), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                                    DataCell(Text('${payment.paymentDate.year}/${payment.paymentDate.month}/${payment.paymentDate.day}')),
                                    DataCell(Row(
                                      children:[
                                        // زر الطباعة ومعاينة PDF
                                        IconButton(
                                          icon: const Icon(Icons.print, color: Colors.blue),
                                          tooltip: 'معاينة وطباعة الفاتورة',
                                          onPressed: () async {
                                            // 1. إظهار مؤشر تحميل بسيط أسفل الشاشة
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('جاري تجهيز الفاتورة...'), duration: Duration(seconds: 1)),
                                            );

                                            // 2. جلب البيانات
                                            final contract = state.contracts.firstWhere((c) => c.id == payment.contractId);
                                            final client = state.clients.firstWhere((c) => c.id == contract.clientId);
                                            
                                            // 3. توليد الـ PDF كبيانات (Bytes)
                                            final pdfBytes = await PdfGenerator.generateReceiptPdf(
                                              payment: payment,
                                              contract: contract,
                                              client: client,
                                            );

                                            // 4. الانتقال إلى شاشة المعاينة
                                            if (context.mounted) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => PdfPreviewPage(
                                                    pdfBytes: pdfBytes,
                                                    title: 'فاتورة_${payment.id}_${client.name}',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        // زر إرسال واتساب
                                        IconButton(
                                          // تغيير لون الأيقونة إذا تم الإرسال مسبقاً لتمييزها
                                          icon: Icon(Icons.chat, color: payment.isWhatsAppSent ? Colors.grey : Colors.green),
                                          tooltip: payment.isWhatsAppSent ? 'تم الإرسال مسبقاً (إعادة إرسال)' : 'إرسال الفاتورة عبر واتساب',
                                          onPressed: () async {
                                            // 1. جلب البيانات
                                            final contract = state.contracts.firstWhere((c) => c.id == payment.contractId);
                                            final client = state.clients.firstWhere((c) => c.id == contract.clientId);
                                            
                                            // 2. محاولة فتح الواتساب وإرسال الرسالة
                                            final success = await WhatsAppHelper.sendReceiptMessage(
                                              payment: payment,
                                              contract: contract,
                                              client: client,
                                            );

                                            if (context.mounted) {
                                              if (success) {
                                                // 3. إذا نجح، نخبر قاعدة البيانات بتغيير الحالة
                                                context.read<PaymentsCubit>().markAsSent(payment.id, contract.id);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('تم فتح الواتساب بنجاح!'), backgroundColor: Colors.green),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('فشل فتح الواتساب. تأكد من اتصالك بالإنترنت.'), backgroundColor: Colors.red),
                                                );
                                              }
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

  // نافذة إدخال تفاصيل الدفعة (وصل استلام قسط)
  void _showAddPaymentDialog(BuildContext parentContext, int contractId) {
    final instNumberController = TextEditingController();
    final amountController = TextEditingController();
    final originalAmountController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('وصل استلام قسط جديد'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:[
                TextField(
                  controller: instNumberController,
                  decoration: const InputDecoration(labelText: 'رقم القسط (مثال: 1 أو 2)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'المبلغ المدفوع الفعلي', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: originalAmountController,
                  decoration: const InputDecoration(labelText: 'أصل القسط (حسب العقد)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions:[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (instNumberController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  parentContext.read<PaymentsCubit>().addPayment(
                    contractId: contractId,
                    installmentNumber: int.parse(instNumberController.text),
                    amountPaid: double.parse(amountController.text),
                    originalInstallment: double.parse(originalAmountController.text.isEmpty ? amountController.text : originalAmountController.text),
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('حفظ وإصدار الفاتورة'),
            ),
          ],
        );
      },
    );
  }
}
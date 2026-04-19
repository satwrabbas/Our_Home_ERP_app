// lib/payments/view/payments_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart'; // 🌟 التعديل هنا: ليتعرف على Apartment و Building
import '../cubit/payments_cubit.dart';
import '../../core/utils/ledger_pdf_helper.dart';
import '../../core/utils/pdf_generator.dart';
import '../../core/utils/pdf_preview_page.dart';
import '../../core/utils/whatsapp_helper.dart';
import '../../core/utils/excel_export_helper.dart';

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
          
          if (state.clients.isEmpty || state.contracts.isEmpty) {
            return const Center(
              child: Text(
                'لا يوجد بيانات كافية. يرجى إضافة عميل وتوقيع عقد أولاً.', 
                style: TextStyle(fontSize: 18, color: Colors.grey)
              )
            );
          }

          return Column(
            children:[
              // --- القسم العلوي: اختيار العقد (الفلترة) ---
              Container(
                padding: const EdgeInsets.all(24.0),
                color: Colors.orange.shade50,
                child: Row(
                  children:[
                    const Text('اختر العقد المطلوب: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: state.contracts.any((c) => c.id == state.selectedContractId) ? state.selectedContractId : null,
                        decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                        items: state.contracts.map((contract) {
                          final clientIdx = state.clients.indexWhere((c) => c.id == contract.clientId);
                          final clientName = clientIdx >= 0 ? state.clients[clientIdx].name : 'عميل غير معروف (محذوف)';
                          
                          return DropdownMenuItem(
                            value: contract.id,
                            child: Text('العميل: $clientName (${contract.apartmentDetails})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) context.read<PaymentsCubit>().selectContract(val);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    if (state.selectedContractId != null) ...[
                      // زر الإكسل
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (state.ledgerEntries.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يوجد حركات مالية لتصديرها!'), backgroundColor: Colors.red));
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري تجهيز ملف الإكسل...')));
                          
                          final contract = state.contracts.firstWhere((c) => c.id == state.selectedContractId);
                          final client = state.clients.firstWhere((c) => c.id == contract.clientId);

                          final filePath = await ExcelExportHelper.exportLedgerToExcel(
                            ledgerEntries: state.ledgerEntries, contract: contract, client: client,
                          );

                          if (context.mounted) {
                            if (filePath != null) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم الحفظ بنجاح في: $filePath'), backgroundColor: Colors.green));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل تصدير الملف.'), backgroundColor: Colors.red));
                            }
                          }
                        },
                        icon: const Icon(Icons.table_view),
                        label: const Text('تصدير Excel'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18)),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // 🌟 زر الـ PDF (النسخة المحدثة) 🌟
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (state.ledgerEntries.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يوجد حركات مالية لطباعتها!'), backgroundColor: Colors.red));
                            return;
                          }
                          
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري تجهيز كشف الحساب (PDF)...')));
                          
                          final contract = state.contracts.firstWhere((c) => c.id == state.selectedContractId);
                          final client = state.clients.firstWhere((c) => c.id == contract.clientId);

                          // 🌟 السحر هنا: البحث عن الشقة والمحضر 
                          Apartment? selectedApartment;
                          Building? selectedBuilding;

                          if (contract.apartmentId != null) {
                            final aptIndex = state.apartments.indexWhere((a) => a.id == contract.apartmentId);
                            if (aptIndex != -1) {
                              selectedApartment = state.apartments[aptIndex];
                              final bldIndex = state.buildings.indexWhere((b) => b.id == selectedApartment!.buildingId);
                              if (bldIndex != -1) {
                                selectedBuilding = state.buildings[bldIndex];
                              }
                            }
                          }

                          // 🌟 تمرير كل شيء لملف الـ PDF
                          final pdfBytes = await LedgerPdfHelper.generateLedgerReportPdf(
                            ledgerEntries: state.ledgerEntries,
                            contract: contract,
                            client: client,
                            apartment: selectedApartment, 
                            building: selectedBuilding,   
                          );

                          if (context.mounted) {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => PdfPreviewPage(
                                pdfBytes: pdfBytes, 
                                title: 'كشف_حساب_${client.name}'
                              )
                            ));
                          }
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('كشف حساب PDF'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18)),
                      ),

                      const SizedBox(width: 12),
                      
                      // زر إدخال دفعة
                      ElevatedButton.icon(
                        onPressed: () => _showAddPaymentDialog(context, state.selectedContractId!),
                        icon: const Icon(Icons.payment),
                        label: const Text('إدخال دفعة'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18)),
                      ),
                    ],
                  ],
                ),
              ),

              // --- القسم السفلي: جدول الحركات ---
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
                                    DataCell(Text(entry.id.split('-').first, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                                    DataCell(Text('${entry.amountPaid.toStringAsFixed(0)} ل.س', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                                    DataCell(Text('${entry.meterPriceAtPayment.toStringAsFixed(0)} ل.س')),
                                    DataCell(Text('${entry.convertedMeters.toStringAsFixed(3)} م2', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                                    DataCell(Text('${entry.paymentDate.year}/${entry.paymentDate.month}/${entry.paymentDate.day}')),
                                    DataCell(Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children:[
                                        IconButton(
                                          icon: const Icon(Icons.print, color: Colors.blue),
                                          tooltip: 'معاينة وطباعة الفاتورة',
                                          onPressed: () async {
                                            final contractIdx = state.contracts.indexWhere((c) => c.id == entry.contractId);
                                            if(contractIdx == -1) return;
                                            final contract = state.contracts[contractIdx];

                                            final clientIdx = state.clients.indexWhere((c) => c.id == contract.clientId);
                                            if(clientIdx == -1) return;
                                            final client = state.clients[clientIdx];
                                            
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري تجهيز الفاتورة...')));
                                            final pdfBytes = await PdfGenerator.generateReceiptPdf(entry: entry, contract: contract, client: client);

                                            if (context.mounted) {
                                              Navigator.push(context, MaterialPageRoute(builder: (_) => PdfPreviewPage(pdfBytes: pdfBytes, title: 'فاتورة_${entry.id.split('-').first}_${client.name}')));
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.chat, color: entry.isWhatsAppSent ? Colors.grey : Colors.green),
                                          tooltip: entry.isWhatsAppSent ? 'تم الإرسال (إعادة إرسال)' : 'إرسال الفاتورة عبر واتساب',
                                          onPressed: () async {
                                            final contractIdx = state.contracts.indexWhere((c) => c.id == entry.contractId);
                                            if(contractIdx == -1) return;
                                            final contract = state.contracts[contractIdx];

                                            final clientIdx = state.clients.indexWhere((c) => c.id == contract.clientId);
                                            if(clientIdx == -1) return;
                                            final client = state.clients[clientIdx];
                                            
                                            final success = await WhatsAppHelper.sendReceiptMessage(entry: entry, contract: contract, client: client);

                                            if (context.mounted && success) {
                                              context.read<PaymentsCubit>().markAsSent(entry.id, contract.id);
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

  void _showAddPaymentDialog(BuildContext parentContext, String contractId) {
    final amountController = TextEditingController();
    final discountController = TextEditingController(text: '0'); 

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            
            double amount = double.tryParse(amountController.text) ?? 0;
            double discountPct = double.tryParse(discountController.text) ?? 0;
            double effectiveAmount = amount + (amount * (discountPct / 100));

            return AlertDialog(
              title: const Text('إدخال دفعة جديدة (مع خصم / بونص)', style: TextStyle(color: Colors.deepOrange)),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:[
                    const Text('سيقوم النظام تلقائياً بحساب "الأمتار المحولة" بناءً على أحدث أسعار للمواد.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: 'المبلغ المدفوع الفعلي (ل.س)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setState(() {}), 
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: discountController,
                      decoration: const InputDecoration(
                        labelText: 'نسبة الخصم / البونص المئوية', 
                        border: OutlineInputBorder(),
                        suffixText: '%', 
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setState(() {}), 
                    ),
                    const SizedBox(height: 16),
                    if (amount > 0)
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: discountPct > 0 ? Colors.green.shade50 : Colors.orange.shade50, 
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: discountPct > 0 ? Colors.green : Colors.orange.shade200)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('المبلغ المعتمد للتحويل:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(
                              '${effectiveAmount.toStringAsFixed(0)} ل.س',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: discountPct > 0 ? Colors.green.shade700 : Colors.deepOrange),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              actions:[
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                  onPressed: amount > 0 ? () {
                    parentContext.read<PaymentsCubit>().addLedgerEntry(
                      contractId: contractId,
                      amountPaid: amount,
                      discountPercentage: discountPct, 
                    );
                    Navigator.pop(dialogContext);
                  } : null, 
                  child: const Text('حفظ الدفعة وحساب الأمتار آلياً'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
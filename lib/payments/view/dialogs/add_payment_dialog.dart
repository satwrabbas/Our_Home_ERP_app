// lib/payments/view/dialogs/add_payment_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/payments_cubit.dart';

void showAddPaymentDialog(BuildContext parentContext, String contractId) {
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
                        children:[
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
                  // إغلاق الديالوج أولاً
                  Navigator.pop(dialogContext);
                  
                  // إظهار رسالة للمستخدم
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('جاري إضافة الدفعة وتحديث السجلات...'),
                      duration: Duration(seconds: 1),
                    ),
                  );

                  // استدعاء دالة الحفظ
                  parentContext.read<PaymentsCubit>().addLedgerEntry(
                    contractId: contractId,
                    amountPaid: amount,
                    discountPercentage: discountPct, 
                  );
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
// lib/payments/view/dialogs/add_payment_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🌟 مكتبة Formatters
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/payments_cubit.dart';
import '../../../contracts/view/dialogs/verify_pin_dialog.dart'; 

// ==========================================
// 🌟 أداة تنسيق الأرقام (تضع فاصلة لكل 3 أرقام أثناء الكتابة)
// ==========================================
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');
    
    String formatted = '';
    int count = 0;
    for (int i = digitsOnly.length - 1; i >= 0; i--) {
      if (count != 0 && count % 3 == 0) formatted = ',$formatted';
      formatted = digitsOnly[i] + formatted;
      count++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

void showAddPaymentDialog(BuildContext parentContext, String contractId) {
  final amountController = TextEditingController();
  final discountController = TextEditingController(text: '0'); 

  bool isHistoricalPayment = false;
  bool isDetailedMode = false; 
  DateTime selectedHistoricalDate = DateTime.now();
  
  final meterPriceCtrl = TextEditingController(); 
  
  final histIronCtrl = TextEditingController(); 
  final histCementCtrl = TextEditingController();
  final histBlockCtrl = TextEditingController();
  final histFormworkCtrl = TextEditingController();
  final histAggregatesCtrl = TextEditingController();
  final histWorkerCtrl = TextEditingController();

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          
          // 🌟 السحر هنا: قراءة الأرقام بدون فواصل لحساب المعاينة الحية
          double amount = double.tryParse(amountController.text.replaceAll(',', '')) ?? 0;
          double discountPct = double.tryParse(discountController.text) ?? 0;
          double effectiveAmount = amount + (amount * (discountPct / 100));

          double customMeterPrice = double.tryParse(meterPriceCtrl.text.replaceAll(',', '')) ?? 0;
          double previewMeters = customMeterPrice > 0 ? (effectiveAmount / customMeterPrice) : 0;

          return AlertDialog(
            title: const Text('إدخال دفعة جديدة', style: TextStyle(color: Colors.deepOrange)),
            content: SizedBox(
              width: 500, 
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:[
                    // 🌟 1. مفتاح الدفعة القديمة
                    Container(
                      decoration: BoxDecoration(
                        color: isHistoricalPayment ? Colors.red.shade50 : Colors.transparent,
                        border: Border.all(color: isHistoricalPayment ? Colors.red : Colors.transparent),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: SwitchListTile(
                        title: const Text('إدخال دفعة قديمة (تاريخية)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        subtitle: const Text('لتسجيل حركات سابقة وإدخال سعر المتر يدوياً.'),
                        value: isHistoricalPayment,
                        activeColor: Colors.red,
                        onChanged: (val) async {
                          if (val) {
                            bool authorized = await showVerifyPinDialog(parentContext);
                            if (authorized) {
                              setState(() => isHistoricalPayment = true);
                              
                              // 🌟 فتح نافذة التاريخ تلقائياً
                              final pickedDate = await showDatePicker(
                                context: dialogContext, 
                                initialDate: selectedHistoricalDate,
                                firstDate: DateTime(2000), 
                                lastDate: DateTime.now(),
                                builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Colors.red)), child: child!),
                              );
                              if (pickedDate != null) {
                                setState(() => selectedHistoricalDate = pickedDate);
                              }
                            }
                          } else {
                            setState(() {
                              isHistoricalPayment = false;
                              isDetailedMode = false;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🌟 2. إعدادات التاريخ والمواد (تظهر فقط إذا كانت الدفعة قديمة)
                    if (isHistoricalPayment) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.red.shade300, width: 2), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            // التاريخ 🌟 (زر محدث وأنيق)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:[
                                const Text('📅 تاريخ الدفع:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade50,
                                    foregroundColor: Colors.red.shade700,
                                    elevation: 0,
                                    side: BorderSide(color: Colors.red.shade300, width: 2),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                  icon: const Icon(Icons.calendar_month, size: 22),
                                  label: Text(
                                    '${selectedHistoricalDate.year}/${selectedHistoricalDate.month}/${selectedHistoricalDate.day}', 
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                                  ),
                                  onPressed: () async {
                                    final pickedDate = await showDatePicker(
                                      context: dialogContext, initialDate: selectedHistoricalDate,
                                      firstDate: DateTime(2000), lastDate: DateTime.now(),
                                      builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Colors.red)), child: child!),
                                    );
                                    if (pickedDate != null) setState(() => selectedHistoricalDate = pickedDate);
                                  },
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: Colors.red),
                            
                            // اختيار طريقة الإدخال
                            Row(
                              children:[
                                Expanded(
                                  child: RadioListTile<bool>(
                                    title: const Text('إدخال مباشر', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    subtitle: const Text('سعر المتر فقط', style: TextStyle(fontSize: 11)),
                                    value: false,
                                    groupValue: isDetailedMode,
                                    onChanged: (val) => setState(() => isDetailedMode = val!),
                                    activeColor: Colors.red,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<bool>(
                                    title: const Text('إدخال تفصيلي', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    subtitle: const Text('مواد تُحفظ بالسجل', style: TextStyle(fontSize: 11)),
                                    value: true,
                                    groupValue: isDetailedMode,
                                    onChanged: (val) => setState(() => isDetailedMode = val!),
                                    activeColor: Colors.red,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // 🌟 الحقول مع إضافة الفواصل
                            if (!isDetailedMode)
                              TextField(
                                controller: meterPriceCtrl,
                                inputFormatters: [ThousandsFormatter()], // 🌟 إضافة الفواصل
                                decoration: const InputDecoration(labelText: 'سعر المتر المربع في ذلك الوقت (ل.س)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.speed, color: Colors.red), filled: true, fillColor: Colors.white),
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                              )
                            else
                              Column(
                                children: [
                                  Row(
                                    children:[
                                      Expanded(child: TextField(controller: histIronCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'الحديد', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                      const SizedBox(width: 8),
                                      Expanded(child: TextField(controller: histCementCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'الإسمنت', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children:[
                                      Expanded(child: TextField(controller: histBlockCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'البلوك 15', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                      const SizedBox(width: 8),
                                      Expanded(child: TextField(controller: histFormworkCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'الكوفراج', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children:[
                                      Expanded(child: TextField(controller: histAggregatesCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'المواد الحصوية', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                      const SizedBox(width: 8),
                                      Expanded(child: TextField(controller: histWorkerCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'أجرة العامل', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('سيتم حساب سعر المتر آلياً بناءً على هذه المواد ومعاملات العقد.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                       const Text('سيقوم النظام تلقائياً بحساب "الأمتار المحولة" بناءً على أحدث أسعار للمواد محفوظة في النظام.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                       const SizedBox(height: 16),
                    ],

                    // 🌟 3. حقول المبلغ والخصم الأساسية
                    TextField(
                      controller: amountController,
                      inputFormatters:[ThousandsFormatter()], // 🌟 إضافة الفواصل للمبلغ
                      decoration: const InputDecoration(labelText: 'المبلغ المدفوع الفعلي (ل.س)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money)),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setState(() {}), 
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: discountController,
                      decoration: const InputDecoration(
                        labelText: 'نسبة الخصم / البونص المئوية', 
                        border: OutlineInputBorder(),
                        suffixText: '%', 
                        prefixIcon: Icon(Icons.percent)
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => setState(() {}), 
                    ),
                    const SizedBox(height: 16),

                    // 🌟 4. نافذة المعاينة (Preview)
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
                              '${effectiveAmount.toStringAsFixed(0)} ل.س', // نتركها بدون فواصل هنا أو يمكنك إنشاء دالة فرمتة
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: discountPct > 0 ? Colors.green.shade700 : Colors.deepOrange),
                            ),
                            if (isHistoricalPayment && !isDetailedMode && previewMeters > 0) ...[
                              const Divider(),
                              const Text('الأمتار المحولة (مبدئياً):', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(
                                '${previewMeters.toStringAsFixed(3)} م²',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
                              ),
                            ]
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions:[
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white),
                onPressed: amount > 0 ? () {
                  
                  if (isHistoricalPayment) {
                    if (!isDetailedMode && meterPriceCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('الرجاء إدخال سعر المتر!'), backgroundColor: Colors.red));
                      return;
                    }
                    if (isDetailedMode && (histIronCtrl.text.isEmpty || histCementCtrl.text.isEmpty || histWorkerCtrl.text.isEmpty)) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('الرجاء إدخال جميع أسعار المواد لحفظها في السجل!'), backgroundColor: Colors.red));
                      return;
                    }
                  }

                  Navigator.pop(dialogContext);
                  
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text('جاري إضافة الدفعة وتحديث السجلات...'), duration: Duration(seconds: 1)),
                  );

                  // 🌟 إرسال البيانات للكيوبت مع إزالة الفواصل `replaceAll(',', '')`
                  parentContext.read<PaymentsCubit>().addLedgerEntry(
                    contractId: contractId,
                    amountPaid: amount, // محول وممسوح الفواصل مسبقاً في الأعلى
                    discountPercentage: discountPct, 
                    customDate: isHistoricalPayment ? selectedHistoricalDate : null,
                    customMeterPrice: isHistoricalPayment && !isDetailedMode ? double.parse(meterPriceCtrl.text.replaceAll(',', '')) : null,
                    
                    histIron: isHistoricalPayment && isDetailedMode ? double.parse(histIronCtrl.text.replaceAll(',', '')) : null,
                    histCement: isHistoricalPayment && isDetailedMode ? double.parse(histCementCtrl.text.replaceAll(',', '')) : null,
                    histBlock: isHistoricalPayment && isDetailedMode ? double.parse(histBlockCtrl.text.replaceAll(',', '')) : null,
                    histFormwork: isHistoricalPayment && isDetailedMode ? double.parse(histFormworkCtrl.text.replaceAll(',', '')) : null,
                    histAggregates: isHistoricalPayment && isDetailedMode ? double.parse(histAggregatesCtrl.text.replaceAll(',', '')) : null,
                    histWorker: isHistoricalPayment && isDetailedMode ? double.parse(histWorkerCtrl.text.replaceAll(',', '')) : null,
                  );
                } : null, 
                child: const Text('حفظ الدفعة'),
              ),
            ],
          );
        },
      );
    },
  );
}
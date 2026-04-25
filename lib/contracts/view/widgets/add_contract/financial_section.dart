// lib/contracts/view/widgets/add_contract/financial_section.dart
import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart'; // تأكد من مسار الـ Formatters لديك

class FinancialSection extends StatelessWidget {
  final bool isAllocated;
  final bool isHistoricalContract;
  final TextEditingController areaController;
  final TextEditingController monthsController;
  final TextEditingController durationCoefficientCtrl;
  final TextEditingController priceController;
  final VoidCallback onCalculate;

  const FinancialSection({
    super.key,
    required this.isAllocated,
    required this.isHistoricalContract,
    required this.areaController,
    required this.monthsController,
    required this.durationCoefficientCtrl,
    required this.priceController,
    required this.onCalculate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.teal.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children:[
            // 🌟 1. إخفاء المساحة والمدة بالكامل إذا كان العقد (لاحق التخصص)
            if (isAllocated) ...[
              Row(
                children:[
                  Expanded(flex: 2, child: TextField(
                    controller: areaController, 
                    decoration: const InputDecoration(labelText: 'المساحة الكلية (مجلوبة آلياً)', border: OutlineInputBorder(), filled: true, fillColor: Colors.black12),
                    readOnly: true,
                  )),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: TextField(controller: monthsController, decoration: const InputDecoration(labelText: 'المدة (أشهر)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: TextField(controller: durationCoefficientCtrl, decoration: const InputDecoration(labelText: 'نسبة التقسيط %', border: OutlineInputBorder(), filled: true, fillColor: Colors.orangeAccent), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
            ] else ...[
              // تلميح صغير للموظف
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: const Text('💡 محفظة استثمارية: لا يتطلب هذا العقد تحديد مساحة أو مدة حالياً. اضغط "حساب" لمعرفة تسعيرة المتر المرجعية فقط.', style: TextStyle(color: Colors.blueGrey, fontSize: 12), textAlign: TextAlign.center),
              ),
            ],

            // 🌟 2. زر الحساب وحقل السعر (يبقيان ظاهرين دائماً)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onCalculate,
                icon: const Icon(Icons.calculate),
                label: Text(isHistoricalContract ? 'حساب سعر المتر (تاريخي)' : 'حساب سعر المتر المرجعي (أسعار اليوم)', style: const TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(backgroundColor: isHistoricalContract ? Colors.red.shade700 : Colors.teal.shade700, foregroundColor: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              readOnly: !isHistoricalContract, 
              inputFormatters:[ThousandsFormatter()], // افتراض أنك وضعت هذا الكلاس في formatters.dart
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: isHistoricalContract ? 'سعر المتر المربع (يمكنك تعديله يدوياً)' : 'سعر المتر المربع النهائي (يُحسب آلياً)', 
                border: const OutlineInputBorder(), 
                filled: true, 
                fillColor: isHistoricalContract ? Colors.white : Colors.teal.shade50,
                prefixIcon: isHistoricalContract ? const Icon(Icons.edit, color: Colors.red) : const Icon(Icons.lock, color: Colors.teal),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}
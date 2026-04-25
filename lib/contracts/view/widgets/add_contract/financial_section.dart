import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';

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
    return Column(
      children:[
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children:[
                Expanded(flex: 2, child: TextField(
                  controller: areaController, readOnly: isAllocated, 
                  decoration: InputDecoration(labelText: isAllocated ? 'المساحة (مجلوبة آلياً)' : 'المساحة الكلية / أسهم (م2)', border: const OutlineInputBorder(), filled: isAllocated, fillColor: isAllocated ? Colors.black12 : Colors.white),
                  keyboardType: TextInputType.number,
                )),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: TextField(controller: monthsController, decoration: const InputDecoration(labelText: 'المدة (أشهر)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: TextField(controller: durationCoefficientCtrl, decoration: const InputDecoration(labelText: 'نسبة التقسيط %', border: OutlineInputBorder(), filled: true, fillColor: Colors.orangeAccent), keyboardType: TextInputType.number)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.teal.shade200)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children:[
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton.icon(
                    onPressed: onCalculate,
                    icon: const Icon(Icons.calculate),
                    label: Text(isHistoricalContract ? 'حساب سعر المتر (تاريخي)' : 'حساب سعر المتر (أسعار اليوم)', style: const TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(backgroundColor: isHistoricalContract ? Colors.red.shade700 : Colors.teal.shade700, foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  readOnly: !isHistoricalContract, 
                  inputFormatters: [ThousandsFormatter()],
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: isHistoricalContract ? 'سعر المتر المربع (يمكنك تعديله يدوياً)' : 'سعر المتر المربع النهائي (يُحسب آلياً)', 
                    border: const OutlineInputBorder(), filled: true, 
                    fillColor: isHistoricalContract ? Colors.white : Colors.teal.shade50,
                    prefixIcon: isHistoricalContract ? const Icon(Icons.edit, color: Colors.red) : const Icon(Icons.lock, color: Colors.teal),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
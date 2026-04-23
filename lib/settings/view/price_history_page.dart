// lib/settings/view/price_history_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/settings_cubit.dart';

// 🌟 دالة مساعدة لتنسيق الأرقام بالفواصل
String formatWithCommas(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
}

class PriceHistoryPage extends StatelessWidget {
  const PriceHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('سجل التسعيرات التاريخية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state.priceHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('لا يوجد سجل أسعار محفوظ بعد.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final sortedHistory = List.of(state.priceHistory)..sort((a, b) {
            return b.effectiveDate.compareTo(a.effectiveDate); 
          });

          return ListView(
            padding: const EdgeInsets.all(24.0),
            children:[
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50),
                      dataRowMaxHeight: 65,
                      columnSpacing: 30,
                      columns: const[
                        DataColumn(label: Text('تاريخ التسعيرة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                        DataColumn(label: Text('حديد (كغ)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                        DataColumn(label: Text('اسمنت (كيس)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                        DataColumn(label: Text('بلوك 15', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                        DataColumn(label: Text('كوفراج (م³)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                        DataColumn(label: Text('حصويات (م³)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                        DataColumn(label: Text('عامل (يوم)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                        DataColumn(label: Text('إجراء', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                      ],
                      rows: sortedHistory.asMap().entries.map((mapEntry) {
                        final index = mapEntry.key;
                        final price = mapEntry.value;
                        
                        final hour = price.effectiveDate.hour;
                        final minute = price.effectiveDate.minute.toString().padLeft(2, '0');
                        final date = "${price.effectiveDate.year}/${price.effectiveDate.month}/${price.effectiveDate.day}  ($hour:$minute)";

                        return DataRow(
                          color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                            if (index.isEven) return Colors.grey.withOpacity(0.03); 
                            return null; 
                          }),
                          cells:[
                            DataCell(Text(date, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 13))), 
                            DataCell(Text(formatWithCommas(price.ironPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(formatWithCommas(price.cementPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(formatWithCommas(price.block15Price), style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(formatWithCommas(price.formworkAndPouringWages), style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(formatWithCommas(price.aggregateMaterialsPrice), style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(formatWithCommas(price.ordinaryWorkerWage), style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                tooltip: 'حذف هذه التسعيرة',
                                onPressed: () {
                                  context.read<SettingsCubit>().deleteHistoricalPrice(price.id);
                                },
                              ),
                            ),
                          ],
                        );
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
}
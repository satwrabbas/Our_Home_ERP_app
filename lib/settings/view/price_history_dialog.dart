// lib/settings/view/price_history_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/settings_cubit.dart'; // تأكد من صحة مسار الـ Cubit

class PriceHistoryDialog extends StatelessWidget {
  const PriceHistoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'سجل تغيير الأسعار', 
        style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)
      ),
      content: SizedBox(
        width: 800, // عرض النافذة للكمبيوتر
        height: 400,
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state.priceHistory.isEmpty) {
              return const Center(child: Text('لا يوجد سجل أسعار محفوظ بعد.'));
            }

            return SingleChildScrollView(
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                columns: const[
                  DataColumn(label: Text('تاريخ التسعيرة', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('حديد', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('اسمنت', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('عامل', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('إجراء', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: state.priceHistory.map((price) {
                  final date = "${price.effectiveDate.year}/${price.effectiveDate.month}/${price.effectiveDate.day}";
                  return DataRow(
                    cells:[
                      DataCell(Text(date)),
                      DataCell(Text(price.ironPrice.toStringAsFixed(0))),
                      DataCell(Text(price.cementPrice.toStringAsFixed(0))),
                      DataCell(Text(price.ordinaryWorkerWage.toStringAsFixed(0))),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          tooltip: 'حذف هذه التسعيرة',
                          onPressed: () {
                            // طلب الحذف
                            context.read<SettingsCubit>().deleteHistoricalPrice(price.id);
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
      actions:[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }
}
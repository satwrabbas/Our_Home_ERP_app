// lib/payments/view/deleted_payments_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/payments_cubit.dart';
import 'dialogs/pin_verify_dialog.dart';

// ==========================================
// 🌟 دالة مساعدة لتنسيق الأرقام بالفواصل
// ==========================================
String formatWithCommas(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
}

class DeletedPaymentsView extends StatelessWidget {
  const DeletedPaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الإيصالات الملغاة', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<PaymentsCubit, PaymentsState>(
        builder: (context, state) {
          if (state.deletedLedgerEntries.isEmpty) {
            return const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('لا توجد إيصالات ملغاة', style: TextStyle(fontSize: 20, color: Colors.grey)),
              ],
            ));
          }

          final sortedEntries = List.from(state.deletedLedgerEntries)..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedEntries.length,
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];
              
              final contractIdx = state.contracts.indexWhere((c) => c.id == entry.contractId);
              String clientName = 'غير معروف';
              if (contractIdx != -1) {
                final clientIdx = state.clients.indexWhere((c) => c.id == state.contracts[contractIdx].clientId);
                if (clientIdx != -1) clientName = state.clients[clientIdx].name;
              }

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.money_off, color: Colors.white)),
                  title: Text('إيصال ملغى لـ: $clientName', style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough)),
                  
                  // 🌟 تم تطبيق دالة formatWithCommas هنا لترتيب الملايين
                  subtitle: Text(
                    'المبلغ: ${formatWithCommas(entry.amountPaid)} ل.س\nالأمتار المخصومة: ${entry.convertedMeters.toStringAsFixed(3)} م2\nتم الإلغاء في: ${entry.updatedAt.toLocal().toString().split(' ')[0]}', 
                    style: const TextStyle(color: Colors.redAccent)
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      IconButton(
                        icon: const Icon(Icons.restore, color: Colors.green, size: 30),
                        tooltip: 'استعادة الإيصال والأمتار',
                        onPressed: () {
                          context.read<PaymentsCubit>().restoreLedgerEntry(entry);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الاستعادة وإعادة وزن الأقساط بنجاح.'), backgroundColor: Colors.green));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        tooltip: 'حذف من السجل نهائياً',
                        onPressed: () async {
                          bool isAuth = await verifyPinCode(context, '0938457732', 'الحذف النهائي للسجلات يتطلب رمز الإدارة');
                          if (isAuth && context.mounted) {
                            context.read<PaymentsCubit>().hardDeleteLedgerEntry(entry.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
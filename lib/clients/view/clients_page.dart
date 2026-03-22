import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import '../cubit/clients_cubit.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ClientsView(); // حذفنا الـ BlocProvider من هنا
  }
}

class ClientsView extends StatelessWidget {
  const ClientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العملاء (الفريق الثاني)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      // زر عائم لإضافة عميل جديد
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddClientDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة عميل'),
      ),
      body: BlocBuilder<ClientsCubit, ClientsState>(
        builder: (context, state) {
          if (state.status == ClientsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == ClientsStatus.failure) {
            return Center(child: Text('حدث خطأ: ${state.errorMessage}'));
          } else if (state.clients.isEmpty) {
            return const Center(child: Text('لا يوجد عملاء مضافين حتى الآن.', style: TextStyle(fontSize: 18)));
          }

          // عرض العملاء في جدول أنيق مخصص لسطح المكتب
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
                columns: const[
                  DataColumn(label: Text('م', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('اسم العميل', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('رقم الهاتف', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('الرقم الوطني', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('تاريخ الإضافة', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: state.clients.map((client) {
                  return DataRow(cells:[
                    DataCell(Text(client.id.toString())),
                    DataCell(Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(client.phone)),
                    DataCell(Text(client.nationalId ?? 'غير متوفر')),
                    DataCell(Text('${client.createdAt.year}/${client.createdAt.month}/${client.createdAt.day}')),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  // نافذة منبثقة (Dialog) لإدخال بيانات العميل الجديد
  void _showAddClientDialog(BuildContext parentContext) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final nationalIdController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إضافة عميل جديد (الفريق الثاني)'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'الاسم الرباعي (مثال: يوشع ثابت عباس)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف (للواتساب)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nationalIdController,
                  decoration: const InputDecoration(labelText: 'الرقم الوطني (اختياري)', border: OutlineInputBorder()),
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
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  // نستدعي الـ Cubit الموجود في الشاشة الأم
                  parentContext.read<ClientsCubit>().addClient(
                    name: nameController.text,
                    phone: phoneController.text,
                    nationalId: nationalIdController.text.isEmpty ? null : nationalIdController.text,
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('حفظ العميل'),
            ),
          ],
        );
      },
    );
  }
}
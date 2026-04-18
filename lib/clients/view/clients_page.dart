import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/clients_cubit.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ClientsView();
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                columns: const[
                  DataColumn(label: Text('مُعرّف (ID)', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('اسم العميل', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('رقم الهاتف', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('الرقم الوطني', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('تاريخ الإضافة', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold))), // 🌟 عمود جديد
                ],
                rows: state.clients.map((client) {
                  return DataRow(cells:[
                    // 🌟 عرض أول جزء من الـ UUID فقط (قبل أول "شارحة") لجمالية الجدول
                    DataCell(Text(client.id.split('-').first, style: const TextStyle(color: Colors.grey))),
                    DataCell(Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(client.phone)),
                    DataCell(Text(client.nationalId ?? 'غير متوفر')),
                    DataCell(Text('${client.createdAt.year}/${client.createdAt.month}/${client.createdAt.day}')),
                    // ... (باقي كود الـ DataTable)
                    DataCell(
                      // 🌟 قمنا بوضع الأزرار داخل Row ليكونوا بجانب بعض
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🌟 زر التعديل (جديد)
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                            tooltip: 'تعديل العميل',
                            onPressed: () => _showEditClientDialog(context, client),
                          ),
                          // 🌟 زر الحذف (السابق)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            tooltip: 'حذف العميل',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('تأكيد الحذف'),
                                  content: Text('هل أنت متأكد من حذف العميل "${client.name}"؟'),
                                  actions:[
                                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                      onPressed: () {
                                        context.read<ClientsCubit>().deleteClient(client.id);
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text('حذف نهائي'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddClientDialog(BuildContext parentContext) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final nationalIdController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إضافة عميل جديد'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:[
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم الرباعي', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'رقم الهاتف (للواتساب)', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                TextField(controller: nationalIdController, decoration: const InputDecoration(labelText: 'الرقم الوطني (اختياري)', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions:[
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
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


  /// 🌟 نافذة تعديل بيانات العميل
  void _showEditClientDialog(BuildContext parentContext, dynamic client) {
    // نقوم بملء الحقول ببيانات العميل الحالية فوراً
    final nameController = TextEditingController(text: client.name);
    final phoneController = TextEditingController(text: client.phone);
    final nationalIdController = TextEditingController(text: client.nationalId ?? '');

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تعديل بيانات العميل'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:[
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم الرباعي', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'رقم الهاتف (للواتساب)', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                TextField(controller: nationalIdController, decoration: const InputDecoration(labelText: 'الرقم الوطني (اختياري)', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions:[
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              onPressed: () {
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  // استدعاء دالة التعديل من الـ Cubit
                  parentContext.read<ClientsCubit>().updateClient(
                    id: client.id, // تمرير الـ ID لتحديد العميل المراد تعديله
                    name: nameController.text,
                    phone: phoneController.text,
                    nationalId: nationalIdController.text.isEmpty ? null : nationalIdController.text,
                  );
                  Navigator.pop(dialogContext); // إغلاق النافذة
                }
              },
              child: const Text('حفظ التعديلات'),
            ),
          ],
        );
      },
    );
  }
}
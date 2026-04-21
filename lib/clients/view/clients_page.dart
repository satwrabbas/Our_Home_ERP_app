// lib/clients/view/clients_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/clients_cubit.dart';
import 'deleted_clients_page.dart';
import 'dialogs/add_client_dialog.dart';
import 'dialogs/edit_client_dialog.dart';

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
        actions:[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
              tooltip: 'سلة المحذوفات',
              onPressed: () {
                context.read<ClientsCubit>().fetchDeletedClients(); 
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<ClientsCubit>(),
                      child: const DeletedClientsPage(), // 🌟 استدعاء الشاشة المنفصلة
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => showAddClientDialog(context), // 🌟 استدعاء الدالة المنفصلة
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة عميل'),
      ),
      body: BlocConsumer<ClientsCubit, ClientsState>(
        listener: (context, state) {
          if (state.status == ClientsStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'حدث خطأ غير متوقع', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ClientsStatus.loading && state.clients.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          if (state.clients.isEmpty) {
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
                  DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold))), 
                ],
                rows: state.clients.map((client) {
                  return DataRow(cells:[
                    DataCell(Text(client.id.split('-').first, style: const TextStyle(color: Colors.grey))),
                    DataCell(Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(client.phone)),
                    DataCell(Text(client.nationalId ?? 'غير متوفر')),
                    DataCell(Text('${client.createdAt.year}/${client.createdAt.month}/${client.createdAt.day}')),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.edit_note, color: Colors.blue, size: 28),
                        tooltip: 'تعديل أو حذف العميل',
                        onPressed: () => showEditClientDialog(context, client), // 🌟 استدعاء الدالة المنفصلة
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
}
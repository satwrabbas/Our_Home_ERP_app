// lib/clients/view/deleted_clients_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/clients_cubit.dart';
import 'dialogs/confirm_hard_delete_dialog.dart';

class DeletedClientsPage extends StatelessWidget {
  const DeletedClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة المحذوفات (تحذف تلقائياً بعد 7 أيام)', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ClientsCubit, ClientsState>(
        builder: (context, state) {
          if (state.deletedClients.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Icon(Icons.auto_delete_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('سلة المحذوفات فارغة', style: TextStyle(fontSize: 20, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.deletedClients.length,
            itemBuilder: (context, index) {
              final client = state.deletedClients[index];
              
              final deletionDate = client.updatedAt.toLocal();
              final daysPassed = DateTime.now().difference(deletionDate).inDays;
              final daysLeft = 7 - daysPassed;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.person_off, color: Colors.white)),
                  title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough)),
                  subtitle: Text('رقم الهاتف: ${client.phone}\nباقي $daysLeft أيام على الحذف النهائي', style: const TextStyle(color: Colors.redAccent)),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      IconButton(
                        icon: const Icon(Icons.restore, color: Colors.green, size: 30),
                        tooltip: 'استعادة العميل',
                        onPressed: () {
                          context.read<ClientsCubit>().restoreClient(client.id);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الاستعادة بنجاح، وتتم مزامنتها الآن.'), backgroundColor: Colors.green));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        tooltip: 'حذف نهائي الآن',
                        onPressed: () => showConfirmHardDeleteDialog(context, client),
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
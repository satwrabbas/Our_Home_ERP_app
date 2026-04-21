// lib/contracts/view/deleted_contracts_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../buildings/cubit/buildings_cubit.dart';
import '../cubit/contracts_cubit.dart';
import 'dialogs/confirm_hard_delete_contract_dialog.dart';

class DeletedContractsPage extends StatelessWidget {
  const DeletedContractsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('العقود الملغاة (تحذف نهائياً بعد 7 أيام)', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ContractsCubit, ContractsState>(
        builder: (context, state) {
          if (state.deletedContracts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Icon(Icons.auto_delete_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد عقود ملغاة', style: TextStyle(fontSize: 20, color: Colors.grey)),
                ],
              ),
            );
          }

          final sortedContracts = List.from(state.deletedContracts)
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedContracts.length,
            itemBuilder: (context, index) {
              final contract = sortedContracts[index];
              
              final clientName = state.clients.firstWhere(
                (c) => c.id == contract.clientId, 
                orElse: () => state.clients.first
              ).name;
              
              final deletionDate = contract.updatedAt.toLocal();
              final daysPassed = DateTime.now().difference(deletionDate).inDays;
              final daysLeft = 7 - daysPassed;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.redAccent, 
                      child: Icon(Icons.cancel_presentation, color: Colors.white)
                    ),
                    title: Text(
                      'عقد $clientName (${contract.contractType})', 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.lineThrough)
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                          Text('الكفيل: ${contract.guarantorName}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                          const SizedBox(height: 4),
                          Text('الوصف: ${contract.apartmentDetails}'),
                          const SizedBox(height: 4),
                          Text('السعر: ${contract.baseMeterPriceAtSigning.toStringAsFixed(0)} ل.س | المدة: ${contract.installmentsCount} شهر', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              '⏳ باقي $daysLeft أيام على الحذف النهائي', 
                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children:[
                            IconButton(
                              icon: const Icon(Icons.restore, color: Colors.green, size: 30),
                              tooltip: 'تراجع عن الإلغاء (استعادة)',
                              onPressed: () {
                                context.read<ContractsCubit>().restoreContract(contract);
                                context.read<BuildingsCubit>().loadData();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم استعادة العقد وحجز الشقة بنجاح.'), backgroundColor: Colors.green));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever, color: Colors.red),
                              tooltip: 'حذف نهائي الآن',
                              onPressed: () => showConfirmHardDeleteDialog(context, contract, clientName),
                            ),
                          ],
                        ),
                      ],
                    ),
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
// lib/contracts/view/contracts_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../cubit/contracts_cubit.dart';
import 'deleted_contracts_page.dart';
import 'dialogs/add_contract_dialog.dart';
import 'dialogs/edit_contract_dialog.dart';

class ContractsPage extends StatelessWidget {
  const ContractsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContractsView();
  }
}

class ContractsView extends StatelessWidget {
  const ContractsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العقود والشقق', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions:[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
              tooltip: 'سلة المحذوفات (العقود الملغاة)',
              onPressed: () {
                context.read<ContractsCubit>().fetchDeletedContracts(); 
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<ContractsCubit>(),
                      child: const DeletedContractsPage(),
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
        onPressed: () => showAddContractDialog(context),
        icon: const Icon(Icons.add_home_work),
        label: const Text('عقد جديد'),
        backgroundColor: Colors.teal,
      ),
      body: BlocConsumer<ContractsCubit, ContractsState>(
        listener: (context, state) {
          if (state.status == ContractsStatus.failure) {
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
          if (state.status == ContractsStatus.loading && state.contracts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } 
          if (state.clients.isEmpty) {
            return const Center(child: Text('يرجى إضافة عميل واحد على الأقل أولاً.', style: TextStyle(fontSize: 18)));
          }
          if (state.contracts.isEmpty) {
            return const Center(child: Text('لم يتم توقيع أي عقود بعد. اضغط على "عقد جديد".', style: TextStyle(fontSize: 18)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.teal.shade50),
                columns: const[
                  DataColumn(label: Text('رقم العقد', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('العميل', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('نوع العقد', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('الوصف', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('الكفيل', style: TextStyle(fontWeight: FontWeight.bold))), 
                  DataColumn(label: Text('سعر المتر', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('المدة', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('ملف العقد', style: TextStyle(fontWeight: FontWeight.bold))), 
                  DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: state.contracts.map((contract) {
                  final clientName = state.clients.firstWhere((c) => c.id == contract.clientId, orElse: () => state.clients.first).name;

                  return DataRow(cells:[
                    DataCell(Text(contract.id.split('-').first, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    DataCell(Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(contract.contractType, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))),
                    DataCell(Text(contract.apartmentDetails)),
                    DataCell(Text(contract.guarantorName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))), 
                    DataCell(Text(contract.baseMeterPriceAtSigning.toStringAsFixed(0), style: const TextStyle(color: Colors.green))),
                    DataCell(Text('${contract.installmentsCount} شهر', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                    
                    DataCell(
                      contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty
                          ? TextButton.icon(
                              icon: const Icon(Icons.download, color: Colors.green),
                              label: const Text('فتح العقد', style: TextStyle(color: Colors.green)),
                              onPressed: () async {
                                 final url = Uri.parse(contract.contractFileUrl!);
                                 if (await canLaunchUrl(url)) {
                                   await launchUrl(url); 
                                 }
                              },
                            )
                          : TextButton.icon(
                              icon: const Icon(Icons.upload_file, color: Colors.orange),
                              label: const Text('إرفاق ملف', style: TextStyle(color: Colors.orange)),
                              onPressed: () async {
                                 FilePickerResult? result = await FilePicker.platform.pickFiles(
                                   type: FileType.custom,
                                   allowedExtensions:['doc', 'docx', 'pdf'], 
                                 );

                                 if (result != null && result.files.single.path != null) {
                                   final filePath = result.files.single.path!;
                                   final extension = result.files.single.extension ?? 'docx';
                                   
                                   if(context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('جاري رفع الملف للسحابة... ⏳'), backgroundColor: Colors.orange)
                                      );

                                      await context.read<ContractsCubit>().attachContractFile(
                                        contractId: contract.id,
                                        filePath: filePath,
                                        extension: extension,
                                      );

                                      if(context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('تم إرفاق العقد بنجاح! ✅'), backgroundColor: Colors.green)
                                        );
                                      }
                                   }
                                 }
                              },
                            ),
                    ),

                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.edit_note, color: Colors.blue, size: 28),
                        tooltip: 'إدارة وتعديل العقد',
                        onPressed: () => showEditContractDialog(context, contract),
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
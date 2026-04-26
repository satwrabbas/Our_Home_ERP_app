//lib\contracts\view\widgets\contracts_search_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../cubit/contracts_cubit.dart';
import '../../../core/utils/formatters.dart';
import '../dialogs/edit_contract_dialog.dart';

class ContractsDataTable extends StatelessWidget {
  final List<dynamic> contracts; 
  final List<dynamic> clients;

  const ContractsDataTable({super.key, required this.contracts, required this.clients});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.teal.shade50),
            columns: const[
              DataColumn(label: Text('رقم العقد', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
              DataColumn(label: Text('العميل', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
              DataColumn(label: Text('النوع', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
              DataColumn(label: Text('سعر المتر', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
              DataColumn(label: Text('ملف العقد', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
              DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
            ],
            rows: contracts.asMap().entries.map((entry) {
              final index = entry.key;
              final contract = entry.value;
              
              // 🌟 الحل هنا: استخدام indexWhere لتفادي خطأ الـ Null
              final clientIdx = clients.indexWhere((c) => c.id == contract.clientId);
              final clientName = clientIdx >= 0 ? clients[clientIdx].name : 'عميل محذوف';

              return DataRow(
                color: WidgetStateProperty.resolveWith<Color?>((states) => index.isEven ? Colors.grey.withOpacity(0.03) : null),
                cells:[
                  DataCell(Text(contract.id.split('-').first.toUpperCase())),
                  DataCell(Text(clientName)), // 🌟 استخدام الاسم مباشرة هنا
                  DataCell(Text(contract.contractType)),
                  DataCell(Text('${NumberFormatters.formatWithCommas(contract.baseMeterPriceAtSigning)} ل.س')),
                  DataCell(_buildFileAction(context, contract)),
                  DataCell(IconButton(
                    icon: const Icon(Icons.edit_note, color: Colors.blue),
                    onPressed: () => showEditContractDialog(context, contract),
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFileAction(BuildContext context, dynamic contract) {
    bool hasFile = contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty;
    return TextButton.icon(
      icon: Icon(hasFile ? Icons.download : Icons.upload_file, color: hasFile ? Colors.green : Colors.orange, size: 18),
      label: Text(hasFile ? 'فتح' : 'إرفاق', style: TextStyle(color: hasFile ? Colors.green : Colors.orange)),
      onPressed: () async {
        if (hasFile) {
          final url = Uri.parse(contract.contractFileUrl!);
          if (await canLaunchUrl(url)) await launchUrl(url);
        } else {
          _pickAndUploadFile(context, contract.id);
        }
      },
    );
  }

  void _pickAndUploadFile(BuildContext context, String contractId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions:['doc', 'docx', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      if (context.mounted) {
        context.read<ContractsCubit>().attachContractFile(
              contractId: contractId,
              filePath: result.files.single.path!,
              extension: result.files.single.extension ?? 'docx',
            );
      }
    }
  }
}
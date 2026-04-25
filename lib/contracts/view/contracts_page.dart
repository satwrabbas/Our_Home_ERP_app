// lib/contracts/view/contracts_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../cubit/contracts_cubit.dart';
// 🌟 الاستيرادات الثلاثة التي كانت ناقصة لحل الخطأ
import '../../../buildings/cubit/buildings_cubit.dart'; 
import '../../../settings/cubit/settings_cubit.dart';
import 'add_contract_page.dart'; 

import 'deleted_contracts_page.dart';
import 'dialogs/edit_contract_dialog.dart';

// ==========================================
// 🌟 دالة مساعدة لتنسيق الأرقام بالفواصل
// ==========================================
String formatWithCommas(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
}

class ContractsPage extends StatelessWidget {
  const ContractsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContractsView();
  }
}

class ContractsView extends StatefulWidget {
  const ContractsView({super.key});

  @override
  State<ContractsView> createState() => _ContractsViewState();
}

class _ContractsViewState extends State<ContractsView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('إدارة العقود والشقق', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        backgroundColor: Colors.teal.shade600,
        elevation: 0,
        actions:[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white, size: 28),
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
        onPressed: () {
          // 🌟 الانتقال لصفحة الإضافة الجديدة مع تمرير الـ Cubits
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers:[
                  BlocProvider.value(value: context.read<ContractsCubit>()),
                  BlocProvider.value(value: context.read<BuildingsCubit>()),
                  BlocProvider.value(value: context.read<SettingsCubit>()),
                ],
                child: const AddContractPage(), 
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_home_work),
        label: const Text('عقد جديد', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
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
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          } 
          if (state.clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Icon(Icons.group_add, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('يرجى إضافة عميل واحد على الأقل أولاً من قسم العملاء.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              )
            );
          }
          if (state.contracts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Icon(Icons.real_estate_agent, size: 80, color: Colors.teal.shade200),
                  const SizedBox(height: 16),
                  const Text('لم يتم توقيع أي عقود بعد. اضغط على "عقد جديد" للبدء.', style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
                ],
              )
            );
          }

          final filteredContracts = state.contracts.where((contract) {
            if (_searchQuery.isEmpty) return true;
            
            final clientIdx = state.clients.indexWhere((c) => c.id == contract.clientId);
            final clientName = clientIdx >= 0 ? state.clients[clientIdx].name.toLowerCase() : '';
            final searchLower = _searchQuery.toLowerCase();
            final contractIdShort = contract.id.split('-').first.toLowerCase();

            return clientName.contains(searchLower) || 
                   contract.apartmentDetails.toLowerCase().contains(searchLower) ||
                   contract.contractType.toLowerCase().contains(searchLower) ||
                   contractIdShort.contains(searchLower);
          }).toList();

          return Column(
            children:[
              // ==========================================
              // 🌟 القسم العلوي: شريط البحث
              // ==========================================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow:[BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  border: Border(bottom: BorderSide(color: Colors.teal.shade100, width: 2)),
                ),
                child: Row(
                  children:[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.search, color: Colors.teal.shade600, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value; 
                          });
                        },
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: '🔍 ابحث عن اسم العميل، الوصف، أو رقم العقد...',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
                          ),
                          suffixIcon: _searchQuery.isNotEmpty 
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  setState(() => _searchQuery = '');
                                  FocusScope.of(context).unfocus();
                                },
                              ) 
                            : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.teal.shade200)),
                      child: Text('النتيجة: ${filteredContracts.length} عقود', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
                    )
                  ],
                ),
              ),

              // ==========================================
              // 🌟 القسم السفلي: جدول العقود
              // ==========================================
              Expanded(
                child: filteredContracts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          Icon(Icons.search_off, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('لا يوجد نتائج مطابقة لبحثك: "$_searchQuery"', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                        ],
                      )
                    )
                  : ListView(
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
                                columnSpacing: 20, 
                                horizontalMargin: 16,
                                headingRowColor: WidgetStateProperty.all(Colors.teal.shade50),
                                dataRowMinHeight: 50, 
                                dataRowMaxHeight: 70,
                                columns: const[
                                  DataColumn(label: Text('رقم العقد', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13))),
                                  DataColumn(label: Text('العميل', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13))),
                                  DataColumn(label: Text('النوع', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13))),
                                  DataColumn(label: Text('الوصف', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13))),
                                  DataColumn(label: Text('الكفيل', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13))), 
                                  DataColumn(label: Text('سعر المتر', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13))),
                                  DataColumn(label: Text('المدة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13))),
                                  DataColumn(label: Text('ملف العقد', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13))), 
                                  DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13))),
                                ],
                                rows: filteredContracts.asMap().entries.map((mapEntry) {
                                  final index = mapEntry.key;
                                  final contract = mapEntry.value;
                                  
                                  final clientIdx = state.clients.indexWhere((c) => c.id == contract.clientId);
                                  final clientName = clientIdx >= 0 ? state.clients[clientIdx].name : 'عميل محذوف';

                                  return DataRow(
                                    color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                      if (index.isEven) return Colors.grey.withOpacity(0.03); 
                                      return null; 
                                    }),
                                    cells:[
                                      DataCell(Text(contract.id.split('-').first.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600, fontSize: 12))),
                                      
                                      DataCell(
                                        SizedBox(
                                          width: 120,
                                          child: Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                                        )
                                      ),

                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(6)),
                                          child: Text(contract.contractType, style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                                        )
                                      ),
                                      
                                      DataCell(
                                        SizedBox(
                                          width: 150,
                                          child: Tooltip(
                                            message: contract.apartmentDetails, 
                                            child: Text(
                                              contract.apartmentDetails, 
                                              style: const TextStyle(fontSize: 12), 
                                              maxLines: 2, 
                                              overflow: TextOverflow.ellipsis
                                            ),
                                          ),
                                        )
                                      ),

                                      DataCell(
                                        SizedBox(
                                          width: 100,
                                          child: Text(contract.guarantorName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                                        )
                                      ), 
                                      
                                      DataCell(Text('${formatWithCommas(contract.baseMeterPriceAtSigning)} ل.س', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13))),
                                      
                                      DataCell(Text('${contract.installmentsCount} ش', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 13))),
                                      
                                      DataCell(
                                        contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty
                                            ? TextButton.icon(
                                                icon: const Icon(Icons.download, color: Colors.green, size: 18),
                                                label: const Text('فتح', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                                onPressed: () async {
                                                   final url = Uri.parse(contract.contractFileUrl!);
                                                   if (await canLaunchUrl(url)) {
                                                     await launchUrl(url); 
                                                   }
                                                },
                                              )
                                            : TextButton.icon(
                                                icon: const Icon(Icons.upload_file, color: Colors.orange, size: 18),
                                                label: const Text('إرفاق', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
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
                                          icon: const Icon(Icons.edit_note, color: Colors.blue, size: 24),
                                          tooltip: 'إدارة وتعديل العقد',
                                          onPressed: () => showEditContractDialog(context, contract),
                                        ),
                                      ),
                                    ]
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}
// lib/clients/view/clients_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart'; // 🌟 إضافة ضرورية لحقن الـ Repository
import '../cubit/clients_cubit.dart';
import 'deleted_clients_page.dart';
import 'dialogs/add_client_dialog.dart';
import 'dialogs/edit_client_dialog.dart';


import '../../dashboard/cubit/dashboard_cubit.dart';
import '../../payments/cubit/payments_cubit.dart';
import '../../schedule/cubit/schedule_cubit.dart';
// 🌟 استدعاء ملفات الملف التعريفي الجديدة
import '../../profile/cubit/client_profile_cubit.dart';
import '../../profile/view/client_profile_page.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ClientsView();
  }
}

// 🌟 تحويل الشاشة إلى StatefulWidget لدعم خاصية البحث
class ClientsView extends StatefulWidget {
  const ClientsView({super.key});

  @override
  State<ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<ClientsView> {
  String _searchQuery = ''; // 🌟 متغير لتخزين نص البحث

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('إدارة العملاء (الفريق الثاني)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent, // 🌟 ثيم أزرق للعملاء
        elevation: 0,
        actions:[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white, size: 28),
              tooltip: 'سلة المحذوفات',
              onPressed: () {
                context.read<ClientsCubit>().fetchDeletedClients();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<ClientsCubit>(),
                      child: const DeletedClientsPage(),
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
        onPressed: () => showAddClientDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة عميل', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
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
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }

          if (state.clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Icon(Icons.group_off, size: 80, color: Colors.blue.shade200),
                  const SizedBox(height: 16),
                  const Text('لا يوجد عملاء مضافين حتى الآن.', style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
                ],
              )
            );
          }

          // 🌟 فلترة العملاء بناءً على نص البحث
          final filteredClients = state.clients.where((client) {
            if (_searchQuery.isEmpty) return true;
            
            final searchLower = _searchQuery.toLowerCase();
            final idShort = client.id.split('-').first.toLowerCase();

            return client.name.toLowerCase().contains(searchLower) || 
                   client.phone.contains(searchLower) ||
                   (client.nationalId?.contains(searchLower) ?? false) ||
                   idShort.contains(searchLower);
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
                  border: Border(bottom: BorderSide(color: Colors.blue.shade100, width: 2)),
                ),
                child: Row(
                  children:[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.search, color: Colors.blue.shade600, size: 28),
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
                          hintText: '🔍 ابحث عن اسم العميل، رقم الهاتف، أو الرقم الوطني...',
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
                            borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
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
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.shade200)),
                      child: Text('النتيجة: ${filteredClients.length} عملاء', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                    )
                  ],
                ),
              ),

              // ==========================================
              // 🌟 القسم السفلي: جدول العملاء
              // ==========================================
              Expanded(
                child: filteredClients.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          Icon(Icons.person_search, size: 80, color: Colors.grey.shade300),
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
                              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 90),
                              child: DataTable(
                                columnSpacing: 22, 
                                horizontalMargin: 20, 
                                headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                                dataRowMinHeight: 55, 
                                dataRowMaxHeight: 75,
                                columns: const[
                                  DataColumn(label: Text('مُعرّف (ID)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))),
                                  DataColumn(label: Text('اسم العميل / الملف التعريفي', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))),
                                  DataColumn(label: Text('رقم الهاتف', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))),
                                  DataColumn(label: Text('الرقم الوطني', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))),
                                  DataColumn(label: Text('تاريخ الإضافة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))),
                                  DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent, fontSize: 14))), 
                                ],
                                rows: filteredClients.asMap().entries.map((mapEntry) {
                                  final index = mapEntry.key;
                                  final client = mapEntry.value;
                                  
                                  return DataRow(
                                    color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                      if (index.isEven) return Colors.grey.withOpacity(0.03); 
                                      return null; 
                                    }),
                                    cells:[
                                      DataCell(Text(client.id.split('-').first.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600, fontSize: 14))),
                                      
                                      // 🌟 السحر هنا: تحويل الاسم لزر يفتح الملف التعريفي الشامل
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 200),
                                          child: InkWell(
                                            onTap: () {
                                              // 🌟 حفظنا الكيوبتات لكي لا تضيع عندما نفتح نافذة جديدة
                                              final dashboardCubit = context.read<DashboardCubit>();
                                              final paymentsCubit = context.read<PaymentsCubit>();
                                              final scheduleCubit = context.read<ScheduleCubit>();

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => MultiBlocProvider(
                                                    providers:[
                                                      BlocProvider.value(value: dashboardCubit),
                                                      BlocProvider.value(value: paymentsCubit),
                                                      BlocProvider.value(value: scheduleCubit),
                                                      BlocProvider(create: (_) => ClientProfileCubit(context.read<ErpRepository>())..fetchClientData(client)),
                                                    ],
                                                    child: ClientProfilePage(client: client),
                                                  ),
                                                ),
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.indigo.withOpacity(0.05),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.indigo.withOpacity(0.2))
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children:[
                                                  const Icon(Icons.open_in_new, size: 14, color: Colors.indigo),
                                                  const SizedBox(width: 6),
                                                  Flexible(
                                                    child: Text(
                                                      client.name, 
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo), 
                                                      maxLines: 2, 
                                                      overflow: TextOverflow.ellipsis
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ),
                                      
                                      DataCell(Text(client.phone, style: const TextStyle(fontSize: 14, color: Colors.black87))),
                                      
                                      DataCell(Text(client.nationalId ?? 'غير متوفر', style: TextStyle(fontSize: 14, color: client.nationalId != null ? Colors.black87 : Colors.grey))),
                                      
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                                          child: Text('${client.createdAt.year}/${client.createdAt.month.toString().padLeft(2,'0')}/${client.createdAt.day.toString().padLeft(2,'0')}', 
                                            style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 13)
                                          ),
                                        )
                                      ),
                                      
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(Icons.edit_note, color: Colors.blue, size: 26),
                                          tooltip: 'تعديل أو حذف العميل',
                                          onPressed: () => showEditClientDialog(context, client), 
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
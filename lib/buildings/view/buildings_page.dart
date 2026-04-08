//buildings_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show Building, Apartment; // 🌟 تم استيراد Apartment هنا
import '../cubit/buildings_cubit.dart';
import 'dialogs/add_building_dialog.dart';
import 'dialogs/add_apartment_dialog.dart';
import 'dialogs/apartment_details_dialog.dart';
import 'dialogs/building_details_dialog.dart';
import 'dialogs/copy_floor_dialog.dart';

class BuildingsPage extends StatelessWidget {
  const BuildingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BuildingsCubit(context.read<ErpRepository>())..loadData(),
      child: const BuildingsView(),
    );
  }
}

class BuildingsView extends StatelessWidget {
  const BuildingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كتالوج المشاريع والشقق', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: BlocBuilder<BuildingsCubit, BuildingsState>(
        builder: (context, state) {
          if (state.status == BuildingsStatus.loading) return const Center(child: CircularProgressIndicator());
          if (state.buildings.isEmpty) return const Center(child: Text('لا توجد محاضر. اضغط على الزر بالأسفل لإضافة محضر جديد.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.buildings.length,
            itemBuilder: (context, index) {
              final building = state.buildings[index];
              final bldApartments = state.apartments.where((a) => a.buildingId == building.id).toList();

              // 🌟 استخراج أسماء الطوابق المتاحة من المحضر
              Map<String, dynamic> availableFloors = {};
              try {
                availableFloors = jsonDecode(building.floorCoefficients);
              } catch (e) {}

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: Row(
                    children: [
                      Text('🏢 ${building.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.domain_verification, color: Colors.teal),
                        tooltip: 'عرض تفاصيل المحضر',
                        onPressed: () => showBuildingDetailsDialog(context, building),
                      ),
                    ],
                  ),
                  subtitle: Text('الموقع: ${building.location} | إجمالي الشقق: ${bldApartments.length}'),
                  children: [
                    if (availableFloors.isEmpty)
                      const Padding(padding: EdgeInsets.all(16.0), child: Text('لم يتم إعداد طوابق لهذا المحضر بعد.')),
                    
                    // 🌟 عرض الطوابق كقوائم داخلية (Nested ExpansionTiles)
                    ...availableFloors.keys.map((floorName) {
                      // شقق هذا الطابق تحديداً
                      final floorApts = bldApartments.where((a) => a.floorName == floorName).toList();
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.indigo.shade100),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              Icon(Icons.layers, color: Colors.indigo.shade300, size: 20),
                              const SizedBox(width: 8),
                              Text('$floorName ( ${floorApts.length} شقق )', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                            ],
                          ),
                          children: [
                            if (floorApts.isEmpty)
                              const Padding(padding: EdgeInsets.all(16.0), child: Text('لا توجد شقق في هذا الطابق.', style: TextStyle(color: Colors.grey))),
                            if (floorApts.isNotEmpty)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50),
                                  columns: const [
                                    DataColumn(label: Text('رقم الشقة')),
                                    DataColumn(label: Text('المساحة')),
                                    DataColumn(label: Text('الاتجاه')),
                                    DataColumn(label: Text('الحالة')),
                                    DataColumn(label: Text('إجراءات')),
                                  ],
                                  rows: floorApts.map((apt) => DataRow(cells: [
                                    DataCell(Text(apt.apartmentNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(Text('${apt.area} م2')),
                                    DataCell(Text(apt.directionName ?? '-')),
                                    DataCell(Chip(
                                      label: Text(apt.status == 'available' ? 'متاحة' : 'مباعة', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                      backgroundColor: apt.status == 'available' ? Colors.green : Colors.red,
                                      padding: EdgeInsets.zero,
                                    )),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.info_outline, color: Colors.indigo),
                                        onPressed: () => showApartmentDetailsDialog(context, apt),
                                      ),
                                    ),
                                  ])).toList(),
                                ),
                              ),
                            
                            // 🌟 أزرار التحكم الخاصة بالطابق
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              color: Colors.grey.shade50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.add_home),
                                    label: const Text('إضافة شقة هنا'),
                                    onPressed: () => showAddApartmentDialog(context, building, preSelectedFloor: floorName),
                                  ),
                                  // 🌟 زر النسخ (يظهر فقط إذا كان هناك شقق لنسخها)
                                  if (floorApts.isNotEmpty)
                                    TextButton.icon(
                                      icon: const Icon(Icons.copy_all, color: Colors.orange),
                                      label: const Text('نسخ نموذج الطابق', style: TextStyle(color: Colors.orange)),
                                      onPressed: () => showCopyFloorDialog(context, building, floorName, floorApts, availableFloors.keys.toList()),
                                    ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        onPressed: () => showAddBuildingDialog(context),
        icon: const Icon(Icons.domain_add, color: Colors.white),
        label: const Text('إضافة محضر جديد', style: TextStyle(color: Colors.white)),
      ),
    );
  }  
}
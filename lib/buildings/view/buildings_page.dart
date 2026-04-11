//buildings_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show Building, Apartment;
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
                  // 👈 التعديل هنا: جعلناها false لكي تبقى الجوارير مقفلة عند فتح الصفحة
                  initiallyExpanded: false, 
                  
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
                                physics: const BouncingScrollPhysics(), // حركة سكرول ناعمة
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.indigo.shade50, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.indigo.withOpacity(0.04),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: DataTable(
                                      headingRowHeight: 54, // ارتفاع صف العناوين
                                      dataRowMinHeight: 60, // ارتفاع صفوف البيانات
                                      dataRowMaxHeight: 60,
                                      horizontalMargin: 24, // المساحة الجانبية للجدول
                                      columnSpacing: 40,    // المسافة بين الأعمدة
                                      dividerThickness: 0.5, // سماكة الخط الفاصل أرق وأجمل
                                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)), // لون رمادي مزرق فاتح جداً للعناوين
                                      headingTextStyle: const TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        color: Color(0xFF475569), // لون العناوين رمادي احترافي
                                        fontSize: 14,
                                      ),
                                      columns: const [
                                        DataColumn(label: Text('رقم الشقة')),
                                        DataColumn(label: Text('المساحة')),
                                        DataColumn(label: Text('الاتجاه')),
                                        DataColumn(label: Text('الحالة')),
                                        DataColumn(label: Text('إجراءات')),
                                      ],
                                      rows: floorApts.map((apt) {
                                        final isAvailable = apt.status == 'available';
                                        return DataRow(
                                          cells: [
                                            // رقم الشقة
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.door_front_door_outlined, size: 18, color: Colors.indigo.shade300),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    apt.apartmentNumber, 
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // المساحة
                                            DataCell(Text('${apt.area} م²', style: const TextStyle(fontWeight: FontWeight.w500))),
                                            // الاتجاه
                                            DataCell(Text(apt.directionName ?? '-', style: TextStyle(color: Colors.grey.shade700))),
                                            // الحالة (تصميم Badge حديث)
                                            DataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: isAvailable ? Colors.green.shade200 : Colors.red.shade200,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  isAvailable ? 'متاحة' : 'مباعة', 
                                                  style: TextStyle(
                                                    color: isAvailable ? Colors.green.shade700 : Colors.red.shade700, 
                                                    fontWeight: FontWeight.bold, 
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // إجراءات
                                            DataCell(
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.indigo.shade50,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: IconButton(
                                                  icon: const Icon(Icons.remove_red_eye_rounded, size: 20, color: Colors.indigo),
                                                  tooltip: 'عرض التفاصيل',
                                                  onPressed: () => showApartmentDetailsDialog(context, apt),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
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
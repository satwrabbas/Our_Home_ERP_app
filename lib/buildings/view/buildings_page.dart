// lib/buildings/view/buildings_page.dart
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
// 🌟 الاستيرادات الجديدة للنوافذ المنفصلة
import 'dialogs/edit_building_dialog.dart';
import 'dialogs/edit_apartment_dialog.dart';

// 🌟 تحويلها إلى StatefulWidget لطلب البيانات بآمان دون إنشاء BlocProvider جديد
class BuildingsPage extends StatefulWidget {
  const BuildingsPage({super.key});

  @override
  State<BuildingsPage> createState() => _BuildingsPageState();
}

class _BuildingsPageState extends State<BuildingsPage> {
  @override
  void initState() {
    super.initState();
    // 🚀 تحديث البيانات فور دخول الصفحة من الـ Cubit المركزي (Global)
    context.read<BuildingsCubit>().loadData();
  }

  @override
  Widget build(BuildContext context) {
    // 🚀 أزلنا الـ BlocProvider من هنا لكي تتصل الصفحة بنفس الـ Cubit الذي تعدله صفحة العقود
    return const BuildingsView();
  }
}

class BuildingsView extends StatelessWidget {
  const BuildingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' المشاريع والشقق', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: BlocConsumer<BuildingsCubit, BuildingsState>(
        listener: (context, state) {
          if (state.status == BuildingsStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'حدث خطأ', style: const TextStyle(fontWeight: FontWeight.bold)),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == BuildingsStatus.loading && state.buildings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.buildings.isEmpty) {
            return const Center(child: Text('لا توجد محاضر. اضغط على الزر بالأسفل لإضافة محضر جديد.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.buildings.length,
            itemBuilder: (context, index) {
              final building = state.buildings[index];
              final bldApartments = state.apartments.where((a) => a.buildingId == building.id).toList();

              // استخراج أسماء الطوابق المتاحة من المحضر
              Map<String, dynamic> availableFloors = {};
              try {
                availableFloors = jsonDecode(building.floorCoefficients);
              } catch (e) {
                // تجاهل الخطأ في حال كانت البيانات فارغة أو غير صالحة
              }

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  initiallyExpanded: false, 
                  
                  title: Row(
                    children:[
                      Text(
                        '🏢 ${building.name}', 
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children:[
                          // 🌟 استدعاء الدالة من الملف المفصول
                          IconButton(
                            icon: const Icon(Icons.edit_note, color: Colors.orange),
                            tooltip: 'تعديل اسم وموقع المحضر',
                            onPressed: () => showEditBuildingDialog(context, building), 
                          ),
                          IconButton(
                            icon: const Icon(Icons.domain_verification, color: Colors.teal),
                            tooltip: 'عرض تفاصيل المحضر',
                            onPressed: () => showBuildingDetailsDialog(context, building),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  subtitle: Text(
                    'الموقع: ${building.location} | إجمالي الشقق: ${bldApartments.length}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  children:[
                    if (availableFloors.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0), 
                        child: Text('لم يتم إعداد طوابق لهذا المحضر بعد.'),
                      ),
                    
                    ...availableFloors.keys.map((floorName) {
                      final floorApts = bldApartments.where((a) => a.floorName == floorName).toList();
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.indigo.shade100, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: ExpansionTile(
                          title: Row(
                            children:[
                              Icon(Icons.layers, color: Colors.indigo.shade300, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '$floorName ( ${floorApts.length} شقق )', 
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                              ),
                            ],
                          ),
                          children:[
                            if (floorApts.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16.0), 
                                child: Text('لا توجد شقق في هذا الطابق.', style: TextStyle(color: Colors.grey)),
                              ),
                            
                            if (floorApts.isNotEmpty)
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.indigo.shade50, width: 1.5),
                                    boxShadow:[
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
                                      headingRowHeight: 54,
                                      dataRowMinHeight: 60,
                                      dataRowMaxHeight: 60,
                                      horizontalMargin: 24,
                                      columnSpacing: 40,
                                      dividerThickness: 0.5,
                                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                                      headingTextStyle: const TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        color: Color(0xFF475569), 
                                        fontSize: 14,
                                      ),
                                      columns: const[
                                        DataColumn(label: Text('رقم الشقة')),
                                        DataColumn(label: Text('المساحة')),
                                        DataColumn(label: Text('الاتجاه')),
                                        DataColumn(label: Text('الحالة')),
                                        DataColumn(label: Text('إجراءات')),
                                      ],
                                      rows: floorApts.map((apt) {
                                        final isAvailable = apt.status == 'available';
                                        return DataRow(
                                          cells:[
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children:[
                                                  Icon(Icons.door_front_door_outlined, size: 18, color: Colors.indigo.shade300),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    apt.apartmentNumber, 
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            DataCell(Text('${apt.area} م²', style: const TextStyle(fontWeight: FontWeight.w500))),
                                            DataCell(Text(apt.directionName ?? '-', style: TextStyle(color: Colors.grey.shade700))),
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
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children:[
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 8), 
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange.shade50,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: IconButton(
                                                      icon: const Icon(Icons.edit_note, size: 20, color: Colors.orange),
                                                      tooltip: 'تعديل الشقة',
                                                      // 🌟 استدعاء الدالة من الملف المفصول
                                                      onPressed: () => showEditApartmentDialog(context, apt),
                                                    ),
                                                  ),
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
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12), 
                                  bottomRight: Radius.circular(12)
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children:[
                                  TextButton.icon(
                                    icon: const Icon(Icons.add_home),
                                    label: const Text('إضافة شقة هنا'),
                                    onPressed: () => showAddApartmentDialog(context, building, preSelectedFloor: floorName),
                                  ),
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
        heroTag: null,
        backgroundColor: Colors.indigo,
        onPressed: () => showAddBuildingDialog(context),
        icon: const Icon(Icons.domain_add, color: Colors.white),
        label: const Text('إضافة محضر جديد', style: TextStyle(color: Colors.white)),
      ),
    );
  }  
}
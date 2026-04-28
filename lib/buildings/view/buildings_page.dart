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
import 'dialogs/edit_building_dialog.dart';
import 'dialogs/edit_apartment_dialog.dart';
// 🌟 استيراد نافذة المحلات التجارية الجديدة
import 'dialogs/add_shop_dialog.dart';

class BuildingsPage extends StatefulWidget {
  const BuildingsPage({super.key});

  @override
  State<BuildingsPage> createState() => _BuildingsPageState();
}

class _BuildingsPageState extends State<BuildingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<BuildingsCubit>().loadData();
  }

  @override
  Widget build(BuildContext context) {
    return const BuildingsView();
  }
}

class BuildingsView extends StatelessWidget {
  const BuildingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كتالوج المشاريع والوحدات العقارية', style: TextStyle(color: Colors.white)),
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
              
              // 🌟 فلترة الوحدات العقارية إلى شقق ومحلات
              final allUnits = state.apartments.where((a) => a.buildingId == building.id).toList();
              final bldApartments = allUnits.where((a) => a.unitType == 'apartment').toList();
              final bldShops = allUnits.where((a) => a.unitType == 'shop').toList();

              Map<String, dynamic> availableFloors = {};
              try {
                availableFloors = jsonDecode(building.floorCoefficients);
              } catch (e) {
                // تجاهل
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
                  
                  // 🌟 تحديث العنوان الفرعي ليعرض عدد الشقق والمحلات
                  subtitle: Text(
                    'الموقع: ${building.location} | الشقق: ${bldApartments.length} | المحلات: ${bldShops.length}',
                    style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                  ),
                  children:[
                    // ==========================================
                    // 🚪 1. قسم الشقق السكنية (يُعرض حسب الطوابق)
                    // ==========================================
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
                                  decoration: _tableDecoration(Colors.indigo.shade50),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: DataTable(
                                      headingRowHeight: 54, dataRowMinHeight: 60, dataRowMaxHeight: 60,
                                      horizontalMargin: 24, columnSpacing: 40, dividerThickness: 0.5,
                                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                                      columns: const[
                                        DataColumn(label: Text('رقم الشقة', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('المساحة', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('الاتجاه', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
                                        DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
                                      ],
                                      rows: floorApts.map((apt) => _buildDataRow(context, apt, isShop: false)).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
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

                    // ==========================================
                    // 🏪 2. قسم المحلات التجارية (يعرض كقائمة مستقلة)
                    // ==========================================
                    if (bldShops.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange.shade200, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.orange.shade50,
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: true, // نفتحه افتراضياً ليلفت الانتباه
                          title: Row(
                            children:[
                              Icon(Icons.storefront, color: Colors.orange.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'المحلات التجارية ( ${bldShops.length} محلات )', 
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                              ),
                            ],
                          ),
                          children:[
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Container(
                                decoration: _tableDecoration(Colors.orange.shade100),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: DataTable(
                                    headingRowHeight: 54, dataRowMinHeight: 60, dataRowMaxHeight: 60,
                                    horizontalMargin: 24, columnSpacing: 40, dividerThickness: 0.5,
                                    headingRowColor: WidgetStateProperty.all(Colors.orange.shade50),
                                    columns: const[
                                      DataColumn(label: Text('رقم/رمز المحل', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
                                      DataColumn(label: Text('المساحة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
                                      DataColumn(label: Text('الواجهة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
                                      DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
                                      DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))),
                                    ],
                                    rows: bldShops.map((shop) => _buildDataRow(context, shop, isShop: true)).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),
                    
                    // ==========================================
                    // 🌟 3. أزرار إضافة الوحدة (محل جديد)
                    // ==========================================
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
                            ),
                            icon: const Icon(Icons.add_business),
                            label: const Text('إضافة محل تجاري للمحضر', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => showAddShopDialog(context, building),
                          ),
                        ],
                      ),
                    ),
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

  // دالة مساعدة لتصميم إطار الجداول
  BoxDecoration _tableDecoration(Color borderColor) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor, width: 1.5),
      boxShadow:[
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 4)),
      ],
    );
  }

  // دالة مساعدة لرسم صف في الجدول (للشقق والمحلات)
  DataRow _buildDataRow(BuildContext context, Apartment apt, {required bool isShop}) {
    final isAvailable = apt.status == 'available';
    final mainColor = isShop ? Colors.orange : Colors.indigo;
    
    return DataRow(
      cells:[
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children:[
              Icon(isShop ? Icons.store : Icons.door_front_door_outlined, size: 18, color: mainColor.shade300),
              const SizedBox(width: 8),
              Text(
                apt.apartmentNumber, 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: mainColor),
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
              border: Border.all(color: isAvailable ? Colors.green.shade200 : Colors.red.shade200, width: 1),
            ),
            child: Text(
              isAvailable ? 'متاحة' : 'مباعة', 
              style: TextStyle(
                color: isAvailable ? Colors.green.shade700 : Colors.red.shade700, 
                fontWeight: FontWeight.bold, fontSize: 12,
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
                decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.edit_note, size: 20, color: Colors.orange),
                  tooltip: 'تعديل',
                  // يمكنك لاحقاً عمل نافذة تعديل خاصة للمحلات إذا احتجت
                  onPressed: () => showEditApartmentDialog(context, apt), 
                ),
              ),
              Container(
                decoration: BoxDecoration(color: Colors.indigo.shade50, shape: BoxShape.circle),
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
  }
}
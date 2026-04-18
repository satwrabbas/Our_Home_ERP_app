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

// ... باقي الكود كما هو تماماً (appBar و BlocConsumer الخ...)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كتالوج المشاريع والشقق', style: TextStyle(color: Colors.white)),
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
            // ... (باقي الكود يبقى كما هو)
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
                  // 👈 تبقى الجوارير مقفلة عند الفتح
                  initiallyExpanded: false, 
                  
                  title: Row(
                    children: [
                      Text(
                        '🏢 ${building.name}', 
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      const Spacer(),
                      // 🌟 الأزرار موضوعة في Row لترتيبها
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🌟 زر تعديل المحضر (الجديد)
                          IconButton(
                            icon: const Icon(Icons.edit_note, color: Colors.orange),
                            tooltip: 'تعديل اسم وموقع المحضر',
                            onPressed: () => _showEditBuildingDialog(context, building),
                          ),
                          // 🌟 زر التفاصيل (القديم)
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
                  children: [
                    if (availableFloors.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0), 
                        child: Text('لم يتم إعداد طوابق لهذا المحضر بعد.'),
                      ),
                    
                    // عرض الطوابق كقوائم داخلية
                    ...availableFloors.keys.map((floorName) {
                      // شقق هذا الطابق تحديداً
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
                            children: [
                              Icon(Icons.layers, color: Colors.indigo.shade300, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '$floorName ( ${floorApts.length} شقق )', 
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                              ),
                            ],
                          ),
                          children: [
                            // في حال لا يوجد شقق
                            if (floorApts.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16.0), 
                                child: Text('لا توجد شقق في هذا الطابق.', style: TextStyle(color: Colors.grey)),
                              ),
                            
                            // 🌟 التصميم الحديث والجديد لجدول الشقق (SaaS Design)
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
                                            // 1. رقم الشقة
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
                                            // 2. المساحة
                                            DataCell(Text('${apt.area} م²', style: const TextStyle(fontWeight: FontWeight.w500))),
                                            // 3. الاتجاه
                                            DataCell(Text(apt.directionName ?? '-', style: TextStyle(color: Colors.grey.shade700))),
                                            // 4. الحالة (Badge)
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
                                            // 5. إجراءات (الأزرار)
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // 🌟 زر تعديل الشقة (الجديد)
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 8), // مسافة بين الزرين
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange.shade50,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: IconButton(
                                                      icon: const Icon(Icons.edit_note, size: 20, color: Colors.orange),
                                                      tooltip: 'تعديل الشقة',
                                                      onPressed: () => _showEditApartmentDialog(context, apt),
                                                    ),
                                                  ),
                                                  // 🌟 زر التفاصيل (القديم)
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
                            
                            // أزرار التحكم الخاصة بالطابق (لم يتم حذف أي زر)
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
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.add_home),
                                    label: const Text('إضافة شقة هنا'),
                                    onPressed: () => showAddApartmentDialog(context, building, preSelectedFloor: floorName),
                                  ),
                                  // زر النسخ (يظهر فقط إذا كان هناك شقق لنسخها)
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
      // زر إضافة محضر جديد (الزر العائم)
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        onPressed: () => showAddBuildingDialog(context),
        icon: const Icon(Icons.domain_add, color: Colors.white),
        label: const Text('إضافة محضر جديد', style: TextStyle(color: Colors.white)),
      ),
    );
  }  

  // ==========================================
  // ✏️ نافذة تعديل المحضر (Building)
  // ==========================================
  void _showEditBuildingDialog(BuildContext parentContext, dynamic building) {
    // تعبئة البيانات مسبقاً
    final nameController = TextEditingController(text: building.name);
    final locationController = TextEditingController(text: building.location ?? '');

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تعديل بيانات المحضر', style: TextStyle(color: Colors.indigo)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController, 
                  decoration: const InputDecoration(labelText: 'اسم المحضر', border: OutlineInputBorder())
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController, 
                  decoration: const InputDecoration(labelText: 'الموقع / العنوان', border: OutlineInputBorder())
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  parentContext.read<BuildingsCubit>().updateBuilding(
                    id: building.id,
                    name: nameController.text.trim(),
                    location: locationController.text.trim(),
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('حفظ التعديلات'),
            ),
          ],
        );
      },
    );
  }


  // ==========================================
  // ✏️ نافذة تعديل الشقة (Apartment)
  // ==========================================
  void _showEditApartmentDialog(BuildContext parentContext, dynamic apt) {
    // تعبئة البيانات مسبقاً
    final numberController = TextEditingController(text: apt.apartmentNumber);
    final areaController = TextEditingController(text: apt.area.toString());
    
    // حفظ الاتجاه الحالي
    String selectedDirection = apt.directionName ?? 'شمالي';
    
    // قائمة الاتجاهات المسموح بها لتجنب الأخطاء الإملائية
    final List<String> directions = ['شمالي', 'جنوبي', 'شرقي', 'غربي', 'شمالي شرقي', 'شمالي غربي', 'جنوبي شرقي', 'جنوبي غربي'];
    
    // التأكد من أن الاتجاه الموجود في القاعدة موجود في القائمة، وإلا نختار أول عنصر
    if (!directions.contains(selectedDirection)) {
      selectedDirection = directions.first;
    }

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('تعديل الشقة ( ${apt.apartmentNumber} )', style: const TextStyle(color: Colors.indigo)),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // تنبيه هندسي
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.amber.shade50,
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.brown, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'لا يمكن تعديل معاملات التميز أو الطابق حفاظاً على سلامة الحسابات. لتغييرها يجب حذف الشقة وإضافتها من جديد.',
                              style: TextStyle(color: Colors.brown, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: numberController, 
                            decoration: const InputDecoration(labelText: 'رقم الشقة', border: OutlineInputBorder())
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: areaController, 
                            decoration: const InputDecoration(labelText: 'المساحة (م²)', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: selectedDirection,
                      decoration: const InputDecoration(labelText: 'الاتجاه', border: OutlineInputBorder()),
                      items: directions.map((dir) => DropdownMenuItem(value: dir, child: Text(dir))).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedDirection = val!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                  onPressed: () {
                    if (numberController.text.trim().isNotEmpty && areaController.text.trim().isNotEmpty) {
                      parentContext.read<BuildingsCubit>().updateApartment(
                        id: apt.id,
                        apartmentNumber: numberController.text.trim(),
                        area: double.tryParse(areaController.text.trim()) ?? apt.area,
                        directionName: selectedDirection,
                      );
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('حفظ التعديلات'),
                ),
              ],
            );
          }
        );
      },
    );
  }

}
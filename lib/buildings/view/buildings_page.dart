//buildings_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show Building, Apartment; // 🌟 تم استيراد Apartment هنا
import '../cubit/buildings_cubit.dart';
import 'dialogs/add_building_dialog.dart';


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
                        onPressed: () => _showBuildingDetailsDialog(context, building),
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
                                        onPressed: () => _showApartmentDetailsDialog(context, apt),
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
                                    onPressed: () => _showAddApartmentDialog(context, building, preSelectedFloor: floorName),
                                  ),
                                  // 🌟 زر النسخ (يظهر فقط إذا كان هناك شقق لنسخها)
                                  if (floorApts.isNotEmpty)
                                    TextButton.icon(
                                      icon: const Icon(Icons.copy_all, color: Colors.orange),
                                      label: const Text('نسخ نموذج الطابق', style: TextStyle(color: Colors.orange)),
                                      onPressed: () => _showCopyFloorDialog(context, building, floorName, floorApts, availableFloors.keys.toList()),
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

  // ===============================================
  // 🏢 دالة توليد أسماء الطوابق بالعربية
  // ===============================================
  String _getArabicFloorName(int floorNumber) {
    if (floorNumber == 0) return 'الطابق الأرضي';
    if (floorNumber > 0) {
      const names = ['الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس', 'السادس'];
      return 'الطابق ${names[floorNumber - 1]}';
    } else {
      const names = ['الأول', 'الثاني', 'الثالث'];
      return 'القبو ${names[floorNumber.abs() - 1]}';
    }
  }

  // ===============================================
  // 🔍 نافذة عرض تفاصيل ومعاملات الشقة (محدثة مع الحالة)
  // ===============================================
  void _showApartmentDetailsDialog(BuildContext context, Apartment apt) {
    Map<String, dynamic> aptCoeffs = {};
    try {
      aptCoeffs = jsonDecode(apt.customCoefficients);
    } catch (e) {
      print('Error decoding: $e');
    }

    // 🌟 التحقق من حالة الشقة
    final bool isAvailable = apt.status == 'available';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('تفاصيل الشقة ${apt.apartmentNumber}', style: const TextStyle(color: Colors.indigo)),
            // 🌟 شريطة ملونة توضح حالة الشقة فور فتح النافذة
            Chip(
              label: Text(isAvailable ? 'متاحة للبيع' : 'مباعة', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: isAvailable ? Colors.green : Colors.red,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الطابق: ${apt.floorName}', style: const TextStyle(fontSize: 16)),
            Text('الاتجاه: ${apt.directionName ?? "-"}', style: const TextStyle(fontSize: 16)),
            Text('المساحة: ${apt.area} م2', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            // 🌟 توضيح نصي إضافي
            Text('الحالة الحالية: ${isAvailable ? "لم يتم توقيع عقد عليها بعد" : "تم توقيع عقد ومربوطة بعميل"}', 
                 style: TextStyle(color: isAvailable ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold)),
            
            const Divider(height: 30, thickness: 2),
            const Text('المعاملات المطبقة على هذه الشقة:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 12),
            if (aptCoeffs.isEmpty)
              const Text('لا توجد معاملات خاصة مسجلة.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: aptCoeffs.entries.map((e) {
                  return Chip(
                    label: Text('${e.key}: ${e.value}%'),
                    backgroundColor: Colors.teal.shade50,
                    side: BorderSide(color: Colors.teal.shade200),
                  );
                }).toList(),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  // ===============================================
  // 🏢 نافذة إضافة المحضر
  // ===============================================
  void _showAddBuildingDialog(BuildContext parentContext) {
    final nameCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    
    final locationCoeffCtrl = TextEditingController(text: '0');
    final streetCoeffCtrl = TextEditingController(text: '0');
    final elevatorCoeffCtrl = TextEditingController(text: '0');

    int basementsCount = 0; 
    int floorsCount = 1;    
    Map<int, TextEditingController> floorControllers = {};

    showDialog(
      context: parentContext,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (statefulCtx, setState) {
          
          List<Widget> buildFloorInputs() {
            List<Widget> widgets = [];
            for (int i = -basementsCount; i <= floorsCount; i++) {
              floorControllers.putIfAbsent(i, () => TextEditingController(text: '0'));
              widgets.add(
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      SizedBox(width: 120, child: Text(_getArabicFloorName(i), style: const TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                        child: TextField(
                          controller: floorControllers[i],
                          decoration: const InputDecoration(labelText: 'نسبة التمييز %', border: OutlineInputBorder(), isDense: true),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                )
              );
            }
            return widgets;
          }

          return AlertDialog(
            title: const Text('إضافة محضر جديد (إعداد الهيكل)'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المحضر', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'الموقع', border: OutlineInputBorder())),
                    
                    const Divider(height: 30, thickness: 2),
                    const Text('معاملات المحضر العامة (%)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: locationCoeffCtrl, decoration: const InputDecoration(labelText: 'الموقع %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: streetCoeffCtrl, decoration: const InputDecoration(labelText: 'الشارع %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: elevatorCoeffCtrl, decoration: const InputDecoration(labelText: 'المصعد %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      ],
                    ),

                    const Divider(height: 30, thickness: 2),
                    const Text('هيكل الطوابق ونسب التمييز لكل طابق', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                    const SizedBox(height: 12),
                    
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.indigo.shade50,
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: basementsCount,
                              decoration: const InputDecoration(labelText: 'عدد الأقبية (تحت الأرض)'),
                              items: [0, 1, 2, 3].map((e) => DropdownMenuItem(value: e, child: Text('$e قبو'))).toList(),
                              onChanged: (val) => setState(() => basementsCount = val!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: floorsCount,
                              decoration: const InputDecoration(labelText: 'عدد الطوابق (فوق الأرضي)'),
                              items: [0, 1, 2, 3, 4].map((e) => DropdownMenuItem(value: e, child: Text('$e طابق'))).toList(),
                              onChanged: (val) => setState(() => floorsCount = val!),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...buildFloorInputs(),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty) {
                    Map<String, double> finalFloorCoeffs = {};
                    floorControllers.forEach((floorNum, ctrl) {
                      final val = double.tryParse(ctrl.text);
                      if (val != null) finalFloorCoeffs[_getArabicFloorName(floorNum)] = val;
                    });

                    Map<String, double> finalDirCoeffs = {};
                    void addGeneralVal(String key, String val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null && parsed != 0.0) finalDirCoeffs[key] = parsed;
                    }
                    addGeneralVal('الموقع', locationCoeffCtrl.text);
                    addGeneralVal('الشارع', streetCoeffCtrl.text);
                    addGeneralVal('المصعد', elevatorCoeffCtrl.text);

                    parentContext.read<BuildingsCubit>().addBuilding(
                      name: nameCtrl.text, 
                      location: locCtrl.text,
                      floorCoeffs: finalFloorCoeffs,
                      dirCoeffs: finalDirCoeffs,
                    );
                    Navigator.pop(dialogCtx);
                  }
                },
                child: const Text('اعتماد وحفظ المحضر'),
              )
            ],
          );
        }
      ),
    );
  }

  // ===============================================
  // 🚪 نافذة إضافة الشقة (مع نسبة الربح مضافة)
  // ===============================================
  void _showAddApartmentDialog(BuildContext parentContext, Building building, {String? preSelectedFloor}) {

    final numCtrl = TextEditingController();
    final areaCtrl = TextEditingController();
    final dirNameCtrl = TextEditingController();

    final directionCoeffCtrl = TextEditingController(text: '0');
    final yardCoeffCtrl = TextEditingController(text: '0');
    final profitCoeffCtrl = TextEditingController(text: '0'); // 🌟 نسبة الربح للشقة

    Map<String, dynamic> availableFloors = {};
    try {
      availableFloors = jsonDecode(building.floorCoefficients);
    } catch (e) {
      print('Error decoding floor coeffs: $e');
    }

    String? selectedFloorName = preSelectedFloor ?? (availableFloors.keys.isNotEmpty ? availableFloors.keys.first : null);

    showDialog(
      context: parentContext,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (statefulCtx, setState) {
          return AlertDialog(
            title: const Text('إضافة شقة للكتالوج'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: TextField(controller: numCtrl, decoration: const InputDecoration(labelText: 'رقم الشقة', border: OutlineInputBorder()))),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: areaCtrl, decoration: const InputDecoration(labelText: 'المساحة (م2)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  DropdownButtonFormField<String>(
                    value: selectedFloorName,
                    decoration: const InputDecoration(labelText: 'اختر الطابق (يحدد النسبة آلياً)', border: OutlineInputBorder()),
                    items: availableFloors.keys.map((floorName) {
                      final percentage = availableFloors[floorName];
                      return DropdownMenuItem(value: floorName, child: Text('$floorName (نسبة: $percentage%)'));
                    }).toList(),
                    onChanged: (val) => setState(() => selectedFloorName = val),
                  ),
                  const SizedBox(height: 12),

                  TextField(controller: dirNameCtrl, decoration: const InputDecoration(labelText: 'الاتجاه (مثال: قبلي/شمالي)', border: OutlineInputBorder())),
                  
                  const Divider(height: 30, thickness: 2),
                  const Text('معاملات خاصة بهذه الشقة فقط (%)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: directionCoeffCtrl, decoration: const InputDecoration(labelText: 'نسبة الاتجاه %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(controller: yardCoeffCtrl, decoration: const InputDecoration(labelText: 'نسبة الوجيبة %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // 🌟 حقل نسبة الربح
                  TextField(
                    controller: profitCoeffCtrl, 
                    decoration: const InputDecoration(
                      labelText: 'نسبة الربح المستهدفة (هامش الربح) %', 
                      border: OutlineInputBorder(), 
                      filled: true, 
                      fillColor: Color(0xFFE8F5E9)
                    ), 
                    keyboardType: TextInputType.number
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  if (numCtrl.text.isNotEmpty && areaCtrl.text.isNotEmpty && selectedFloorName != null) {
                    Map<String, double> aptCoeffs = {};
                    
                    final floorPercentage = (availableFloors[selectedFloorName] as num).toDouble();
                    if (floorPercentage != 0.0) aptCoeffs['الطابق ($selectedFloorName)'] = floorPercentage;

                    void addVal(String key, String val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null && parsed != 0.0) aptCoeffs[key] = parsed;
                    }
                    addVal('الاتجاه', directionCoeffCtrl.text);
                    addVal('الوجيبة', yardCoeffCtrl.text);
                    addVal('هامش الربح', profitCoeffCtrl.text); // 🌟 حفظ الربح في JSON الشقة

                    parentContext.read<BuildingsCubit>().addApartment(
                      buildingId: building.id,
                      aptNumber: numCtrl.text,
                      area: double.parse(areaCtrl.text),
                      floorName: selectedFloorName!, 
                      directionName: dirNameCtrl.text,
                      customCoeffs: aptCoeffs, 
                    );
                    Navigator.pop(dialogCtx);
                  }
                },
                child: const Text('حفظ الشقة'),
              )
            ],
          );
        }
      ),
    );
  }

  // ===============================================
  // 🏢 نافذة عرض تفاصيل ومعاملات المحضر
  // ===============================================
  void _showBuildingDetailsDialog(BuildContext context, Building building) {
    Map<String, dynamic> floorCoeffs = {};
    Map<String, dynamic> generalCoeffs = {};

    // فك تشفير JSON الخاص بالمحضر
    try {
      floorCoeffs = jsonDecode(building.floorCoefficients);
      generalCoeffs = jsonDecode(building.directionCoefficients);
    } catch (e) {
      print('Error decoding building coeffs: $e');
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تفاصيل محضر: ${building.name}', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الموقع الجغرافي: ${building.location ?? "غير محدد"}', style: const TextStyle(fontSize: 16)),
              
              const Divider(height: 30, thickness: 2),
              
              const Text('المعاملات العامة للمحضر:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 12),
              if (generalCoeffs.isEmpty)
                const Text('لا توجد معاملات عامة مسجلة.')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: generalCoeffs.entries.map((e) {
                    return Chip(
                      label: Text('${e.key}: ${e.value}%'),
                      backgroundColor: Colors.amber.shade50, // لون مميز للمعاملات العامة
                      side: BorderSide(color: Colors.amber.shade200),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 24),

              const Text('هيكل الطوابق ونسب التمييز:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 12),
              if (floorCoeffs.isEmpty)
                const Text('لم يتم إعداد هيكل طوابق لهذا المحضر.')
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: floorCoeffs.entries.map((e) {
                    return Chip(
                      label: Text('${e.key}  [ ${e.value}% ]'),
                      backgroundColor: Colors.indigo.shade50, // لون مميز للطوابق
                      side: BorderSide(color: Colors.indigo.shade200),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  // ===============================================
  // 📋 نافذة النسخ الآمن للطوابق (Smart Duplicate)
  // ===============================================
  void _showCopyFloorDialog(
    BuildContext parentContext, 
    Building building, 
    String sourceFloorName, 
    List<Apartment> sourceApartments, 
    List<String> allFloors
  ) {
    // استبعاد الطابق الحالي من قائمة النسخ
    List<String> targetFloors = allFloors.where((f) => f != sourceFloorName).toList();
    if (targetFloors.isEmpty) {
      ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('لا توجد طوابق أخرى للنسخ إليها!')));
      return;
    }

    String? selectedTargetFloor = targetFloors.first;
    
    // إنشاء متحكمات نصية لأرقام الشقق الجديدة
    Map<String, TextEditingController> newNumberControllers = {};
    for (var apt in sourceApartments) {
      // وضعنا الرقم القديم مع إشارة نجمة كمقترح مبدئي ليعلم المستخدم أي شقة ينسخ
      newNumberControllers[apt.id] = TextEditingController(text: '${apt.apartmentNumber}*');
    }

    showDialog(
      context: parentContext,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.copy, color: Colors.orange),
                const SizedBox(width: 8),
                Text('استنساخ شقق $sourceFloorName', style: const TextStyle(color: Colors.orange)),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('سيتم نسخ المساحات، الاتجاهات، ومعاملات الربح والوجيبة بدقة تامة.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedTargetFloor,
                      decoration: const InputDecoration(labelText: 'اختر الطابق الوجهة (الهدف)', border: OutlineInputBorder(), filled: true, fillColor: Colors.orangeAccent),
                      items: targetFloors.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      onChanged: (val) => setState(() => selectedTargetFloor = val),
                    ),
                    const Divider(height: 30, thickness: 2),
                    const Text('يرجى تحديد أرقام الشقق الجديدة لمنع التكرار:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    
                    // توليد حقول لإدخال أرقام الشقق الجديدة
                    ...sourceApartments.map((apt) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(child: Text('نسخة من (${apt.apartmentNumber}): \n مساحة ${apt.area}م2', style: const TextStyle(fontSize: 12))),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: newNumberControllers[apt.id],
                                decoration: const InputDecoration(labelText: 'رقم الشقة الجديد', border: OutlineInputBorder(), isDense: true),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('إلغاء')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                onPressed: () async {
                  // التحقق من أن جميع الأرقام تم تعبئتها
                  bool hasEmpty = newNumberControllers.values.any((c) => c.text.trim().isEmpty);
                  if (hasEmpty || selectedTargetFloor == null) {
                    ScaffoldMessenger.of(dialogCtx).showSnackBar(const SnackBar(content: Text('يرجى تعبئة أرقام جميع الشقق!')));
                    return;
                  }

                  // جلب نسبة الطابق الجديد (الهدف) من JSON المحضر
                  Map<String, dynamic> availableFloors = jsonDecode(building.floorCoefficients);
                  final targetFloorPercentage = (availableFloors[selectedTargetFloor] as num).toDouble();

                  // عملية النسخ: الدوران على الشقق الأصلية، وإضافة شقق جديدة
                  final cubit = parentContext.read<BuildingsCubit>();
                  
                  for (var apt in sourceApartments) {
                    // فك تشفير معاملات الشقة القديمة
                    Map<String, dynamic> copiedCoeffs = jsonDecode(apt.customCoefficients);
                    
                    // 🚨 تحديث معامل الطابق بالاسم والنسبة الخاصة بالطابق الجديد!
                    // يجب إزالة المعامل القديم أولاً إذا كان موجوداً
                    copiedCoeffs.removeWhere((key, value) => key.startsWith('الطابق'));
                    if (targetFloorPercentage != 0.0) {
                      copiedCoeffs['الطابق ($selectedTargetFloor)'] = targetFloorPercentage;
                    }

                    // تحويلها لـ Map<String, double> لتقبلها دالة الإضافة
                    Map<String, double> finalCoeffs = {};
                    copiedCoeffs.forEach((k, v) => finalCoeffs[k] = (v as num).toDouble());

                    // إرسال الشقة الجديدة لقاعدة البيانات
                    await cubit.addApartment(
                      buildingId: building.id,
                      aptNumber: newNumberControllers[apt.id]!.text.trim(), // الرقم الجديد المكتوب باليد
                      area: apt.area, // نفس المساحة
                      floorName: selectedTargetFloor!, // الطابق الجديد
                      directionName: apt.directionName ?? '', // نفس الاتجاه
                      customCoeffs: finalCoeffs, // نفس المعاملات + تعديل نسبة الطابق
                    );
                  }

                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(content: Text('تم استنساخ الشقق إلى $selectedTargetFloor بنجاح! ✅'), backgroundColor: Colors.green));
                },
                child: const Text('حفظ الشقق المستنسخة'),
              )
            ],
          );
        }
      ),
    );
  }
}
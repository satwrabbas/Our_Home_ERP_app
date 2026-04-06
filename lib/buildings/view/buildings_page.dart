//buildings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import '../cubit/buildings_cubit.dart';

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
        title: const Text('كتالوج المشاريع والشقق (Offline)', style: TextStyle(color: Colors.white)),
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

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text('🏢 ${building.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  subtitle: Text('الموقع: ${building.location} | إجمالي الشقق: ${bldApartments.length}'),
                  children: [
                    if (bldApartments.isEmpty)
                      const Padding(padding: EdgeInsets.all(16.0), child: Text('لم يتم إدخال شقق في هذا المحضر بعد.')),
                    if (bldApartments.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('الشقة')),
                            DataColumn(label: Text('الطابق')),
                            DataColumn(label: Text('الاتجاه')),
                            DataColumn(label: Text('المساحة')),
                            DataColumn(label: Text('الحالة')),
                          ],
                          rows: bldApartments.map((apt) => DataRow(cells: [
                            DataCell(Text(apt.apartmentNumber, style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(apt.floorName)),
                            DataCell(Text(apt.directionName ?? '-')),
                            DataCell(Text('${apt.area} م2')),
                            DataCell(Chip(
                              label: Text(apt.status == 'available' ? 'متاحة' : 'مباعة', style: const TextStyle(color: Colors.white)),
                              backgroundColor: apt.status == 'available' ? Colors.green : Colors.red,
                            )),
                          ])).toList(),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddApartmentDialog(context, building.id),
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة شقة جديدة لهذا المحضر'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade50),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        onPressed: () => _showAddBuildingDialog(context),
        icon: const Icon(Icons.domain_add, color: Colors.white),
        label: const Text('إضافة محضر جديد', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // ===============================================
  // 🏢 نافذة إضافة المحضر (مع معاملات الموقع)
  // ===============================================
  void _showAddBuildingDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    
    // حقول معاملات المحضر
    final locationCoeffCtrl = TextEditingController(text: '0');
    final streetCoeffCtrl = TextEditingController(text: '0');
    final elevatorCoeffCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة محضر (مشروع) جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المحضر (مثال: برج السلام)', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'الموقع (مثال: شارع الثورة)', border: OutlineInputBorder())),
              const Divider(height: 30, thickness: 2),
              const Text('قوالب النسب المئوية العامة للمحضر (%)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: locationCoeffCtrl, decoration: const InputDecoration(labelText: 'الموقع %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: streetCoeffCtrl, decoration: const InputDecoration(labelText: 'الشارع %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: elevatorCoeffCtrl, decoration: const InputDecoration(labelText: 'المصعد %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                // تجميع معاملات المحضر في Map
                Map<String, double> bldCoeffs = {};
                void addVal(String key, String val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null && parsed != 0.0) bldCoeffs[key] = parsed;
                }
                addVal('الموقع', locationCoeffCtrl.text);
                addVal('الشارع', streetCoeffCtrl.text);
                addVal('المصعد', elevatorCoeffCtrl.text);

                // سنقوم بتخزينها في حقل floorCoefficients (كاستخدام عام للمحضر)
                context.read<BuildingsCubit>().addBuilding(
                  name: nameCtrl.text, 
                  location: locCtrl.text,
                  floorCoeffs: bldCoeffs, // <- 🌟 سيتم تحويلها لـ JSON في الـ Cubit
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('حفظ المحضر'),
          )
        ],
      ),
    );
  }

  // ===============================================
  // 🚪 نافذة إضافة الشقة (مع المعاملات الخاصة)
  // ===============================================
  void _showAddApartmentDialog(BuildContext context, String buildingId) {
    final numCtrl = TextEditingController();
    final areaCtrl = TextEditingController();
    final floorNameCtrl = TextEditingController();
    final dirNameCtrl = TextEditingController();

    // حقول معاملات الشقة
    final floorCoeffCtrl = TextEditingController(text: '0');
    final directionCoeffCtrl = TextEditingController(text: '0');
    final yardCoeffCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
              Row(
                children: [
                  Expanded(child: TextField(controller: floorNameCtrl, decoration: const InputDecoration(labelText: 'اسم الطابق', border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: dirNameCtrl, decoration: const InputDecoration(labelText: 'الاتجاه', border: OutlineInputBorder()))),
                ],
              ),
              const Divider(height: 30, thickness: 2),
              const Text('معاملات التمييز الخاصة بهذه الشقة (%)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: floorCoeffCtrl, decoration: const InputDecoration(labelText: 'الطابق %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: directionCoeffCtrl, decoration: const InputDecoration(labelText: 'الاتجاه %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: yardCoeffCtrl, decoration: const InputDecoration(labelText: 'الوجيبة %', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (numCtrl.text.isNotEmpty && areaCtrl.text.isNotEmpty) {
                // تجميع معاملات الشقة في Map
                Map<String, double> aptCoeffs = {};
                void addVal(String key, String val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null && parsed != 0.0) aptCoeffs[key] = parsed;
                }
                addVal('الطابق', floorCoeffCtrl.text);
                addVal('الاتجاه', directionCoeffCtrl.text);
                addVal('الوجيبة', yardCoeffCtrl.text);

                context.read<BuildingsCubit>().addApartment(
                  buildingId: buildingId,
                  aptNumber: numCtrl.text,
                  area: double.parse(areaCtrl.text),
                  floorName: floorNameCtrl.text,
                  directionName: dirNameCtrl.text,
                  customCoeffs: aptCoeffs, // <- 🌟 سيتم تحويلها لـ JSON في الـ Cubit
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('حفظ الشقة'),
          )
        ],
      ),
    );
  }
}
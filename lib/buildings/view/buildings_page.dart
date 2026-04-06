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
              // جلب شقق هذا المحضر فقط
              final bldApartments = state.apartments.where((a) => a.buildingId == building.id).toList();

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text('🏢 ${building.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  subtitle: Text('الموقع: ${building.location} | إجمالي الشقق المُدخلة: ${bldApartments.length}'),
                  children:[
                    if (bldApartments.isEmpty)
                      const Padding(padding: EdgeInsets.all(16.0), child: Text('لم يتم إدخال شقق في هذا المحضر بعد.')),
                    if (bldApartments.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const[
                            DataColumn(label: Text('رقم الشقة')),
                            DataColumn(label: Text('الطابق')),
                            DataColumn(label: Text('الاتجاه')),
                            DataColumn(label: Text('المساحة')),
                            DataColumn(label: Text('الحالة')),
                          ],
                          rows: bldApartments.map((apt) => DataRow(cells:[
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
  // 🏢 نافذة إضافة المحضر
  // ===============================================
  void _showAddBuildingDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final locCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة محضر (مشروع) جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المحضر (مثال: برج السلام)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'الموقع (مثال: شارع الثورة)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            const Text('ملاحظة: إضافة قوالب النسب (كـ JSON) سيتم تصميمها في مرحلة لاحقة.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions:[
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                context.read<BuildingsCubit>().addBuilding(name: nameCtrl.text, location: locCtrl.text);
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
  // 🚪 نافذة إضافة الشقة
  // ===============================================
  void _showAddApartmentDialog(BuildContext context, String buildingId) {
    final numCtrl = TextEditingController();
    final areaCtrl = TextEditingController();
    final floorNameCtrl = TextEditingController();
    final dirNameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة شقة للكتالوج'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            TextField(controller: numCtrl, decoration: const InputDecoration(labelText: 'رقم/رمز الشقة (مثال: 101, A2)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: areaCtrl, decoration: const InputDecoration(labelText: 'المساحة (م2)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: floorNameCtrl, decoration: const InputDecoration(labelText: 'الطابق (مثال: الطابق الثاني)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: dirNameCtrl, decoration: const InputDecoration(labelText: 'الاتجاه (مثال: جنوبي)', border: OutlineInputBorder())),
          ],
        ),
        actions:[
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (numCtrl.text.isNotEmpty && areaCtrl.text.isNotEmpty) {
                context.read<BuildingsCubit>().addApartment(
                  buildingId: buildingId,
                  aptNumber: numCtrl.text,
                  area: double.parse(areaCtrl.text),
                  floorName: floorNameCtrl.text,
                  directionName: dirNameCtrl.text,
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
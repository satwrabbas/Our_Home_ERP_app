import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import '../cubit/contracts_cubit.dart';

class ContractsPage extends StatelessWidget {
  const ContractsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContractsView();
  }
}

class ContractsView extends StatelessWidget {
  const ContractsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العقود والشقق', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddContractDialog(context),
        icon: const Icon(Icons.add_home_work),
        label: const Text('عقد جديد'),
        backgroundColor: Colors.teal,
      ),
      body: BlocBuilder<ContractsCubit, ContractsState>(
        builder: (context, state) {
          // 1. حالة التحميل
          if (state.status == ContractsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          // 2. إذا لم يقم المستخدم بإضافة أي عميل في التطبيق بعد
          if (state.clients.isEmpty) {
            return const Center(
              child: Text('يرجى إضافة عميل واحد على الأقل من شاشة العملاء قبل إضافة العقود.', style: TextStyle(fontSize: 18)),
            );
          }

          // 3. إذا كان هناك عملاء، لكن لا يوجد أي عقد حتى الآن
          if (state.contracts.isEmpty) {
            return const Center(
              child: Text('لم يتم توقيع أي عقود بعد. اضغط على "عقد جديد".', style: TextStyle(fontSize: 18)),
            );
          }

          // 4. عرض العقود في جدول أنيق (إذا كان هناك عقود)
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.teal.shade50), // تم تعديل MaterialStateProperty إلى WidgetStateProperty لتناسب التحديثات الجديدة
                columns: const[
                  DataColumn(label: Text('رقم العقد', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('وصف الشقة', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('المساحة (م2)', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('سعر المتر', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('القيمة الإجمالية', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('القسط الشهري', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: state.contracts.map((contract) {
                  return DataRow(cells:[
                    DataCell(Text(contract.id.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(contract.apartmentDescription)),
                    DataCell(Text('${contract.apartmentArea} م2')),
                    DataCell(Text(contract.pricePerSqmAtSigning.toStringAsFixed(0))),
                    DataCell(Text(contract.totalContractValue.toStringAsFixed(0), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                    DataCell(Text(contract.monthlyInstallment.toStringAsFixed(0))),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddContractDialog(BuildContext parentContext) {
    final state = parentContext.read<ContractsCubit>().state;
    if (state.clients.isEmpty) return;

    // المتغيرات
    int? selectedClientId = state.clients.first.id;
    final descController = TextEditingController();
    final areaController = TextEditingController();
    final priceController = TextEditingController();
    final installmentController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('توقيع عقد شقة جديد'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:[
                  // قائمة منسدلة لاختيار العميل
                  DropdownButtonFormField<int>(
                    value: selectedClientId,
                    decoration: const InputDecoration(labelText: 'اختر العميل (الفريق الثاني)', border: OutlineInputBorder()),
                    items: state.clients.map((client) {
                      return DropdownMenuItem(
                        value: client.id,
                        child: Text(client.name),
                      );
                    }).toList(),
                    onChanged: (val) => selectedClientId = val,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'وصف الشقة (مثال: شقة لاحقة التخصص الطابق الأول)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: areaController,
                    decoration: const InputDecoration(labelText: 'مساحة الشقة (م2)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'سعر المتر المربع عند التوقيع', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: installmentController,
                    decoration: const InputDecoration(labelText: 'القسط الشهري المتفق عليه', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions:[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedClientId != null && areaController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  parentContext.read<ContractsCubit>().addContract(
                    clientId: selectedClientId!,
                    description: descController.text,
                    area: double.parse(areaController.text),
                    pricePerSqm: double.parse(priceController.text),
                    monthlyInstallment: double.parse(installmentController.text.isEmpty ? "0" : installmentController.text),
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('حفظ العقد'),
            ),
          ],
        );
      },
    );
  }
}
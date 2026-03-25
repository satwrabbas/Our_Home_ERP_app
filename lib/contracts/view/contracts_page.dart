import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/calculator_helper.dart';
import '../../settings/cubit/settings_cubit.dart';
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
          if (state.status == ContractsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } 
          if (state.clients.isEmpty) {
            return const Center(child: Text('يرجى إضافة عميل واحد على الأقل أولاً.', style: TextStyle(fontSize: 18)));
          }
          if (state.contracts.isEmpty) {
            return const Center(child: Text('لم يتم توقيع أي عقود بعد. اضغط على "عقد جديد".', style: TextStyle(fontSize: 18)));
          }

          // عرض العقود بأسماء الحقول الجديدة
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.teal.shade50),
                columns: const[
                  DataColumn(label: Text('رقم العقد', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('وصف الشقة', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('المساحة الكلية (م2)', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('سعر المتر المبدئي', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('تاريخ التوقيع', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('مكتمل؟', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: state.contracts.map((contract) {
                  return DataRow(cells:[
                    DataCell(Text(contract.id.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(contract.apartmentDetails)),
                    DataCell(Text('${contract.totalArea} م2')),
                    DataCell(Text(contract.baseMeterPriceAtSigning.toStringAsFixed(0), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                    DataCell(Text('${contract.contractDate.year}/${contract.contractDate.month}/${contract.contractDate.day}')),
                    DataCell(Icon(contract.isCompleted ? Icons.check_circle : Icons.pending_actions, color: contract.isCompleted ? Colors.green : Colors.orange)),
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
    final currentPrices = parentContext.read<SettingsCubit>().state.currentPrices;

    if (state.clients.isEmpty) return;

    int? selectedClientId = state.clients.first.id;
    final detailsController = TextEditingController();
    final areaController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('توقيع عقد شقة جديد (تسعير مرن)'),
          content: SizedBox(
            width: 550,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:[
                  DropdownButtonFormField<int>(
                    value: selectedClientId,
                    decoration: const InputDecoration(labelText: 'اختر العميل', border: OutlineInputBorder()),
                    items: state.clients.map((client) => DropdownMenuItem(value: client.id, child: Text(client.name))).toList(),
                    onChanged: (val) => selectedClientId = val,
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: detailsController, decoration: const InputDecoration(labelText: 'تفاصيل الشقة (أرضي، قبو، الخ)', border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  TextField(controller: areaController, decoration: const InputDecoration(labelText: 'المساحة الكلية (م2)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  
                  // الزر السحري
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (currentPrices == null) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('يرجى حفظ أسعار المواد من شاشة الإعدادات أولاً!'), backgroundColor: Colors.red));
                          return;
                        }
                        if (areaController.text.isEmpty) return;

                        final calculations = CalculatorHelper.calculateContractValues(
                          area: double.parse(areaController.text),
                          currentPrices: currentPrices,
                        );

                        priceController.text = calculations['pricePerSqm']!.toStringAsFixed(0);
                        ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('تم احتساب سعر المتر الأساسي بنجاح!'), backgroundColor: Colors.green));
                      },
                      icon: const Icon(Icons.calculate),
                      label: const Text('حساب سعر المتر مبدئياً (حسب سوق اليوم)'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700, foregroundColor: Colors.white),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(thickness: 2)),

                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'سعر المتر المربع عند التوقيع (ل.س)', border: OutlineInputBorder(), filled: true, fillColor: Colors.black12),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions:[
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (selectedClientId != null && areaController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  parentContext.read<ContractsCubit>().addContract(
                    clientId: selectedClientId!,
                    details: detailsController.text,
                    area: double.parse(areaController.text),
                    basePrice: double.parse(priceController.text),
                    coefficients: {}, // المعاملات الخاصة تُضاف لاحقاً إن وجدت
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('اعتماد وحفظ العقد'),
            ),
          ],
        );
      },
    );
  }
}
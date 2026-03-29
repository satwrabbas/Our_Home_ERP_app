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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.teal.shade50),
                columns: const[
                  DataColumn(label: Text('رقم العقد', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('العميل', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('نوع العقد', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('الوصف', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('المساحة', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('سعر المتر', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('المدة', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('التاريخ', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: state.contracts.map((contract) {
                  final clientName = state.clients.firstWhere((c) => c.id == contract.clientId, orElse: () => state.clients.first).name;

                  return DataRow(cells:[
                    DataCell(Text(contract.id.split('-').first, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    DataCell(Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(contract.contractType, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))),
                    DataCell(Text(contract.apartmentDetails)),
                    DataCell(Text('${contract.totalArea} م2')),
                    DataCell(Text(contract.baseMeterPriceAtSigning.toStringAsFixed(0), style: const TextStyle(color: Colors.green))),
                    DataCell(Text('${contract.installmentsCount} شهر', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                    DataCell(Text('${contract.contractDate.year}/${contract.contractDate.month}/${contract.contractDate.day}')),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: 'إلغاء وحذف العقد',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('تأكيد الإلغاء'),
                              content: Text('هل أنت متأكد من إلغاء عقد الشقة الخاص بالعميل "$clientName"؟'),
                              actions:[
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('تراجع')),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                  onPressed: () {
                                    context.read<ContractsCubit>().deleteContract(contract.id);
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text('حذف نهائي'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
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

    String? selectedClientId = state.clients.first.id;
    String selectedContractType = 'لاحق التخصص'; 

    double floorCoefficient = 0.0;
    double directionCoefficient = 0.0;

    final detailsController = TextEditingController();
    final areaController = TextEditingController();
    final priceController = TextEditingController();
    final monthsController = TextEditingController(text: '48'); 

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            // 🌟 هل العقد مخصص لنُظهر خيارات التميز وتفاصيل الشقة؟
            bool isAllocated = selectedContractType == 'متخصص';
            
            // 🌟 هل يحتاج لكتابة تفاصيل الشقة؟ (لاحق التخصص لا يحتاج)
            bool needsDetails = selectedContractType != 'لاحق التخصص';

            return AlertDialog(
              title: const Text('توقيع عقد شقة جديد (تسعير مرن)', style: TextStyle(color: Colors.teal)),
              content: SizedBox(
                width: 550,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      DropdownButtonFormField<String>(
                        value: selectedClientId,
                        decoration: const InputDecoration(labelText: 'اختر العميل (الفريق الثاني)', border: OutlineInputBorder()),
                        items: state.clients.map((client) => DropdownMenuItem(value: client.id, child: Text(client.name))).toList(),
                        onChanged: (val) => setState(() => selectedClientId = val),
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: selectedContractType,
                        decoration: const InputDecoration(labelText: 'نوع العقد', border: OutlineInputBorder()),
                        items:['لاحق التخصص', 'متخصص', 'تجاري', 'شراكة']
                            .map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedContractType = val ?? 'لاحق التخصص';
                            if (selectedContractType != 'متخصص') {
                              floorCoefficient = 0.0;
                              directionCoefficient = 0.0;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // 🌟 ظهور المعاملات الديناميكي بناءً على نوع العقد
                      if (isAllocated) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              const Text('معاملات التمييز (تزيد أو تنقص السعر بنسبة مئوية):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                              const SizedBox(height: 12),
                              Row(
                                children:[
                                  Expanded(
                                    child: DropdownButtonFormField<double>(
                                      value: floorCoefficient,
                                      decoration: const InputDecoration(labelText: 'معامل الطابق', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                                      items: const[
                                        DropdownMenuItem(value: -0.02, child: Text('قبو (-2%)')),
                                        DropdownMenuItem(value: 0.0, child: Text('أرضي (0%)')),
                                        DropdownMenuItem(value: 0.05, child: Text('طابق أول (+5%)')),
                                        DropdownMenuItem(value: 0.03, child: Text('طابق ثاني (+3%)')),
                                        DropdownMenuItem(value: -0.01, child: Text('طابق أخير (-1%)')),
                                      ],
                                      onChanged: (val) => setState(() => floorCoefficient = val ?? 0.0),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DropdownButtonFormField<double>(
                                      value: directionCoefficient,
                                      decoration: const InputDecoration(labelText: 'معامل الاتجاه', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                                      items: const[
                                        DropdownMenuItem(value: 0.0, child: Text('شمالي (0%)')),
                                        DropdownMenuItem(value: 0.02, child: Text('قبلي/جنوبي (+2%)')),
                                        DropdownMenuItem(value: 0.01, child: Text('شرقي (+1%)')),
                                        DropdownMenuItem(value: 0.015, child: Text('إطلالة شارعين (+1.5%)')),
                                      ],
                                      onChanged: (val) => setState(() => directionCoefficient = val ?? 0.0),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 🌟 إخفاء حقل تفاصيل الشقة إذا كان العقد لاحق التخصص
                      if (needsDetails) ...[
                        TextField(controller: detailsController, decoration: const InputDecoration(labelText: 'تفاصيل الشقة (أرضي، قبو، الخ)', border: OutlineInputBorder())),
                        const SizedBox(height: 16),
                      ],
                      
                      Row(
                        children:[
                          Expanded(child: TextField(controller: areaController, decoration: const InputDecoration(labelText: 'المساحة الكلية (م2) أو عدد الأسهم', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                          const SizedBox(width: 16),
                          Expanded(child: TextField(controller: monthsController, decoration: const InputDecoration(labelText: 'مدة التقسيط (أشهر)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
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

                            Map<String, double> coeffs = {};
                            if (isAllocated) {
                              if (floorCoefficient != 0.0) coeffs['floor'] = floorCoefficient;
                              if (directionCoefficient != 0.0) coeffs['direction'] = directionCoefficient;
                            }

                            final calculations = CalculatorHelper.calculateContractValues(
                              area: double.parse(areaController.text),
                              currentPrices: currentPrices,
                              coefficients: coeffs, 
                            );

                            priceController.text = calculations['pricePerSqm']!.toStringAsFixed(0);
                            ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('تم احتساب سعر المتر مبدئياً بنجاح!'), backgroundColor: Colors.green));
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
                    // 🌟 توليد نص تلقائي إذا كان العقد لاحق التخصص
                    final String finalDetails = needsDetails ? detailsController.text : 'أسهم / لاحق التخصص';

                    if (selectedClientId != null && areaController.text.isNotEmpty && priceController.text.isNotEmpty) {
                      
                      Map<String, double> coeffs = {};
                      if (isAllocated) {
                        if (floorCoefficient != 0.0) coeffs['floor'] = floorCoefficient;
                        if (directionCoefficient != 0.0) coeffs['direction'] = directionCoefficient;
                      }

                      parentContext.read<ContractsCubit>().addContract(
                        clientId: selectedClientId!,
                        contractType: selectedContractType,
                        details: finalDetails, // 🌟 تمرير النص المولد آلياً
                        area: double.parse(areaController.text),
                        basePrice: double.parse(priceController.text),
                        installmentsCount: int.parse(monthsController.text), 
                        coefficients: coeffs, 
                      );
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('اعتماد وحفظ العقد'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
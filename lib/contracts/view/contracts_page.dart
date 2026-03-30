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

    final detailsController = TextEditingController();
    final areaController = TextEditingController();
    final priceController = TextEditingController();
    final monthsController = TextEditingController(text: '48'); 
    
    // 🌟 الحقل الجديد لمعامل مدة التقسيط (يطبق على كل أنواع العقود)
    final durationCoefficientCtrl = TextEditingController(text: '0'); 

    // حقول المعاملات المكانية (تطبق فقط على الشقق المتخصصة)
    final floorCtrl = TextEditingController(text: '0');
    final directionCtrl = TextEditingController(text: '0');
    final streetCtrl = TextEditingController(text: '0');
    final yardCtrl = TextEditingController(text: '0');      
    final elevatorCtrl = TextEditingController(text: '0');  
    final locationCtrl = TextEditingController(text: '0');  

    Map<String, double> buildCoefficientsMap(bool isAllocated) {
      Map<String, double> map = {};
      void addIfValid(String key, String textValue) {
        double? val = double.tryParse(textValue);
        if (val != null && val != 0.0) {
          map[key] = val / 100.0; 
        }
      }
      
      // 🌟 نسبة التقسيط تُطبق دائماً (سواء مخصص أو لاحق التخصص)
      addIfValid('duration', durationCoefficientCtrl.text);

      // النسب المكانية تطبق فقط إذا كان العقد متخصصاً
      if (isAllocated) {
        addIfValid('floor', floorCtrl.text);
        addIfValid('direction', directionCtrl.text);
        addIfValid('street', streetCtrl.text);
        addIfValid('yard', yardCtrl.text);
        addIfValid('elevator', elevatorCtrl.text);
        addIfValid('location', locationCtrl.text);
      }
      return map;
    }

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isAllocated = selectedContractType == 'متخصص';
            bool needsDetails = selectedContractType != 'لاحق التخصص';

            return AlertDialog(
              title: const Text('توقيع عقد شقة جديد (تسعير مرن)', style: TextStyle(color: Colors.teal)),
              content: SizedBox(
                width: 600, 
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
                            if (!isAllocated) {
                              floorCtrl.text = '0';
                              directionCtrl.text = '0';
                              streetCtrl.text = '0';
                              yardCtrl.text = '0';
                              elevatorCtrl.text = '0';
                              locationCtrl.text = '0';
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      if (isAllocated) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50, 
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.teal.shade200)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              const Text('معاملات التمييز المكاني (%) - ضع القيمة 0 لتجاهل المعامل:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                              const SizedBox(height: 16),
                              
                              Row(
                                children:[
                                  Expanded(child: TextField(controller: floorCtrl, decoration: const InputDecoration(labelText: 'نسبة الطابق %', border: OutlineInputBorder(), filled: true, fillColor: Colors.white), keyboardType: TextInputType.number)),
                                  const SizedBox(width: 12),
                                  Expanded(child: TextField(controller: directionCtrl, decoration: const InputDecoration(labelText: 'نسبة الاتجاه %', border: OutlineInputBorder(), filled: true, fillColor: Colors.white), keyboardType: TextInputType.number)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              Row(
                                children:[
                                  Expanded(child: TextField(controller: streetCtrl, decoration: const InputDecoration(labelText: 'نسبة الشارع %', border: OutlineInputBorder(), filled: true, fillColor: Colors.white), keyboardType: TextInputType.number)),
                                  const SizedBox(width: 12),
                                  Expanded(child: TextField(controller: yardCtrl, decoration: const InputDecoration(labelText: 'نسبة الوجيبة %', border: OutlineInputBorder(), filled: true, fillColor: Colors.white), keyboardType: TextInputType.number)),
                                ],
                              ),
                              const SizedBox(height: 12),

                              Row(
                                children:[
                                  Expanded(child: TextField(controller: elevatorCtrl, decoration: const InputDecoration(labelText: 'نسبة المصعد %', border: OutlineInputBorder(), filled: true, fillColor: Colors.white), keyboardType: TextInputType.number)),
                                  const SizedBox(width: 12),
                                  Expanded(child: TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'نسبة الموقع %', border: OutlineInputBorder(), filled: true, fillColor: Colors.white), keyboardType: TextInputType.number)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (needsDetails) ...[
                        TextField(controller: detailsController, decoration: const InputDecoration(labelText: 'تفاصيل الشقة (مثال: الطابق الثاني، إطلالة بحرية)', border: OutlineInputBorder())),
                        const SizedBox(height: 16),
                      ],
                      
                      // 🌟 دمجنا المساحة والمدة ومعامل المدة في صف واحد لذكاء واجهة المستخدم
                      Row(
                        children:[
                          Expanded(flex: 2, child: TextField(controller: areaController, decoration: const InputDecoration(labelText: 'المساحة الكلية (م2)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: TextField(controller: monthsController, decoration: const InputDecoration(labelText: 'المدة (أشهر)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: TextField(controller: durationCoefficientCtrl, decoration: const InputDecoration(labelText: 'نسبة المدة %', border: OutlineInputBorder(), filled: true, fillColor: Colors.orangeAccent, labelStyle: TextStyle(color: Colors.black)), keyboardType: TextInputType.number)),
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

                            // 🌟 استدعاء الدالة المساعدة التي تجمع كل المعاملات (المكانية والزمنية)
                            final Map<String, double> coeffs = buildCoefficientsMap(isAllocated);

                            final calculations = CalculatorHelper.calculateContractValues(
                              area: double.parse(areaController.text),
                              currentPrices: currentPrices,
                              coefficients: coeffs, 
                            );

                            priceController.text = calculations['pricePerSqm']!.toStringAsFixed(0);
                            ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('تم احتساب سعر المتر شامل جميع المعاملات بنجاح!'), backgroundColor: Colors.green));
                          },
                          icon: const Icon(Icons.calculate),
                          label: const Text('حساب سعر المتر مبدئياً (حسب سوق اليوم والمعاملات)'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700, foregroundColor: Colors.white),
                        ),
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(thickness: 2)),

                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: 'سعر المتر المربع النهائي عند التوقيع (ل.س)', border: OutlineInputBorder(), filled: true, fillColor: Colors.black12),
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
                    final String finalDetails = needsDetails ? detailsController.text : 'أسهم / لاحق التخصص';

                    if (selectedClientId != null && areaController.text.isNotEmpty && priceController.text.isNotEmpty) {
                      
                      final Map<String, double> coeffs = buildCoefficientsMap(isAllocated);

                      parentContext.read<ContractsCubit>().addContract(
                        clientId: selectedClientId!,
                        contractType: selectedContractType,
                        details: finalDetails, 
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
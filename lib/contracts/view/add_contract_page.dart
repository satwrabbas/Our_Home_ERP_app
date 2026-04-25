// lib/contracts/view/add_contract_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart'; 
import '../../core/utils/calculator_helper.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../buildings/cubit/buildings_cubit.dart';
import '../cubit/contracts_cubit.dart';
import 'dialogs/verify_pin_dialog.dart';

// ==========================================
// 🌟 أدوات التنسيق
// ==========================================
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');
    String formatted = '';
    int count = 0;
    for (int i = digitsOnly.length - 1; i >= 0; i--) {
      if (count != 0 && count % 3 == 0) formatted = ',$formatted';
      formatted = digitsOnly[i] + formatted;
      count++;
    }
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

String formatNumberWithCommas(num number) {
  String str = number.toInt().toString();
  String formatted = '';
  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    if (count != 0 && count % 3 == 0) formatted = ',$formatted';
    formatted = str[i] + formatted;
    count++;
  }
  return formatted;
}

// ==========================================
// 🌟 صفحة إضافة العقد
// ==========================================
class AddContractPage extends StatefulWidget {
  const AddContractPage({super.key});

  @override
  State<AddContractPage> createState() => _AddContractPageState();
}

class _AddContractPageState extends State<AddContractPage> {
  String? selectedClientId;
  String selectedContractType = 'متخصص'; 
  String? selectedBuildingId;
  String? selectedApartmentId;

  final areaController = TextEditingController();
  final priceController = TextEditingController();
  final monthsController = TextEditingController(text: '48'); 
  final durationCoefficientCtrl = TextEditingController(text: '0'); 
  final guarantorController = TextEditingController(); 
  final monthlyAmountCtrl = TextEditingController(); 

  final blockCoeffCtrl = TextEditingController(text: '0');
  final coloredPlasterCoeffCtrl = TextEditingController(text: '0');
  final marbleStairsCoeffCtrl = TextEditingController(text: '0');
  final marbleFinsCoeffCtrl = TextEditingController(text: '0');
  final plumbingCoeffCtrl = TextEditingController(text: '0');
  final chimneysCoeffCtrl = TextEditingController(text: '0');

  final histIronCtrl = TextEditingController();
  final histCementCtrl = TextEditingController();
  final histBlockCtrl = TextEditingController();
  final histFormworkCtrl = TextEditingController();
  final histAggregatesCtrl = TextEditingController();
  final histWorkerCtrl = TextEditingController();

  Map<String, double> autoImportedCoefficients = {};

  bool isHistoricalContract = false;
  DateTime selectedHistoricalDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<BuildingsCubit>().loadData();
    // تحديد العميل الافتراضي عند فتح الصفحة
    final clients = context.read<ContractsCubit>().state.clients;
    if (clients.isNotEmpty) {
      selectedClientId = clients.first.id;
    }
  }

  @override
  void dispose() {
    areaController.dispose(); priceController.dispose(); monthsController.dispose();
    durationCoefficientCtrl.dispose(); guarantorController.dispose(); monthlyAmountCtrl.dispose();
    blockCoeffCtrl.dispose(); coloredPlasterCoeffCtrl.dispose(); marbleStairsCoeffCtrl.dispose();
    marbleFinsCoeffCtrl.dispose(); plumbingCoeffCtrl.dispose(); chimneysCoeffCtrl.dispose();
    histIronCtrl.dispose(); histCementCtrl.dispose(); histBlockCtrl.dispose();
    histFormworkCtrl.dispose(); histAggregatesCtrl.dispose(); histWorkerCtrl.dispose();
    super.dispose();
  }

  Map<String, double> buildFinalCoefficientsMap(bool isAllocated) {
    Map<String, double> finalMap = {};
    double? durVal = double.tryParse(durationCoefficientCtrl.text);
    if (durVal != null && durVal != 0.0) finalMap['نسبة التقسيط'] = durVal / 100.0;

    if (isAllocated) {
      autoImportedCoefficients.forEach((key, value) => finalMap[key] = value / 100.0);
      void addShared(String key, String val) {
        double? parsed = double.tryParse(val);
        if (parsed != null && parsed != 0.0) finalMap[key] = parsed / 100.0;
      }
      addShared('تجهيزات (بلوك)', blockCoeffCtrl.text);
      addShared('تجهيزات (كلسة ملونة)', coloredPlasterCoeffCtrl.text);
      addShared('تجهيزات (درج رخام)', marbleStairsCoeffCtrl.text);
      addShared('تجهيزات (سلاحات رخام)', marbleFinsCoeffCtrl.text);
      addShared('تجهيزات (نوازل صحية)', plumbingCoeffCtrl.text);
      addShared('تجهيزات (صواعد مداخن)', chimneysCoeffCtrl.text);
    }
    return finalMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('توقيع عقد جديد', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.teal.shade600,
        centerTitle: true,
      ),
      // 🌟 شريط سفلي ثابت للأزرار
      bottomNavigationBar: _buildBottomBar(context),
      
      body: BlocBuilder<ContractsCubit, ContractsState>(
        builder: (context, state) {
          return BlocBuilder<BuildingsCubit, BuildingsState>(
            builder: (context, buildingsState) {
              return BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, settingsState) {
                  
                  if (state.clients.isEmpty) {
                    return const Center(child: Text('يرجى إضافة عميل أولاً.', style: TextStyle(fontSize: 18)));
                  }

                  final buildings = buildingsState.buildings;
                  final allApartments = buildingsState.apartments;
                  final currentPrices = settingsState.currentPrices;

                  bool isAllocated = selectedContractType == 'متخصص'; 
                  final availableApartments = allApartments.where((apt) => apt.buildingId == selectedBuildingId && apt.status == 'available').toList();

                  return Center(
                    child: SizedBox(
                      width: 800, // تحديد عرض أقصى ليكون جميلاً على الشاشات الكبيرة
                      child: ListView(
                        padding: const EdgeInsets.all(24.0),
                        children:[
                          
                          // 🌟 قسم العقد التاريخي
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children:[
                                  SwitchListTile(
                                    title: const Text('إدخال عقد قديم (تاريخي)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                    subtitle: const Text('يتيح لك تحديد تاريخ توقيع قديم وإدخال أسعار المواد في ذلك الوقت.'),
                                    value: isHistoricalContract,
                                    activeColor: Colors.red,
                                    onChanged: (val) async {
                                      if (val) {
                                        bool authorized = await showVerifyPinDialog(context);
                                        if (authorized) {
                                          setState(() => isHistoricalContract = true);
                                          final pickedDate = await showDatePicker(
                                            context: context, initialDate: selectedHistoricalDate,
                                            firstDate: DateTime(2000), lastDate: DateTime.now(),
                                            builder: (ctx, child) => Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Colors.red)), child: child!),
                                          );
                                          if (pickedDate != null) setState(() => selectedHistoricalDate = pickedDate);
                                        }
                                      } else {
                                        setState(() { isHistoricalContract = false; priceController.clear(); });
                                      }
                                    },
                                  ),
                                  if (isHistoricalContract) ...[
                                    const Divider(color: Colors.red),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children:[
                                        const Text('📅 تاريخ التوقيع:', style: TextStyle(fontWeight: FontWeight.bold)),
                                        TextButton.icon(
                                          icon: const Icon(Icons.calendar_month, color: Colors.red),
                                          label: Text('${selectedHistoricalDate.year}/${selectedHistoricalDate.month}/${selectedHistoricalDate.day}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                                          onPressed: () async {
                                            final pickedDate = await showDatePicker(
                                              context: context, initialDate: selectedHistoricalDate,
                                              firstDate: DateTime(2000), lastDate: DateTime.now(),
                                              builder: (ctx, child) => Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Colors.red)), child: child!),
                                            );
                                            if (pickedDate != null) setState(() => selectedHistoricalDate = pickedDate);
                                          },
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                                      child: Column(
                                        children:[
                                          const Text('💰 أسعار المواد في ذلك التاريخ (ل.س)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 12),
                                          Row(
                                            children:[
                                              Expanded(child: TextField(controller: histIronCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'الحديد', border: OutlineInputBorder(), isDense: true, fillColor: Colors.white, filled: true), keyboardType: TextInputType.number)),
                                              const SizedBox(width: 8),
                                              Expanded(child: TextField(controller: histCementCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'الإسمنت', border: OutlineInputBorder(), isDense: true, fillColor: Colors.white, filled: true), keyboardType: TextInputType.number)),
                                              const SizedBox(width: 8),
                                              Expanded(child: TextField(controller: histBlockCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'البلوك 15', border: OutlineInputBorder(), isDense: true, fillColor: Colors.white, filled: true), keyboardType: TextInputType.number)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children:[
                                              Expanded(child: TextField(controller: histFormworkCtrl, inputFormatters:[ThousandsFormatter()], decoration: const InputDecoration(labelText: 'الكوفراج', border: OutlineInputBorder(), isDense: true, fillColor: Colors.white, filled: true), keyboardType: TextInputType.number)),
                                              const SizedBox(width: 8),
                                              Expanded(child: TextField(controller: histAggregatesCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'حصويات', border: OutlineInputBorder(), isDense: true, fillColor: Colors.white, filled: true), keyboardType: TextInputType.number)),
                                              const SizedBox(width: 8),
                                              Expanded(child: TextField(controller: histWorkerCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'أجرة العامل', border: OutlineInputBorder(), isDense: true, fillColor: Colors.white, filled: true), keyboardType: TextInputType.number)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 🌟 قسم البيانات الأساسية
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children:[
                                  DropdownButtonFormField<String>(
                                    value: selectedClientId,
                                    decoration: const InputDecoration(labelText: 'اختر العميل (الفريق الثاني)', border: OutlineInputBorder()),
                                    items: state.clients.map((client) => DropdownMenuItem(value: client.id, child: Text(client.name))).toList(),
                                    onChanged: (val) => setState(() => selectedClientId = val),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                     controller: guarantorController, 
                                     decoration: const InputDecoration(labelText: 'اسم الكفيل الثلاثي', border: OutlineInputBorder())
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    value: selectedContractType,
                                    decoration: const InputDecoration(labelText: 'نوع العقد', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                                    items:['متخصص', 'لاحق التخصص']
                                        .map((type) => DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        selectedContractType = val ?? 'متخصص';
                                        if (selectedContractType == 'لاحق التخصص') {
                                          autoImportedCoefficients.clear();
                                          selectedBuildingId = null;
                                          selectedApartmentId = null;
                                          areaController.text = ''; 
                                        } else {
                                          monthlyAmountCtrl.clear();
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 🌟 قسم لاحق التخصص (المبلغ الشهري)
                          if (!isAllocated) ...[
                            Card(
                              elevation: 2, color: Colors.blue.shade50,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.blue.shade200)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:[
                                    const Row(
                                      children:[
                                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                                        SizedBox(width: 8),
                                        Text('العقد لاحق التخصص. النظام سيولد نقطة تفاعل شهرية واحدة.', style: TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: monthlyAmountCtrl,
                                      inputFormatters: [ThousandsFormatter()],
                                      decoration: const InputDecoration(
                                        labelText: 'المبلغ المتفق عليه شهرياً (ل.س)', 
                                        border: OutlineInputBorder(), filled: true, fillColor: Colors.white,
                                        prefixIcon: Icon(Icons.payments, color: Colors.blue)
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // 🌟 قسم المتخصص (اختيار العقار)
                          if (isAllocated) ...[
                            Card(
                              elevation: 2, color: Colors.amber.shade50,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.amber.shade200)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:[
                                    const Text('🏠 اختيار العقار من الكتالوج', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 16)),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      value: selectedBuildingId,
                                      decoration: const InputDecoration(labelText: 'اختر المحضر', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                                      items: buildings.map((b) => DropdownMenuItem(value: b.id, child: Text('${b.name} (${b.location ?? ''})'))).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          selectedBuildingId = val;
                                          selectedApartmentId = null;
                                          areaController.text = '';
                                          autoImportedCoefficients.clear();
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    DropdownButtonFormField<String>(
                                      value: selectedApartmentId,
                                      decoration: const InputDecoration(labelText: 'اختر الشقة المتاحة', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                                      items: availableApartments.map((apt) => DropdownMenuItem(value: apt.id, child: Text('شقة: ${apt.apartmentNumber} | طابق: ${apt.floorName}'))).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          selectedApartmentId = val;
                                          if (val != null) {
                                            final apt = availableApartments.firstWhere((a) => a.id == val);
                                            final bld = buildings.firstWhere((b) => b.id == apt.buildingId);
                                            areaController.text = apt.area.toString();
                                            autoImportedCoefficients.clear();
                                            try {
                                              final Map<String, dynamic> bldGeneralMap = jsonDecode(bld.directionCoefficients);
                                              bldGeneralMap.forEach((k, v) {
                                                if (k != 'شمالي' && k != 'جنوبي' && k != 'شرقي' && k != 'غربي') autoImportedCoefficients[k] = (v as num).toDouble();
                                              });
                                              final Map<String, dynamic> aptMap = jsonDecode(apt.customCoefficients);
                                              aptMap.forEach((k, v) {
                                                if (!k.startsWith('مساحة')) autoImportedCoefficients[k] = (v as num).toDouble();
                                              });
                                            } catch (e) { debugPrint('خطأ: $e'); }
                                          }
                                        });
                                      },
                                      disabledHint: Text(selectedBuildingId == null ? 'يرجى اختيار المحضر أولاً' : 'لا يوجد شقق متاحة!'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // 🌟 قسم المساحة والمدة
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children:[
                                  Expanded(flex: 2, child: TextField(
                                    controller: areaController, readOnly: isAllocated, 
                                    decoration: InputDecoration(labelText: isAllocated ? 'المساحة (مجلوبة آلياً)' : 'المساحة الكلية / أسهم (م2)', border: const OutlineInputBorder(), filled: isAllocated, fillColor: isAllocated ? Colors.black12 : Colors.white),
                                    keyboardType: TextInputType.number,
                                  )),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: TextField(controller: monthsController, decoration: const InputDecoration(labelText: 'المدة (أشهر)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                                  const SizedBox(width: 12),
                                  Expanded(flex: 2, child: TextField(controller: durationCoefficientCtrl, decoration: const InputDecoration(labelText: 'نسبة التقسيط %', border: OutlineInputBorder(), filled: true, fillColor: Colors.orangeAccent), keyboardType: TextInputType.number)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 🌟 قسم الحساب المالي
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.teal.shade200)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children:[
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        if (areaController.text.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('البيانات غير مكتملة! أدخل المساحة.'), backgroundColor: Colors.red));
                                          return;
                                        }

                                        MaterialPricesHistoryData targetPrices;

                                        if (isHistoricalContract) {
                                          if (histIronCtrl.text.isEmpty || histCementCtrl.text.isEmpty || histWorkerCtrl.text.isEmpty) {
                                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء تعبئة جميع أسعار المواد التاريخية!'), backgroundColor: Colors.red));
                                             return;
                                          }
                                          targetPrices = MaterialPricesHistoryData(
                                            id: 'dummy', effectiveDate: selectedHistoricalDate, userId: 'dummy', createdAt: DateTime.now(), updatedAt: DateTime.now(), isDeleted: false, isSynced: false,
                                            ironPrice: double.parse(histIronCtrl.text.replaceAll(',', '')), cementPrice: double.parse(histCementCtrl.text.replaceAll(',', '')),
                                            block15Price: double.parse(histBlockCtrl.text.replaceAll(',', '')), formworkAndPouringWages: double.parse(histFormworkCtrl.text.replaceAll(',', '')),
                                            aggregateMaterialsPrice: double.parse(histAggregatesCtrl.text.replaceAll(',', '')), ordinaryWorkerWage: double.parse(histWorkerCtrl.text.replaceAll(',', '')),
                                          );
                                        } else {
                                          if (currentPrices == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى ضبط أسعار المواد في الإعدادات أولاً.'), backgroundColor: Colors.red));
                                            return;
                                          }
                                          targetPrices = currentPrices;
                                        }

                                        final Map<String, double> finalCoeffs = buildFinalCoefficientsMap(isAllocated);
                                        final calculations = CalculatorHelper.calculateContractValues(
                                          area: double.parse(areaController.text),
                                          currentPrices: targetPrices,
                                          coefficients: finalCoeffs, 
                                        );

                                        priceController.text = formatNumberWithCommas(calculations['pricePerSqm']!);
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isHistoricalContract ? 'تم الحساب بناءً على المواد التاريخية ✅' : 'تم الحساب بناءً على أسعار اليوم ✅'), backgroundColor: Colors.green));
                                      },
                                      icon: const Icon(Icons.calculate),
                                      label: Text(isHistoricalContract ? 'حساب سعر المتر (تاريخي)' : 'حساب سعر المتر (أسعار اليوم)', style: const TextStyle(fontSize: 16)),
                                      style: ElevatedButton.styleFrom(backgroundColor: isHistoricalContract ? Colors.red.shade700 : Colors.teal.shade700, foregroundColor: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: priceController,
                                    readOnly: !isHistoricalContract, 
                                    inputFormatters:[ThousandsFormatter()],
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      labelText: isHistoricalContract ? 'سعر المتر المربع (يمكنك تعديله يدوياً)' : 'سعر المتر المربع النهائي (يُحسب آلياً)', 
                                      border: const OutlineInputBorder(), 
                                      filled: true, 
                                      fillColor: isHistoricalContract ? Colors.white : Colors.teal.shade50,
                                      prefixIcon: isHistoricalContract ? const Icon(Icons.edit, color: Colors.red) : const Icon(Icons.lock, color: Colors.teal),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 100), // مساحة إضافية لكي لا يغطي الشريط السفلي على المحتوى
                        ],
                      ),
                    ),
                  );
                }
              );
            }
          );
        }
      ),
    );
  }

  // 🌟 شريط الأزرار السفلي (يظل ظاهراً دائماً)
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow:[BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children:[
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('إلغاء والتراجع', style: TextStyle(fontSize: 16, color: Colors.grey))
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal, 
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18)
            ),
            icon: const Icon(Icons.check_circle),
            label: const Text('اعتماد وتوقيع العقد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onPressed: () async { 
              bool isAllocated = selectedContractType == 'متخصص'; 
              
              if (isAllocated && selectedApartmentId == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار شقة من الكتالوج!'), backgroundColor: Colors.red));
                return;
              }
              if (areaController.text.isEmpty || priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تعبئة المساحة وحساب/إدخال السعر!'), backgroundColor: Colors.red));
                return;
              }
              if (!isAllocated && monthlyAmountCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال المبلغ المتفق عليه شهرياً!'), backgroundColor: Colors.red));
                return;
              }
              if (isHistoricalContract && (histIronCtrl.text.isEmpty || histCementCtrl.text.isEmpty || histWorkerCtrl.text.isEmpty)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يجب إدخال جميع أسعار المواد لحفظها في السجل!'), backgroundColor: Colors.red));
                return;
              }

              final Map<String, double> finalCoeffs = buildFinalCoefficientsMap(isAllocated);
              
              String generatedDetails = '';
              if (isAllocated) {
                final allApartments = context.read<BuildingsCubit>().state.apartments;
                final buildings = context.read<BuildingsCubit>().state.buildings;
                final apt = allApartments.firstWhere((a) => a.id == selectedApartmentId);
                final bld = buildings.firstWhere((b) => b.id == selectedBuildingId);
                generatedDetails = 'محضر: ${bld.name} | شقة: ${apt.apartmentNumber} | طابق: ${apt.floorName}';
              } else {
                generatedDetails = 'عقد $selectedContractType (غير مخصص / أسهم)';
              }

              // 🌟 حفظ البيانات واستدعاء الـ Cubit
              final double agreedAmount = !isAllocated ? (double.tryParse(monthlyAmountCtrl.text.replaceAll(',', '')) ?? 0.0) : 0.0;

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري حفظ وتوقيع العقد... ⏳'), backgroundColor: Colors.teal));

              await context.read<ContractsCubit>().addContract(
                clientId: selectedClientId!,
                contractType: selectedContractType,
                details: generatedDetails, 
                apartmentId: isAllocated ? selectedApartmentId : null,
                area: double.parse(areaController.text),
                basePrice: double.parse(priceController.text.replaceAll(',', '')), 
                installmentsCount: int.parse(monthsController.text), 
                guarantorName: guarantorController.text.trim().isEmpty ? 'بدون كفيل' : guarantorController.text.trim(),
                agreedMonthlyAmount: agreedAmount,
                coefficients: finalCoeffs, 
                customDate: isHistoricalContract ? selectedHistoricalDate : null, 
                
                histIron: isHistoricalContract ? double.parse(histIronCtrl.text.replaceAll(',', '')) : null, 
                histCement: isHistoricalContract ? double.parse(histCementCtrl.text.replaceAll(',', '')) : null,
                histBlock: isHistoricalContract ? double.parse(histBlockCtrl.text.replaceAll(',', '')) : null,
                histFormwork: isHistoricalContract ? double.parse(histFormworkCtrl.text.replaceAll(',', '')) : null,
                histAggregates: isHistoricalContract ? double.parse(histAggregatesCtrl.text.replaceAll(',', '')) : null,
                histWorker: isHistoricalContract ? double.parse(histWorkerCtrl.text.replaceAll(',', '')) : null,
              );

              if (context.mounted) {
                Navigator.pop(context); // إغلاق الصفحة والعودة للجدول
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم توقيع العقد وحفظه بنجاح! ✅'), backgroundColor: Colors.green));
              }
            },
          ),
        ],
      ),
    );
  }
}
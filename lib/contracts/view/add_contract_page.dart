//lib\contracts\view\add_contract_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart'; 
import '../../core/utils/calculator_helper.dart';
import '../../core/utils/formatters.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../../buildings/cubit/buildings_cubit.dart';
import '../cubit/contracts_cubit.dart';
import 'dialogs/verify_pin_dialog.dart';

// استيراد الأقسام التي قمنا بفصلها
import 'widgets/add_contract/historical_section.dart';
import 'widgets/add_contract/basic_info_section.dart';
import 'widgets/add_contract/auto_coefficients_section.dart';
import 'widgets/add_contract/shared_coefficients_section.dart';
import 'widgets/add_contract/property_section.dart';
import 'widgets/add_contract/financial_section.dart';

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

  // معاملات إضافية (تم تركها للتبسيط أو يمكن وضعها في ماب)
  final blockCoeffCtrl = TextEditingController(text: '0');
  final coloredPlasterCoeffCtrl = TextEditingController(text: '0');
  final marbleStairsCoeffCtrl = TextEditingController(text: '0');
  final marbleFinsCoeffCtrl = TextEditingController(text: '0');
  final plumbingCoeffCtrl = TextEditingController(text: '0');
  final chimneysCoeffCtrl = TextEditingController(text: '0');

  // معاملات التاريخ
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
    final clients = context.read<ContractsCubit>().state.clients;
    if (clients.isNotEmpty) selectedClientId = clients.first.id;
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

  // --- دوال المنطق ---
  void _onApartmentSelected(String? aptId, List<dynamic> availableApartments, List<dynamic> buildings) {
    setState(() {
      selectedApartmentId = aptId;
      if (aptId != null) {
        final apt = availableApartments.firstWhere((a) => a.id == aptId);
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
  }

  // ==========================================
  // 🧮 دالة الحساب الذكية (معدلة)
  // ==========================================
  void _calculatePrice(MaterialPricesHistoryData? currentPrices) {
    bool isAllocated = selectedContractType == 'متخصص';

    // 🌟 1. تجاوز التحقق من المساحة إذا كان لاحق التخصص
    if (isAllocated && areaController.text.isEmpty) {
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

    Map<String, double> finalCoeffs = {};
    if (isAllocated) {
      double? durVal = double.tryParse(durationCoefficientCtrl.text);
      if (durVal != null && durVal != 0.0) finalCoeffs['نسبة التقسيط'] = durVal / 100.0;
      autoImportedCoefficients.forEach((key, value) => finalCoeffs[key] = value / 100.0);
    }

    // 🌟 2. إذا كان العقد لاحق التخصص، نرسل (مساحة 1 متر وهمية) للحاسبة فقط لكي تُخرج لنا سعر المتر وتتجنب القسمة على صفر
    double dummyAreaForCalculation = isAllocated ? double.parse(areaController.text) : 1.0;

    final calculations = CalculatorHelper.calculateContractValues(
      area: dummyAreaForCalculation,
      currentPrices: targetPrices,
      coefficients: finalCoeffs, 
    );
    priceController.text = NumberFormatters.formatWithCommas(calculations['pricePerSqm']!);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isHistoricalContract ? 'تم الحساب بناءً على المواد التاريخية ✅' : 'تم الحساب بناءً على أسعار اليوم ✅'), backgroundColor: Colors.green));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text('توقيع عقد جديد', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), backgroundColor: Colors.teal.shade600, centerTitle: true),
      bottomNavigationBar: _buildBottomBar(context),
      
      body: BlocBuilder<ContractsCubit, ContractsState>(
        builder: (context, state) {
          return BlocBuilder<BuildingsCubit, BuildingsState>(
            builder: (context, buildingsState) {
              return BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, settingsState) {
                  if (state.clients.isEmpty) return const Center(child: Text('يرجى إضافة عميل أولاً.', style: TextStyle(fontSize: 18)));

                  bool isAllocated = selectedContractType == 'متخصص'; 
                  final availableApartments = buildingsState.apartments.where((apt) => apt.buildingId == selectedBuildingId && apt.status == 'available').toList();

                  return Center(
                    child: SizedBox(
                      width: 800,
                      child: ListView(
                        padding: const EdgeInsets.all(24.0),
                        children:[
                          HistoricalSection(
                            isHistorical: isHistoricalContract,
                            selectedDate: selectedHistoricalDate,
                            histIronCtrl: histIronCtrl, histCementCtrl: histCementCtrl, histBlockCtrl: histBlockCtrl,
                            histFormworkCtrl: histFormworkCtrl, histAggregatesCtrl: histAggregatesCtrl, histWorkerCtrl: histWorkerCtrl,
                            onToggle: (val) async {
                              if (val) {
                                if (await showVerifyPinDialog(context)) setState(() => isHistoricalContract = true);
                              } else {
                                setState(() { isHistoricalContract = false; priceController.clear(); });
                              }
                            },
                            onDateTap: () async {
                              final pickedDate = await showDatePicker(context: context, initialDate: selectedHistoricalDate, firstDate: DateTime(2000), lastDate: DateTime.now());
                              if (pickedDate != null) setState(() => selectedHistoricalDate = pickedDate);
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          BasicInfoSection(
                            clients: state.clients,
                            selectedClientId: selectedClientId,
                            guarantorController: guarantorController,
                            selectedContractType: selectedContractType,
                            onClientChanged: (val) => setState(() => selectedClientId = val),
                            onTypeChanged: (val) {
                              setState(() {
                                selectedContractType = val ?? 'متخصص';
                                if (!isAllocated) { autoImportedCoefficients.clear(); selectedBuildingId = null; selectedApartmentId = null; areaController.clear(); } 
                                else { monthlyAmountCtrl.clear(); }
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          PropertySection(
                            isAllocated: isAllocated,
                            buildings: buildingsState.buildings,
                            availableApartments: availableApartments,
                            selectedBuildingId: selectedBuildingId,
                            selectedApartmentId: selectedApartmentId,
                            monthlyAmountCtrl: monthlyAmountCtrl,
                            onBuildingChanged: (val) => setState(() { selectedBuildingId = val; selectedApartmentId = null; areaController.clear(); autoImportedCoefficients.clear(); }),
                            onApartmentChanged: (val) => _onApartmentSelected(val, availableApartments, buildingsState.buildings),
                          ),
                          const SizedBox(height: 16),

                          // 🌟 هنا نضع القسم الذي يسحب المعاملات الآلية (يظهر فقط للمتخصص)
                          if (isAllocated)
                            AutoCoefficientsSection(coefficients: autoImportedCoefficients),

                          // 🌟 هنا نضع قسم التجهيزات المشتركة (يظهر فقط للمتخصص)
                          if (isAllocated)
                            SharedCoefficientsSection(
                              blockCoeffCtrl: blockCoeffCtrl, coloredPlasterCoeffCtrl: coloredPlasterCoeffCtrl,
                              marbleStairsCoeffCtrl: marbleStairsCoeffCtrl, marbleFinsCoeffCtrl: marbleFinsCoeffCtrl,
                              plumbingCoeffCtrl: plumbingCoeffCtrl, chimneysCoeffCtrl: chimneysCoeffCtrl,
                            ),
                          
                          FinancialSection(
                            isAllocated: isAllocated,
                            isHistoricalContract: isHistoricalContract,
                            areaController: areaController,
                            monthsController: monthsController,
                            durationCoefficientCtrl: durationCoefficientCtrl,
                            priceController: priceController,
                            onCalculate: () => _calculatePrice(settingsState.currentPrices),
                          ),
                          const SizedBox(height: 100), 
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

  // --- دالة الحفظ السفلية بقيت هنا لاحتياجها لجميع القيم ---
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(color: Colors.white, boxShadow:[BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children:[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء والتراجع', style: TextStyle(fontSize: 16, color: Colors.grey))),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18)),
            icon: const Icon(Icons.check_circle),
            label: const Text('اعتماد وتوقيع العقد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            onPressed: _saveContract,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 🚀 دالة الإرسال والحفظ للـ Backend (معدلة للنظام المفتوح)
  // ==========================================
  Future<void> _saveContract() async {
    bool isAllocated = selectedContractType == 'متخصص'; 
    
    if (isAllocated && selectedApartmentId == null) return _showError('يرجى اختيار شقة من الكتالوج!');
    if (isAllocated && areaController.text.isEmpty) return _showError('يرجى تعبئة المساحة!');
    if (priceController.text.isEmpty) return _showError('يرجى حساب السعر أولاً!');
    
    // 🌟 التعديل 1: إجبار المستخدم على إدخال المبلغ الشهري لجميع أنواع العقود
    if (monthlyAmountCtrl.text.isEmpty) return _showError('يرجى إدخال المبلغ المتفق عليه شهرياً!');

    Map<String, double> finalCoeffs = {};
    if (isAllocated) {
      autoImportedCoefficients.forEach((key, value) => finalCoeffs[key] = value / 100.0);
      double? durVal = double.tryParse(durationCoefficientCtrl.text);
      if (durVal != null && durVal != 0.0) finalCoeffs['نسبة التقسيط'] = durVal / 100.0;
    }

    String generatedDetails = '';
    if (isAllocated) {
      final allApartments = context.read<BuildingsCubit>().state.apartments;
      final buildings = context.read<BuildingsCubit>().state.buildings;
      final apt = allApartments.firstWhere((a) => a.id == selectedApartmentId);
      final bld = buildings.firstWhere((b) => b.id == selectedBuildingId);
      generatedDetails = 'محضر: ${bld.name} | شقة: ${apt.apartmentNumber} | طابق: ${apt.floorName}';
    } else {
      generatedDetails = 'محفظة استثمارية (عقد لاحق التخصص)';
    }

    // 🌟 التعديل 2: أخذ المبلغ الشهري بغض النظر عن نوع العقد
    final double agreedAmount = double.tryParse(monthlyAmountCtrl.text.replaceAll(',', '')) ?? 0.0;
    if (agreedAmount <= 0) return _showError('المبلغ الشهري يجب أن يكون أكبر من صفر!');

    final double finalArea = isAllocated ? double.parse(areaController.text) : 0.0;
    // 🌟 التعديل 3: نبقي الـ 48 شهراً شكلياً للمتخصص لكي لا تنكسر واجهاتك القديمة حالياً
    final int finalMonths = isAllocated ? int.parse(monthsController.text) : 48; 

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري الحفظ وتوقيع العقد... ⏳'), backgroundColor: Colors.teal));
    
    await context.read<ContractsCubit>().addContract(
      clientId: selectedClientId!, 
      contractType: selectedContractType, 
      details: generatedDetails, 
      apartmentId: isAllocated ? selectedApartmentId : null,
      area: finalArea, 
      basePrice: double.parse(priceController.text.replaceAll(',', '')), 
      installmentsCount: finalMonths, 
      guarantorName: guarantorController.text.trim(),
      agreedMonthlyAmount: agreedAmount, // 🌟 يتم إرساله دائماً
      coefficients: finalCoeffs, 
      customDate: isHistoricalContract ? selectedHistoricalDate : null, 
      histIron: isHistoricalContract ? double.parse(histIronCtrl.text.replaceAll(',', '')) : null, 
      histCement: isHistoricalContract ? double.parse(histCementCtrl.text.replaceAll(',', '')) : null,
      histBlock: isHistoricalContract ? double.parse(histBlockCtrl.text.replaceAll(',', '')) : null,
      histFormwork: isHistoricalContract ? double.parse(histFormworkCtrl.text.replaceAll(',', '')) : null,
      histAggregates: isHistoricalContract ? double.parse(histAggregatesCtrl.text.replaceAll(',', '')) : null,
      histWorker: isHistoricalContract ? double.parse(histWorkerCtrl.text.replaceAll(',', '')) : null,
    );

    if (mounted) { 
      Navigator.pop(context); 
      _showSuccess('تم توقيع العقد بنجاح! ✅'); 
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
}
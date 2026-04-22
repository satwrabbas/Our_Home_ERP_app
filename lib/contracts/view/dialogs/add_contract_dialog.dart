// lib/contracts/view/dialogs/add_contract_dialog.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🌟 مكتبة الـ Formatters
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart'; 
import '../../../core/utils/calculator_helper.dart';
import '../../../settings/cubit/settings_cubit.dart';
import '../../../buildings/cubit/buildings_cubit.dart';
import '../../cubit/contracts_cubit.dart';
import 'verify_pin_dialog.dart';

// ==========================================
// 🌟 أداة تنسيق الأرقام (تضع فاصلة لكل 3 أرقام أثناء الكتابة)
// ==========================================
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    // مسح أي شيء ليس رقماً
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');
    
    String formatted = '';
    int count = 0;
    for (int i = digitsOnly.length - 1; i >= 0; i--) {
      if (count != 0 && count % 3 == 0) formatted = ',$formatted';
      formatted = digitsOnly[i] + formatted;
      count++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// 🌟 دالة مساعدة لتنسيق الأرقام برمجياً
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

void showAddContractDialog(BuildContext parentContext) {
  final state = parentContext.read<ContractsCubit>().state;
  final buildingsCubit = parentContext.read<BuildingsCubit>();
  final settingsCubit = parentContext.read<SettingsCubit>();

  buildingsCubit.loadData();

  if (state.clients.isEmpty) return;

  String? selectedClientId = state.clients.first.id;
  String selectedContractType = 'متخصص'; 
  
  String? selectedBuildingId;
  String? selectedApartmentId;

  final areaController = TextEditingController();
  final priceController = TextEditingController();
  final monthsController = TextEditingController(text: '48'); 
  final durationCoefficientCtrl = TextEditingController(text: '0'); 
  final guarantorController = TextEditingController(); 
  
  final blockCoeffCtrl = TextEditingController(text: '0');
  final coloredPlasterCoeffCtrl = TextEditingController(text: '0');
  final marbleStairsCoeffCtrl = TextEditingController(text: '0');
  final marbleFinsCoeffCtrl = TextEditingController(text: '0');
  final plumbingCoeffCtrl = TextEditingController(text: '0');
  final chimneysCoeffCtrl = TextEditingController(text: '0');

  // حقول أسعار المواد التاريخية
  final histIronCtrl = TextEditingController();
  final histCementCtrl = TextEditingController();
  final histBlockCtrl = TextEditingController();
  final histFormworkCtrl = TextEditingController();
  final histAggregatesCtrl = TextEditingController();
  final histWorkerCtrl = TextEditingController();

  Map<String, double> autoImportedCoefficients = {};

  bool isHistoricalContract = false;
  DateTime selectedHistoricalDate = DateTime.now();

  Map<String, double> buildFinalCoefficientsMap(bool isAllocated) {
    Map<String, double> finalMap = {};
    
    double? durVal = double.tryParse(durationCoefficientCtrl.text);
    if (durVal != null && durVal != 0.0) {
      finalMap['نسبة التقسيط'] = durVal / 100.0;
    }

    if (isAllocated) {
      autoImportedCoefficients.forEach((key, value) {
        finalMap[key] = value / 100.0;
      });

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

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return BlocBuilder<BuildingsCubit, BuildingsState>(
        bloc: buildingsCubit, 
        builder: (context, buildingsState) {
          return BlocBuilder<SettingsCubit, SettingsState>(
            bloc: settingsCubit,
            builder: (context, settingsState) {
              return StatefulBuilder(
                builder: (context, setState) {
                  
                  final buildings = buildingsState.buildings;
                  final allApartments = buildingsState.apartments;
                  final currentPrices = settingsState.currentPrices;

                  bool isAllocated = selectedContractType == 'متخصص'; 
                  
                  final availableApartments = allApartments.where((apt) => 
                     apt.buildingId == selectedBuildingId && apt.status == 'available'
                  ).toList();

                  return AlertDialog(
                    title: const Text('توقيع عقد جديد', style: TextStyle(color: Colors.teal)),
                    content: SizedBox(
                      width: 650, 
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children:[
                            // 🌟 1. مفتاح تفعيل العقد القديم
                            Container(
                              decoration: BoxDecoration(
                                color: isHistoricalContract ? Colors.red.shade50 : Colors.transparent,
                                border: Border.all(color: isHistoricalContract ? Colors.red : Colors.transparent),
                                borderRadius: BorderRadius.circular(8)
                              ),
                              child: SwitchListTile(
                                title: const Text('إدخال عقد قديم (تاريخي)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                subtitle: const Text('يتيح لك تحديد تاريخ توقيع قديم وإدخال أسعار المواد في ذلك الوقت.'),
                                value: isHistoricalContract,
                                activeColor: Colors.red,
                                onChanged: (val) async {
                                  if (val) {
                                    bool authorized = await showVerifyPinDialog(parentContext);
                                    if (authorized) {
                                      setState(() => isHistoricalContract = true);
                                      
                                      // 🌟 السحر هنا: فتح نافذة التاريخ تلقائياً بعد إدخال الرمز الصحيح!
                                      final pickedDate = await showDatePicker(
                                        context: dialogContext,
                                        initialDate: selectedHistoricalDate,
                                        firstDate: DateTime(2000), 
                                        lastDate: DateTime.now(),
                                        builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Colors.red)), child: child!),
                                      );
                                      if (pickedDate != null) {
                                        setState(() => selectedHistoricalDate = pickedDate);
                                      }
                                    }
                                  } else {
                                    setState(() {
                                      isHistoricalContract = false;
                                      priceController.clear(); 
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 🌟 2. محدد التاريخ وحقول المواد 
                            if (isHistoricalContract) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.red.shade300, width: 2), borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  children:[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children:[
                                        const Text('📅 تاريخ التوقيع:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        // 🌟 زر التاريخ الأنيق والواضح
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red.shade50,
                                            foregroundColor: Colors.red.shade700,
                                            elevation: 0,
                                            side: BorderSide(color: Colors.red.shade300, width: 2),
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                          ),
                                          icon: const Icon(Icons.calendar_month, size: 22),
                                          label: Text(
                                            '${selectedHistoricalDate.year}/${selectedHistoricalDate.month}/${selectedHistoricalDate.day}', 
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                                          ),
                                          onPressed: () async {
                                            final pickedDate = await showDatePicker(
                                              context: dialogContext,
                                              initialDate: selectedHistoricalDate,
                                              firstDate: DateTime(2000), 
                                              lastDate: DateTime.now(),
                                              builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: const ColorScheme.light(primary: Colors.red)), child: child!),
                                            );
                                            if (pickedDate != null) setState(() => selectedHistoricalDate = pickedDate);
                                          },
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(color: Colors.red),
                                    const Text('💰 أسعار المواد في ذلك التاريخ (ستُحفظ في السجل تلقائياً)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 12),
                                    
                                    // 🌟 أضفنا inputFormatters لكل حقل ليفصل الأرقام بالفاصلة
                                    Row(
                                      children:[
                                        Expanded(child: TextField(controller: histIronCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'الحديد', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                        const SizedBox(width: 8),
                                        Expanded(child: TextField(controller: histCementCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'الإسمنت', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children:[
                                        Expanded(child: TextField(controller: histBlockCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'البلوك 15', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                        const SizedBox(width: 8),
                                        Expanded(child: TextField(controller: histFormworkCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'الكوفراج', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children:[
                                        Expanded(child: TextField(controller: histAggregatesCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'المواد الحصوية', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                        const SizedBox(width: 8),
                                        Expanded(child: TextField(controller: histWorkerCtrl, inputFormatters: [ThousandsFormatter()], decoration: const InputDecoration(labelText: 'أجرة العامل', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],

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
                              decoration: const InputDecoration(labelText: 'نوع العقد', border: OutlineInputBorder()),
                              items:['متخصص', 'لاحق التخصص', 'تجاري', 'شراكة']
                                  .map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedContractType = val ?? 'متخصص';
                                  if (selectedContractType != 'متخصص') {
                                    autoImportedCoefficients.clear();
                                    selectedBuildingId = null;
                                    selectedApartmentId = null;
                                    areaController.text = ''; 
                                  }
                                });
                              },
                            ),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(thickness: 2)),

                            if (isAllocated) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber)),
                                child: Column(
                                  children:[
                                    const Text('🏠 اختيار العقار من الكتالوج', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                                    const SizedBox(height: 12),
                                    
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
                                    const SizedBox(height: 12),
                                    
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
                                                if (k != 'شمالي' && k != 'جنوبي' && k != 'شرقي' && k != 'غربي') {
                                                  autoImportedCoefficients[k] = (v as num).toDouble();
                                                }
                                              });
                                              
                                              final Map<String, dynamic> aptMap = jsonDecode(apt.customCoefficients);
                                              aptMap.forEach((k, v) {
                                                if (!k.startsWith('مساحة')) {
                                                  autoImportedCoefficients[k] = (v as num).toDouble();
                                                }
                                              });
                                            } catch (e) {
                                              debugPrint('خطأ في فك تشفير النسب: $e');
                                            }
                                          }
                                        });
                                      },
                                      disabledHint: Text(selectedBuildingId == null ? 'يرجى اختيار المحضر أولاً' : 'لا يوجد شقق متاحة!'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            if (isAllocated && autoImportedCoefficients.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.teal.shade200)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:[
                                    const Row(
                                      children:[
                                        Icon(Icons.auto_awesome, color: Colors.teal),
                                        SizedBox(width: 8),
                                        Text('تم سحب معاملات التميز آلياً:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: autoImportedCoefficients.entries.map((e) {
                                        return Chip(
                                          label: Text('${e.key}: ${e.value}%'),
                                          backgroundColor: Colors.white,
                                          side: const BorderSide(color: Colors.teal),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            Row(
                              children:[
                                Expanded(flex: 2, child: TextField(
                                  controller: areaController, 
                                  readOnly: isAllocated, 
                                  decoration: InputDecoration(
                                    labelText: isAllocated ? 'المساحة (مجلوبة آلياً)' : 'المساحة الكلية / أسهم (م2)', 
                                    border: const OutlineInputBorder(), 
                                    filled: isAllocated, 
                                    fillColor: isAllocated ? Colors.black12 : Colors.white
                                  ),
                                  keyboardType: TextInputType.number,
                                )),
                                const SizedBox(width: 12),
                                Expanded(flex: 2, child: TextField(controller: monthsController, decoration: const InputDecoration(labelText: 'المدة (أشهر)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                                const SizedBox(width: 12),
                                Expanded(flex: 2, child: TextField(controller: durationCoefficientCtrl, decoration: const InputDecoration(labelText: 'نسبة التقسيط %', border: OutlineInputBorder(), filled: true, fillColor: Colors.orangeAccent), keyboardType: TextInputType.number)),
                              ],
                            ),
                            const SizedBox(height: 16),

                            if (isAllocated) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blueGrey.shade200)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:[
                                    const Text('🛠️ معاملات التجهيزات المشتركة (%)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                                    const SizedBox(height: 12),
                                    Row(
                                      children:[
                                        Expanded(child: TextField(controller: blockCoeffCtrl, decoration: const InputDecoration(labelText: 'بلوك %', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                        const SizedBox(width: 8),
                                        Expanded(child: TextField(controller: coloredPlasterCoeffCtrl, decoration: const InputDecoration(labelText: 'كلسة ملونة %', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                        const SizedBox(width: 8),
                                        Expanded(child: TextField(controller: marbleStairsCoeffCtrl, decoration: const InputDecoration(labelText: 'درج رخام %', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children:[
                                        Expanded(child: TextField(controller: marbleFinsCoeffCtrl, decoration: const InputDecoration(labelText: 'سلاحات رخام %', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                        const SizedBox(width: 8),
                                        Expanded(child: TextField(controller: plumbingCoeffCtrl, decoration: const InputDecoration(labelText: 'نوازل صحية %', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                        const SizedBox(width: 8),
                                        Expanded(child: TextField(controller: chimneysCoeffCtrl, decoration: const InputDecoration(labelText: 'صواعد مداخن %', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // زر حساب السعر
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (areaController.text.isEmpty) {
                                    ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('البيانات غير مكتملة! أدخل المساحة.'), backgroundColor: Colors.red));
                                    return;
                                  }

                                  MaterialPricesHistoryData targetPrices;

                                  if (isHistoricalContract) {
                                    if (histIronCtrl.text.isEmpty || histCementCtrl.text.isEmpty || histWorkerCtrl.text.isEmpty) {
                                       ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('الرجاء تعبئة جميع أسعار المواد التاريخية!'), backgroundColor: Colors.red));
                                       return;
                                    }
                                    
                                    // 🌟 مسح الفواصل قبل التحويل لرقم للعمليات الحسابية
                                    targetPrices = MaterialPricesHistoryData(
                                      id: 'dummy', effectiveDate: selectedHistoricalDate, userId: 'dummy', createdAt: DateTime.now(), updatedAt: DateTime.now(), isDeleted: false, isSynced: false,
                                      ironPrice: double.parse(histIronCtrl.text.replaceAll(',', '')),
                                      cementPrice: double.parse(histCementCtrl.text.replaceAll(',', '')),
                                      block15Price: double.parse(histBlockCtrl.text.replaceAll(',', '')),
                                      formworkAndPouringWages: double.parse(histFormworkCtrl.text.replaceAll(',', '')),
                                      aggregateMaterialsPrice: double.parse(histAggregatesCtrl.text.replaceAll(',', '')),
                                      ordinaryWorkerWage: double.parse(histWorkerCtrl.text.replaceAll(',', '')),
                                    );
                                  } else {
                                    if (currentPrices == null) {
                                      ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('يرجى ضبط أسعار المواد في الإعدادات أولاً.'), backgroundColor: Colors.red));
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

                                  // 🌟 السحر هنا: وضع الفواصل في السعر المحسوب
                                  priceController.text = formatNumberWithCommas(calculations['pricePerSqm']!);
                                  
                                  ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(isHistoricalContract ? 'تم الحساب بناءً على المواد التاريخية المدخلة ✅' : 'تم الحساب بناءً على أسعار اليوم ✅'), backgroundColor: Colors.green));
                                },
                                icon: const Icon(Icons.calculate),
                                label: Text(isHistoricalContract ? 'حساب سعر المتر (تاريخي)' : 'حساب سعر المتر (أسعار اليوم)'),
                                style: ElevatedButton.styleFrom(backgroundColor: isHistoricalContract ? Colors.red.shade700 : Colors.teal.shade700, foregroundColor: Colors.white),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(thickness: 2)),

                            // حقل السعر النهائي 
                            TextField(
                              controller: priceController,
                              readOnly: !isHistoricalContract, 
                              inputFormatters:[ThousandsFormatter()], // 🌟 إضافة التنسيق هنا أيضاً
                              decoration: InputDecoration(
                                labelText: isHistoricalContract ? 'سعر المتر المربع (يمكنك تعديله يدوياً)' : 'سعر المتر المربع النهائي (يُحسب آلياً)', 
                                border: const OutlineInputBorder(), 
                                filled: true, 
                                fillColor: isHistoricalContract ? Colors.white : Colors.black12,
                                prefixIcon: isHistoricalContract ? const Icon(Icons.edit, color: Colors.red) : const Icon(Icons.lock, color: Colors.grey),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions:[
                      TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                        onPressed: () async { 
                          if (isAllocated && selectedApartmentId == null) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('يرجى اختيار شقة من الكتالوج!'), backgroundColor: Colors.red));
                            return;
                          }
                          if (areaController.text.isEmpty || priceController.text.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('يرجى تعبئة المساحة وحساب/إدخال السعر!'), backgroundColor: Colors.red));
                            return;
                          }

                          if (isHistoricalContract && (histIronCtrl.text.isEmpty || histCementCtrl.text.isEmpty || histWorkerCtrl.text.isEmpty)) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('يجب إدخال جميع أسعار المواد لحفظها في السجل!'), backgroundColor: Colors.red));
                            return;
                          }

                          final Map<String, double> finalCoeffs = buildFinalCoefficientsMap(isAllocated);
                          
                          String generatedDetails = '';
                          if (isAllocated) {
                            final apt = availableApartments.firstWhere((a) => a.id == selectedApartmentId);
                            final bld = buildings.firstWhere((b) => b.id == selectedBuildingId);
                            generatedDetails = 'محضر: ${bld.name} | شقة: ${apt.apartmentNumber} | طابق: ${apt.floorName}';
                          } else {
                            generatedDetails = 'عقد $selectedContractType (غير مخصص / أسهم)';
                          }

                          Navigator.pop(dialogContext);

                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            SnackBar(
                              content: Text(isHistoricalContract ? 'جاري حفظ الأسعار التاريخية ثم توقيع العقد... ⏳' : 'جاري حفظ وتوقيع العقد وتحديث الكتالوج... ⏳'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.teal,
                            )
                          );

                          // 🌟 الإرسال إلى Cubit (مع مسح الفواصل قبل الإرسال)
                          await parentContext.read<ContractsCubit>().addContract(
                            clientId: selectedClientId!,
                            contractType: selectedContractType,
                            details: generatedDetails, 
                            apartmentId: isAllocated ? selectedApartmentId : null,
                            area: double.parse(areaController.text),
                            basePrice: double.parse(priceController.text.replaceAll(',', '')), // 🌟 مسح الفاصلة
                            installmentsCount: int.parse(monthsController.text), 
                            guarantorName: guarantorController.text.trim().isEmpty ? 'بدون كفيل' : guarantorController.text.trim(),
                            coefficients: finalCoeffs, 
                            customDate: isHistoricalContract ? selectedHistoricalDate : null, 
                            
                            histIron: isHistoricalContract ? double.parse(histIronCtrl.text.replaceAll(',', '')) : null, // 🌟 مسح الفاصلة
                            histCement: isHistoricalContract ? double.parse(histCementCtrl.text.replaceAll(',', '')) : null,
                            histBlock: isHistoricalContract ? double.parse(histBlockCtrl.text.replaceAll(',', '')) : null,
                            histFormwork: isHistoricalContract ? double.parse(histFormworkCtrl.text.replaceAll(',', '')) : null,
                            histAggregates: isHistoricalContract ? double.parse(histAggregatesCtrl.text.replaceAll(',', '')) : null,
                            histWorker: isHistoricalContract ? double.parse(histWorkerCtrl.text.replaceAll(',', '')) : null,
                          );
                          
                          if (isAllocated && parentContext.mounted) {
                            parentContext.read<BuildingsCubit>().loadData();
                          }

                          if (parentContext.mounted) {
                            final currentState = parentContext.read<ContractsCubit>().state;
                            if (currentState.status != ContractsStatus.failure) {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                  content: Text('تم توقيع العقد وحفظه بنجاح! ✅'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 3),
                                )
                              );
                            }
                          }
                        },
                        child: const Text('اعتماد وتوقيع العقد'),
                      ),
                    ],
                  );
                }
              );
            }
          );
        }
      );
    },
  );
}
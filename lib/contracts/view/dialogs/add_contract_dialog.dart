// lib/contracts/view/dialogs/add_contract_dialog.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/calculator_helper.dart';
import '../../../settings/cubit/settings_cubit.dart';
import '../../../buildings/cubit/buildings_cubit.dart';
import '../../cubit/contracts_cubit.dart';

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

  Map<String, double> autoImportedCoefficients = {};

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
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade50, 
                                  borderRadius: BorderRadius.circular(8), 
                                  border: Border.all(color: Colors.blueGrey.shade200)
                                ),
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

                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (currentPrices == null || areaController.text.isEmpty) {
                                    ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('البيانات غير مكتملة! أدخل المساحة وتأكد من أسعار الإعدادات.'), backgroundColor: Colors.red));
                                    return;
                                  }

                                  final Map<String, double> finalCoeffs = buildFinalCoefficientsMap(isAllocated);

                                  final calculations = CalculatorHelper.calculateContractValues(
                                    area: double.parse(areaController.text),
                                    currentPrices: currentPrices,
                                    coefficients: finalCoeffs, 
                                  );

                                  priceController.text = calculations['pricePerSqm']!.toStringAsFixed(0);
                                  ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('تم الحساب بناءً على أسعار اليوم ✅'), backgroundColor: Colors.green));
                                },
                                icon: const Icon(Icons.calculate),
                                label: const Text('حساب سعر المتر مبدئياً'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700, foregroundColor: Colors.white),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(thickness: 2)),

                            TextField(
                              controller: priceController,
                              decoration: const InputDecoration(labelText: 'سعر المتر المربع النهائي (ل.س)', border: OutlineInputBorder(), filled: true, fillColor: Colors.black12),
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
                            ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('يرجى تعبئة المساحة وحساب السعر!'), backgroundColor: Colors.red));
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
                            const SnackBar(
                              content: Text('جاري حفظ وتوقيع العقد وتحديث الكتالوج... ⏳'),
                              duration: Duration(seconds: 1),
                              backgroundColor: Colors.teal,
                            )
                          );

                          await parentContext.read<ContractsCubit>().addContract(
                            clientId: selectedClientId!,
                            contractType: selectedContractType,
                            details: generatedDetails, 
                            apartmentId: isAllocated ? selectedApartmentId : null,
                            area: double.parse(areaController.text),
                            basePrice: double.parse(priceController.text),
                            installmentsCount: int.parse(monthsController.text), 
                            guarantorName: guarantorController.text.trim().isEmpty ? 'بدون كفيل' : guarantorController.text.trim(),
                            coefficients: finalCoeffs, 
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
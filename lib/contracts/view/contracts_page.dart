//lib\contracts\view\contracts_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/calculator_helper.dart';
import '../../settings/cubit/settings_cubit.dart';
import '../cubit/contracts_cubit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../buildings/cubit/buildings_cubit.dart';

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
      body: BlocConsumer<ContractsCubit, ContractsState>(
        listener: (context, state) {
          // 🌟 عرض الخطأ عبر SnackBar بدلاً من الشاشة الحمراء
          if (state.status == ContractsStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'حدث خطأ غير متوقع', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ContractsStatus.loading && state.contracts.isEmpty) {
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
                  DataColumn(label: Text('الكفيل', style: TextStyle(fontWeight: FontWeight.bold))), // 🌟 عمود جديد
                  DataColumn(label: Text('سعر المتر', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('المدة', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('ملف العقد', style: TextStyle(fontWeight: FontWeight.bold))), // 🌟 عمود جديد
                  DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: state.contracts.map((contract) {
                  final clientName = state.clients.firstWhere((c) => c.id == contract.clientId, orElse: () => state.clients.first).name;

                  return DataRow(cells:[
                    DataCell(Text(contract.id.split('-').first, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                    DataCell(Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(contract.contractType, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))),
                    DataCell(Text(contract.apartmentDetails)),
                    DataCell(Text(contract.guarantorName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))), // 🌟 عرض الكفيل
                    DataCell(Text(contract.baseMeterPriceAtSigning.toStringAsFixed(0), style: const TextStyle(color: Colors.green))),
                    DataCell(Text('${contract.installmentsCount} شهر', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange))),
                    
                    // 🌟 خلية ملف العقد (زر إرفاق أو زر فتح)
                    DataCell(
                      contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty
                          ? TextButton.icon(
                              icon: const Icon(Icons.download, color: Colors.green),
                              label: const Text('فتح العقد', style: TextStyle(color: Colors.green)),
                              onPressed: () async {
                                 final url = Uri.parse(contract.contractFileUrl!);
                                 if (await canLaunchUrl(url)) {
                                   await launchUrl(url); 
                                 }
                              },
                            )
                          : TextButton.icon(
                              icon: const Icon(Icons.upload_file, color: Colors.orange),
                              label: const Text('إرفاق ملف', style: TextStyle(color: Colors.orange)),
                              onPressed: () async {
                                 FilePickerResult? result = await FilePicker.platform.pickFiles(
                                   type: FileType.custom,
                                   allowedExtensions:['doc', 'docx', 'pdf'], 
                                 );

                                 if (result != null && result.files.single.path != null) {
                                   final filePath = result.files.single.path!;
                                   final extension = result.files.single.extension ?? 'docx';
                                   
                                   if(context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('جاري رفع الملف للسحابة... ⏳'), backgroundColor: Colors.orange)
                                      );

                                      await context.read<ContractsCubit>().attachContractFile(
                                        contractId: contract.id,
                                        filePath: filePath,
                                        extension: extension,
                                      );

                                      if(context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('تم إرفاق العقد بنجاح! ✅'), backgroundColor: Colors.green)
                                        );
                                      }
                                   }
                                 }
                              },
                            ),
                    ),

                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🌟 زر التعديل (الجديد)
                          IconButton(
                            icon: const Icon(Icons.edit_note, color: Colors.blue),
                            tooltip: 'تعديل تفاصيل العقد',
                            onPressed: () => _showEditContractDialog(context, contract),
                          ),
                          // 🌟 زر الحذف (السابق)
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
                        ],
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

  // ==========================================
  // 🌟 نافذة إضافة العقد (الكتالوج الذكي والمؤتمت) 🌟
  // ==========================================
  void _showAddContractDialog(BuildContext parentContext) {
    final state = parentContext.read<ContractsCubit>().state;
    final currentPrices = parentContext.read<SettingsCubit>().state.currentPrices;
    
    final buildingsState = parentContext.read<BuildingsCubit>().state;
    final buildings = buildingsState.buildings;
    final allApartments = buildingsState.apartments;

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
    // 🌟 متحكمات التجهيزات المشتركة الجديدة 🌟
    final blockCoeffCtrl = TextEditingController(text: '0');
    final coloredPlasterCoeffCtrl = TextEditingController(text: '0');
    final marbleStairsCoeffCtrl = TextEditingController(text: '0');
    final marbleFinsCoeffCtrl = TextEditingController(text: '0');
    final plumbingCoeffCtrl = TextEditingController(text: '0');
    final chimneysCoeffCtrl = TextEditingController(text: '0');

    // 🌟 ماب ستحمل المعاملات التلقائية المستوردة من قاعدة البيانات
    Map<String, double> autoImportedCoefficients = {};

    // بناء الماب النهائية التي ستُرسل للآلة الحاسبة وللحفظ
    Map<String, double> buildFinalCoefficientsMap(bool isAllocated) {
      Map<String, double> finalMap = {};
      
      // 1. إضافة نسبة المدة (تطبق على كل أنواع العقود)
      double? durVal = double.tryParse(durationCoefficientCtrl.text);
      if (durVal != null && durVal != 0.0) {
        finalMap['نسبة التقسيط'] = durVal / 100.0;
      }

      // 2. إذا كان العقد متخصص فقط
      if (isAllocated) {
        // أ. أضف المعاملات الآلية المستوردة من الكتالوج (محضر + شقة)
        autoImportedCoefficients.forEach((key, value) {
          finalMap[key] = value / 100.0;
        });

        // ب. أضف التجهيزات المشتركة
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
        return StatefulBuilder(
          builder: (context, setState) {
            bool isAllocated = selectedContractType == 'متخصص'; // 🌟 متغير يحدد هل العقد متخصص أم لا
            
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
                            // 🌟 تنظيف البيانات إذا قام المحاسب بتغيير نوع العقد
                            if (selectedContractType != 'متخصص') {
                              autoImportedCoefficients.clear();
                              selectedBuildingId = null;
                              selectedApartmentId = null;
                              areaController.text = ''; // إفراغ المساحة ليكتبها يدوياً
                            }
                          });
                        },
                      ),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(thickness: 2)),

                      // 🌟 إظهار الكتالوج "فقط" إذا كان العقد متخصص 🌟
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
                                      
                                      // 🚀 تفريغ الماب قبل تعبئتها من جديد
                                      autoImportedCoefficients.clear();
                                      
                                      try {
                                        // 1. سحب المعاملات العامة للمحضر (الموقع، الشارع، المصعد)
                                        final Map<String, dynamic> bldGeneralMap = jsonDecode(bld.directionCoefficients);
                                        bldGeneralMap.forEach((k, v) {
                                          if (k != 'شمالي' && k != 'جنوبي' && k != 'شرقي' && k != 'غربي') {
                                            autoImportedCoefficients[k] = (v as num).toDouble();
                                          }
                                        });
                                        
                                        // 2. 🌟 سحب معاملات الشقة الخاصة (مع فلترة المساحات الهندسية)
                                        final Map<String, dynamic> aptMap = jsonDecode(apt.customCoefficients);
                                        aptMap.forEach((k, v) {
                                          // 🚨 الفلترة: نتجاهل الحقول التي تبدأ بكلمة "مساحة" لأنها أرقام فيزيائية وليست نسب مالية!
                                          if (!k.startsWith('مساحة')) {
                                            autoImportedCoefficients[k] = (v as num).toDouble();
                                          }
                                        });
                                        
                                      } catch (e) {
                                        print('خطأ في فك تشفير النسب: $e');
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

                      // العرض الآلي للمعاملات (Read-only)
                      if (isAllocated && autoImportedCoefficients.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.teal.shade200)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              const Row(
                                children: [
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
                          // 🌟 المساحة: قراءة فقط إذا متخصص (لأنها تأتي من الشقة)، وقابلة للكتابة إذا غير متخصص
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
                        // 🌟 قسم التجهيزات المشتركة 🌟
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50, 
                            borderRadius: BorderRadius.circular(8), 
                            border: Border.all(color: Colors.blueGrey.shade200)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🛠️ معاملات التجهيزات المشتركة (%)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: TextField(controller: blockCoeffCtrl, decoration: const InputDecoration(labelText: 'بلوك %', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                  const SizedBox(width: 8),
                                  Expanded(child: TextField(controller: coloredPlasterCoeffCtrl, decoration: const InputDecoration(labelText: 'كلسة ملونة %', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                  const SizedBox(width: 8),
                                  Expanded(child: TextField(controller: marbleStairsCoeffCtrl, decoration: const InputDecoration(labelText: 'درج رخام %', border: OutlineInputBorder(), isDense: true), keyboardType: TextInputType.number)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
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
                              ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('البيانات غير مكتملة! أدخل المساحة.'), backgroundColor: Colors.red));
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
                  onPressed: () {
                    // 🌟 الحماية والتحقق
                    if (isAllocated && selectedApartmentId == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('يرجى اختيار شقة من الكتالوج!'), backgroundColor: Colors.red));
                      return;
                    }
                    if (areaController.text.isEmpty || priceController.text.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('يرجى تعبئة المساحة وحساب السعر!'), backgroundColor: Colors.red));
                      return;
                    }

                    final Map<String, double> finalCoeffs = buildFinalCoefficientsMap(isAllocated);
                    
                    // 🌟 توليد التفاصيل بناءً على نوع العقد
                    String generatedDetails = '';
                    if (isAllocated) {
                      final apt = availableApartments.firstWhere((a) => a.id == selectedApartmentId);
                      final bld = buildings.firstWhere((b) => b.id == selectedBuildingId);
                      generatedDetails = 'محضر: ${bld.name} | شقة: ${apt.apartmentNumber} | طابق: ${apt.floorName}';
                    } else {
                      generatedDetails = 'عقد $selectedContractType (غير مخصص / أسهم)';
                    }

                    parentContext.read<ContractsCubit>().addContract(
                      clientId: selectedClientId!,
                      contractType: selectedContractType,
                      details: generatedDetails, 
                      apartmentId: isAllocated ? selectedApartmentId : null, // 🌟 يرسل الشقة فقط إذا كان متخصص
                      area: double.parse(areaController.text),
                      basePrice: double.parse(priceController.text),
                      installmentsCount: int.parse(monthsController.text), 
                      guarantorName: guarantorController.text.trim().isEmpty ? 'بدون كفيل' : guarantorController.text.trim(),
                      coefficients: finalCoeffs, 
                    );
                    
                    // تحديث واجهة المشاريع (إذا تم بيع شقة لكي تختفي من المتاحات)
                    if (isAllocated) {
                      parentContext.read<BuildingsCubit>().loadData();
                    }
                    
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('اعتماد وتوقيع العقد'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // ==========================================
  // ✏️ نافذة التعديل (للمعلومات القابلة للتعديل + إرفاق الملف)
  // ==========================================
  void _showEditContractDialog(BuildContext parentContext, dynamic contract) {
    final detailsController = TextEditingController(text: contract.apartmentDetails);
    final guarantorController = TextEditingController(text: contract.guarantorName);
    final monthsController = TextEditingController(text: contract.installmentsCount.toString());

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تعديل تفاصيل العقد', style: TextStyle(color: Colors.blue)),
          content: SizedBox(
            width: 450, // تم تكبير العرض قليلاً ليتناسب مع زر الملف
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // تنبيه للمحاسب
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.amber.shade50,
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.brown, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'لا يمكن تغيير العميل، العقار، أو سعر المتر بعد التوقيع. يمكنك فقط تحديث التفاصيل، الكفيل، المدة، أو استبدال ملف العقد.',
                            style: TextStyle(color: Colors.brown, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(controller: detailsController, decoration: const InputDecoration(labelText: 'وصف العقد / التفاصيل (الشروط الإضافية)', border: OutlineInputBorder()), maxLines: 2),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(flex: 2, child: TextField(controller: guarantorController, decoration: const InputDecoration(labelText: 'اسم الكفيل', border: OutlineInputBorder()))),
                      const SizedBox(width: 12),
                      Expanded(flex: 1, child: TextField(controller: monthsController, decoration: const InputDecoration(labelText: 'المدة (أشهر)', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 🌟 قسم ملف العقد (الاستبدال أو الإرفاق)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty ? Icons.check_circle : Icons.warning_amber_rounded,
                              color: contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty ? 'يوجد ملف مرفق' : 'لا يوجد ملف',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.upload_file, color: Colors.blue),
                          label: Text(contract.contractFileUrl != null && contract.contractFileUrl!.isNotEmpty ? 'استبدال الملف' : 'إرفاق ملف'),
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['doc', 'docx', 'pdf'], 
                            );

                            if (result != null && result.files.single.path != null) {
                              final filePath = result.files.single.path!;
                              final extension = result.files.single.extension ?? 'docx';
                              
                              if(parentContext.mounted) {
                                ScaffoldMessenger.of(parentContext).showSnackBar(
                                  const SnackBar(content: Text('جاري رفع الملف الجديد للسحابة... ⏳'), backgroundColor: Colors.orange)
                                );

                                // استدعاء الدالة لرفع الملف
                                await parentContext.read<ContractsCubit>().attachContractFile(
                                  contractId: contract.id,
                                  filePath: filePath,
                                  extension: extension,
                                );

                                if(parentContext.mounted) {
                                  ScaffoldMessenger.of(parentContext).showSnackBar(
                                    const SnackBar(content: Text('تم استبدال/إرفاق الملف بنجاح! ✅ (يمكنك إغلاق هذه النافذة)'), backgroundColor: Colors.green)
                                  );
                                  // إغلاق نافذة التعديل تلقائياً بعد رفع الملف بنجاح
                                  Navigator.pop(dialogContext); 
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              onPressed: () {
                if (monthsController.text.isNotEmpty) {
                  parentContext.read<ContractsCubit>().updateContract(
                    id: contract.id,
                    details: detailsController.text,
                    guarantorName: guarantorController.text.isEmpty ? 'بدون كفيل' : guarantorController.text,
                    installmentsCount: int.parse(monthsController.text),
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('حفظ التعديلات النصية'),
            ),
          ],
        );
      },
    );
  }
}
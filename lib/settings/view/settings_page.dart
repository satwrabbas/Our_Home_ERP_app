//lib\settings\view\settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import '../cubit/settings_cubit.dart'; 

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(context.read<ErpRepository>())..fetchPrices(),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final ironController = TextEditingController();
  final cementController = TextEditingController();
  final blockController = TextEditingController();
  final formworkController = TextEditingController(); 
  final aggregatesController = TextEditingController();
  final workerController = TextEditingController();

  @override
  void dispose() {
    ironController.dispose();
    cementController.dispose();
    blockController.dispose();
    formworkController.dispose();
    aggregatesController.dispose();
    workerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الأسعار الافرادية للمواد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        // 🌟 التعديل الأول: الشاشة تستمع إذا تغيرت الحالة أو إذا تغيرت البيانات القادمة من القاعدة المحلية!
        listenWhen: (previous, current) => 
            previous.status != current.status || 
            previous.currentPrices != current.currentPrices,
            
        listener: (context, state) {
          // 1. تحديث حقول النصوص إذا جاءت بيانات جديدة
          if (state.status == SettingsStatus.success && state.currentPrices != null) {
            ironController.text = state.currentPrices!.ironPrice.toStringAsFixed(0);
            cementController.text = state.currentPrices!.cementPrice.toStringAsFixed(0);
            blockController.text = state.currentPrices!.block15Price.toStringAsFixed(0);
            formworkController.text = state.currentPrices!.formworkAndPouringWages.toStringAsFixed(0);
            aggregatesController.text = state.currentPrices!.aggregateMaterialsPrice.toStringAsFixed(0);
            workerController.text = state.currentPrices!.ordinaryWorkerWage.toStringAsFixed(0);
          }

          // 2. 🌟 إظهار رسالة النجاح فقط إذا كنا في حالة تحميل (الضغط على الزر) ثم أصبحنا نجاح
          // لكي لا تظهر الرسالة المزعجة عندما تتحدث البيانات تلقائياً في الخلفية بسبب الـ Realtime
          if (state.status == SettingsStatus.success && state.currentPrices != null) {
             // يمكننا الاعتماد على الوقت لعدم عرض الرسالة عند أول فتح للشاشة
             // ولكن للتبسيط، الـ SnackBar الحالي سيعمل بشكل أفضل إذا فصلناه عن الـ UI البث المباشر
          }

          // 3. إظهار رسالة الخطأ إن وجدت
          if (state.status == SettingsStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('خطأ: ${state.errorMessage}'), backgroundColor: Colors.red, duration: const Duration(seconds: 5)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == SettingsStatus.loading || state.status == SettingsStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Container(
              width: 600, 
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:[
                    const Icon(Icons.engineering, size: 50, color: Colors.blueGrey),
                    const SizedBox(height: 16),
                    const Text('الأسعار الافرادية (كما هي في الإكسل)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text('النظام سيضرب هذه الأرقام بالكميات الثابتة لحساب سعر المتر', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    
                    TextField(controller: ironController, decoration: const InputDecoration(labelText: 'سعر (1 كغ) حديد مبروم واصل', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    TextField(controller: cementController, decoration: const InputDecoration(labelText: 'سعر (1 كيس) اسمنت واصل', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    TextField(controller: blockController, decoration: const InputDecoration(labelText: 'سعر (1 بلوكة) سماكة 15 سم واصل', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    TextField(controller: formworkController, decoration: const InputDecoration(labelText: 'أجور كوفراج وصب وبيتون مسلح لـ (1 م³)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    TextField(controller: aggregatesController, decoration: const InputDecoration(labelText: 'سعر (1 م³) مواد حصوية (بحص+نحاتة) واصل', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    TextField(controller: workerController, decoration: const InputDecoration(labelText: 'أجرة (1 يوم) لعامل عادي 7 ساعات', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                    
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          
                          // 🌟 إظهار رسالة الحفظ هنا لربطها بحدث الضغط على الزر مباشرة
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('جاري الحفظ والمزامنة...'), backgroundColor: Colors.orange, duration: Duration(seconds: 2)),
                          );

                          context.read<SettingsCubit>().updatePrices(
                            iron: double.tryParse(ironController.text) ?? 0,
                            cement: double.tryParse(cementController.text) ?? 0,
                            block15: double.tryParse(blockController.text) ?? 0,
                            formwork: double.tryParse(formworkController.text) ?? 0,
                            aggregates: double.tryParse(aggregatesController.text) ?? 0,
                            worker: double.tryParse(workerController.text) ?? 0,
                          );
                        },
                        child: const Text('حفظ الأسعار الافرادية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
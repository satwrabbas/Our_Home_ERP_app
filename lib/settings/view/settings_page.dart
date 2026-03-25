import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import '../cubit/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsView();
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
  final concreteController = TextEditingController();
  final aggregatesController = TextEditingController();
  final workerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الأسعار اليومية للمواد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state.status == SettingsStatus.success && state.currentPrices != null) {
            ironController.text = state.currentPrices!.ironPrice.toString();
            cementController.text = state.currentPrices!.cementPrice.toString();
            blockController.text = state.currentPrices!.block15Price.toString();
            formworkController.text = state.currentPrices!.formworkAndPouringWages.toString();
            concreteController.text = state.currentPrices!.reinforcedConcretePrice.toString();
            aggregatesController.text = state.currentPrices!.aggregateMaterialsPrice.toString();
            workerController.text = state.currentPrices!.ordinaryWorkerWage.toString();
          }
        },
        builder: (context, state) {
          if (state.status == SettingsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Container(
              width: 600,
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView( // أضفنا سكرول لتسع العناصر
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:[
                    const Icon(Icons.engineering, size: 50, color: Colors.blueGrey),
                    const SizedBox(height: 16),
                    const Text('أسعار المواد اليومية (وفقاً للعقد المعتمد)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    
                    TextField(controller: ironController, decoration: const InputDecoration(labelText: 'ثمن حديد مبروم واصل الى موقع العمل', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    TextField(controller: cementController, decoration: const InputDecoration(labelText: 'ثمن اسمنت واصل الى موقع العمل', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    TextField(controller: blockController, decoration: const InputDecoration(labelText: 'ثمن بلوك اسمنتي سماكة 15 سم واصل', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    TextField(controller: formworkController, decoration: const InputDecoration(labelText: 'اجور كوفارج و صب حديد وتحديد بيتون', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    TextField(controller: concreteController, decoration: const InputDecoration(labelText: 'مسلح لزوم قواعد واعمدة وبلاطة هوردي', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    TextField(controller: aggregatesController, decoration: const InputDecoration(labelText: 'ثمن مواد حصوية جرجرة (بحص + نحاتة) واصل', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    TextField(controller: workerController, decoration: const InputDecoration(labelText: 'اجور عمل لعامل عادي 7 ساعات', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                    
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                        onPressed: () {
                          context.read<SettingsCubit>().updatePrices(
                            iron: double.tryParse(ironController.text) ?? 0,
                            cement: double.tryParse(cementController.text) ?? 0,
                            block15: double.tryParse(blockController.text) ?? 0,
                            formwork: double.tryParse(formworkController.text) ?? 0,
                            concrete: double.tryParse(concreteController.text) ?? 0,
                            aggregates: double.tryParse(aggregatesController.text) ?? 0,
                            worker: double.tryParse(workerController.text) ?? 0,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الأسعار بنجاح!')));
                        },
                        child: const Text('حفظ الإعدادات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
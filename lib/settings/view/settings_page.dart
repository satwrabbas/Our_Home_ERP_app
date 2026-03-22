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
  final workerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات التسعير (المحرك الحسابي)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state.status == SettingsStatus.success && state.currentPrices != null) {
            // ملء الحقول بالأسعار الحالية فور جلبها
            ironController.text = state.currentPrices!.ironPrice.toString();
            cementController.text = state.currentPrices!.cementPrice.toString();
            blockController.text = state.currentPrices!.blockPrice.toString();
            workerController.text = state.currentPrices!.workerDailyRate.toString();
          }
        },
        builder: (context, state) {
          if (state.status == SettingsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(32.0),
              margin: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const[BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:[
                  const Icon(Icons.engineering, size: 60, color: Colors.blueGrey),
                  const SizedBox(height: 16),
                  const Text('أسعار المواد اليومية', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text('تغيير هذه الأسعار سيؤثر على حسابات العقود الجديدة.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  
                  TextField(
                    controller: ironController,
                    decoration: const InputDecoration(labelText: 'سعر طن الحديد (ل.س)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.hardware)),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: cementController,
                    decoration: const InputDecoration(labelText: 'سعر طن الأسمنت (ل.س)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.foundation)),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: blockController,
                    decoration: const InputDecoration(labelText: 'سعر البلوكة (ل.س)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.grid_on)),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: workerController,
                    decoration: const InputDecoration(labelText: 'أجرة العامل اليومية (ل.س)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                      onPressed: () {
                        context.read<SettingsCubit>().updatePrices(
                          iron: double.tryParse(ironController.text) ?? 0,
                          cement: double.tryParse(cementController.text) ?? 0,
                          block: double.tryParse(blockController.text) ?? 0,
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
          );
        },
      ),
    );
  }
}
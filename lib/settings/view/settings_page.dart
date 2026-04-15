//lib\settings\view\settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import 'price_history_dialog.dart';
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

  bool _isProcessingBackup = false; // لمنع الضغط المزدوج أثناء النسخ

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
        title: const Text('إعدادات النظام والأسعار', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) => 
            previous.status != current.status || 
            previous.currentPrices != current.currentPrices,
            
        listener: (context, state) {
          if (state.status == SettingsStatus.success && state.currentPrices != null) {
            ironController.text = state.currentPrices!.ironPrice.toStringAsFixed(0);
            cementController.text = state.currentPrices!.cementPrice.toStringAsFixed(0);
            blockController.text = state.currentPrices!.block15Price.toStringAsFixed(0);
            formworkController.text = state.currentPrices!.formworkAndPouringWages.toStringAsFixed(0);
            aggregatesController.text = state.currentPrices!.aggregateMaterialsPrice.toStringAsFixed(0);
            workerController.text = state.currentPrices!.ordinaryWorkerWage.toStringAsFixed(0);
          }

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
                child: FocusTraversalGroup(
                  policy: WidgetOrderTraversalPolicy(), 
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      const Icon(Icons.engineering, size: 50, color: Colors.blueGrey),
                      const SizedBox(height: 16),
                      const Text('الأسعار الافرادية للمواد', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const Text('النظام سيضرب هذه الأرقام بالكميات الثابتة لحساب سعر المتر', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            final settingsCubit = context.read<SettingsCubit>();
                            settingsCubit.fetchPriceHistory();
                            showDialog(
                              context: context,
                              builder: (ctx) => BlocProvider.value(
                                value: settingsCubit, 
                                child: const PriceHistoryDialog(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.history),
                          label: const Text('سجل تغيير الأسعار'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextField(
                        controller: ironController, 
                        decoration: const InputDecoration(labelText: 'سعر (1 كغ) حديد مبروم واصل', border: OutlineInputBorder()), 
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next, 
                      ),
                      const SizedBox(height: 12),
                      
                      TextField(
                        controller: cementController, 
                        decoration: const InputDecoration(labelText: 'سعر (1 كيس) اسمنت واصل', border: OutlineInputBorder()), 
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      
                      TextField(
                        controller: blockController, 
                        decoration: const InputDecoration(labelText: 'سعر (1 بلوكة) سماكة 15 سم واصل', border: OutlineInputBorder()), 
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      
                      TextField(
                        controller: formworkController, 
                        decoration: const InputDecoration(labelText: 'أجور كوفراج وصب وبيتون مسلح لـ (1 م³)', border: OutlineInputBorder()), 
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      
                      TextField(
                        controller: aggregatesController, 
                        decoration: const InputDecoration(labelText: 'سعر (1 م³) مواد حصوية (بحص+نحاتة) واصل', border: OutlineInputBorder()), 
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      
                      TextField(
                        controller: workerController, 
                        decoration: const InputDecoration(labelText: 'أجرة (1 يوم) لعامل عادي 7 ساعات', border: OutlineInputBorder()), 
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done, 
                        onSubmitted: (_) => _savePrices(context),
                      ),
                      
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                          onPressed: () => _savePrices(context),
                          child: const Text('حفظ الأسعار الافرادية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),

                      // ==========================================
                      // 🛡️ القسم الجديد: أمان البيانات والنسخ الاحتياطي
                      // ==========================================
                      const SizedBox(height: 40),
                      const Divider(thickness: 2),
                      const SizedBox(height: 20),

                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.security, color: Colors.blueGrey, size: 30),
                          SizedBox(width: 10),
                          Text('إدارة قاعدة البيانات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: _isProcessingBackup ? null : () => _handleBackup(context),
                              icon: _isProcessingBackup 
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.save_alt),
                              label: const Text('نسخ احتياطي يدوي', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: _isProcessingBackup ? null : () => _handleRestore(context),
                              icon: const Icon(Icons.restore_page),
                              label: const Text('استعادة البيانات', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20), // مساحة سفلية
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _savePrices(BuildContext context) {
    FocusScope.of(context).unfocus();
                          
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
  }

  // ==========================================
  // 🛡️ دوال معالجة النسخ والاستعادة (UI Handlers)
  // ==========================================

  Future<void> _handleBackup(BuildContext context) async {
    setState(() => _isProcessingBackup = true);
    
    final resultMsg = await context.read<SettingsCubit>().createManualBackup();
    
    setState(() => _isProcessingBackup = false);

    if (mounted) {
      _showResultDialog(context, 'النسخ الاحتياطي', resultMsg);
    }
  }

  Future<void> _handleRestore(BuildContext context) async {
    // 🚨 تحذير المستخدم قبل الاستعادة
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [Icon(Icons.warning, color: Colors.red), SizedBox(width: 8), Text('تحذير خطير')]),
        content: const Text('استعادة قاعدة بيانات سيؤدي إلى استبدال البيانات الحالية بالكامل وإغلاق النظام.\n\nهل أنت متأكد أنك تريد المتابعة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('نعم، قم بالاستعادة')
          ),
        ],
      )
    );

    if (confirm == true && mounted) {
      setState(() => _isProcessingBackup = true);
      
      final resultMsg = await context.read<SettingsCubit>().restoreDatabase();
      
      setState(() => _isProcessingBackup = false);

      if (mounted) {
        _showResultDialog(context, 'استعادة البيانات', resultMsg);
      }
    }
  }

  // دالة مساعدة لإظهار نتيجة العمليات
  void _showResultDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // إجبار المستخدم على قراءة الرسالة
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً'),
          )
        ],
      )
    );
  }
}
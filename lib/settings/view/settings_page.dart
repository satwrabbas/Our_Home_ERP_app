// lib/settings/view/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🌟 مكتبة الفواصل
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import '../cubit/settings_cubit.dart'; 

import 'price_history_page.dart'; // 🌟 استدعاء الصفحة الجديدة بدلاً من الديالوج
import 'dialogs/confirm_restore_dialog.dart';
import 'dialogs/result_message_dialog.dart';

// ==========================================
// 🌟 أداة تنسيق الأرقام بالفواصل أثناء الكتابة
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
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// دالة مساعدة لوضع الفواصل في الحقول عند تحميل الصفحة
String formatNumber(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
}

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

  final ScrollController _scrollController = ScrollController();
  bool _isProcessingBackup = false; 

  @override
  void dispose() {
    ironController.dispose();
    cementController.dispose();
    blockController.dispose();
    formworkController.dispose();
    aggregatesController.dispose();
    workerController.dispose();
    _scrollController.dispose(); 
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
            // 🌟 تعبئة الحقول مع إضافة الفواصل
            ironController.text = formatNumber(state.currentPrices!.ironPrice);
            cementController.text = formatNumber(state.currentPrices!.cementPrice);
            blockController.text = formatNumber(state.currentPrices!.block15Price);
            formworkController.text = formatNumber(state.currentPrices!.formworkAndPouringWages);
            aggregatesController.text = formatNumber(state.currentPrices!.aggregateMaterialsPrice);
            workerController.text = formatNumber(state.currentPrices!.ordinaryWorkerWage);
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
            child: SizedBox(
              width: 600, 
              child: Scrollbar(
                controller: _scrollController, 
                thumbVisibility: true, 
                child: SingleChildScrollView(
                  controller: _scrollController, 
                  padding: const EdgeInsets.all(24.0), 
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
                              
                              // 🌟 الانتقال لصفحة كاملة بدلاً من الديالوج
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: settingsCubit, 
                                    child: const PriceHistoryPage(),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.history),
                            label: const Text('سجل تغيير الأسعار'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 🌟 إضافة الفواصل أثناء الكتابة
                        TextField(
                          controller: ironController, 
                          inputFormatters: [ThousandsFormatter()],
                          decoration: const InputDecoration(labelText: 'سعر (1 كغ) حديد مبروم واصل', border: OutlineInputBorder()), 
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next, 
                        ),
                        const SizedBox(height: 12),
                        
                        TextField(
                          controller: cementController, 
                          inputFormatters: [ThousandsFormatter()],
                          decoration: const InputDecoration(labelText: 'سعر (1 كيس) اسمنت واصل', border: OutlineInputBorder()), 
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        
                        TextField(
                          controller: blockController, 
                          inputFormatters: [ThousandsFormatter()],
                          decoration: const InputDecoration(labelText: 'سعر (1 بلوكة) سماكة 15 سم واصل', border: OutlineInputBorder()), 
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        
                        TextField(
                          controller: formworkController, 
                          inputFormatters: [ThousandsFormatter()],
                          decoration: const InputDecoration(labelText: 'أجور كوفراج وصب وبيتون مسلح لـ (1 م³)', border: OutlineInputBorder()), 
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        
                        TextField(
                          controller: aggregatesController, 
                          inputFormatters: [ThousandsFormatter()],
                          decoration: const InputDecoration(labelText: 'سعر (1 م³) مواد حصوية (بحص+نحاتة) واصل', border: OutlineInputBorder()), 
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        
                        TextField(
                          controller: workerController, 
                          inputFormatters: [ThousandsFormatter()],
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
                          children:[
                            Icon(Icons.security, color: Colors.blueGrey, size: 30),
                            SizedBox(width: 10),
                            Text('إدارة قاعدة البيانات', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children:[
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
                        const SizedBox(height: 20), 
                      ],
                    ),
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

    // 🌟 إزالة الفواصل قبل تحويل النصوص إلى أرقام وحفظها
    context.read<SettingsCubit>().updatePrices(
      iron: double.tryParse(ironController.text.replaceAll(',', '')) ?? 0,
      cement: double.tryParse(cementController.text.replaceAll(',', '')) ?? 0,
      block15: double.tryParse(blockController.text.replaceAll(',', '')) ?? 0,
      formwork: double.tryParse(formworkController.text.replaceAll(',', '')) ?? 0,
      aggregates: double.tryParse(aggregatesController.text.replaceAll(',', '')) ?? 0,
      worker: double.tryParse(workerController.text.replaceAll(',', '')) ?? 0,
    );
  }

  Future<void> _handleBackup(BuildContext context) async {
    setState(() => _isProcessingBackup = true);
    final resultMsg = await context.read<SettingsCubit>().createManualBackup();
    setState(() => _isProcessingBackup = false);
    if (mounted) showResultMessageDialog(context, title: 'النسخ الاحتياطي', message: resultMsg);
  }

  Future<void> _handleRestore(BuildContext context) async {
    final confirm = await showConfirmRestoreDialog(context);
    if (confirm == true && mounted) {
      setState(() => _isProcessingBackup = true);
      final resultMsg = await context.read<SettingsCubit>().restoreDatabase();
      setState(() => _isProcessingBackup = false);
      if (mounted) showResultMessageDialog(context, title: 'استعادة البيانات', message: resultMsg);
    }
  }
}
// lib/settings/view/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import '../cubit/settings_cubit.dart'; 

import 'price_history_page.dart'; 
import 'dialogs/confirm_restore_dialog.dart';
import 'dialogs/result_message_dialog.dart';

// 🌟 استدعاء شاشة سلة المحذوفات
import '../../recycle_bin/view/recycle_bin_page.dart';

// 🌟 استدعاء الحارس الشخصي والصلاحيات
import '../../auth/cubit/auth_cubit.dart';
import '../../core/constants/app_permissions.dart';

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

  Widget _buildPriceField({
    required TextEditingController controller, 
    required String label, 
    required IconData icon, 
    required TextInputAction textInputAction,
    void Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller, 
      inputFormatters: [ThousandsFormatter()],
      keyboardType: TextInputType.number,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label, 
        prefixIcon: Icon(icon, color: Colors.blueGrey.shade400, size: 22),
        suffixText: 'ل.س',
        suffixStyle: TextStyle(color: Colors.blueGrey.shade300, fontWeight: FontWeight.bold, fontSize: 12),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.blueGrey.shade500, width: 2)),
      ), 
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🌟 جلب حالة الصلاحيات للمستخدم الحالي
    final authState = context.watch<AuthCubit>().state;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: BlocConsumer<SettingsCubit, SettingsState>(
          listenWhen: (previous, current) => 
              previous.status != current.status || 
              previous.currentPrices != current.currentPrices,
              
          listener: (context, state) {
            if (state.status == SettingsStatus.success && state.currentPrices != null) {
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
              return const Center(child: CircularProgressIndicator(color: Colors.blueGrey));
            }

            return Center(
              child: SizedBox(
                width: 700,
                child: Scrollbar(
                  controller: _scrollController, 
                  thumbVisibility: true, 
                  child: SingleChildScrollView(
                    controller: _scrollController, 
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0), 
                    child: FocusTraversalGroup(
                      policy: WidgetOrderTraversalPolicy(), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                          // ==========================================
                          // 🌟 عنوان الصفحة المدمج والأنيق
                          // ==========================================
                          Row(
                            children:[
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: Colors.blueGrey.shade50, borderRadius: BorderRadius.circular(12)),
                                child: Icon(Icons.settings_suggest, color: Colors.blueGrey.shade700, size: 30),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text(
                                  'إعدادات النظام والأسعار', 
                                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),

                          // ==========================================
                          // 💰 بطاقة إعداد الأسعار الإفرادية
                          // ==========================================
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blueGrey.shade100, width: 1.5),
                              boxShadow:[BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children:[
                                    const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        Text('الأسعار الافرادية للمواد', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                                        SizedBox(height: 4),
                                        Text('النظام سيضرب هذه الأرقام بالكميات الثابتة لحساب سعر المتر', style: TextStyle(color: Colors.grey, fontSize: 13)),
                                      ],
                                    ),
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.indigo,
                                        side: BorderSide(color: Colors.indigo.shade200, width: 2),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                      ),
                                      onPressed: () {
                                        final settingsCubit = context.read<SettingsCubit>();
                                        settingsCubit.fetchPriceHistory();
                                        
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
                                      icon: const Icon(Icons.history, size: 20),
                                      label: const Text('سجل الأسعار', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                                
                                Row(
                                  children:[
                                    Expanded(
                                      child: _buildPriceField(
                                        controller: ironController, 
                                        label: 'سعر (1 كغ) حديد مبروم', 
                                        icon: Icons.hardware, 
                                        textInputAction: TextInputAction.next
                                      )
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildPriceField(
                                        controller: cementController, 
                                        label: 'سعر (1 كيس) اسمنت', 
                                        icon: Icons.foundation, 
                                        textInputAction: TextInputAction.next
                                      )
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                Row(
                                  children:[
                                    Expanded(
                                      child: _buildPriceField(
                                        controller: blockController, 
                                        label: 'سعر (1 بلوكة) سماكة 15', 
                                        icon: Icons.view_in_ar, 
                                        textInputAction: TextInputAction.next
                                      )
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildPriceField(
                                        controller: formworkController, 
                                        label: 'أجور كوفراج وبيتون (1 م³)', 
                                        icon: Icons.architecture, 
                                        textInputAction: TextInputAction.next
                                      )
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                Row(
                                  children:[
                                    Expanded(
                                      child: _buildPriceField(
                                        controller: aggregatesController, 
                                        label: 'سعر (1 م³) مواد حصوية', 
                                        icon: Icons.landslide, 
                                        textInputAction: TextInputAction.next
                                      )
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildPriceField(
                                        controller: workerController, 
                                        label: 'أجرة (يوم) عامل 7 ساعات', 
                                        icon: Icons.engineering, 
                                        textInputAction: TextInputAction.done,
                                        onSubmitted: (_) => _savePrices(context),
                                      )
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // 🌟 حماية زر الحفظ (الزر الباهت)
                                // إذا لم يكن لديه صلاحية تعديل الأسعار، يصبح الزر باهتاً ولا يعمل
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey.shade800, 
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.grey.shade300,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                    ),
                                    onPressed: authState.hasPermission(AppPermissions.updatePrices) 
                                        ? () => _savePrices(context) 
                                        : null,
                                    icon: const Icon(Icons.save),
                                    label: const Text('اعتماد وحفظ الأسعار ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ==========================================
                          // 🗑️ بطاقة إدارة المحذوفات الشاملة (مخفية بالكامل إن لم يمتلك الصلاحية)
                          // ==========================================
                          if (authState.hasPermission(AppPermissions.viewRecycleBin)) ...[
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.red.shade100, width: 1.5),
                                boxShadow:[BoxShadow(color: Colors.red.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:[
                                  Row(
                                    children:[
                                      Icon(Icons.delete_sweep, color: Colors.red.shade600, size: 28),
                                      const SizedBox(width: 12),
                                      const Text('إدارة المحذوفات (سلة المهملات)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('استعادة العملاء، العقود، المحاضر، الشقق والإيصالات الملغاة أو حذفها نهائياً. (يتم التنظيف التلقائي بعد 7 أيام)', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                  const SizedBox(height: 20),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 55,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade50,
                                        foregroundColor: Colors.red.shade800,
                                        elevation: 0,
                                        side: BorderSide(color: Colors.red.shade200, width: 1.5),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => const RecycleBinPage()));
                                      },
                                      icon: const Icon(Icons.recycling, size: 24),
                                      label: const Text('فتح سلة المحذوفات الشاملة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // ==========================================
                          // 🛡️ بطاقة أمان البيانات والنسخ الاحتياطي
                          // ==========================================
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.teal.shade100, width: 1.5),
                              boxShadow:[BoxShadow(color: Colors.teal.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:[
                                Row(
                                  children:[
                                    Icon(Icons.security, color: Colors.teal.shade600, size: 28),
                                    const SizedBox(width: 12),
                                    const Text('أمان قاعدة البيانات المحلية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('أخذ نسخة احتياطية يدوية لقاعدة البيانات (للحفظ على فلاشة) أو استعادة بيانات سابقة.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                const SizedBox(height: 20),

                                Row(
                                  children:[
                                    Expanded(
                                      child: SizedBox(
                                        height: 55,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal.shade600,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: _isProcessingBackup ? null : () => _handleBackup(context),
                                          icon: _isProcessingBackup 
                                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                              : const Icon(Icons.save_alt),
                                          label: const Text('نسخ احتياطي يدوي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // زر الاستعادة (متاح فقط للآدمن لحمايته من التخريب)
                                    Expanded(
                                      child: SizedBox(
                                        height: 55,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueGrey.shade100,
                                            foregroundColor: Colors.blueGrey.shade900,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: (_isProcessingBackup || !authState.isSystemAdmin) ? null : () => _handleRestore(context),
                                          icon: const Icon(Icons.restore_page),
                                          label: const Text('استعادة البيانات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40), 
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _savePrices(BuildContext context) {
    FocusScope.of(context).unfocus();
                          
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري الحفظ والمزامنة...'), backgroundColor: Colors.orange, duration: Duration(seconds: 2)),
    );

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
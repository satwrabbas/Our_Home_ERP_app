// lib/schedule/view/tabs/traditional_schedule_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Contract; 
import '../../cubit/schedule_cubit.dart';
import '../../../core/utils/whatsapp_helper.dart';

import '../dialogs/edit_schedule_dialog.dart';
import '../dialogs/reschedule_dialog.dart';
import '../dialogs/edit_single_schedule_dialog.dart';

class TraditionalScheduleTab extends StatelessWidget {
  final ScheduleState state;

  const TraditionalScheduleTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    int totalInstallments = 0;
    int paidInstallments = 0;
    int pendingInstallments = 0;
    int overdueInstallments = 0;
    
    Contract? currentContract;
    double metersPerInstallment = 0.0;

    if (state.selectedContractId != null && state.scheduleList.isNotEmpty) {
      totalInstallments = state.scheduleList.length;
      paidInstallments = state.scheduleList.where((s) => s.status == 'paid').length;
      pendingInstallments = state.scheduleList.where((s) => s.status != 'paid').length;
      overdueInstallments = state.scheduleList.where((s) => s.status != 'paid' && s.dueDate.isBefore(DateTime.now())).length;
      
      final idx = state.contracts.indexWhere((c) => c.id == state.selectedContractId);
      if (idx != -1) {
        currentContract = state.contracts[idx];
        if (currentContract.installmentsCount > 0) {
          metersPerInstallment = currentContract.totalArea / currentContract.installmentsCount;
        }
      }
    }

    return Column(
      children:[
        // ==========================================
        // 1. القسم العلوي الثابت: البحث المتقدم والأزرار المصغرة
        // ==========================================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            border: Border(bottom: BorderSide(color: Colors.indigo.shade200, width: 2)),
          ),
          child: Row(
            children:[
              const Icon(Icons.person_search, color: Colors.indigo, size: 36),
              const SizedBox(width: 16),
              
              // 🌟 محرك البحث الحديث (DropdownMenu)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return DropdownMenu<String>(
                      width: constraints.maxWidth, // ليتمدد ويأخذ العرض المتاح
                      enableSearch: true, // 🌟 تفعيل البحث
                      enableFilter: true, // 🌟 تفعيل الفلترة أثناء الكتابة
                      hintText: '🔍 اكتب اسم العميل أو العقار للبحث السريع...',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      inputDecorationTheme: InputDecorationTheme(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      initialSelection: state.contracts.any((c) => c.id == state.selectedContractId) ? state.selectedContractId : null,
                      onSelected: (val) {
                        if (val != null) context.read<ScheduleCubit>().selectContract(val);
                      },
                      dropdownMenuEntries: state.contracts.map((contract) {
                        final clientIdx = state.clients.indexWhere((c) => c.id == contract.clientId);
                        final clientName = clientIdx >= 0 ? state.clients[clientIdx].name : 'عميل غير معروف (محذوف)';
                        return DropdownMenuEntry<String>(
                          value: contract.id, 
                          label: '$clientName (${contract.apartmentDetails})',
                        );
                      }).toList(),
                    );
                  }
                ),
              ),
              
              // 🌟 أزرار التحكم المصغرة والجانبية
              if (state.selectedContractId != null) ...[
                const SizedBox(width: 16),
                
                // زر خصائص العقد (مصغر)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.indigo,
                    side: const BorderSide(color: Colors.indigo, width: 1.5),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  icon: const Icon(Icons.settings, size: 20),
                  label: const Text('خصائص العقد', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    if (currentContract != null) showEditScheduleDialog(context, currentContract);
                  },
                ),

                const SizedBox(width: 12),
                
                // زر إعادة الجدولة (مصغر وبارز)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  icon: const Icon(Icons.autorenew, size: 20),
                  label: const Text('إعادة الجدولة', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    if (currentContract != null) showRescheduleDialog(context, currentContract);
                  },
                ),
              ],
            ],
          ),
        ),

        // ==========================================
        // 2. القسم السفلي القابل للتمرير (Scrollable)
        // الإحصائيات + الجدول معاً ليصعدا للأعلى عند التمرير
        // ==========================================
        Expanded(
          child: state.selectedContractId == null
              ? _buildEmptyState() 
              : state.scheduleList.isEmpty
                  ? const Center(child: Text('لم يتم توليد أي جدول أقساط لهذا العقد.', style: TextStyle(fontSize: 18)))
                  : ListView( // 🌟 تم استبدال Column بـ ListView لكي يصعد الملخص للأعلى!
                      padding: const EdgeInsets.all(24.0),
                      children:[
                        // 🌟 بطاقة الملخص الإحصائي ودليل الألوان
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow:[BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            children:[
                              // دليل الألوان (Legend)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:[
                                  _buildLegendItem(Colors.green, 'مُسدد ✓'),
                                  const SizedBox(width: 24),
                                  _buildLegendItem(Colors.orange, 'معلق / قادم ⏳'),
                                  const SizedBox(width: 24),
                                  _buildLegendItem(Colors.red, 'متأخر 🚨'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // بطاقة الإحصائيات (Summary Card)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children:[
                                    _buildStatItem('إجمالي الأقساط', totalInstallments.toString(), Colors.indigo),
                                    _buildStatItem('تم السداد', paidInstallments.toString(), Colors.green),
                                    _buildStatItem('المتبقي', pendingInstallments.toString(), Colors.orange),
                                    _buildStatItem('المتأخر الآن', overdueInstallments.toString(), Colors.red, isAlert: overdueInstallments > 0),
                                    _buildStatItem('متوسط القسط', '~ ${metersPerInstallment.toStringAsFixed(2)} م²', Colors.teal),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24), // مسافة بين الملخص والجدول

                        // 🌟 جدول الاستحقاقات الفعلي
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          clipBehavior: Clip.antiAlias,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal, // 🌟 للتمرير الأفقي في حال كانت الشاشة صغيرة
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width - 60, // ملء الشاشة تقريباً
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(Colors.indigo.shade100),
                                dataRowMaxHeight: 70, // تكبير مساحة السطر لراحة العين
                                columns: const[
                                  DataColumn(label: Text('رقم القسط', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('تاريخ الاستحقاق', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('الكمية (م²)', style: TextStyle(fontWeight: FontWeight.bold))), 
                                  DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('إجراءات (تواصل وتعديل)', style: TextStyle(fontWeight: FontWeight.bold))), 
                                ],
                                rows: state.scheduleList.map((schedule) {
                                  final isPaid = schedule.status == 'paid';
                                  final isOverdue = !isPaid && schedule.dueDate.isBefore(DateTime.now());

                                  String statusText = 'قادم / معلق';
                                  Color statusColor = Colors.orange;

                                  if (isPaid) {
                                    statusText = 'تم التسديد ✓';
                                    statusColor = Colors.green;
                                  } else if (isOverdue) {
                                    statusText = 'متأخر جداً 🚨';
                                    statusColor = Colors.red;
                                  }

                                  return DataRow(
                                    color: WidgetStateProperty.all(isOverdue ? Colors.red.shade50 : Colors.transparent),
                                    cells:[
                                      DataCell(Text(schedule.installmentNumber.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                      
                                      DataCell(
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children:[
                                            Text('${schedule.dueDate.year}/${schedule.dueDate.month}/${schedule.dueDate.day}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                            if (schedule.notes != null && schedule.notes!.isNotEmpty)
                                              Text(schedule.notes!, style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontStyle: FontStyle.italic)),
                                          ],
                                        )
                                      ),

                                      DataCell(
                                        isPaid 
                                          ? const Text('مُثبتة 🔒', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))
                                          : Text('~ ${metersPerInstallment.toStringAsFixed(2)} م²', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))
                                      ),

                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor)),
                                          child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                                        )
                                      ),

                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children:[
                                            isPaid
                                              ? const Text('سُددت عبر الإيصالات', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                                              : ElevatedButton.icon(
                                                  onPressed: () async {
                                                    final contractIdx = state.contracts.indexWhere((c) => c.id == schedule.contractId);
                                                    if(contractIdx == -1) return;
                                                    final contract = state.contracts[contractIdx];

                                                    final clientIdx = state.clients.indexWhere((c) => c.id == contract.clientId);
                                                    if(clientIdx == -1) return;
                                                    final client = state.clients[clientIdx];
                                                    
                                                    final success = await WhatsAppHelper.sendReminderMessage(
                                                      schedule: schedule, contract: contract, client: client,
                                                    );

                                                    if (context.mounted) {
                                                      if (success) {
                                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم فتح الواتساب لإرسال التذكير!'), backgroundColor: Colors.green));
                                                      } else {
                                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل فتح الواتساب.'), backgroundColor: Colors.red));
                                                      }
                                                  }
                                                  },
                                                  icon: const Icon(Icons.chat, size: 18),
                                                  label: const Text('تذكير'),
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12)),
                                                ),
                                                
                                            if (!isPaid) ...[
                                              const SizedBox(width: 12),
                                              Container(
                                                decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8)),
                                                child: IconButton(
                                                  icon: const Icon(Icons.edit_calendar, color: Colors.indigo),
                                                  tooltip: 'تأجيل أو تعديل تاريخ هذا القسط وإضافة ملاحظة',
                                                  onPressed: () => showEditSingleScheduleDialog(context, schedule),
                                                ),
                                              ),
                                            ]
                                          ],
                                        )
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }

  // ==========================================
  // 🛠️ دوال مساعدة لرسم واجهة الملخص
  // ==========================================
  
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children:[
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, Color color, {bool isAlert = false}) {
    return Column(
      children:[
        Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(
          value, 
          style: TextStyle(
            fontSize: 26, // 🌟 تكبير الأرقام لتبدو كالداشبورد
            fontWeight: FontWeight.bold, 
            color: color,
            shadows: isAlert ?[BoxShadow(color: Colors.red.shade300, blurRadius: 12)] : null,
          )
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Icon(Icons.query_stats, size: 100, color: Colors.indigo.shade200),
          const SizedBox(height: 24),
          const Text('نظام متابعة الأقساط والجدولة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
          const SizedBox(height: 12),
          SizedBox(
            width: 400,
            child: Text(
              'استخدم محرك البحث بالأعلى لاختيار عميل.\n\nمن هنا يمكنك: \n✅ مراقبة الدفعات المتأخرة.\n🔄 إعادة جدولة الأقساط المستقبلية بأمان.\n📝 تأجيل قسط محدد لظروف العميل.\n📲 إرسال رسائل مطالبة عبر واتساب.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
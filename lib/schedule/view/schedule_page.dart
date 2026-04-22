// lib/schedule/view/schedule_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/schedule_cubit.dart';
import '../../core/utils/whatsapp_helper.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScheduleView();
  }
}

class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 🌟 عدد التبويبات
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المراقبة والتحليل المالي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.indigo,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.orange,
            indicatorWeight: 4,
            tabs:[
              Tab(icon: Icon(Icons.radar), text: 'رادار التخصص (ذكاء مالي)'),
              Tab(icon: Icon(Icons.table_chart), text: 'جدول الأقساط التقليدي'),
            ],
          ),
        ),
        body: BlocBuilder<ScheduleCubit, ScheduleState>(
          builder: (context, state) {
            if (state.status == ScheduleStatus.loading && state.contracts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.clients.isEmpty || state.contracts.isEmpty) {
              return const Center(child: Text('لا يوجد بيانات كافية.', style: TextStyle(fontSize: 18, color: Colors.grey)));
            }

            return TabBarView(
              children:[
                // 🌟 التبويبة الأولى: رادار التخصص (الجديدة كلياً)
                _buildRadarTab(context, state),
                
                // 🌟 التبويبة الثانية: جدول الأقساط (القديمة المحدثة)
                _buildTraditionalScheduleTab(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // 🧭 واجهة "رادار التخصص" الذكية
  // ==========================================
  Widget _buildRadarTab(BuildContext context, ScheduleState state) {
    if (state.allocationAlerts.isEmpty) {
      return const Center(
        child: Text('لا يوجد عقود "لاحق التخصص" حالياً لمراقبتها.', style: TextStyle(fontSize: 18, color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.allocationAlerts.length,
      itemBuilder: (context, index) {
        final alert = state.allocationAlerts[index];
        final target = context.read<ScheduleCubit>().targetAllocationMeters;
        
        // حساب النسبة المئوية لشريط التقدم
        double progress = alert.accumulatedMeters / target;
        if (progress > 1.0) progress = 1.0;

        // تحديد الألوان حسب الخطورة
        Color cardBorderColor;
        Color progressColor;
        IconData urgencyIcon;
        String urgencyText;

        if (alert.urgencyLevel == 'high') {
          cardBorderColor = Colors.red;
          progressColor = Colors.redAccent;
          urgencyIcon = Icons.local_fire_department;
          urgencyText = alert.accumulatedMeters >= target 
              ? 'تجاوز نسبة التخصص! يتطلب إجراء فوراً' 
              : 'خطر! سيتخصص خلال ${alert.estimatedMonthsLeft} شهر';
        } else if (alert.urgencyLevel == 'medium') {
          cardBorderColor = Colors.orange;
          progressColor = Colors.orange;
          urgencyIcon = Icons.warning_amber_rounded;
          urgencyText = 'يقترب. متبقي ${alert.estimatedMonthsLeft} أشهر تقريباً';
        } else {
          cardBorderColor = Colors.green;
          progressColor = Colors.green;
          urgencyIcon = Icons.shield;
          urgencyText = alert.estimatedMonthsLeft == 999 
              ? 'لا توجد دفعات حالية (آمن)' 
              : 'آمن. متبقي أكثر من ${alert.estimatedMonthsLeft} أشهر ببطء';
        }

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: cardBorderColor.withOpacity(0.5), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Text('العميل: ${alert.client.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Chip(
                      avatar: Icon(urgencyIcon, color: Colors.white, size: 18),
                      label: Text(urgencyText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: progressColor,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('الوصف: ${alert.contract.apartmentDetails}', style: const TextStyle(color: Colors.blueGrey)),
                const Divider(),
                
                // شريط التقدم (Progress Bar)
                Row(
                  children:[
                    const Text('مستوى التخصص: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade200,
                          color: progressColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${alert.accumulatedMeters.toStringAsFixed(1)} / $target م²', style: TextStyle(fontWeight: FontWeight.bold, color: progressColor)),
                  ],
                ),
                const SizedBox(height: 12),
                
                // قسم التحليل
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:[
                      Column(
                        children:[
                          const Icon(Icons.speed, color: Colors.blue),
                          const SizedBox(height: 4),
                          const Text('سرعة الدفع', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text('${alert.averageMetersPerMonth.toStringAsFixed(1)} م²/شهر', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children:[
                          const Icon(Icons.timelapse, color: Colors.purple),
                          const SizedBox(height: 4),
                          const Text('عمر العقد', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text('${DateTime.now().difference(alert.contract.contractDate).inDays ~/ 30} شهر', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children:[
                          Icon(Icons.flag, color: progressColor),
                          const SizedBox(height: 4),
                          const Text('المدة المتبقية', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(alert.estimatedMonthsLeft == 999 ? 'غير محدد' : '${alert.estimatedMonthsLeft} أشهر', style: TextStyle(fontWeight: FontWeight.bold, color: progressColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // 📅 واجهة "الجدول التقليدي" (الكود القديم المرتب)
  // ==========================================
  Widget _buildTraditionalScheduleTab(BuildContext context, ScheduleState state) {
    return Column(
      children:[
        Container(
          padding: const EdgeInsets.all(24.0),
          color: Colors.indigo.shade50,
          child: Row(
            children:[
              const Icon(Icons.calendar_month, color: Colors.indigo, size: 30),
              const SizedBox(width: 16),
              const Text('متابعة أقساط العميل: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: state.contracts.any((c) => c.id == state.selectedContractId) ? state.selectedContractId : null,
                  decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                  items: state.contracts.map((contract) {
                    final clientIdx = state.clients.indexWhere((c) => c.id == contract.clientId);
                    final clientName = clientIdx >= 0 ? state.clients[clientIdx].name : 'عميل غير معروف (محذوف)';
                    return DropdownMenuItem(
                      value: contract.id, 
                      child: Text('العميل: $clientName (${contract.apartmentDetails})')
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) context.read<ScheduleCubit>().selectContract(val);
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.selectedContractId == null
              ? const Center(child: Text('يرجى اختيار عقد من القائمة بالأعلى لعرض جدول الأقساط.', style: TextStyle(fontSize: 18, color: Colors.grey)))
              : state.scheduleList.isEmpty
                  ? const Center(child: Text('لم يتم توليد أي جدول أقساط لهذا العقد.', style: TextStyle(fontSize: 18)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(Colors.indigo.shade100),
                          columns: const[
                            DataColumn(label: Text('رقم القسط', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('تاريخ الاستحقاق', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('إجراءات (تواصل)', style: TextStyle(fontWeight: FontWeight.bold))), 
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
                                DataCell(Text('${schedule.dueDate.year}/${schedule.dueDate.month}/${schedule.dueDate.day}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: statusColor)),
                                    child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                                  )
                                ),
                                DataCell(
                                  isPaid
                                    ? const Text('مُسددة في دفتر الأستاذ', style: TextStyle(color: Colors.grey))
                                    : ElevatedButton.icon(
                                        onPressed: () async {
                                          final contractIdx = state.contracts.indexWhere((c) => c.id == schedule.contractId);
                                          if(contractIdx == -1) return;
                                          final contract = state.contracts[contractIdx];

                                          final clientIdx = state.clients.indexWhere((c) => c.id == contract.clientId);
                                          if(clientIdx == -1) return;
                                          final client = state.clients[clientIdx];
                                          
                                          final success = await WhatsAppHelper.sendReminderMessage(
                                            schedule: schedule,
                                            contract: contract,
                                            client: client,
                                          );

                                          if (context.mounted) {
                                            if (success) {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم فتح الواتساب لإرسال التذكير!'), backgroundColor: Colors.green));
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل فتح الواتساب.'), backgroundColor: Colors.red));
                                            }
                                          }
                                        },
                                        icon: const Icon(Icons.chat),
                                        label: const Text('تذكير (واتساب)'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                      ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}
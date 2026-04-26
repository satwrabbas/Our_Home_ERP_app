//lib\profile\view\client_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_storage_api/local_storage_api.dart' show Client;
import '../cubit/client_profile_cubit.dart';

// 🌟 سيتم إنشاء هذا الملف في الخطوة القادمة
import 'contract_details_page.dart'; 

String formatWithCommas(num number) {
  RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return number.toInt().toString().replaceAllMapped(reg, (Match match) => '${match[1]},');
}

class ClientProfilePage extends StatelessWidget {
  final Client client;

  const ClientProfilePage({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('الملف التعريفي الشامل ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.indigo.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<ClientProfileCubit, ClientProfileState>(
        builder: (context, state) {
          if (state.status == ClientProfileStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: Colors.indigo));
          }
          if (state.status == ClientProfileStatus.failure) {
            return Center(child: Text(state.errorMessage ?? 'حدث خطأ', style: const TextStyle(color: Colors.red)));
          }

          final summaries = state.contractsSummary;

          return CustomScrollView(
            slivers:[
              // ==========================================
              // 🌟 قسم الهيدر (معلومات العميل والتقييم)
              // ==========================================
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade800,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children:[
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white24,
                        child: Text(
                          client.name.isNotEmpty ? client.name.substring(0, 1) : '?',
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(client.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          const Icon(Icons.phone, color: Colors.white70, size: 16),
                          const SizedBox(width: 4),
                          Text(client.phone, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                          const SizedBox(width: 16),
                          if (client.nationalId != null && client.nationalId!.isNotEmpty) ...[
                            const Icon(Icons.badge, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(client.nationalId!, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                          ]
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // 📊 شريط الإحصائيات المالي المجمع
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow:[BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                        ),
                        child: Row(
                          children:[
                            _buildTopStat('إجمالي العقود', summaries.length.toString(), Icons.folder_shared, Colors.indigo),
                            Container(height: 40, width: 1, color: Colors.grey.shade300),
                            _buildTopStat('إجمالي المدفوعات', '${formatWithCommas(state.grandTotalPaid)} ل.س', Icons.account_balance_wallet, Colors.green),
                            Container(height: 40, width: 1, color: Colors.grey.shade300),
                            _buildTopStat('أقساط متأخرة', state.totalOverdueAcrossAll.toString(), Icons.warning_rounded, state.totalOverdueAcrossAll > 0 ? Colors.red : Colors.green),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ==========================================
              // 🌟 قائمة العقود (المحفظة)
              // ==========================================
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 16),
                  child: Text('عقود وممتلكات العميل (المحفظة)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                ),
              ),

              if (summaries.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children:[
                          Icon(Icons.folder_off, size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text('هذا العميل لا يملك أي عقود حالياً.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final summary = summaries[index];
                      final contract = summary.contract;
                      final isAllocated = contract.contractType == 'متخصص';

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        // 🌟 التعديل هنا: إضافة InkWell للبطاقة للذهاب لشاشة التفاصيل
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          elevation: 1,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ContractDetailsPage(
                                    contract: contract, 
                                    client: client,
                                    summary: summary,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children:[
                                  // رأس البطاقة
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isAllocated ? Colors.amber.shade50 : Colors.blue.shade50,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children:[
                                        Row(
                                          children:[
                                            Icon(isAllocated ? Icons.apartment : Icons.savings, color: isAllocated ? Colors.amber.shade800 : Colors.blue.shade700),
                                            const SizedBox(width: 8),
                                            Text(contract.contractType, style: TextStyle(fontWeight: FontWeight.bold, color: isAllocated ? Colors.amber.shade800 : Colors.blue.shade700)),
                                          ],
                                        ),
                                        Row(
                                          children:[
                                            Text(
                                              'تاريخ التوقيع: ${contract.contractDate.year}/${contract.contractDate.month}/${contract.contractDate.day}',
                                              style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // محتوى البطاقة
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children:[
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children:[
                                              Text(contract.apartmentDetails, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                                              const SizedBox(height: 8),
                                              Row(
                                                children:[
                                                  const Icon(Icons.payments, size: 14, color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text('المطلوب شهرياً: ${formatWithCommas(contract.agreedMonthlyAmount)} ل.س', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children:[
                                                  const Icon(Icons.price_check, size: 14, color: Colors.green),
                                                  const SizedBox(width: 4),
                                                  Text('المدفوع لهذا العقد: ${formatWithCommas(summary.totalPaid)} ل.س', style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(width: 1, height: 60, color: Colors.grey.shade200, margin: const EdgeInsets.symmetric(horizontal: 16)),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children:[
                                              const Text('حالة المراقبة', style: TextStyle(color: Colors.blueGrey, fontSize: 11)),
                                              const SizedBox(height: 4),
                                              if (summary.overdueSchedulesCount > 0)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.red.shade200)),
                                                  child: Text('${summary.overdueSchedulesCount} متأخر', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                                                )
                                              else
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.green.shade200)),
                                                  child: const Text('منتظم ✓', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                                ),
                                              const SizedBox(height: 4),
                                              Text('${summary.paidSchedulesCount} أشهر مُسددة', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: summaries.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:[
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
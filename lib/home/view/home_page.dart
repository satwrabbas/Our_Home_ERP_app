import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import '../cubit/home_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🌟 ملاحظة: لأننا وضعنا الـ Provider في Dashboard، لا نحتاج لتكراره هنا
    return const HomeView();
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('الرئيسية - الإحصائيات والمؤشرات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        actions:[
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'تحديث الإحصائيات',
            onPressed: () => context.read<HomeCubit>().fetchDashboardData(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == HomeStatus.failure) {
            return Center(child: Text('حدث خطأ: ${state.errorMessage}', style: const TextStyle(color: Colors.red)));
          }

          // 🌟 عرض الإحصائيات بشكل آمن (مع وضع قيمة افتراضية "0" إذا لم توجد بيانات)
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                const Text('المؤشرات المالية والهندسية', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 24),

                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children:[
                    _buildKpiCard(
                      title: 'إجمالي الإيرادات (الصندوق)',
                      value: '${state.totalRevenue.toStringAsFixed(0)} ل.س',
                      icon: Icons.account_balance_wallet,
                      color: Colors.green,
                    ),
                    _buildKpiCard(
                      title: 'إجمالي الأمتار المتعاقد عليها',
                      value: '${state.totalSoldMeters.toStringAsFixed(2)} م2',
                      icon: Icons.architecture,
                      color: Colors.blue,
                    ),
                    _buildKpiCard(
                      title: 'الأمتار المحولة (تم تسديدها)',
                      value: '${state.totalConvertedMeters.toStringAsFixed(3)} م2',
                      icon: Icons.check_circle,
                      color: Colors.deepOrange,
                    ),
                    _buildKpiCard(
                      title: 'إجمالي العقود الموقعة',
                      value: state.contractsCount.toString(),
                      icon: Icons.description,
                      color: Colors.teal,
                    ),
                    _buildKpiCard(
                      title: 'إجمالي عدد العملاء',
                      value: state.clientsCount.toString(),
                      icon: Icons.people,
                      color: Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                const Text('آخر الحركات المالية (أحدث 5 دفعات في الشركة)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 16),

                if (state.recentPayments.isEmpty)
                  const Text('لا توجد حركات مالية مسجلة بعد في دفتر الأستاذ.', style: TextStyle(fontSize: 16, color: Colors.grey))
                else
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const[BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                      columns: const[
                        DataColumn(label: Text('رقم الإيصال', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('المبلغ المدفوع', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('الأمتار المحولة', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('تاريخ الدفع', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: state.recentPayments.map((payment) {
                        return DataRow(cells:[
                          DataCell(Text(payment.id.split('-').first, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                          DataCell(Text('${payment.amountPaid.toStringAsFixed(0)} ل.س', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                          DataCell(Text('${payment.convertedMeters.toStringAsFixed(3)} م2', style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold))),
                          DataCell(Text('${payment.paymentDate.year}/${payment.paymentDate.month}/${payment.paymentDate.day}')),
                        ]);
                      }).toList(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKpiCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const[BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
        border: Border(bottom: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children:[
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, size: 30, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// lib/recycle_bin/view/recycle_bin_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import '../cubit/recycle_bin_cubit.dart';

class RecycleBinPage extends StatelessWidget {
  const RecycleBinPage({super.key});

  @override
  Widget build(BuildContext context) {
    // حقن الـ Cubit محلياً لهذه الشاشة فقط
    return BlocProvider(
      create: (context) => RecycleBinCubit(context.read<ErpRepository>())..loadAllDeletedData(),
      child: const RecycleBinView(),
    );
  }
}

class RecycleBinView extends StatelessWidget {
  const RecycleBinView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // عدد التبويبات
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سلة المحذوفات الشاملة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.red.shade800,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs:[
              Tab(icon: Icon(Icons.domain), text: 'المحاضر'),
              Tab(icon: Icon(Icons.door_front_door), text: 'الوحدات'),
              Tab(icon: Icon(Icons.people), text: 'العملاء'),
              Tab(icon: Icon(Icons.description), text: 'العقود'),
              Tab(icon: Icon(Icons.receipt_long), text: 'المدفوعات'),
            ],
          ),
        ),
        body: BlocConsumer<RecycleBinCubit, RecycleBinState>(
          listener: (context, state) {
            if (state.status == RecycleBinStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'خطأ', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
            }
          },
          builder: (context, state) {
            if (state.status == RecycleBinStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              children:[
                _buildList(context, state.deletedBuildings, 'المحاضر', 
                  (item) => item.name, 
                  (item) => context.read<RecycleBinCubit>().restoreBuilding(item.id),
                  (item) => context.read<RecycleBinCubit>().hardDeleteBuilding(item.id)
                ),
                _buildList(context, state.deletedApartments, 'الوحدات (الشقق/المحلات)', 
                  (item) => 'وحدة رقم: ${item.apartmentNumber} | المساحة: ${item.area}', 
                  (item) => context.read<RecycleBinCubit>().restoreApartment(item.id),
                  (item) => context.read<RecycleBinCubit>().hardDeleteApartment(item.id)
                ),
                _buildList(context, state.deletedClients, 'العملاء', 
                  (item) => item.name, 
                  (item) => context.read<RecycleBinCubit>().restoreClient(item.id),
                  (item) => context.read<RecycleBinCubit>().hardDeleteClient(item.id)
                ),
                _buildList(context, state.deletedContracts, 'العقود', 
                  (item) => 'عقد مساحة: ${item.totalArea} م²', 
                  (item) => context.read<RecycleBinCubit>().restoreContract(item.id),
                  (item) => context.read<RecycleBinCubit>().hardDeleteContract(item.id)
                ),
                _buildList(context, state.deletedPayments, 'المدفوعات والإيصالات', 
                  (item) => 'مبلغ الدفعة: ${item.amountPaid}', 
                  (item) => context.read<RecycleBinCubit>().restorePayment(item.id),
                  (item) => context.read<RecycleBinCubit>().hardDeletePayment(item.id)
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 🌟 دالة مساعدة ذكية لبناء القوائم لكل تبويب لتجنب تكرار الكود
  Widget _buildList<T>(BuildContext context, List<T> items, String emptyMessage, String Function(T) getTitle, void Function(T) onRestore, void Function(T) onHardDelete) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            Icon(Icons.check_circle_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('سلة المحذوفات فارغة من $emptyMessage', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
            const SizedBox(height: 8),
            Text('يتم تنظيف السلة تلقائياً كل 7 أيام.', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.delete_outline, color: Colors.white)),
            title: Text(getTitle(item), style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('محذوف', style: TextStyle(color: Colors.red)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children:[
                IconButton(
                  icon: const Icon(Icons.restore, color: Colors.green),
                  tooltip: 'استعادة',
                  onPressed: () => onRestore(item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  tooltip: 'حذف نهائي',
                  onPressed: () {
                    // رسالة تأكيد أخيرة قبل الحذف المدمر
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('حذف نهائي', style: TextStyle(color: Colors.red)),
                        content: const Text('هل أنت متأكد؟ سيتم مسح هذا العنصر نهائياً ولن تتمكن من استعادته أبداً.'),
                        actions:[
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            onPressed: () {
                              onHardDelete(item);
                              Navigator.pop(ctx);
                            },
                            child: const Text('نعم، مسح نهائي'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
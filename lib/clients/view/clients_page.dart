//lib\clients\view\clients_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/clients_cubit.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ClientsView();
  }
}

class ClientsView extends StatelessWidget {
  const ClientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العملاء (الفريق الثاني)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions:[
          // 🌟 زر سلة المحذوفات الجديد
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
              tooltip: 'سلة المحذوفات',
              onPressed: () {
                // الانتقال لصفحة المحذوفات مع تمرير نفس الـ Cubit
                context.read<ClientsCubit>().fetchDeletedClients(); // جلب البيانات قبل الفتح
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<ClientsCubit>(),
                      child: const DeletedClientsView(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _showAddClientDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة عميل'),
      ),
      body: BlocConsumer<ClientsCubit, ClientsState>(
        // 1. الـ Listener: للرد على الحالات دون تغيير الشاشة (مثل إظهار SnackBar)
        listener: (context, state) {
          if (state.status == ClientsStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'حدث خطأ غير متوقع', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        
        // 2. الـ Builder: لبناء واجهة المستخدم
        builder: (context, state) {
          // عرض دائرة التحميل فقط إذا كانت البيانات فارغة وتتم عملية التحميل
          if (state.status == ClientsStatus.loading && state.clients.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          // إذا لم يكن هناك عملاء
          if (state.clients.isEmpty) {
            return const Center(child: Text('لا يوجد عملاء مضافين حتى الآن.', style: TextStyle(fontSize: 18)));
          }

          // 🌟 تم إزالة شرط الـ failure من هنا حتى لا يختفي الجدول عند حدوث خطأ!

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                columns: const [
                  DataColumn(label: Text('مُعرّف (ID)', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('اسم العميل', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('رقم الهاتف', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('الرقم الوطني', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('تاريخ الإضافة', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('إجراءات', style: TextStyle(fontWeight: FontWeight.bold))), 
                ],
                rows: state.clients.map((client) {
                  return DataRow(cells: [
                    DataCell(Text(client.id.split('-').first, style: const TextStyle(color: Colors.grey))),
                    DataCell(Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(client.phone)),
                    DataCell(Text(client.nationalId ?? 'غير متوفر')),
                    DataCell(Text('${client.createdAt.year}/${client.createdAt.month}/${client.createdAt.day}')),
                    DataCell(
                      // 🌟 تم إزالة Row وزر الحذف، أصبح هناك زر واحد فقط يفتح نافذة التعديل/الحذف
                      IconButton(
                        icon: const Icon(Icons.edit_note, color: Colors.blue, size: 28),
                        tooltip: 'تعديل أو حذف العميل',
                        onPressed: () => _showEditClientDialog(context, client),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddClientDialog(BuildContext parentContext) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final nationalIdController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إضافة عميل جديد'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:[
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم الرباعي', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'رقم الهاتف (للواتساب)', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                TextField(controller: nationalIdController, decoration: const InputDecoration(labelText: 'الرقم الوطني (اختياري)', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions:[
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  parentContext.read<ClientsCubit>().addClient(
                    name: nameController.text,
                    phone: phoneController.text,
                    nationalId: nationalIdController.text.isEmpty ? null : nationalIdController.text,
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('حفظ العميل'),
            ),
          ],
        );
      },
    );
  }


  /// 🌟 نافذة تعديل أو حذف بيانات العميل
  void _showEditClientDialog(BuildContext parentContext, dynamic client) {
    final nameController = TextEditingController(text: client.name);
    final phoneController = TextEditingController(text: client.phone);
    final nationalIdController = TextEditingController(text: client.nationalId ?? '');

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تعديل بيانات العميل', style: TextStyle(color: Colors.blue)),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:[
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'الاسم الرباعي', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'رقم الهاتف (للواتساب)', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                TextField(controller: nationalIdController, decoration: const InputDecoration(labelText: 'الرقم الوطني (اختياري)', border: OutlineInputBorder())),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween, // 🌟 لجعل زر الحذف على اليمين والباقي على اليسار
          actions:[
            // 🗑️ زر الحذف (مدمج داخل النافذة)
            TextButton.icon(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text('حذف نهائي', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.pop(dialogContext); // إغلاق النافذة
                
                bool isAuthorized = await _verifyPin(parentContext); 
                
                if (isAuthorized && parentContext.mounted) {
                  // 🌟 نكتفي بإرسال الطلب للـ Cubit فقط.
                  // إذا فشل، الـ BlocConsumer سيعرض رسالة الخطأ لوحده!
                  parentContext.read<ClientsCubit>().deleteClient(client.id);
                }
              },
            ),
            
            // ✏️ أزرار الحفظ والإلغاء
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  onPressed: () async {
                    if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                      Navigator.pop(dialogContext);

                      bool isAuthorized = await _verifyPin(parentContext);
                      
                      if (isAuthorized && parentContext.mounted) {
                        // 🌟 نكتفي بإرسال الطلب للـ Cubit فقط.
                        parentContext.read<ClientsCubit>().updateClient(
                          id: client.id, 
                          name: nameController.text,
                          phone: phoneController.text,
                          nationalId: nationalIdController.text.isEmpty ? null : nationalIdController.text,
                        );
                      }
                    }
                  },
                  child: const Text('حفظ التعديلات'),
                ),
              ],
            )
          ],
        );
      },
    );
  }


  // ==========================================
  // 🔐 نافذة التحقق من رمز الأمان (PIN Code)
  // ==========================================
  Future<bool> _verifyPin(BuildContext context) async {
    final pinController = TextEditingController();
    bool isAuthorized = false;
    final String correctPin = '0000'; // 🌟 الرمز الافتراضي (يمكنك تغييره)

    await showDialog(
      context: context,
      barrierDismissible: false, // لا يمكن إغلاقها بالنقر خارجها
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('تأكيد الصلاحية', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('هذه العملية حساسة. يرجى إدخال رمز الأمان (PIN):'),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                obscureText: true, // إخفاء الأرقام ككلمة سر
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 4,
                style: const TextStyle(fontSize: 24, letterSpacing: 12),
                decoration: const InputDecoration(border: OutlineInputBorder(), counterText: ''),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                if (pinController.text == correctPin) {
                  isAuthorized = true;
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('الرمز غير صحيح! ❌'), backgroundColor: Colors.red)
                  );
                  pinController.clear();
                }
              },
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );

    return isAuthorized;
  }

  
}


// ==============================================================
// 🌟 الشاشة الجديدة: سلة المحذوفات (Recycle Bin) -[نسخة محمية]
// ==============================================================
class DeletedClientsView extends StatelessWidget {
  const DeletedClientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة المحذوفات (تحذف تلقائياً بعد 7 أيام)', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ClientsCubit, ClientsState>(
        builder: (context, state) {
          if (state.deletedClients.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Icon(Icons.auto_delete_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('سلة المحذوفات فارغة', style: TextStyle(fontSize: 20, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.deletedClients.length,
            itemBuilder: (context, index) {
              final client = state.deletedClients[index];
              
              // حساب الأيام المتبقية للحذف النهائي
              final deletionDate = client.updatedAt.toLocal();
              final daysPassed = DateTime.now().difference(deletionDate).inDays;
              final daysLeft = 7 - daysPassed;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.redAccent, child: Icon(Icons.person_off, color: Colors.white)),
                  title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough)),
                  subtitle: Text('رقم الهاتف: ${client.phone}\nباقي $daysLeft أيام على الحذف النهائي', style: const TextStyle(color: Colors.redAccent)),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      // ♻️ زر الاستعادة
                      IconButton(
                        icon: const Icon(Icons.restore, color: Colors.green, size: 30),
                        tooltip: 'استعادة العميل',
                        onPressed: () {
                          context.read<ClientsCubit>().restoreClient(client.id);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الاستعادة بنجاح، وتتم مزامنتها الآن.'), backgroundColor: Colors.green));
                        },
                      ),
                      // 🗑️ زر الحذف النهائي الفوري (محمي برمز سري)
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        tooltip: 'حذف نهائي الآن',
                        onPressed: () => _confirmHardDelete(context, client),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🔐 نافذة تأكيد الحذف النهائي مع التحقق من الرمز
  void _confirmHardDelete(BuildContext context, dynamic client) {
    final pinController = TextEditingController();
    final String correctPin = '0938457732'; // 🌟 رمز الأمان المخصص للحذف النهائي

    showDialog(
      context: context,
      barrierDismissible: false, // لا يمكن إغلاقها بالنقر خارجها
      builder: (ctx) => AlertDialog(
        title: const Row(
          children:[
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('تحذير نهائي', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:[
            Text('هل أنت متأكد من حذف العميل "${client.name}" نهائياً؟ هذا الإجراء لا يمكن التراجع عنه.\n\nيرجى إدخال رمز المدير للتأكيد:'),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              obscureText: true, // إخفاء الرمز أثناء الكتابة
              keyboardType: TextInputType.number, // عرض لوحة الأرقام فقط
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, letterSpacing: 4),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'رمز الأمان',
              ),
            ),
          ],
        ),
        actions:[
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              if (pinController.text == correctPin) {
                // 🌟 الرمز صحيح -> قم بالحذف وأغلق النافذة
                context.read<ClientsCubit>().forceHardDelete(client.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم الحذف النهائي بنجاح.'), backgroundColor: Colors.green)
                );
              } else {
                // ❌ الرمز خاطئ -> أظهر رسالة خطأ وأفرغ الحقل
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('رمز الأمان غير صحيح! ❌'), backgroundColor: Colors.red)
                );
                pinController.clear();
              }
            },
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );
  }
}
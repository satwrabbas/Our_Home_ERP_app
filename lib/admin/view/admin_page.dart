import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart';

import '../cubit/admin_cubit.dart';
import '../../core/constants/app_permissions.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminCubit(context.read<ErpRepository>())..loadAdminData(),
      child: const AdminView(),
    );
  }
}

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 🌟 معجم تحويل الأكواد البرمجية إلى أسماء واضحة للمدير
  final Map<String, String> permissionNames = {
    AppPermissions.viewClients: 'عرض العملاء',
    AppPermissions.createClients: 'إضافة عميل',
    AppPermissions.editClients: 'تعديل عميل',
    AppPermissions.deleteClients: 'حذف عميل',
    AppPermissions.viewContracts: 'عرض العقود',
    AppPermissions.createContracts: 'إنشاء عقد جديد',
    AppPermissions.restructureContracts: 'إعادة جدولة الأقساط',
    AppPermissions.viewPayments: 'عرض الأقساط والمدفوعات',
    AppPermissions.addPayments: 'قبض دفعة جديدة',
    AppPermissions.editPayments: 'تعديل مبلغ الدفعة',
    AppPermissions.deletePayments: 'حذف دفعة',
    AppPermissions.viewPrices: 'رؤية أسعار المواد',
    AppPermissions.updatePrices: 'تعديل أسعار المواد',
    AppPermissions.manageBuildings: 'إدارة المحاضر والشقق',
    AppPermissions.viewRecycleBin: 'رؤية سلة المحذوفات',
    AppPermissions.restoreItems: 'استعادة المحذوفات',
    AppPermissions.hardDeleteItems: 'الحذف النهائي المدمر',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('لوحة تحكم الإدارة (المدير العام)'),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          tabs: const[
            Tab(icon: Icon(Icons.group), text: 'الموظفين (تعيين الأدوار)'),
            Tab(icon: Icon(Icons.security), text: 'قوالب الصلاحيات (الأدوار)'),
          ],
        ),
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state.status == AdminStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'خطأ'), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          if (state.status == AdminStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children:[
              _buildUsersTab(context, state),
              _buildRolesTab(context, state),
            ],
          );
        },
      ),
    );
  }

  // =====================================
  // 👥 التبويب الأول: إدارة الموظفين
  // =====================================
  Widget _buildUsersTab(BuildContext context, AdminState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.users.length,
      itemBuilder: (context, index) {
        final user = state.users[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: user.isActive ? Colors.green : Colors.red,
              child: Icon(user.isActive ? Icons.person : Icons.person_off, color: Colors.white),
            ),
            title: Text(user.fullName ?? user.email, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(user.email),
            trailing: SizedBox(
              width: 250,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children:[
                  // قائمة منسدلة لاختيار دور الموظف
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('اختر الدور'),
                      value: user.roleId,
                      items: state.roles.map((role) {
                        return DropdownMenuItem(value: role.id, child: Text(role.name));
                      }).toList(),
                      onChanged: (newRoleId) {
                        context.read<AdminCubit>().updateUser(user.id, newRoleId, user.isActive);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // زر إيقاف / تفعيل الحساب
                  Switch(
                    value: user.isActive,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      context.read<AdminCubit>().updateUser(user.id, user.roleId, val);
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =====================================
  // 🛡️ التبويب الثاني: إدارة القوالب (الأدوار)
  // =====================================
  Widget _buildRolesTab(BuildContext context, AdminState state) {
    return Column(
      children:[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('إنشاء قالب دور جديد'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade800, foregroundColor: Colors.white),
            onPressed: () => _showRoleDialog(context, null),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.roles.length,
            itemBuilder: (context, index) {
              final role = state.roles[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.shield, color: Colors.amber, size: 36),
                  title: Text(role.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(role.isSystemRole ? 'دور أساسي في النظام' : 'دور مخصص'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_square, color: Colors.blue),
                    onPressed: () => _showRoleDialog(context, role),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 🌟 نافذة التعديل/الإضافة للصلاحيات (Checkboxes)
  void _showRoleDialog(BuildContext parentContext, AppRole? role) {
    final nameController = TextEditingController(text: role?.name ?? '');
    
    // جلب الصلاحيات السابقة إن وجدت
    List<String> currentPerms =[];
    if (role != null && role.permissionsJson.isNotEmpty) {
      try {
        currentPerms = List<String>.from(jsonDecode(role.permissionsJson));
      } catch (_) {}
    }

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(role == null ? 'دور جديد' : 'تعديل: ${role.name}'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:[
                    if (role == null) 
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'اسم الدور (مثال: محاسب فرع)', border: OutlineInputBorder()),
                      ),
                    const SizedBox(height: 16),
                    const Text('الصلاحيات الممنوحة:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: AppPermissions.all.map((permCode) {
                          final bool hasPerm = currentPerms.contains(permCode);
                          return CheckboxListTile(
                            title: Text(permissionNames[permCode] ?? permCode),
                            value: hasPerm,
                            activeColor: Colors.blueGrey.shade900,
                            onChanged: role?.isSystemRole == true 
                              ? null // منع تعديل الـ Admin
                              : (bool? val) {
                                  setState(() {
                                    if (val == true) {
                                      currentPerms.add(permCode);
                                    } else {
                                      currentPerms.remove(permCode);
                                    }
                                  });
                                },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions:[
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: Colors.red))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey.shade900, foregroundColor: Colors.white),
                  onPressed: () {
                    if (role == null) {
                      if (nameController.text.trim().isNotEmpty) {
                        parentContext.read<AdminCubit>().createNewRole(nameController.text.trim(), currentPerms);
                        Navigator.pop(ctx);
                      }
                    } else {
                      parentContext.read<AdminCubit>().updateRole(role.id, currentPerms);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          }
        );
      }
    );
  }
}
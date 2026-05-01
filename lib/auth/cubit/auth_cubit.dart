import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._erpRepository) : super(const AuthState()) {
    checkSession(); // التحقق التلقائي بمجرد تشغيل التطبيق
  }

  final ErpRepository _erpRepository;

  Future<void> checkSession() async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final userId = _erpRepository.currentUserId;

      // 1. إذا لم يكن هناك يوزر في السحابة، فهو غير مسجل دخول
      if (userId == null) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
        return;
      }

      // 2. إذا كان مسجلاً، نجلب بياناته من قاعدة البيانات المحلية (Drift)
      final localUser = await _erpRepository.getLocalUserById(userId);

      if (localUser == null) {
        // إذا كان مسجل دخول لكن بياناته لم تنزل بعد محلياً (مثلاً أول مرة يفتح التطبيق)
        // نقوم بإجبار مزامنة سريعة لجلب بياناته فوراً
        await _erpRepository.pullDataFromCloud();
        final retryUser = await _erpRepository.getLocalUserById(userId);
        
        if (retryUser == null) {
          emit(state.copyWith(
            status: AuthStatus.error, 
            errorMessage: 'بيانات المستخدم غير موجودة في النظام. تواصل مع الإدارة.'
          ));
          return;
        }
        _processUserPermissions(retryUser);
      } else {
        _processUserPermissions(localUser);
      }

    } catch (e) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: e.toString()));
    }
  }

  // 🌟 محرك دمج الصلاحيات (الرياضيات الذكية والمحمية)
  Future<void> _processUserPermissions(dynamic localUser) async {
    // 1. التحقق من حالة الحساب
    if (localUser.isActive == false) {
      emit(state.copyWith(
        status: AuthStatus.error, 
        errorMessage: 'هذا الحساب تم إيقافه من قبل الإدارة.'
      ));
      return;
    }

    String roleName = 'بدون دور';
    bool isSystemAdmin = false;
    Set<String> finalPermissions = {}; // نستخدم Set لمنع التكرار

    // 2. جلب قالب الدور (Role)
    if (localUser.roleId != null) {
      final role = await _erpRepository.getRoleById(localUser.roleId!);
      if (role != null) {
        roleName = role.name;
        isSystemAdmin = role.isSystemRole;

        // 🛡️ حماية فك تشفير صلاحيات الدور
        final String rolePermsStr = role.permissionsJson?.trim() ?? '';
        if (rolePermsStr.isNotEmpty && rolePermsStr != 'null') {
          try {
            List<dynamic> rolePerms = jsonDecode(rolePermsStr);
            finalPermissions.addAll(rolePerms.cast<String>());
          } catch (e) {
            print('⚠️ خطأ في فك تشفير صلاحيات الدور: $e');
          }
        }
      }
    }

    // 3. إضافة الاستثناءات (Extra)
    // 🛡️ حماية فك تشفير الاستثناءات
    final String extraPermsStr = localUser.extraPermissionsJson?.trim() ?? '';
    if (extraPermsStr.isNotEmpty && extraPermsStr != 'null') {
      try {
        List<dynamic> extraPerms = jsonDecode(extraPermsStr);
        finalPermissions.addAll(extraPerms.cast<String>());
      } catch (e) {
        print('⚠️ خطأ في فك تشفير الاستثناءات المضافة: $e');
      }
    }

    // 4. طرح الصلاحيات المسحوبة (Revoked)
    // 🛡️ حماية فك تشفير الممنوعات
    final String revokedPermsStr = localUser.revokedPermissionsJson?.trim() ?? '';
    if (revokedPermsStr.isNotEmpty && revokedPermsStr != 'null') {
      try {
        List<dynamic> revokedPerms = jsonDecode(revokedPermsStr);
        finalPermissions.removeAll(revokedPerms.cast<String>());
      } catch (e) {
        print('⚠️ خطأ في فك تشفير الاستثناءات المسحوبة: $e');
      }
    }

    // 5. حفظ النتيجة النهائية النظيفة في الحالة (State)
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      userId: localUser.id,
      userName: localUser.fullName ?? localUser.email,
      roleName: roleName,
      isSystemAdmin: isSystemAdmin,
      permissions: finalPermissions.toList(),
    ));
  }

  // دالة لتسجيل الخروج يدوياً
  Future<void> logout() async {
    emit(state.copyWith(status: AuthStatus.loading));
    await _erpRepository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
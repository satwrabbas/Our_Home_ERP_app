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

  // 🌟 محرك دمج الصلاحيات (الرياضيات الذكية)
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

        // فك تشفير صلاحيات الدور من JSON إلى List
        List<dynamic> rolePerms = jsonDecode(role.permissionsJson);
        finalPermissions.addAll(rolePerms.cast<String>());
      }
    }

    // 3. إضافة الاستثناءات (Extra)
    List<dynamic> extraPerms = jsonDecode(localUser.extraPermissionsJson);
    finalPermissions.addAll(extraPerms.cast<String>());

    // 4. طرح الصلاحيات المسحوبة (Revoked)
    List<dynamic> revokedPerms = jsonDecode(localUser.revokedPermissionsJson);
    finalPermissions.removeAll(revokedPerms.cast<String>());

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
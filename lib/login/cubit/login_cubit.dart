import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._erpRepository) : super(const LoginState());

  final ErpRepository _erpRepository;

  /// تحديث الإيميل في الـ State عند كتابة المستخدم
  void emailChanged(String value) {
    emit(state.copyWith(email: value, status: LoginStatus.initial));
  }

  /// تحديث كلمة المرور في الـ State
  void passwordChanged(String value) {
    emit(state.copyWith(password: value, status: LoginStatus.initial));
  }

  /// 🌟 إرسال طلب تسجيل الدخول إلى السحابة (Supabase)
  Future<void> submit() async {
    // 1. التحقق من أن الحقول غير فارغة
    if (state.email.isEmpty || state.password.isEmpty) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'الرجاء إدخال البريد الإلكتروني وكلمة المرور.',
      ));
      return;
    }

    // 2. إظهار دائرة التحميل
    emit(state.copyWith(status: LoginStatus.loading));
    
    try {
      // 3. محاولة تسجيل الدخول عبر المستودع
      await _erpRepository.signIn(
        email: state.email.trim(),
        password: state.password,
      );
      
      // 4. نجاح الدخول!
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      // 5. في حال كان الإيميل أو الباسورد خاطئاً
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'فشل تسجيل الدخول. تأكد من صحة الإيميل وكلمة المرور أو اتصالك بالإنترنت.',
      ));
    }
  }
}
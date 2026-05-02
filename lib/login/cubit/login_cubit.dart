//lib\login\cubit\login_cubit.dart
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:path_provider/path_provider.dart'; // 🌟 للوصول لملفات النظام
import 'package:path/path.dart' as p;

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._erpRepository) : super(const LoginState());

  final ErpRepository _erpRepository;

  // ==========================================
  // 🌟 استرجاع الإيميل المحفوظ عند فتح الشاشة
  // ==========================================
  Future<void> loadSavedEmail() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'remember_me.txt'));
      
      if (file.existsSync()) {
        final savedEmail = await file.readAsString();
        if (savedEmail.isNotEmpty) {
          // نعرض الإيميل المحفوظ ونفعل مربع "تذكرني"
          emit(state.copyWith(email: savedEmail, rememberMe: true));
        }
      }
    } catch (e) {
      // نتجاهل الخطأ بصمت إذا كان التطبيق يُفتح لأول مرة
    }
  }

  void emailChanged(String value) {
    emit(state.copyWith(email: value, status: LoginStatus.initial));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, status: LoginStatus.initial));
  }

  // 🌟 تغيير حالة مربع "تذكرني"
  void rememberMeChanged(bool value) {
    emit(state.copyWith(rememberMe: value, status: LoginStatus.initial));
  }

  Future<void> submit() async {
    if (state.email.isEmpty || state.password.isEmpty) {
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: 'الرجاء إدخال البريد الإلكتروني وكلمة المرور.'));
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));
    
    try {
      await _erpRepository.signIn(
        email: state.email.trim(),
        password: state.password,
      );
      
      // ==========================================
      // 🌟 حفظ أو مسح الإيميل محلياً بناءً على خيار "تذكرني"
      // ==========================================
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'remember_me.txt'));
      
      if (state.rememberMe) {
        await file.writeAsString(state.email.trim()); // حفظ الإيميل
      } else {
        if (file.existsSync()) await file.delete(); // مسح الإيميل إذا ألغى الخيار
      }

      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'فشل تسجيل الدخول. تأكد من صحة البيانات أو اتصالك بالإنترنت.',
      ));
    }
  }
}
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
// نحتاج استدعاء مكتبة drift للوصول إلى Value() عند إنشاء ClientsCompanion
import 'package:local_storage_api/local_storage_api.dart' show ClientsCompanion;
import 'package:drift/drift.dart' show Value;

part 'clients_state.dart';

class ClientsCubit extends Cubit<ClientsState> {
  ClientsCubit(this._erpRepository) : super(const ClientsState());

  final ErpRepository _erpRepository;

  /// جلب جميع العملاء من قاعدة البيانات
  Future<void> fetchClients() async {
    emit(state.copyWith(status: ClientsStatus.loading));
    try {
      final clients = await _erpRepository.getClients();
      emit(state.copyWith(status: ClientsStatus.success, clients: clients));
    } catch (e) {
      emit(state.copyWith(status: ClientsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// إضافة عميل جديد
  Future<void> addClient({required String name, required String phone, String? nationalId}) async {
    try {
      final newClient = ClientsCompanion.insert(
        name: name,
        phone: phone,
        nationalId: Value(nationalId),
      );
      
      await _erpRepository.addClient(newClient);
      
      // بعد الإضافة بنجاح، نُعيد جلب القائمة لتحديث الشاشة
      await fetchClients();
    } catch (e) {
      emit(state.copyWith(status: ClientsStatus.failure, errorMessage: e.toString()));
    }
  }
}
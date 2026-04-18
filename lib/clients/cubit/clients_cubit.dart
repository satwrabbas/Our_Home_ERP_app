import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show ClientsCompanion;
import 'package:drift/drift.dart' show Value;

part 'clients_state.dart';

class ClientsCubit extends Cubit<ClientsState> {
  ClientsCubit(this._erpRepository) : super(const ClientsState());

  final ErpRepository _erpRepository;

  /// جلب جميع العملاء (النشطين غير المحذوفين)
  Future<void> fetchClients() async {
    if (state.status == ClientsStatus.initial) emit(state.copyWith(status: ClientsStatus.loading));
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
        userId:  '',
      );
      
      await _erpRepository.addClient(newClient);
      await fetchClients(); // تحديث الشاشة
    } catch (e) {
      emit(state.copyWith(status: ClientsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// 🌟 تعديل بيانات العميل
  Future<void> updateClient({
    required String id,
    required String name,
    required String phone,
    String? nationalId,
  }) async {
    try {
      // 1. إظهار حالة التحميل (اختياري، يمكنك تجاهلها إذا كنت تفضل التحديث الصامت)
      emit(state.copyWith(status: ClientsStatus.loading));

      // 2. إرسال طلب التعديل للـ Repository
      // ملاحظة: يجب التأكد من إضافة هذه الدالة في ErpRepository الخاص بك
      await _erpRepository.updateClient(
        id: id,
        name: name,
        phone: phone,
        nationalId: nationalId,
      );

      // 3. جلب البيانات من جديد لتحديث الجدول
      await fetchClients();
    } catch (e) {
      emit(state.copyWith(status: ClientsStatus.failure, errorMessage: e.toString()));
    }
  }
  
  /// 🌟 حذف عميل (حذف مؤقت Soft Delete)
  Future<void> deleteClient(String id) async { // 🌟 لاحظ أن الـ ID أصبح String
    try {
      await _erpRepository.deleteClient(id);
      await fetchClients(); // تحديث الشاشة ليختفي العميل
    } catch (e) {
      emit(state.copyWith(status: ClientsStatus.failure, errorMessage: e.toString()));
    }
  }
}
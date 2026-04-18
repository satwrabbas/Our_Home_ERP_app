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
        userId:  '', // تأكد من تمرير הـ User ID الصحيح إذا لزم الأمر
      );
      
      await _erpRepository.addClient(newClient);
      await fetchClients(); // تحديث الشاشة
      
    } catch (e) {
      String errorMessage = e.toString();
      
      // 🌟 التعرف على خطأ تكرار رقم الهاتف وتحويله لرسالة مفهومة
      if (errorMessage.contains('UNIQUE constraint failed: clients.phone') || errorMessage.contains('2067')) {
        errorMessage = 'رقم الهاتف هذا مستخدم بالفعل لعميل آخر!';
      } else {
        errorMessage = 'حدث خطأ أثناء إضافة العميل.';
      }

      emit(state.copyWith(status: ClientsStatus.failure, errorMessage: errorMessage));
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
      // 1. استدعاء دالة التعديل من الـ Repository
      await _erpRepository.updateClient(
        id: id,
        name: name,
        phone: phone,
        nationalId: nationalId,
      );

      // 2. تحديث الشاشة بعد النجاح
      await fetchClients(); 
      
    } catch (e) {
      String errorMessage = e.toString();
      
      // 🌟 التعرف على خطأ تكرار رقم الهاتف
      if (errorMessage.contains('UNIQUE constraint failed: clients.phone') || errorMessage.contains('2067')) {
        errorMessage = 'رقم الهاتف هذا مستخدم بالفعل لعميل آخر! لا يمكن تعديله لهذا الرقم.';
      } else {
        errorMessage = 'حدث خطأ أثناء تعديل بيانات العميل.';
      }

      // إرسال حالة الفشل ليقوم الـ SnackBar بعرضها
      emit(state.copyWith(status: ClientsStatus.failure, errorMessage: errorMessage));
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
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';

part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit(this._erpRepository) : super(const ScheduleState());

  final ErpRepository _erpRepository;

  /// 1. جلب البيانات الأساسية (العملاء والعقود الفعالة) لملء القوائم المنسدلة
  Future<void> fetchInitialData() async {
    emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      final clients = await _erpRepository.getClients();
      final contracts = await _erpRepository.getAllContracts();
      
      emit(state.copyWith(
        status: ScheduleStatus.success,
        clients: clients,
        contracts: contracts,
      ));
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: e.toString()));
    }
  }

  /// 2. عند اختيار عقد من القائمة المنسدلة، نجلب "جدول الاستحقاقات" الخاص به
  Future<void> selectContract(String contractId) async {
    emit(state.copyWith(status: ScheduleStatus.loading, selectedContractId: contractId));
    try {
      // جلب الأقساط المجدولة (مرتبة من الأقدم استحقاقاً إلى الأحدث)
      final scheduleList = await _erpRepository.getContractSchedule(contractId);
      emit(state.copyWith(status: ScheduleStatus.success, scheduleList: scheduleList));
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: e.toString()));
    }
  }

  /// 3. دالة لتغيير حالة القسط يدوياً (مثلاً من معلق pending إلى مدفوع paid)
  Future<void> markAsPaid(String scheduleId, String contractId) async {
    try {
      await _erpRepository.updateScheduleStatus(scheduleId, 'paid');
      // تحديث الجدول بعد التعديل لتتغير الألوان أمام المحاسب فوراً
      await selectContract(contractId);
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: e.toString()));
    }
  }
}
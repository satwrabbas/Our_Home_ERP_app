import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show MaterialPricesCompanion;
import 'package:drift/drift.dart' show Value;

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._erpRepository) : super(const SettingsState());

  final ErpRepository _erpRepository;

  /// جلب أحدث الأسعار لعرضها للمهندس
  Future<void> fetchPrices() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final prices = await _erpRepository.getLatestPrices();
      emit(state.copyWith(status: SettingsStatus.success, currentPrices: prices));
    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// حفظ تحديثات الأسعار الجديدة
  Future<void> updatePrices({
    required double iron,
    required double cement,
    required double block,
    required double worker,
  }) async {
    try {
      final newPrices = MaterialPricesCompanion.insert(
        ironPrice: iron,
        cementPrice: cement,
        blockPrice: block,
        workerDailyRate: worker,
        lastUpdated: Value(DateTime.now()), // استخدام Value لأن لها قيمة افتراضية
      );
      
      await _erpRepository.savePrices(newPrices);
      await fetchPrices(); // تحديث الشاشة بعد الحفظ
    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.failure, errorMessage: e.toString()));
    }
  }
}
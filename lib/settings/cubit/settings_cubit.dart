import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show MaterialPricesHistoryCompanion;
import 'package:drift/drift.dart' show Value;

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._erpRepository) : super(const SettingsState());

  final ErpRepository _erpRepository;

  /// جلب أحدث تسعيرة معتمدة من السجل التاريخي
  Future<void> fetchPrices() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final prices = await _erpRepository.getLatestPrices();
      emit(state.copyWith(status: SettingsStatus.success, currentPrices: prices));
    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.failure, errorMessage: e.toString()));
    }
  }

/// إضافة تسعيرة جديدة إلى السجل (6 بنود مدمجة)
  Future<void> updatePrices({
    required double iron,
    required double cement,
    required double block15,
    required double formwork, // الكوفراج والبيتون معاً
    required double aggregates,
    required double worker,
  }) async {
    try {
      final newPrices = MaterialPricesHistoryCompanion.insert(
        ironPrice: iron,
        cementPrice: cement,
        block15Price: block15,
        formworkAndPouringWages: formwork,
        aggregateMaterialsPrice: aggregates,
        ordinaryWorkerWage: worker,
        effectiveDate: Value(DateTime.now()), 
      );
      
      await _erpRepository.savePrices(newPrices);
      await fetchPrices(); 
    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.failure, errorMessage: e.toString()));
    }
  }
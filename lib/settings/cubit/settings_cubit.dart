import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show MaterialPricesHistoryCompanion, MaterialPricesHistoryData;
import 'package:drift/drift.dart' show Value;

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._erpRepository) : super(const SettingsState());

  final ErpRepository _erpRepository;

  /// جلب أحدث تسعيرة (مع محاولة سحب التحديثات من الإنترنت أولاً)
  Future<void> fetchPrices() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      // 🌟 التعديل الجوهري: سحب البيانات من السحابة أولاً لضمان الحصول على أسعار المدير الآخر
      await _erpRepository.pullDataFromCloud();
      
      final prices = await _erpRepository.getLatestPrices();
      emit(state.copyWith(status: SettingsStatus.success, currentPrices: prices));
    } catch (e) {
      // في حال فشل الإنترنت، نعرض البيانات المحلية الموجودة أصلاً
      final prices = await _erpRepository.getLatestPrices();
      emit(state.copyWith(
        status: SettingsStatus.success, 
        currentPrices: prices,
        errorMessage: "تعذر التحديث من السحابة، يتم عرض البيانات المحلية."
      ));
    }
  }

  /// إضافة تسعيرة جديدة
  Future<void> updatePrices({
    required double iron,
    required double cement,
    required double block15,
    required double formwork,
    required double aggregates,
    required double worker,
  }) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      // 🌟 التعديل الثاني: الحصول على userId الحقيقي
      final String? userId = _erpRepository.currentUserId;
      if (userId == null) throw Exception('يجب تسجيل الدخول لتحديث الأسعار.');

      final newPrices = MaterialPricesHistoryCompanion.insert(
        ironPrice: iron,
        cementPrice: cement,
        block15Price: block15,
        formworkAndPouringWages: formwork,
        aggregateMaterialsPrice: aggregates,
        ordinaryWorkerWage: worker,
        effectiveDate: Value(DateTime.now()), 
        userId: userId, // 🚨 تم وضع المعرف الحقيقي هنا
        isDeleted: const Value(false),
      );
      
      // حفظ محلياً + مزامنة سحابية (تأكد أن Repository.savePrices تستدعي syncPendingData)
      await _erpRepository.savePrices(newPrices);
      
      // 🌟 إجبار المزامنة لرفع الأسعار الجديدة فوراً
      await _erpRepository.forceSyncWithCloud();

      // إعادة الجلب للتأكد من حالة النجاح
      await fetchPrices(); 
    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.failure, errorMessage: e.toString()));
    }
  }
}
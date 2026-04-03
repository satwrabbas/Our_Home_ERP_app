//settings_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show MaterialPricesHistoryCompanion, MaterialPricesHistoryData;
import 'package:drift/drift.dart' show Value;

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._erpRepository) : super(const SettingsState()) {
    _startWatchingPrices(); // بدء المراقبة بمجرد فتح الشاشة
  }

  final ErpRepository _erpRepository;
  StreamSubscription<MaterialPricesHistoryData?>? _pricesSubscription;

  /// 🌟 الاستماع الحي للقاعدة المحلية
  void _startWatchingPrices() {
    // نشترك في بث قاعدة البيانات المحلية
    _pricesSubscription = _erpRepository.watchLatestPrices().listen(
      (prices) {
        emit(state.copyWith(
          status: SettingsStatus.success, 
          currentPrices: prices,
        ));
      },
      onError: (error) {
        emit(state.copyWith(status: SettingsStatus.failure, errorMessage: error.toString()));
      },
    );
  }

  /// 🌟 أعدنا هذه الدالة لكي لا يظهر خطأ في الـ UI (Dashboard & Settings Pages)
  /// وظيفتها الآن هي فقط الطلب من السحابة جلب البيانات، 
  /// والـ Stream بالأعلى سيتولى تحديث الشاشة تلقائياً
  Future<void> fetchPrices() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      await _erpRepository.pullDataFromCloud();
      // لا داعي لعمل emit هنا للنجاح، لأن الـ Stream سيشعر بالبيانات ويحدث الـ UI
    } catch (e) {
      // في حال انقطاع الإنترنت (كما ظهر في الخطأ عندك)
      emit(state.copyWith(
        status: SettingsStatus.success, 
        errorMessage: "تعذر الاتصال بالسحابة (أنت تعمل الآن Offline).",
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
        userId: userId, 
        isDeleted: const Value(false),
      );
      
      // حفظ محلياً + مزامنة سحابية
      await _erpRepository.savePrices(newPrices);
      
      // بمجرد الحفظ المحلي، الـ Stream سيحدث الشاشة.
      // نطلب مزامنة السحابة في الخلفية
      _erpRepository.forceSyncWithCloud();

    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.failure, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _pricesSubscription?.cancel(); // إغلاق الاشتراك لمنع تسريب الذاكرة
    return super.close();
  }
}
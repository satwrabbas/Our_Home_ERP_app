import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show ContractsCompanion;
import 'package:drift/drift.dart' show Value;

part 'contracts_state.dart';

class ContractsCubit extends Cubit<ContractsState> {
  ContractsCubit(this._erpRepository) : super(const ContractsState());

  final ErpRepository _erpRepository;

  /// جلب العملاء والعقود الفعالة (غير المحذوفة) لعرضها في الجدول
  Future<void> fetchData() async {
    if (state.status == ContractsStatus.initial) emit(state.copyWith(status: ContractsStatus.loading));
    try {
      final clients = await _erpRepository.getClients();
      final allContracts = await _erpRepository.getAllContracts();
      
      emit(state.copyWith(
        status: ContractsStatus.success, 
        clients: clients, 
        contracts: allContracts
      ));
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// 🌟 إضافة عقد جديد (يدعم تحديد عدد أشهر التقسيط المخصصة لكل عميل)
  Future<void> addContract({
    required String clientId, 
    required String contractType, 
    required String details,
    required double area,
    required double basePrice,
    required int installmentsCount, // 🌟 الحقل الجديد الذي طلبته
    Map<String, dynamic> coefficients = const {}, 
  }) async {
    try {
      final newContract = ContractsCompanion.insert(
        clientId: clientId,
        contractType: Value(contractType),
        apartmentDetails: details,
        totalArea: area,
        baseMeterPriceAtSigning: basePrice,
        installmentsCount: Value(installmentsCount), // 🌟 حفظ عدد الأشهر في القاعدة
        coefficients: Value(jsonEncode(coefficients)),
        contractDate: DateTime.now(),
      );
      
      await _erpRepository.addContract(newContract);
      await fetchData(); // تحديث الشاشة بعد الحفظ
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// إلغاء العقد (حذف مؤقت Soft Delete)
  Future<void> deleteContract(String id) async { 
    try {
      await _erpRepository.deleteContract(id);
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }
}
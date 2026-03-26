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

  /// جلب العملاء والعقود الفعالة (غير المحذوفة)
  Future<void> fetchData() async {
    emit(state.copyWith(status: ContractsStatus.loading));
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

  /// 🌟 إضافة عقد جديد (باستخدام String UUID ونوع العقد)
  Future<void> addContract({
    required String clientId, // أصبحت String
    required String contractType, // نوع العقد (متخصص / لاحق التخصص)
    required String details,
    required double area,
    required double basePrice,
    Map<String, dynamic> coefficients = const {}, 
  }) async {
    try {
      final newContract = ContractsCompanion.insert(
        clientId: clientId,
        contractType: Value(contractType), // إضافة النوع الجديد
        apartmentDetails: details,
        totalArea: area,
        baseMeterPriceAtSigning: basePrice,
        coefficients: Value(jsonEncode(coefficients)),
        contractDate: DateTime.now(),
      );
      
      await _erpRepository.addContract(newContract);
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// 🌟 إلغاء العقد (حذف مؤقت Soft Delete)
  Future<void> deleteContract(String id) async { // أصبحت String
    try {
      await _erpRepository.deleteContract(id);
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }
}
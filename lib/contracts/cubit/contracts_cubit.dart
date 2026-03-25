import 'dart:convert'; // ✅ ضروري للـ JSON
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show ContractsCompanion;
import 'package:drift/drift.dart' show Value;

part 'contracts_state.dart';

class ContractsCubit extends Cubit<ContractsState> {
  ContractsCubit(this._erpRepository) : super(const ContractsState());

  final ErpRepository _erpRepository;

  /// جلب جميع العملاء والعقود (غير المحذوفة)
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

  /// إضافة عقد جديد بالتصميم الهندسي المرن
  Future<void> addContract({
    required int clientId,
    required String details,
    required double area,
    required double basePrice,
    Map<String, dynamic> coefficients = const {}, // المعاملات كـ Map
  }) async {
    try {
      final newContract = ContractsCompanion.insert(
        clientId: clientId,
        apartmentDetails: details,
        totalArea: area,
        baseMeterPriceAtSigning: basePrice,
        coefficients: Value(jsonEncode(coefficients)), // تحويل الـ Map إلى نص JSON للحفظ
        contractDate: DateTime.now(),
      );
      
      await _erpRepository.addContract(newContract);
      await fetchData(); // تحديث الشاشة
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }
}
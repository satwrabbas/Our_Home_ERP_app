import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show ContractsCompanion;
import 'package:drift/drift.dart' show Value;

part 'contracts_state.dart';

class ContractsCubit extends Cubit<ContractsState> {
  ContractsCubit(this._erpRepository) : super(const ContractsState());

  final ErpRepository _erpRepository;

  /// جلب جميع العملاء والعقود (لتهيئة الشاشة)
  Future<void> fetchData() async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      final clients = await _erpRepository.getClients();
      final allContracts = await _erpRepository.getAllContracts(); // جلب العقود
      
      emit(state.copyWith(
        status: ContractsStatus.success, 
        clients: clients, 
        contracts: allContracts // تمرير العقود للشاشة
      ));
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// إضافة عقد جديد بناءً على معادلات الإكسل
  Future<void> addContract({
    required int clientId,
    required String description,
    required double area,
    required double pricePerSqm,
    required double monthlyInstallment,
  }) async {
    try {
      // العملية الحسابية من الإكسل: إجمالي العقد = مساحة الشقة * سعر المتر
      final totalValue = area * pricePerSqm;

      final newContract = ContractsCompanion.insert(
        clientId: clientId,
        apartmentDescription: description,
        apartmentArea: area,
        pricePerSqmAtSigning: pricePerSqm,
        totalContractValue: totalValue,
        monthlyInstallment: monthlyInstallment,
        signatureDate: DateTime.now(), // تاريخ اليوم
      );
      
      await _erpRepository.addContract(newContract);
      await fetchData(); // تحديث الشاشة بعد الإضافة
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }
}
//lib\contracts\cubit\contracts_cubit.dart
import 'dart:io';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show ContractsCompanion, Contract, Client;
import 'package:drift/drift.dart' show Value;

part 'contracts_state.dart';

class ContractsCubit extends Cubit<ContractsState> {
  ContractsCubit(this._erpRepository) : super(const ContractsState());

  final ErpRepository _erpRepository;

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

  // 🌟 جلب العقود المحذوفة لسلة المهملات
  Future<void> fetchDeletedContracts() async {
    try {
      final deleted = await _erpRepository.getDeletedContracts();
      emit(state.copyWith(deletedContracts: deleted));
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> addContract({
    required String clientId, 
    required String contractType, 
    required String details,
    required String? apartmentId, 
    required double area,
    required double basePrice,
    required int installmentsCount, 
    required String guarantorName, 
    Map<String, double> coefficients = const {}, 
  }) async {
    emit(state.copyWith(status: ContractsStatus.loading)); 
    try {
      final String? userId = _erpRepository.currentUserId;
      if (userId == null) throw Exception('يجب تسجيل الدخول أولاً لإنشاء العقود.');

      final newContract = ContractsCompanion.insert(
        clientId: clientId,
        apartmentId: Value(apartmentId), 
        contractType: Value(contractType),
        apartmentDetails: Value(details), 
        totalArea: area,
        baseMeterPriceAtSigning: basePrice,
        installmentsCount: Value(installmentsCount), 
        coefficients: Value(jsonEncode(coefficients)),
        contractDate: DateTime.now().toUtc(), // 🌍 تم التصحيح لـ UTC
        guarantorName: guarantorName, 
        userId: userId, 
      );
      
      await _erpRepository.addContract(newContract);
      
      if (apartmentId != null && apartmentId.isNotEmpty) {
        await _erpRepository.changeApartmentStatus(apartmentId, 'sold');
      }

      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> attachContractFile({required String contractId, required String filePath, required String extension}) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      final file = File(filePath);
      await _erpRepository.attachFileToContract(contractId, file, extension);
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: 'فشل إرفاق الملف: $e'));
    }
  }

  Future<void> deleteContract(String id) async { 
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      final contractToCancel = state.contracts.firstWhere((c) => c.id == id);
      await _erpRepository.deleteContract(id);

      if (contractToCancel.apartmentId != null && contractToCancel.apartmentId!.isNotEmpty) {
        await _erpRepository.changeApartmentStatus(contractToCancel.apartmentId!, 'available');
      }
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  // 🌟 استعادة عقد من سلة المحذوفات
  Future<void> restoreContract(Contract contract) async {
    try {
      // 1. استعادة العقد مع أقساطه ودفعاته
      await _erpRepository.restoreContract(contract.id);

      // 2. حجز الشقة مرة أخرى لكي لا تباع مرتين!
      if (contract.apartmentId != null && contract.apartmentId!.isNotEmpty) {
        await _erpRepository.changeApartmentStatus(contract.apartmentId!, 'sold');
      }

      await fetchDeletedContracts(); // تحديث شاشة المحذوفات
      await fetchData(); // تحديث الشاشة الرئيسية
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  // 🌟 الحذف النهائي (المدمر)
  Future<void> forceHardDelete(String contractId) async {
    try {
      await _erpRepository.forceHardDeleteContract(contractId);
      await fetchDeletedContracts(); // تحديث شاشة المحذوفات
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> updateContract({
    required String id,
    required String details,
    required String guarantorName,
    required int installmentsCount,
  }) async {
    try {
      await _erpRepository.updateContract(
        id: id,
        apartmentDetails: details,
        guarantorName: guarantorName,
        installmentsCount: installmentsCount,
      );
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: 'حدث خطأ أثناء تعديل العقد: $e'));
    }
  }
}
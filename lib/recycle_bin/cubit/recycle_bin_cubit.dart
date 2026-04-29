// lib/recycle_bin/cubit/recycle_bin_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart';

part 'recycle_bin_state.dart';

class RecycleBinCubit extends Cubit<RecycleBinState> {
  RecycleBinCubit(this._erpRepository) : super(const RecycleBinState());

  final ErpRepository _erpRepository;

  /// جلب كافة البيانات المحذوفة في النظام
  Future<void> loadAllDeletedData() async {
    emit(state.copyWith(status: RecycleBinStatus.loading));
    try {
      final buildings = await _erpRepository.getDeletedBuildings();
      final apartments = await _erpRepository.getDeletedApartments();
      final clients = await _erpRepository.getDeletedClients();
      final contracts = await _erpRepository.getDeletedContracts();
      final payments = await _erpRepository.getDeletedLedgerEntries();

      emit(state.copyWith(
        status: RecycleBinStatus.success,
        deletedBuildings: buildings,
        deletedApartments: apartments,
        deletedClients: clients,
        deletedContracts: contracts,
        deletedPayments: payments,
      ));
    } catch (e) {
      emit(state.copyWith(status: RecycleBinStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // ♻️ دوال الاستعادة (Restore)
  // ==========================================
  Future<void> restoreBuilding(String id) async {
    await _erpRepository.restoreBuilding(id);
    await loadAllDeletedData();
  }

  Future<void> restoreApartment(String id) async {
    await _erpRepository.restoreApartment(id);
    await loadAllDeletedData();
  }

  Future<void> restoreClient(String id) async {
    await _erpRepository.restoreClient(id);
    await loadAllDeletedData();
  }

  Future<void> restoreContract(String id) async {
    await _erpRepository.restoreContract(id);
    await loadAllDeletedData();
  }

  Future<void> restorePayment(String id) async {
    await _erpRepository.restoreLedgerEntry(id);
    await loadAllDeletedData();
  }

  // ==========================================
  // 💥 دوال الحذف النهائي (Hard Delete)
  // ==========================================
  Future<void> hardDeleteBuilding(String id) async {
    await _erpRepository.forceHardDeleteBuilding(id);
    await loadAllDeletedData();
  }

  Future<void> hardDeleteApartment(String id) async {
    await _erpRepository.forceHardDeleteApartment(id);
    await loadAllDeletedData();
  }

  Future<void> hardDeleteClient(String id) async {
    await _erpRepository.forceHardDeleteClient(id);
    await loadAllDeletedData();
  }

  Future<void> hardDeleteContract(String id) async {
    await _erpRepository.forceHardDeleteContract(id);
    await loadAllDeletedData();
  }

  Future<void> hardDeletePayment(String id) async {
    await _erpRepository.forceHardDeleteLedgerEntry(id);
    await loadAllDeletedData();
  }
}
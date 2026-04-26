//lib\profile\cubit\client_profile_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show Client, Contract;

part 'client_profile_state.dart';

class ClientProfileCubit extends Cubit<ClientProfileState> {
  ClientProfileCubit(this._erpRepository) : super(const ClientProfileState());

  final ErpRepository _erpRepository;

  Future<void> fetchClientData(Client client) async {
    emit(state.copyWith(status: ClientProfileStatus.loading, client: client));
    
    try {
      // 1. جلب كل العقود الخاصة بهذا العميل
      final clientContracts = await _erpRepository.getContractsForClient(client.id);

      List<ContractProfileSummary> summaries =[];
      double grandTotal = 0.0;
      int globalOverdue = 0;

      final now = DateTime.now().toUtc();

      // 2. الدخول في حلقة لجلب الإحصائيات الدقيقة لكل عقد
      for (var contract in clientContracts) {
        // أ. جلب المدفوعات لجمع المبالغ
        final ledger = await _erpRepository.getContractLedger(contract.id);
        final totalPaidForContract = ledger.fold(0.0, (sum, entry) => sum + entry.amountPaid);
        grandTotal += totalPaidForContract;

        // ب. جلب الأقساط لمعرفة الملتزم والمتأخر
        final schedules = await _erpRepository.getContractSchedule(contract.id);
        final paidCount = schedules.where((s) => s.status == 'paid').length;
        final overdueCount = schedules.where((s) => s.status == 'pending' && s.dueDate.isBefore(now)).length;
        globalOverdue += overdueCount;

        summaries.add(ContractProfileSummary(
          contract: contract,
          totalPaid: totalPaidForContract,
          overdueSchedulesCount: overdueCount,
          paidSchedulesCount: paidCount,
        ));
      }

      // 3. ترتيب العقود (الأحدث أولاً بناءً على تاريخ التوقيع)
      summaries.sort((a, b) => b.contract.contractDate.compareTo(a.contract.contractDate));

      emit(state.copyWith(
        status: ClientProfileStatus.success,
        contractsSummary: summaries,
        grandTotalPaid: grandTotal,
        totalOverdueAcrossAll: globalOverdue,
      ));

    } catch (e) {
      emit(state.copyWith(status: ClientProfileStatus.failure, errorMessage: 'فشل تحميل الملف التعريفي: $e'));
    }
  }
}
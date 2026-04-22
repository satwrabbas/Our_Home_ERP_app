// lib/schedule/cubit/schedule_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
// استدعاء الكلاسات الضرورية
import 'package:local_storage_api/local_storage_api.dart' show Contract, Client, InstallmentsScheduleData;

part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit(this._erpRepository) : super(const ScheduleState());

  final ErpRepository _erpRepository;
  final double targetAllocationMeters = 50.0; // 🌟 هدف التخصص (يمكنك تغييره إلى 40 أو أي رقم)

  Future<void> fetchInitialData() async {
    if (state.status == ScheduleStatus.initial) emit(state.copyWith(status: ScheduleStatus.loading));
    try {
      final clients = await _erpRepository.getClients();
      final contracts = await _erpRepository.getAllContracts();
      
      // 🌟 تشغيل محرك الرادار بصمت
      final alerts = await _generateAllocationRadar(contracts, clients);

      emit(state.copyWith(
        status: ScheduleStatus.success,
        clients: clients,
        contracts: contracts,
        allocationAlerts: alerts, // 🌟 حفظ التنبيهات
      ));
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 🧠 محرك التنبؤ الذكي (Predictive Engine)
  // ==========================================
  Future<List<AllocationAlertData>> _generateAllocationRadar(List<Contract> allContracts, List<Client> allClients) async {
    List<AllocationAlertData> radarList =[];

    // 1. فلترة العقود "لاحق التخصص" فقط والتي لم يتم تسليمها
    final unallocatedContracts = allContracts.where((c) => c.contractType == 'لاحق التخصص' && !c.isCompleted).toList();

    for (var contract in unallocatedContracts) {
      final clientIdx = allClients.indexWhere((c) => c.id == contract.clientId);
      if (clientIdx == -1) continue; 
      final client = allClients[clientIdx];

      // 2. جلب دفتر المدفوعات الخاص بهذا العقد فقط
      final ledger = await _erpRepository.getContractLedger(contract.id);
      
      // 3. حساب إجمالي الأمتار المشتراة
      double accumulatedMeters = ledger.fold(0, (sum, item) => sum + item.convertedMeters);

      // 4. حساب عمر العقد بالأشهر (لمعرفة سرعة العميل)
      final DateTime startDate = contract.contractDate;
      int monthsPassed = DateTime.now().difference(startDate).inDays ~/ 30;
      if (monthsPassed < 1) monthsPassed = 1; // حماية من القسمة على صفر للعقود الجديدة جداً

      // 5. حساب متوسط الأمتار شهرياً (سرعة الإنجاز)
      double averageMetersPerMonth = accumulatedMeters / monthsPassed;

      // 6. تقدير الزمن المتبقي
      int estimatedMonthsLeft = 999; // افتراضي إذا كان لا يدفع
      if (averageMetersPerMonth > 0) {
        double metersLeft = targetAllocationMeters - accumulatedMeters;
        if (metersLeft < 0) metersLeft = 0;
        estimatedMonthsLeft = (metersLeft / averageMetersPerMonth).ceil();
      }

      // 7. تحديد مستوى الخطورة
      String urgency = 'low';
      if (accumulatedMeters >= targetAllocationMeters || estimatedMonthsLeft <= 2) {
        urgency = 'high'; // خطر جداً: سيتخصص قريباً أو تجاوز النسبة
      } else if (estimatedMonthsLeft <= 6) {
        urgency = 'medium'; // متوسط
      }

      radarList.add(
        AllocationAlertData(
          contract: contract,
          client: client,
          accumulatedMeters: accumulatedMeters,
          averageMetersPerMonth: averageMetersPerMonth,
          estimatedMonthsLeft: estimatedMonthsLeft,
          urgencyLevel: urgency,
        )
      );
    }

    // 8. ترتيب القائمة بحيث يظهر الأكثر خطورة (الأقل أشهراً متبقية) في الأعلى
    radarList.sort((a, b) => a.estimatedMonthsLeft.compareTo(b.estimatedMonthsLeft));

    return radarList;
  }

  Future<void> selectContract(String contractId) async {
    emit(state.copyWith(selectedContractId: contractId));
    try {
      final scheduleList = await _erpRepository.getContractSchedule(contractId);
      emit(state.copyWith(status: ScheduleStatus.success, scheduleList: scheduleList));
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> markAsPaid(String scheduleId, String contractId) async {
    try {
      await _erpRepository.updateScheduleStatus(scheduleId, 'paid');
      await selectContract(contractId);
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: e.toString()));
    }
  }
}
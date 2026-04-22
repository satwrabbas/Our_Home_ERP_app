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
      
      // 🌟 1. تشغيل محرك رادار التخصص بصمت
      final allocationAlerts = await _generateAllocationRadar(contracts, clients);

      // 🌟 2. تشغيل محرك المتعثرين (الديون المتراكمة) بصمت
      final overdueAlerts = await _generateOverdueRadar(contracts, clients);

      emit(state.copyWith(
        status: ScheduleStatus.success,
        clients: clients,
        contracts: contracts,
        allocationAlerts: allocationAlerts, // 🌟 حفظ تنبيهات التخصص
        overdueAlerts: overdueAlerts,       // 🌟 حفظ تنبيهات المتعثرين
      ));
    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 🚨 محرك المتعثرين والمتأخرين (Overdue Radar Engine)
  // ==========================================
  Future<List<OverdueContractAlert>> _generateOverdueRadar(List<Contract> allContracts, List<Client> allClients) async {
    // 1. جلب جميع الأقساط المعلقة المتأخرة عن موعدها من المستودع
    final allOverdueSchedules = await _erpRepository.getAllOverdueSchedules();
    
    // 2. تجميع الأقساط لكل عقد على حدة
    Map<String, List<InstallmentsScheduleData>> grouped = {};
    for (var s in allOverdueSchedules) {
       grouped.putIfAbsent(s.contractId, () =>[]).add(s);
    }

    List<OverdueContractAlert> alerts =[];
    final now = DateTime.now().toUtc();

    grouped.forEach((contractId, schedules) {
       final contractIdx = allContracts.indexWhere((c) => c.id == contractId);
       if (contractIdx == -1) return;
       final contract = allContracts[contractIdx];

       final clientIdx = allClients.indexWhere((c) => c.id == contract.clientId);
       if (clientIdx == -1) return;
       final client = allClients[clientIdx];

       // أقدم قسط متأخر (القائمة تأتي مرتبة، فالأول هو الأقدم)
       final oldestSchedule = schedules.first;
       final maxDaysOverdue = now.difference(oldestSchedule.dueDate).inDays;

       // تصنيف الخطورة
       String severity = 'notice'; // 🟡 أيام قليلة
       if (maxDaysOverdue >= 60) {
         severity = 'critical'; // 🔴 أكثر من شهرين
       } else if (maxDaysOverdue >= 30) {
         severity = 'warning'; // 🟠 أكثر من شهر
       }

       alerts.add(OverdueContractAlert(
          contract: contract,
          client: client,
          overdueSchedules: schedules,
          maxDaysOverdue: maxDaysOverdue,
          severity: severity,
       ));
    });

    // 3. الترتيب بحيث يظهر الأسوأ والأكثر تأخراً في أعلى القائمة
    alerts.sort((a, b) => b.maxDaysOverdue.compareTo(a.maxDaysOverdue));
    
    return alerts;
  }

  // ==========================================
  // 🧠 محرك التنبؤ الذكي للتخصص (Predictive Engine)
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

    // 8. ترتيب القائمة بحيث يظهر الأكثر خطورة في الأعلى
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

  // ==========================================
  // ⚙️ دالة جديدة لتعديل خصائص العقد من شاشة الجدول
  // ==========================================
  Future<void> updateContractSettings({
    required String id,
    required String details,
    required String guarantorName,
    required int installmentsCount,
    required DateTime contractDate,
  }) async {
    try {
      // 1. إرسال التعديلات للمستودع (والذي سيقوم آلياً بحذف الأقساط الزائدة)
      await _erpRepository.updateContract(
        id: id,
        apartmentDetails: details,
        guarantorName: guarantorName,
        installmentsCount: installmentsCount,
        contractDate: contractDate,
      );

      // 2. إعادة تحميل البيانات الأساسية لتحديث (الرادارات)
      await fetchInitialData();

      // 3. تحديث جدول الأقساط المعروض حالياً لتظهر التغييرات فوراً
      await selectContract(id);

    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: 'فشل تعديل الجدول: $e'));
    }
  }

  // ==========================================
  // 🔄 دالة إعادة الجدولة الذكية (Smart Restructuring)
  // ==========================================
  Future<void> restructureSchedule({
    required String contractId,
    required int newRemainingMonths,
    required DateTime newStartDate,
  }) async {
    try {
      // 1. استدعاء العملية الجراحية من المستودع
      await _erpRepository.restructureContractSchedule(
        contractId: contractId,
        newRemainingMonths: newRemainingMonths,
        newStartDate: newStartDate,
      );

      // 2. تحديث الإحصائيات والرادارات لأن مدة العقد الإجمالية تغيرت
      await fetchInitialData();

      // 3. تحديث جدول الأقساط المعروض حالياً لتظهر الأقساط الجديدة فوراً
      await selectContract(contractId);

    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: 'فشل إعادة الجدولة: $e'));
    }
  }


  // ==========================================
  // ✏️ تعديل تاريخ قسط فردي وإضافة ملاحظة
  // ==========================================
  Future<void> updateIndividualSchedule({
    required String scheduleId,
    required String contractId,
    required DateTime newDueDate,
    String? notes,
  }) async {
    try {
      await _erpRepository.updateIndividualSchedule(
        scheduleId: scheduleId,
        newDueDate: newDueDate,
        notes: notes,
      );
      
      // تحديث الجدول وإعادة حساب الرادارات (لأن التواريخ تغيرت)
      await fetchInitialData();
      await selectContract(contractId);

    } catch (e) {
      emit(state.copyWith(status: ScheduleStatus.failure, errorMessage: 'فشل تعديل القسط: $e'));
    }
  }


  
}
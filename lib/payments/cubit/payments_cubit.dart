// lib/payments/cubit/payments_cubit.dart
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart'; 
import 'package:drift/drift.dart' show Value;
import 'package:local_storage_api/local_storage_api.dart' show PaymentsLedgerCompanion, PaymentsLedgerData, Contract, Client, Apartment, Building, MaterialPricesHistoryCompanion, MaterialPricesHistoryData; 

import '../../core/utils/calculator_helper.dart';

part 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  PaymentsCubit(this._erpRepository) : super(const PaymentsState());

  final ErpRepository _erpRepository;

  // ==========================================
  // 1. التهيئة وجلب البيانات الأساسية
  // ==========================================
  Future<void> fetchInitialData() async {
    if (state.status == PaymentsStatus.initial) emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      final clients = await _erpRepository.getClients();
      final contracts = await _erpRepository.getAllContracts();
      final apartments = await _erpRepository.getAllApartments();
      final buildings = await _erpRepository.getBuildings();
      
      emit(state.copyWith(
        status: PaymentsStatus.success,
        clients: clients,
        contracts: contracts,
        apartments: apartments, 
        buildings: buildings,   
      ));
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> selectContract(String contractId) async {
    emit(state.copyWith(selectedContractId: contractId, status: PaymentsStatus.loading));
    try {
      // نفترض أن المستودع يرجع الدفعات مرتبة من الأحدث للأقدم!
      final ledgerEntries = await _erpRepository.getContractLedger(contractId);
      emit(state.copyWith(status: PaymentsStatus.success, ledgerEntries: ledgerEntries));
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // ⚙️ المحرك المركزي الذكي لتوليد الأقساط (Rolling Checkpoint Engine)
  // ==========================================
  Future<void> _autoAdvanceSchedule(String contractId, Contract contract, double paidAmount) async {
    // 1. جلب الأقساط المعلقة (التي ينتظرها الرادار)
    final schedules = await _erpRepository.getContractSchedule(contractId);
    final pendingSchedules = schedules.where((s) => s.status == 'pending').toList();
    
    if (pendingSchedules.isEmpty) return; // لا يوجد نقاط معلقة

    // 2. حساب كم شهر يغطي هذا المبلغ
    int monthsToAdvance = 1;
    if (contract.agreedMonthlyAmount > 0) {
      monthsToAdvance = (paidAmount / contract.agreedMonthlyAmount).floor();
      // حتى لو دفع دفعة جزئية (أقل من القسط)، سنتقدم شهراً لكي لا يتوقف الرادار، 
      // أو يمكنك تعديلها لتشترط سداد القسط كاملاً. حالياً جعلناها 1 كحد أدنى.
      if (monthsToAdvance < 1) monthsToAdvance = 1; 
    }

    // 3. التقدم للأمام وإغلاق الأشهر المستحقة
    for (int i = 0; i < monthsToAdvance; i++) {
      // نجلب الأقساط مجدداً في كل دورة لأننا نولد قسطاً جديداً
      final currentSchedules = await _erpRepository.getContractSchedule(contractId);
      final currentPending = currentSchedules.where((s) => s.status == 'pending').toList();
      if (currentPending.isEmpty) break;

      final targetSchedule = currentPending.first;
      // توليد تاريخ الشهر القادم
      final nextDueDate = DateTime.utc(targetSchedule.dueDate.year, targetSchedule.dueDate.month + 1, targetSchedule.dueDate.day);

      // هذه الدالة تغلق القسط الحالي بـ paid، وتولد قسطاً جديداً للشهر القادم!
      await _erpRepository.handleRollingCheckpoint(
        contractId: contractId,
        scheduleId: targetSchedule.id,
        actionType: 'paid',
        nextDueDate: nextDueDate,
      );
    }
  }

  // ==========================================
  // 🌟 دالة الإضافة المعدلة لتدعم (الوضع الطبيعي / القديم السريع / القديم التفصيلي)
  // ==========================================
  Future<void> addLedgerEntry({
    required String contractId, 
    required double amountPaid,
    double discountPercentage = 0, 
    String? scheduleId, 
    DateTime? customDate, // 🌟 تاريخ الدفعة القديمة
    double? customMeterPrice, // 🌟 سعر المتر المُدخل يدوياً للسرعة
    // 🌟 حقول المواد للحالة التفصيلية
    double? histIron, double? histCement, double? histBlock, 
    double? histFormwork, double? histAggregates, double? histWorker,
  }) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      final contractIndex = state.contracts.indexWhere((c) => c.id == contractId);
      if (contractIndex == -1) throw Exception('هذا العقد غير موجود.');
      final contract = state.contracts[contractIndex];

      final String? userId = _erpRepository.currentUserId;
      if (userId == null) throw Exception('يجب تسجيل الدخول.');

      // جلب معاملات العقد (التي تؤثر على سعر المتر)
      Map<String, double> contractCoefficients = {};
      try {
        if (contract.coefficients.isNotEmpty && contract.coefficients != '{}') {
          contractCoefficients = jsonDecode(contract.coefficients).map<String, double>((key, value) => MapEntry(key, (value as num).toDouble()));
        }
      } catch (_) {}

      // 🌍 تحديد تاريخ الدفعة الفعلي
      final paymentDateToSave = customDate?.toUtc() ?? DateTime.now().toUtc();
      
      double meterPriceToUse = 0.0;
      String pricesSnapshotJson = '{}';

      // 🧠 المحرك الذكي لتحديد السعر واللقطة (Snapshot):
      if (customDate != null && customMeterPrice != null && histIron == null) {
        // ----------------------------------------------------
        // 🚀 الحالة 1: دفعة قديمة (سريعة) - تم إدخال سعر المتر مباشرة
        // ----------------------------------------------------
        meterPriceToUse = customMeterPrice;
        pricesSnapshotJson = jsonEncode({
          'note': 'إدخال تاريخي سريع',
          'manual_meter_price': customMeterPrice
        });
        
      } else if (customDate != null && histIron != null) {
        // ----------------------------------------------------
        // 🛠️ الحالة 2: دفعة قديمة (تفصيلية) - تم إدخال مواد لتُحفظ في السجل
        // ----------------------------------------------------
        final historicalPrices = MaterialPricesHistoryCompanion.insert(
          effectiveDate: Value(paymentDateToSave), 
          ironPrice: histIron, cementPrice: histCement!, block15Price: histBlock!,
          formworkAndPouringWages: histFormwork!, aggregateMaterialsPrice: histAggregates!,
          ordinaryWorkerWage: histWorker!, userId: userId,
        );
        
        // 1. حفظ التسعيرة رسمياً في الإعدادات
        await _erpRepository.savePrices(historicalPrices);

        // 2. إنشاء كائن وهمي لتمريره للحاسبة
        final targetPrices = MaterialPricesHistoryData(
          id: 'dummy', effectiveDate: paymentDateToSave, ironPrice: histIron,
          cementPrice: histCement, block15Price: histBlock, formworkAndPouringWages: histFormwork,
          aggregateMaterialsPrice: histAggregates, ordinaryWorkerWage: histWorker,
          userId: userId, createdAt: DateTime.now(), updatedAt: DateTime.now(),
          isDeleted: false, isSynced: false,
        );

        // 3. حساب السعر النهائي بناءً على معاملات العقد والمواد القديمة
        final calculations = CalculatorHelper.calculateContractValues(
          area: contract.totalArea, currentPrices: targetPrices, coefficients: contractCoefficients,
        );
        
        meterPriceToUse = calculations['pricePerSqm']!;
        pricesSnapshotJson = jsonEncode({
          'iron': histIron, 'cement': histCement, 'block': histBlock,
          'formwork': histFormwork, 'aggregates': histAggregates, 'worker': histWorker,
        });

      } else {
        // ----------------------------------------------------
        // 🟢 الحالة 3: الوضع الطبيعي (دفعة اليوم)
        // ----------------------------------------------------
        final currentPrices = await _erpRepository.getLatestPrices();
        if (currentPrices == null) throw Exception('يرجى إضافة أسعار المواد أولاً في الإعدادات.');
        
        final calculations = CalculatorHelper.calculateContractValues(
          area: contract.totalArea, currentPrices: currentPrices, coefficients: contractCoefficients,
        );
        
        meterPriceToUse = calculations['pricePerSqm']!;
        pricesSnapshotJson = jsonEncode({
          'iron': currentPrices.ironPrice, 'cement': currentPrices.cementPrice, 'block': currentPrices.block15Price,
          'formwork': currentPrices.formworkAndPouringWages, 'aggregates': currentPrices.aggregateMaterialsPrice,
          'worker': currentPrices.ordinaryWorkerWage,
        });
      }

      // 💰 الحساب المالي الموحد
      final double effectiveAmount = amountPaid + (amountPaid * (discountPercentage / 100));
      final double convertedMeters = effectiveAmount / meterPriceToUse;

      // 💾 حفظ الدفعة
      final newEntry = PaymentsLedgerCompanion.insert(
        contractId: contractId,
        scheduleId: scheduleId != null ? Value(scheduleId) : const Value.absent(), 
        paymentDate: paymentDateToSave, // 🌍 التاريخ المعالج
        amountPaid: amountPaid, 
        meterPriceAtPayment: meterPriceToUse, // 💰 السعر المعالج
        convertedMeters: convertedMeters, 
        pricesSnapshot: Value(pricesSnapshotJson), 
        fees: Value(discountPercentage), 
        userId: userId,
      );
      
      await _erpRepository.addLedgerEntry(newEntry);
      
      // 🌟 السحر الحقيقي: بمجرد الحفظ، نقوم بتحريك عجلة الزمن للأمام في صفحة المراقبة!
      await _autoAdvanceSchedule(contractId, contract, effectiveAmount);
      
      await selectContract(contractId);
      
      _erpRepository.forceSyncWithCloud().catchError((e) => print('Sync Error: $e'));
      
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }


  // ==========================================
  // 3. ✏️ تعديل دفعة (بصلاحيات الإدارة) - يُستخدم للقيود القديمة
  // ==========================================
  Future<void> editOldLedgerEntry({
    required PaymentsLedgerData entryToEdit,
    required double newAmountPaid,
    required double newDiscountPercentage,
  }) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      final contract = state.contracts.firstWhere((c) => c.id == entryToEdit.contractId);

      // 🌟 الحساب المالي الدقيق: 
      // نحن نعدل قيمة المبلغ فقط، لكننا نستخدم *سعر المتر القديم* المحفوظ في الإيصال 
      // لكي لا نفسد الدفعة بأسعار اليوم!
      final double effectiveAmount = newAmountPaid + (newAmountPaid * (newDiscountPercentage / 100));
      final double newConvertedMeters = effectiveAmount / entryToEdit.meterPriceAtPayment;

      // تحديث القاعدة
      await _erpRepository.updateLedgerEntryAmount(
        entryId: entryToEdit.id,
        newAmount: newAmountPaid,
        newDiscount: newDiscountPercentage,
        newConvertedMeters: newConvertedMeters,
      );


      await selectContract(entryToEdit.contractId); // تحديث الواجهة
      _erpRepository.forceSyncWithCloud().catchError((e) => print('Sync Error: $e'));

    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: 'فشل تعديل الدفعة: $e'));
    }
  }

  // ==========================================
  // 4. 🗑️ حذف "آخر دفعة فقط" (خطأ لحظي)
  // ==========================================
  Future<void> softDeleteLastEntry(PaymentsLedgerData entryToDelete) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      // 1. الحماية المالية: التأكد أن هذه الدفعة هي "الأحدث" ترتيباً
      final allEntriesForContract = await _erpRepository.getContractLedger(entryToDelete.contractId);
      
      // نفترض أن القائمة مرتبة بحيث العنصر 0 هو الأحدث
      if (allEntriesForContract.isEmpty || allEntriesForContract.first.id != entryToDelete.id) {
        throw Exception('تحذير مالي: لا يمكن حذف دفعة قديمة، يمكنك فقط تعديل قيمتها بصلاحيات الإدارة. يسمح بحذف آخر دفعة فقط.');
      }

      final contract = state.contracts.firstWhere((c) => c.id == entryToDelete.contractId);

      // 2. الحذف الوهمي (Soft Delete)
      await _erpRepository.softDeleteLedgerEntry(entryToDelete.id);


      await selectContract(entryToDelete.contractId);
      _erpRepository.forceSyncWithCloud().catchError((e) => print('Sync Error: $e'));

    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // 5. 🗑️ سلة المحذوفات (الإيصالات الملغاة)
  // ==========================================
  Future<void> fetchDeletedEntries() async {
    try {
      final deleted = await _erpRepository.getDeletedLedgerEntries();
      emit(state.copyWith(deletedLedgerEntries: deleted));
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> restoreLedgerEntry(PaymentsLedgerData entry) async {
    try {
      await _erpRepository.restoreLedgerEntry(entry.id);
      
      final contract = state.contracts.firstWhere((c) => c.id == entry.contractId);
      

      await fetchDeletedEntries(); // تحديث السلة
      await selectContract(entry.contractId); // تحديث الواجهة الأم
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> hardDeleteLedgerEntry(String entryId) async {
    try {
      await _erpRepository.forceHardDeleteLedgerEntry(entryId);
      await fetchDeletedEntries();
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  // ==========================================
  // واتساب
  // ==========================================
  Future<void> markAsSent(String entryId, String contractId) async {
    try {
      await _erpRepository.markWhatsAppAsSent(entryId);
      await _erpRepository.syncPendingData(); 
      await selectContract(contractId);
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: 'فشل في تحديث حالة الواتساب: $e'));
    }
  }
}
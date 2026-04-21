// lib/payments/cubit/payments_cubit.dart
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart'; 
import 'package:drift/drift.dart' show Value;

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
  // ⚙️ المحرك المحاسبي المركزي (إعادة وزن الأقساط)
  // ==========================================
  /// يتم استدعاء هذه الدالة بعد (إضافة، تعديل، حذف، أو استعادة) أي دفعة 
  /// لتقوم بجمع الأمتار من الصفر وإعادة توزيع الأقساط المستحقة برمجياً.
  Future<void> _recalculateInstallmentsStatus(String contractId, Contract contract) async {
    // 1. جلب كل الدفعات "السليمة" فقط
    final allEntries = await _erpRepository.getContractLedger(contractId);
    
    // 2. جمع كل الأمتار المحولة
    double totalConvertedMetersAccumulated = allEntries.fold(0, (sum, item) => sum + item.convertedMeters);

    // 3. حساب كم شهر تم تسديده بالكامل
    final int monthsCount = contract.installmentsCount > 0 ? contract.installmentsCount : 48;
    final double requiredMetersPerMonth = contract.totalArea / monthsCount;
    final int fullyPaidMonths = (totalConvertedMetersAccumulated / requiredMetersPerMonth).floor();
    
    // 4. جلب الأقساط وإعادة ضبط حالتها
    final schedules = await _erpRepository.getContractSchedule(contractId);

    for (var schedule in schedules) {
      String targetStatus = (schedule.installmentNumber <= fullyPaidMonths) ? 'paid' : 'pending';
      // تحديث فقط إذا كانت الحالة تحتاج لتغيير لتقليل استهلاك قاعدة البيانات
      if (schedule.status != targetStatus) {
        await _erpRepository.updateScheduleStatus(schedule.id, targetStatus);
      }
    }
  }

  // ==========================================
  // 2. إضافة دفعة جديدة
  // ==========================================
  Future<void> addLedgerEntry({
    required String contractId, 
    required double amountPaid,
    double discountPercentage = 0, 
    String? scheduleId, 
  }) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      final contractIndex = state.contracts.indexWhere((c) => c.id == contractId);
      if (contractIndex == -1) throw Exception('هذا العقد غير موجود.');
      final contract = state.contracts[contractIndex];

      final currentPrices = await _erpRepository.getLatestPrices();
      if (currentPrices == null) throw Exception('يرجى إضافة أسعار المواد أولاً.');

      final String? userId = _erpRepository.currentUserId;
      if (userId == null) throw Exception('يجب تسجيل الدخول.');

      Map<String, double> contractCoefficients = {};
      try {
        if (contract.coefficients.isNotEmpty && contract.coefficients != '{}') {
          contractCoefficients = jsonDecode(contract.coefficients).map<String, double>((key, value) => MapEntry(key, (value as num).toDouble()));
        }
      } catch (_) {}

      final calculations = CalculatorHelper.calculateContractValues(
        area: contract.totalArea,
        currentPrices: currentPrices,
        coefficients: contractCoefficients,
      );
      
      final double meterPriceToday = calculations['pricePerSqm']!;
      final double effectiveAmount = amountPaid + (amountPaid * (discountPercentage / 100));
      final double convertedMeters = effectiveAmount / meterPriceToday;

      final String pricesSnapshotJson = jsonEncode({
        'iron': currentPrices.ironPrice,
        'cement': currentPrices.cementPrice,
        'block': currentPrices.block15Price,
        'formwork': currentPrices.formworkAndPouringWages,
        'aggregates': currentPrices.aggregateMaterialsPrice,
        'worker': currentPrices.ordinaryWorkerWage,
      });

      final newEntry = PaymentsLedgerCompanion.insert(
        contractId: contractId,
        scheduleId: scheduleId != null ? Value(scheduleId) : const Value.absent(), 
        paymentDate: DateTime.now().toUtc(),
        amountPaid: amountPaid, 
        meterPriceAtPayment: meterPriceToday, 
        convertedMeters: convertedMeters, 
        pricesSnapshot: Value(pricesSnapshotJson), 
        fees: Value(discountPercentage), 
        userId: userId,
      );
      
      await _erpRepository.addLedgerEntry(newEntry);

      // 🌟 تشغيل المحرك المركزي
      await _recalculateInstallmentsStatus(contractId, contract);

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

      // 🌟 تشغيل المحرك المركزي لإعادة توزيع الأقساط بعد تعديل الأمتار
      await _recalculateInstallmentsStatus(entryToEdit.contractId, contract);

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

      // 3. 🌟 تشغيل المحرك المركزي (لأن الأمتار نقصت، يجب أن تعود بعض الأقساط إلى pending)
      await _recalculateInstallmentsStatus(entryToDelete.contractId, contract);

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
      
      // 🌟 تشغيل المحرك المركزي لأن الأمتار رجعت!
      await _recalculateInstallmentsStatus(entry.contractId, contract);

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
// lib/payments/cubit/payments_cubit.dart
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart'; // 🌟 التعديل هنا: أزلنا كلمة show
import 'package:drift/drift.dart' show Value;

import '../../core/utils/calculator_helper.dart';

part 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  PaymentsCubit(this._erpRepository) : super(const PaymentsState());

  final ErpRepository _erpRepository;

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
      final ledgerEntries = await _erpRepository.getContractLedger(contractId);
      emit(state.copyWith(status: PaymentsStatus.success, ledgerEntries: ledgerEntries));
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

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
      if (currentPrices == null) {
        throw Exception('يرجى إضافة أسعار المواد من شاشة الإعدادات أولاً.');
      }

      // 🌟 [الكود الجديد]: تجهيز لقطة الأسعار بصيغة JSON
      final String pricesSnapshotJson = jsonEncode({
        'iron': currentPrices.ironPrice,
        'cement': currentPrices.cementPrice,
        'block': currentPrices.block15Price,
        'formwork': currentPrices.formworkAndPouringWages,
        'aggregates': currentPrices.aggregateMaterialsPrice,
        'worker': currentPrices.ordinaryWorkerWage,
      });

      final String? userId = _erpRepository.currentUserId;
      if (userId == null) throw Exception('يجب تسجيل الدخول لضمان مزامنة البيانات.');

      Map<String, double> contractCoefficients = {};
      try {
        if (contract.coefficients.isNotEmpty && contract.coefficients != '{}') {
          final Map<String, dynamic> decoded = jsonDecode(contract.coefficients);
          contractCoefficients = decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
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

      final newEntry = PaymentsLedgerCompanion.insert(
        contractId: contractId,
        scheduleId: scheduleId != null ? Value(scheduleId) : const Value.absent(), 
        paymentDate: DateTime.now(),
        amountPaid: amountPaid, 
        meterPriceAtPayment: meterPriceToday, 
        convertedMeters: convertedMeters, 
        pricesSnapshot: Value(pricesSnapshotJson), // 🌟 الحقل الجديد هنا
        fees: Value(discountPercentage), 
        userId: userId,
      );

      // 🌟 [السطر الجديد]: حقن اللقطة في قاعدة البيانات
        pricesSnapshot: Value(pricesSnapshotJson), 
      
      await _erpRepository.addLedgerEntry(newEntry);

      final allEntries = await _erpRepository.getContractLedger(contractId);
      double totalConvertedMetersAccumulated = allEntries.fold(0, (sum, item) => sum + item.convertedMeters);

      final int monthsCount = contract.installmentsCount > 0 ? contract.installmentsCount : 48;
      final double requiredMetersPerMonth = contract.totalArea / monthsCount;
      final int fullyPaidMonths = (totalConvertedMetersAccumulated / requiredMetersPerMonth).floor();
      
      final schedules = await _erpRepository.getContractSchedule(contractId);

      for (var schedule in schedules) {
        String targetStatus = (schedule.installmentNumber <= fullyPaidMonths) ? 'paid' : 'pending';
        if (schedule.status != targetStatus) {
          await _erpRepository.updateScheduleStatus(schedule.id, targetStatus);
        }
      }

      await _erpRepository.forceSyncWithCloud();
      await selectContract(contractId);
      
    } catch (e) {
      print('خطأ في إضافة الدفعة: $e');
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

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
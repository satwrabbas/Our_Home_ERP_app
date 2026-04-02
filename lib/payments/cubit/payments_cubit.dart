import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show PaymentsLedgerCompanion;
import 'package:drift/drift.dart' show Value;

// استدعاء الحاسبة الهندسية التي تجلب معادلات الإكسل
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
      
      emit(state.copyWith(
        status: PaymentsStatus.success,
        clients: clients,
        contracts: contracts,
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

  /// 3. 🌟 جوهر النظام المالي: إضافة دفعة وتحديث جدول المراقبة آلياً (الخوارزمية الذكية)
  Future<void> addLedgerEntry({
    required String contractId, 
    required double amountPaid,
    double fees = 0,
    String? scheduleId, 
  }) async {
    emit(state.copyWith(status: PaymentsStatus.loading));
    try {
      // 🌟 حماية ضد العقود المفقودة
      final contractIndex = state.contracts.indexWhere((c) => c.id == contractId);
      if (contractIndex == -1) {
        throw Exception('هذا العقد غير موجود أو تم حذفه.');
      }
      final contract = state.contracts[contractIndex];

      final currentPrices = await _erpRepository.getLatestPrices();
      if (currentPrices == null) {
        throw Exception('يرجى إضافة أسعار المواد من شاشة الإعدادات أولاً لحساب سعر المتر اليوم.');
      }

      Map<String, double> contractCoefficients = {};
      try {
        if (contract.coefficients.isNotEmpty && contract.coefficients != '{}') {
          final Map<String, dynamic> decoded = jsonDecode(contract.coefficients);
          contractCoefficients = decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
        }
      } catch (e) {
        print('تحذير: حدث خطأ أثناء قراءة نسب العقد: $e');
      }

      // حساب سعر المتر بناءً على السوق اليوم ومعاملات العقد
      final calculations = CalculatorHelper.calculateContractValues(
        area: contract.totalArea,
        currentPrices: currentPrices,
        coefficients: contractCoefficients,
      );
      final double meterPriceToday = calculations['pricePerSqm']!;

      // حساب عدد الأمتار لهذه الدفعة
      final double convertedMeters = amountPaid / meterPriceToday;

      // 1. حفظ الدفعة في دفتر الأستاذ
      final newEntry = PaymentsLedgerCompanion.insert(
        contractId: contractId,
        scheduleId: scheduleId != null ? Value(scheduleId) : const Value.absent(), 
        paymentDate: DateTime.now(),
        amountPaid: amountPaid,
        meterPriceAtPayment: meterPriceToday, 
        convertedMeters: convertedMeters,     
        fees: Value(fees),
        userId: '', 
      );
      await _erpRepository.addLedgerEntry(newEntry);

      // 2. تحديث جدول المراقبة آلياً
      final allEntries = await _erpRepository.getContractLedger(contractId);
      double totalConvertedMetersAccumulated = 0;
      for (var entry in allEntries) {
        totalConvertedMetersAccumulated += entry.convertedMeters;
      }

      final int monthsCount = contract.installmentsCount > 0 ? contract.installmentsCount : 48;
      final double requiredMetersPerMonth = contract.totalArea / monthsCount;
      final int fullyPaidMonths = (totalConvertedMetersAccumulated / requiredMetersPerMonth).floor();
      final schedules = await _erpRepository.getContractSchedule(contractId);

      for (var schedule in schedules) {
        if (schedule.installmentNumber <= fullyPaidMonths) {
          if (schedule.status != 'paid') {
            await _erpRepository.updateScheduleStatus(schedule.id, 'paid');
          }
        } else {
          if (schedule.status != 'pending') {
            await _erpRepository.updateScheduleStatus(schedule.id, 'pending');
          }
        }
      }

      await selectContract(contractId);
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> markAsSent(String entryId, String contractId) async {
    try {
      await _erpRepository.markWhatsAppAsSent(entryId);
      await selectContract(contractId);
    } catch (e) {
      emit(state.copyWith(status: PaymentsStatus.failure, errorMessage: 'فشل في تحديث حالة الواتساب: $e'));
    }
  }
}
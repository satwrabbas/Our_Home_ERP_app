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

  /// جلب العملاء والعقود الفعالة (غير المحذوفة) لعرضها في الجدول
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

  /// 🌟 إضافة عقد جديد (يدعم تحديد عدد أشهر التقسيط واسم الكفيل)
  Future<void> addContract({
    required String clientId, 
    required String contractType, 
    required String details,
    required double area,
    required double basePrice,
    required int installmentsCount, 
    required String guarantorName, // 🌟 الحقل الجديد (اسم الكفيل)
    Map<String, dynamic> coefficients = const {}, 
  }) async {
    emit(state.copyWith(status: ContractsStatus.loading)); // إظهار التحميل أثناء الحفظ
    try {
      // 🚨 تأمين الـ userId لضمان المزامنة السحابية (RLS)
      final String? userId = _erpRepository.currentUserId;
      if (userId == null) throw Exception('يجب تسجيل الدخول أولاً لإنشاء العقود.');

      final newContract = ContractsCompanion.insert(
        clientId: clientId,
        contractType: Value(contractType),
        apartmentDetails: details,
        totalArea: area,
        baseMeterPriceAtSigning: basePrice,
        installmentsCount: Value(installmentsCount), 
        coefficients: Value(jsonEncode(coefficients)),
        contractDate: DateTime.now(),
        guarantorName: guarantorName, // 🌟 حفظ اسم الكفيل
        userId: userId, // 🌟 تم الإصلاح هنا
        // contractFileUrl: يُترك فارغاً بشكل افتراضي لأننا سنرفعه لاحقاً عبر الزر
      );
      
      await _erpRepository.addContract(newContract);
      await fetchData(); // تحديث الشاشة بعد الحفظ
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// 🌟 دالة جديدة: إرفاق ملف العقد (Word/PDF)
  Future<void> attachContractFile({
    required String contractId,
    required String filePath,
    required String extension,
  }) async {
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      final file = File(filePath);
      
      // استدعاء دالة الرفع التي أضفناها في المستودع
      await _erpRepository.attachFileToContract(contractId, file, extension);
      
      // إعادة جلب البيانات لكي يتحول الزر في الشاشة من (إرفاق) إلى (فتح العقد)
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: 'فشل إرفاق الملف: $e'));
    }
  }

  /// إلغاء العقد (حذف مؤقت Soft Delete)
  Future<void> deleteContract(String id) async { 
    emit(state.copyWith(status: ContractsStatus.loading));
    try {
      await _erpRepository.deleteContract(id);
      await fetchData(); 
    } catch (e) {
      emit(state.copyWith(status: ContractsStatus.failure, errorMessage: e.toString()));
    }
  }
}
//lib\buildings\cubit\buildings_cubit.dart
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:erp_repository/erp_repository.dart';
import 'package:local_storage_api/local_storage_api.dart' show BuildingsCompanion, ApartmentsCompanion, Building, Apartment;
import 'package:drift/drift.dart' show Value;

part 'buildings_state.dart';

class BuildingsCubit extends Cubit<BuildingsState> {
  BuildingsCubit(this._erpRepository) : super(const BuildingsState());

  final ErpRepository _erpRepository;

  /// جلب كل المحاضر والشقق من القاعدة المحلية
  Future<void> loadData() async {
    emit(state.copyWith(status: BuildingsStatus.loading));
    try {
      final buildings = await _erpRepository.getBuildings();
      final apartments = await _erpRepository.getAllApartments();
      emit(state.copyWith(status: BuildingsStatus.success, buildings: buildings, apartments: apartments));
    } catch (e) {
      emit(state.copyWith(status: BuildingsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// إضافة محضر جديد (مبنى)
  Future<void> addBuilding({
    required String name,
    required String location,
    Map<String, double> floorCoeffs = const {},
    Map<String, double> dirCoeffs = const {},
  }) async {
    try {
      final building = BuildingsCompanion.insert(
        name: name, // تم التصحيح
        location: Value(location),
        floorCoefficients: Value(jsonEncode(floorCoeffs)),
        directionCoefficients: Value(jsonEncode(dirCoeffs)),
        userId: const Value(''), // تم التصحيح إلى Value
      );
      await _erpRepository.addBuilding(building);
      await loadData();
    } catch (e) {
      emit(state.copyWith(status: BuildingsStatus.failure, errorMessage: e.toString()));
    }
  }

  /// إضافة شقة داخل محضر
  Future<void> addApartment({
    required String buildingId,
    required String aptNumber,
    required double area,
    required String floorName,
    required String directionName,
    Map<String, double> customCoeffs = const {},
  }) async {
    try {
      final apartment = ApartmentsCompanion.insert(
        buildingId: buildingId,
        apartmentNumber: aptNumber,
        area: area,
        floorName: floorName,
        directionName: directionName, // تم التصحيح (بدون Value)
        customCoefficients: Value(jsonEncode(customCoeffs)),
        status: const Value('available'), 
        userId: const Value(''),
      );
      await _erpRepository.addApartment(apartment);
      await loadData(); 
    } catch (e) {
      emit(state.copyWith(status: BuildingsStatus.failure, errorMessage: e.toString()));
    }
  }
}
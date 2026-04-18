//lib\buildings\cubit\buildings_state.dart
part of 'buildings_cubit.dart';

enum BuildingsStatus { initial, loading, success, failure }

class BuildingsState extends Equatable {
  const BuildingsState({
    this.status = BuildingsStatus.initial,
    this.buildings = const [],
    this.apartments = const[],
    this.errorMessage,
  });

  final BuildingsStatus status;
  final List<Building> buildings;
  final List<Apartment> apartments;
  final String? errorMessage;

  BuildingsState copyWith({
    BuildingsStatus? status,
    List<Building>? buildings,
    List<Apartment>? apartments,
    String? errorMessage,
  }) {
    return BuildingsState(
      status: status ?? this.status,
      buildings: buildings ?? this.buildings,
      apartments: apartments ?? this.apartments,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>[status, buildings, apartments, errorMessage];
}
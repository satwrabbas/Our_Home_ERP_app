//lib\settings\cubit\settings_state.dart
part of 'settings_cubit.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,
    this.currentPrices, // هنا أصبح النوع MaterialPricesHistoryData
    this.errorMessage,
  });

  final SettingsStatus status;
  final MaterialPricesHistoryData? currentPrices;
  final String? errorMessage;

  SettingsState copyWith({
    SettingsStatus? status,
    MaterialPricesHistoryData? currentPrices,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      currentPrices: currentPrices ?? this.currentPrices,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>[status, currentPrices, errorMessage];
}
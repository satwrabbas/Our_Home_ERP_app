//lib\settings\cubit\settings_state.dart
part of 'settings_cubit.dart';

enum SettingsStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,
    this.currentPrices,
    this.priceHistory = const[], // 🌟 القائمة التي أضفناها
    this.errorMessage,
  });

  final SettingsStatus status;
  final MaterialPricesHistoryData? currentPrices;
  final List<MaterialPricesHistoryData> priceHistory; // 🌟
  final String? errorMessage;

  SettingsState copyWith({
    SettingsStatus? status,
    MaterialPricesHistoryData? currentPrices,
    List<MaterialPricesHistoryData>? priceHistory, // 🌟
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      currentPrices: currentPrices ?? this.currentPrices,
      priceHistory: priceHistory ?? this.priceHistory, // 🌟
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>[status, currentPrices, priceHistory, errorMessage];
}
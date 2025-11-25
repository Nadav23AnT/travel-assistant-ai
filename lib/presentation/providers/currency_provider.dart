import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';
import '../../services/currency_service.dart';

// ============================================
// SERVICE PROVIDER
// ============================================

/// Currency Service provider
final currencyServiceProvider = Provider<CurrencyService>((ref) {
  final service = CurrencyService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ============================================
// EXCHANGE RATES CACHE
// ============================================

/// State for exchange rates with caching
class ExchangeRatesState {
  final Map<String, double> rates;
  final String baseCurrency;
  final DateTime lastUpdated;
  final bool isLoading;
  final String? error;

  const ExchangeRatesState({
    this.rates = const {},
    this.baseCurrency = 'USD',
    required this.lastUpdated,
    this.isLoading = false,
    this.error,
  });

  /// Check if rates are stale (older than 1 hour)
  bool get isStale {
    return DateTime.now().difference(lastUpdated).inHours >= 1;
  }

  ExchangeRatesState copyWith({
    Map<String, double>? rates,
    String? baseCurrency,
    DateTime? lastUpdated,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ExchangeRatesState(
      rates: rates ?? this.rates,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Notifier for managing exchange rates
class ExchangeRatesNotifier extends StateNotifier<ExchangeRatesState> {
  final CurrencyService _service;

  ExchangeRatesNotifier(this._service)
      : super(ExchangeRatesState(lastUpdated: DateTime.fromMillisecondsSinceEpoch(0)));

  /// Fetch exchange rates for a base currency
  Future<void> fetchRates(String baseCurrency) async {
    // Skip if same currency and rates are fresh
    if (state.baseCurrency == baseCurrency &&
        state.rates.isNotEmpty &&
        !state.isStale) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final rates = await _service.getExchangeRates(baseCurrency);
      state = ExchangeRatesState(
        rates: rates,
        baseCurrency: baseCurrency,
        lastUpdated: DateTime.now(),
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Error fetching exchange rates: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Convert amount using cached rates
  double convert(double amount, String from, String to) {
    if (from == to) return amount;
    if (state.rates.isEmpty) return amount;

    return _service.convertSync(amount, from, to, state.rates);
  }

  /// Force refresh rates
  Future<void> refresh() async {
    state = state.copyWith(
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(0),
    );
    await fetchRates(state.baseCurrency);
  }
}

/// Provider for exchange rates
final exchangeRatesProvider =
    StateNotifierProvider<ExchangeRatesNotifier, ExchangeRatesState>((ref) {
  final service = ref.watch(currencyServiceProvider);
  return ExchangeRatesNotifier(service);
});

// ============================================
// CONVENIENCE PROVIDERS
// ============================================

/// Provider to get rates for a specific base currency
final exchangeRatesForCurrencyProvider =
    FutureProvider.family<Map<String, double>, String>((ref, baseCurrency) async {
  final service = ref.watch(currencyServiceProvider);
  return service.getExchangeRates(baseCurrency);
});

/// Provider to convert a specific amount
final convertAmountProvider =
    FutureProvider.family<double, ConversionRequest>((ref, request) async {
  final service = ref.watch(currencyServiceProvider);
  return service.convert(request.amount, request.from, request.to);
});

/// Request object for currency conversion
class ConversionRequest {
  final double amount;
  final String from;
  final String to;

  const ConversionRequest({
    required this.amount,
    required this.from,
    required this.to,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversionRequest &&
        other.amount == amount &&
        other.from == from &&
        other.to == to;
  }

  @override
  int get hashCode => Object.hash(amount, from, to);
}

/// Provider to get available currencies
final availableCurrenciesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(currencyServiceProvider);
  return service.getAvailableCurrencies();
});

// ============================================
// USER HOME CURRENCY PROVIDER
// ============================================

/// Provider for user's home currency (from profile)
/// This is a StateProvider that can be updated when loaded from DB
final userHomeCurrencyProvider = StateProvider<String>((ref) => 'USD');

/// Provider to load and set user's home currency from profile
/// Call this after authentication to initialize the currency
final loadUserHomeCurrencyProvider = FutureProvider<String>((ref) async {
  final authService = AuthService();
  final currency = await authService.getUserDefaultCurrency();

  if (currency != null && currency.isNotEmpty) {
    // Update the state provider with loaded value
    ref.read(userHomeCurrencyProvider.notifier).state = currency;
    return currency;
  }

  return 'USD';
});

/// Provider to initialize user currency on app startup
/// Should be watched in the app's root widget after auth
final initUserCurrencyProvider = FutureProvider<void>((ref) async {
  await ref.watch(loadUserHomeCurrencyProvider.future);
});

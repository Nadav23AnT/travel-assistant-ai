import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';
import '../../services/currency_service.dart';

// ============================================
// CURRENCY DISPLAY MODE
// ============================================

/// Enum for currency display options in expenses screen
enum CurrencyDisplayMode {
  home,  // User's home currency from profile
  usd,   // Always USD
  local, // Local currency based on trip destination
}

// ============================================
// DESTINATION TO CURRENCY MAPPING
// ============================================

/// Maps common travel destinations to their local currency codes
/// This is used to determine the "local" currency based on trip destination
class DestinationCurrencyMapper {
  static const Map<String, String> _countryToCurrency = {
    // Asia
    'thailand': 'THB',
    'thai': 'THB',
    'bangkok': 'THB',
    'phuket': 'THB',
    'chiang mai': 'THB',
    'japan': 'JPY',
    'tokyo': 'JPY',
    'osaka': 'JPY',
    'kyoto': 'JPY',
    'china': 'CNY',
    'beijing': 'CNY',
    'shanghai': 'CNY',
    'hong kong': 'HKD',
    'singapore': 'SGD',
    'malaysia': 'MYR',
    'kuala lumpur': 'MYR',
    'indonesia': 'IDR',
    'bali': 'IDR',
    'jakarta': 'IDR',
    'vietnam': 'VND',
    'hanoi': 'VND',
    'ho chi minh': 'VND',
    'philippines': 'PHP',
    'manila': 'PHP',
    'south korea': 'KRW',
    'korea': 'KRW',
    'seoul': 'KRW',
    'india': 'INR',
    'mumbai': 'INR',
    'delhi': 'INR',
    'taiwan': 'TWD',
    'taipei': 'TWD',

    // Europe
    'france': 'EUR',
    'paris': 'EUR',
    'germany': 'EUR',
    'berlin': 'EUR',
    'munich': 'EUR',
    'italy': 'EUR',
    'rome': 'EUR',
    'milan': 'EUR',
    'venice': 'EUR',
    'florence': 'EUR',
    'spain': 'EUR',
    'madrid': 'EUR',
    'barcelona': 'EUR',
    'portugal': 'EUR',
    'lisbon': 'EUR',
    'netherlands': 'EUR',
    'amsterdam': 'EUR',
    'belgium': 'EUR',
    'brussels': 'EUR',
    'austria': 'EUR',
    'vienna': 'EUR',
    'greece': 'EUR',
    'athens': 'EUR',
    'ireland': 'EUR',
    'dublin': 'EUR',
    'finland': 'EUR',
    'helsinki': 'EUR',
    'uk': 'GBP',
    'united kingdom': 'GBP',
    'england': 'GBP',
    'london': 'GBP',
    'scotland': 'GBP',
    'edinburgh': 'GBP',
    'switzerland': 'CHF',
    'zurich': 'CHF',
    'geneva': 'CHF',
    'sweden': 'SEK',
    'stockholm': 'SEK',
    'norway': 'NOK',
    'oslo': 'NOK',
    'denmark': 'DKK',
    'copenhagen': 'DKK',
    'poland': 'PLN',
    'warsaw': 'PLN',
    'krakow': 'PLN',
    'czech': 'CZK',
    'prague': 'CZK',
    'hungary': 'HUF',
    'budapest': 'HUF',
    'turkey': 'TRY',
    'istanbul': 'TRY',
    'russia': 'RUB',
    'moscow': 'RUB',

    // Americas
    'usa': 'USD',
    'united states': 'USD',
    'new york': 'USD',
    'los angeles': 'USD',
    'san francisco': 'USD',
    'miami': 'USD',
    'las vegas': 'USD',
    'hawaii': 'USD',
    'canada': 'CAD',
    'toronto': 'CAD',
    'vancouver': 'CAD',
    'montreal': 'CAD',
    'mexico': 'MXN',
    'cancun': 'MXN',
    'mexico city': 'MXN',
    'brazil': 'BRL',
    'rio': 'BRL',
    'sao paulo': 'BRL',
    'argentina': 'ARS',
    'buenos aires': 'ARS',
    'colombia': 'COP',
    'bogota': 'COP',
    'peru': 'PEN',
    'lima': 'PEN',
    'chile': 'CLP',
    'santiago': 'CLP',

    // Middle East
    'israel': 'ILS',
    'tel aviv': 'ILS',
    'jerusalem': 'ILS',
    'uae': 'AED',
    'dubai': 'AED',
    'abu dhabi': 'AED',
    'saudi arabia': 'SAR',
    'qatar': 'QAR',
    'doha': 'QAR',

    // Oceania
    'australia': 'AUD',
    'sydney': 'AUD',
    'melbourne': 'AUD',
    'new zealand': 'NZD',
    'auckland': 'NZD',

    // Africa
    'south africa': 'ZAR',
    'cape town': 'ZAR',
    'johannesburg': 'ZAR',
    'egypt': 'EGP',
    'cairo': 'EGP',
    'morocco': 'MAD',
    'marrakech': 'MAD',
    'kenya': 'KES',
    'nairobi': 'KES',
  };

  /// Get currency code for a destination string
  /// Returns null if no match found
  static String? getCurrencyForDestination(String? destination) {
    if (destination == null || destination.isEmpty) return null;

    final lowercaseDestination = destination.toLowerCase().trim();

    // Direct match
    if (_countryToCurrency.containsKey(lowercaseDestination)) {
      return _countryToCurrency[lowercaseDestination];
    }

    // Partial match - check if destination contains any known key
    for (final entry in _countryToCurrency.entries) {
      if (lowercaseDestination.contains(entry.key) ||
          entry.key.contains(lowercaseDestination)) {
        return entry.value;
      }
    }

    return null;
  }

  /// Get currency name for display
  static String getCurrencyDisplayName(String currencyCode) {
    const names = {
      'USD': 'US Dollar',
      'EUR': 'Euro',
      'GBP': 'British Pound',
      'JPY': 'Japanese Yen',
      'THB': 'Thai Baht',
      'CNY': 'Chinese Yuan',
      'AUD': 'Australian Dollar',
      'CAD': 'Canadian Dollar',
      'CHF': 'Swiss Franc',
      'INR': 'Indian Rupee',
      'SGD': 'Singapore Dollar',
      'MXN': 'Mexican Peso',
      'BRL': 'Brazilian Real',
      'ILS': 'Israeli Shekel',
      'AED': 'UAE Dirham',
      'KRW': 'Korean Won',
      'HKD': 'Hong Kong Dollar',
      'NZD': 'New Zealand Dollar',
      'SEK': 'Swedish Krona',
      'NOK': 'Norwegian Krone',
      'DKK': 'Danish Krone',
      'PLN': 'Polish Zloty',
      'CZK': 'Czech Koruna',
      'HUF': 'Hungarian Forint',
      'TRY': 'Turkish Lira',
      'ZAR': 'South African Rand',
      'MYR': 'Malaysian Ringgit',
      'IDR': 'Indonesian Rupiah',
      'PHP': 'Philippine Peso',
      'VND': 'Vietnamese Dong',
      'TWD': 'Taiwan Dollar',
    };
    return names[currencyCode] ?? currencyCode;
  }
}

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

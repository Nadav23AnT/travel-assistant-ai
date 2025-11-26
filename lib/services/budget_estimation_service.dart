import '../utils/country_currency_helper.dart';

/// Service for estimating travel budgets based on destination and trip duration.
/// This is a mock implementation that can be replaced with actual API integration.
class BudgetEstimationService {
  BudgetEstimationService._();

  /// Average daily budget estimates by country (in USD).
  /// These are rough estimates for mid-range travelers.
  static const Map<String, double> _dailyBudgetByCountry = {
    // Western Europe
    'France': 150,
    'Germany': 130,
    'Italy': 120,
    'Spain': 100,
    'United Kingdom': 160,
    'Netherlands': 140,
    'Belgium': 130,
    'Switzerland': 200,
    'Austria': 130,
    'Portugal': 90,
    'Greece': 85,
    'Ireland': 140,

    // Eastern Europe
    'Poland': 60,
    'Czech Republic': 70,
    'Hungary': 65,
    'Croatia': 80,
    'Romania': 50,
    'Bulgaria': 45,
    'Slovenia': 85,
    'Slovakia': 65,

    // Scandinavia
    'Sweden': 160,
    'Norway': 180,
    'Denmark': 170,
    'Finland': 150,
    'Iceland': 200,

    // North America
    'United States': 150,
    'Canada': 130,
    'Mexico': 60,

    // Central & South America
    'Brazil': 70,
    'Argentina': 60,
    'Chile': 80,
    'Peru': 50,
    'Colombia': 50,
    'Costa Rica': 80,
    'Ecuador': 45,
    'Bolivia': 35,

    // Asia
    'Japan': 120,
    'South Korea': 100,
    'China': 70,
    'Thailand': 50,
    'Vietnam': 40,
    'Indonesia': 50,
    'Malaysia': 55,
    'Singapore': 140,
    'Philippines': 45,
    'India': 35,
    'Nepal': 30,
    'Sri Lanka': 45,
    'Cambodia': 40,
    'Laos': 35,
    'Myanmar': 40,
    'Taiwan': 80,

    // Middle East
    'United Arab Emirates': 150,
    'Israel': 130,
    'Turkey': 60,
    'Jordan': 80,
    'Egypt': 50,
    'Morocco': 55,
    'Saudi Arabia': 120,
    'Qatar': 140,

    // Africa
    'South Africa': 70,
    'Kenya': 80,
    'Tanzania': 90,
    'Ethiopia': 50,
    'Ghana': 60,
    'Nigeria': 70,

    // Oceania
    'Australia': 140,
    'New Zealand': 130,
    'Fiji': 100,
  };

  /// Default daily budget if country not found (in USD)
  static const double _defaultDailyBudget = 100;

  /// Get estimated daily budget for a destination
  static SmartBudgetEstimate? getEstimate({
    required String destination,
    required int tripDays,
    required String currency,
  }) {
    if (destination.isEmpty || tripDays <= 0) return null;

    // Extract country from destination
    final country = CountryCurrencyHelper.extractCountryFromDestination(destination);

    // Get base daily budget in USD
    double dailyBudgetUSD = _dailyBudgetByCountry[country] ?? _defaultDailyBudget;

    // Convert to target currency
    double dailyBudget = _convertFromUSD(dailyBudgetUSD, currency);

    return SmartBudgetEstimate(
      dailyBudget: dailyBudget,
      totalBudget: dailyBudget * tripDays,
      currency: currency,
      tripDays: tripDays,
      destination: country,
    );
  }

  /// Check if we have data for a specific country
  static bool hasDataForCountry(String country) {
    return _dailyBudgetByCountry.containsKey(country);
  }

  /// Convert USD to target currency using approximate exchange rates
  /// In production, this should use a real exchange rate API
  static double _convertFromUSD(double amountUSD, String targetCurrency) {
    const exchangeRates = {
      'USD': 1.0,
      'EUR': 0.92,
      'GBP': 0.79,
      'JPY': 149.0,
      'CAD': 1.36,
      'AUD': 1.53,
      'CHF': 0.88,
      'CNY': 7.24,
      'INR': 83.0,
      'MXN': 17.2,
      'BRL': 4.97,
      'KRW': 1320.0,
      'SGD': 1.34,
      'HKD': 7.82,
      'SEK': 10.5,
      'NOK': 10.8,
      'DKK': 6.9,
      'NZD': 1.64,
      'ZAR': 18.5,
      'THB': 35.5,
      'ILS': 3.7,
      'PLN': 4.0,
      'CZK': 23.0,
      'HUF': 360.0,
      'TRY': 32.0,
      'AED': 3.67,
      'SAR': 3.75,
      'PHP': 56.0,
      'MYR': 4.7,
      'IDR': 15700.0,
      'VND': 24500.0,
      'EGP': 31.0,
      'COP': 4000.0,
      'CLP': 900.0,
      'PEN': 3.7,
      'ARS': 850.0,
    };

    final rate = exchangeRates[targetCurrency] ?? 1.0;
    return amountUSD * rate;
  }
}

/// Model for smart budget estimate
class SmartBudgetEstimate {
  final double dailyBudget;
  final double totalBudget;
  final String currency;
  final int tripDays;
  final String destination;

  const SmartBudgetEstimate({
    required this.dailyBudget,
    required this.totalBudget,
    required this.currency,
    required this.tripDays,
    required this.destination,
  });

  /// Format the daily budget for display
  String get formattedDailyBudget {
    return dailyBudget.toStringAsFixed(0);
  }

  /// Format the total budget for display
  String get formattedTotalBudget {
    return totalBudget.toStringAsFixed(0);
  }
}

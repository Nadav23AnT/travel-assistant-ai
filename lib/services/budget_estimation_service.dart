import '../utils/country_currency_helper.dart';

/// Service for estimating travel budgets based on destination and trip duration.
/// This is a mock implementation that can be replaced with actual API integration.
class BudgetEstimationService {
  BudgetEstimationService._();

  /// Average daily budget estimates by country (in USD).
  /// These are realistic estimates for mid-range travelers (2024-2025 prices).
  /// Includes: accommodation, food, local transport, activities, misc.
  /// Excludes: international flights, insurance, shopping.
  static const Map<String, double> _dailyBudgetByCountry = {
    // Western Europe (higher costs due to inflation)
    'France': 185,
    'Germany': 165,
    'Italy': 155,
    'Spain': 130,
    'United Kingdom': 195,
    'Netherlands': 175,
    'Belgium': 165,
    'Switzerland': 280,
    'Austria': 165,
    'Portugal': 115,
    'Greece': 110,
    'Ireland': 175,

    // Eastern Europe
    'Poland': 80,
    'Czech Republic': 95,
    'Hungary': 85,
    'Croatia': 105,
    'Romania': 65,
    'Bulgaria': 60,
    'Slovenia': 110,
    'Slovakia': 85,

    // Scandinavia (expensive region)
    'Sweden': 195,
    'Norway': 230,
    'Denmark': 210,
    'Finland': 185,
    'Iceland': 260,

    // North America
    'United States': 190,
    'Canada': 165,
    'Mexico': 80,

    // Central & South America
    'Brazil': 90,
    'Argentina': 75,
    'Chile': 100,
    'Peru': 65,
    'Colombia': 65,
    'Costa Rica': 105,
    'Ecuador': 60,
    'Bolivia': 45,

    // Asia
    'Japan': 155,
    'South Korea': 125,
    'China': 90,
    'Thailand': 70,
    'Vietnam': 55,
    'Indonesia': 65,
    'Malaysia': 70,
    'Singapore': 175,
    'Philippines': 60,
    'India': 45,
    'Nepal': 40,
    'Sri Lanka': 60,
    'Cambodia': 55,
    'Laos': 45,
    'Myanmar': 55,
    'Taiwan': 105,

    // Middle East
    'United Arab Emirates': 190,
    'Israel': 170,
    'Turkey': 80,
    'Jordan': 105,
    'Egypt': 65,
    'Morocco': 75,
    'Saudi Arabia': 155,
    'Qatar': 180,

    // Africa
    'South Africa': 90,
    'Kenya': 105,
    'Tanzania': 120,
    'Ethiopia': 65,
    'Ghana': 80,
    'Nigeria': 90,

    // Oceania
    'Australia': 175,
    'New Zealand': 165,
    'Fiji': 130,
  };

  /// Default daily budget if country not found (in USD)
  static const double _defaultDailyBudget = 120;

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

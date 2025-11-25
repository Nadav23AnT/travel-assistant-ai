class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'TripBuddy';
  static const String appVersion = '1.0.0';

  // AI Providers
  static const String defaultAiProvider = 'openai';
  static const String defaultAiModel = 'gpt-4';

  // Pagination
  static const int defaultPageSize = 20;

  // Cache durations
  static const Duration cacheDuration = Duration(hours: 1);

  // Expense Categories
  static const List<String> expenseCategories = [
    'transport',
    'accommodation',
    'food',
    'activities',
    'shopping',
    'other',
  ];

  // Trip Statuses
  static const List<String> tripStatuses = [
    'planning',
    'active',
    'completed',
    'canceled',
  ];

  // Member Roles
  static const List<String> memberRoles = [
    'owner',
    'editor',
    'viewer',
  ];

  // Supported Currencies
  static const List<String> supportedCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'ILS',
    'JPY',
    'AUD',
    'CAD',
    'CHF',
    'CNY',
    'INR',
    'THB',
    'MXN',
    'BRL',
  ];

  // Currency display info (code -> name, symbol)
  static const Map<String, Map<String, String>> currencyInfo = {
    'USD': {'name': 'US Dollar', 'symbol': '\$'},
    'EUR': {'name': 'Euro', 'symbol': '\u20AC'},
    'GBP': {'name': 'British Pound', 'symbol': '\u00A3'},
    'ILS': {'name': 'Israeli Shekel', 'symbol': '\u20AA'},
    'JPY': {'name': 'Japanese Yen', 'symbol': '\u00A5'},
    'AUD': {'name': 'Australian Dollar', 'symbol': 'A\$'},
    'CAD': {'name': 'Canadian Dollar', 'symbol': 'C\$'},
    'CHF': {'name': 'Swiss Franc', 'symbol': 'CHF'},
    'CNY': {'name': 'Chinese Yuan', 'symbol': '\u00A5'},
    'INR': {'name': 'Indian Rupee', 'symbol': '\u20B9'},
    'THB': {'name': 'Thai Baht', 'symbol': '\u0E3F'},
    'MXN': {'name': 'Mexican Peso', 'symbol': '\$'},
    'BRL': {'name': 'Brazilian Real', 'symbol': 'R\$'},
  };

  // Default currency
  static const String defaultCurrency = 'USD';

  // Supported Languages (for onboarding)
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'he': 'Hebrew',
    'ja': 'Japanese',
    'zh': 'Chinese',
    'ko': 'Korean',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'ar': 'Arabic',
  };

  // Popular Destinations (for onboarding)
  static const List<Map<String, String>> popularDestinations = [
    {'name': 'Paris', 'country': 'France', 'emoji': '🇫🇷'},
    {'name': 'Tokyo', 'country': 'Japan', 'emoji': '🇯🇵'},
    {'name': 'New York', 'country': 'USA', 'emoji': '🇺🇸'},
    {'name': 'London', 'country': 'UK', 'emoji': '🇬🇧'},
    {'name': 'Rome', 'country': 'Italy', 'emoji': '🇮🇹'},
    {'name': 'Barcelona', 'country': 'Spain', 'emoji': '🇪🇸'},
    {'name': 'Dubai', 'country': 'UAE', 'emoji': '🇦🇪'},
    {'name': 'Bangkok', 'country': 'Thailand', 'emoji': '🇹🇭'},
    {'name': 'Amsterdam', 'country': 'Netherlands', 'emoji': '🇳🇱'},
    {'name': 'Sydney', 'country': 'Australia', 'emoji': '🇦🇺'},
    {'name': 'Tel Aviv', 'country': 'Israel', 'emoji': '🇮🇱'},
    {'name': 'Bali', 'country': 'Indonesia', 'emoji': '🇮🇩'},
  ];
}

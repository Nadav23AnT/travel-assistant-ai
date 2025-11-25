class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'TripBuddy';
  static const String appVersion = '1.0.0';

  // Supabase - will be loaded from environment
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

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
  ];

  // Default currency
  static const String defaultCurrency = 'USD';
}

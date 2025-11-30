import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Enum representing the supported AI providers
enum AIProvider {
  openai,
  openrouter,
  google;

  static AIProvider fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'openrouter':
        return AIProvider.openrouter;
      case 'google':
        return AIProvider.google;
      case 'openai':
      default:
        return AIProvider.openai;
    }
  }
}

/// Enum representing the AI features that can be configured
enum AIFeature {
  aiChat('AI_CHAT', 'gpt-4o-mini'),
  chatTitle('CHAT_TITLE', 'gpt-4o-mini'),
  tripWelcome('TRIP_WELCOME', 'gpt-4o-mini'),
  dailyTip('DAILY_TIP', 'gpt-4o-mini'),
  journalSummary('JOURNAL_SUMMARY', 'gpt-4o-mini'),
  recommendations('RECOMMENDATIONS', 'gpt-4o-mini'),
  budgetEstimate('BUDGET_ESTIMATE', 'gpt-4o-mini');

  final String envPrefix;
  final String defaultModel;

  const AIFeature(this.envPrefix, this.defaultModel);
}

/// Configuration for a specific AI feature
class AIFeatureConfig {
  final AIProvider provider;
  final String model;
  final String apiKey;

  const AIFeatureConfig({
    required this.provider,
    required this.model,
    required this.apiKey,
  });

  bool get isConfigured => apiKey.isNotEmpty;
}

class Env {
  Env._();

  // Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // AI Provider API Keys
  static String get openaiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get openrouterApiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static String get googleAiApiKey => dotenv.env['GOOGLE_AI_API_KEY'] ?? '';

  // Google Maps
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  // RevenueCat
  static String get revenuecatApiKey => dotenv.env['REVENUECAT_API_KEY'] ?? '';
  static String get revenuecatAppleApiKey => dotenv.env['REVENUECAT_APPLE_API_KEY'] ?? '';
  static String get revenuecatGoogleApiKey => dotenv.env['REVENUECAT_GOOGLE_API_KEY'] ?? '';

  // Validation helpers
  static bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static bool get hasOpenAI => openaiApiKey.isNotEmpty;
  static bool get hasOpenRouter => openrouterApiKey.isNotEmpty;
  static bool get hasGoogleAI => googleAiApiKey.isNotEmpty;
  static bool get hasGoogleMaps => googleMapsApiKey.isNotEmpty;

  /// Get the API key for a specific provider
  static String getApiKeyForProvider(AIProvider provider) {
    switch (provider) {
      case AIProvider.openai:
        return openaiApiKey;
      case AIProvider.openrouter:
        return openrouterApiKey;
      case AIProvider.google:
        return googleAiApiKey;
    }
  }

  /// Get the provider configured for a specific feature
  static AIProvider getProviderForFeature(AIFeature feature) {
    final providerKey = '${feature.envPrefix}_PROVIDER';
    final providerValue = dotenv.env[providerKey];
    final provider = AIProvider.fromString(providerValue);

    // Log warning if env variable is missing
    if (providerValue == null || providerValue.isEmpty) {
      debugPrint('Warning: $providerKey not set in .env, defaulting to openai');
    }

    return provider;
  }

  /// Get the model configured for a specific feature
  static String getModelForFeature(AIFeature feature) {
    final modelKey = '${feature.envPrefix}_MODEL';
    final model = dotenv.env[modelKey];

    // Log warning if env variable is missing
    if (model == null || model.isEmpty) {
      debugPrint('Warning: $modelKey not set in .env, defaulting to ${feature.defaultModel}');
      return feature.defaultModel;
    }

    return model;
  }

  /// Get the complete configuration for a feature
  static AIFeatureConfig getConfigForFeature(AIFeature feature) {
    final provider = getProviderForFeature(feature);
    final model = getModelForFeature(feature);
    final apiKey = getApiKeyForProvider(provider);

    return AIFeatureConfig(
      provider: provider,
      model: model,
      apiKey: apiKey,
    );
  }

  /// Check if a feature is properly configured (has valid API key)
  static bool isFeatureConfigured(AIFeature feature) {
    final config = getConfigForFeature(feature);
    return config.isConfigured;
  }

  /// Get a list of all configured features
  static List<AIFeature> get configuredFeatures {
    return AIFeature.values.where(isFeatureConfigured).toList();
  }

  /// Debug: Print all AI feature configurations
  static void debugPrintAIConfig() {
    debugPrint('=== AI Feature Configuration ===');
    for (final feature in AIFeature.values) {
      final config = getConfigForFeature(feature);
      debugPrint(
        '${feature.envPrefix}: provider=${config.provider.name}, '
        'model=${config.model}, configured=${config.isConfigured}'
      );
    }
    debugPrint('================================');
  }
}

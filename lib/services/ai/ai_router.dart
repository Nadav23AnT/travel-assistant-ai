import 'package:flutter/foundation.dart';

import '../../config/env.dart';
import 'ai_provider_interface.dart';
import 'google_provider.dart';
import 'openai_provider.dart';
import 'openrouter_provider.dart';

/// Central AI routing mechanism that directs requests to the appropriate provider
/// based on feature configuration.
///
/// Usage:
/// ```dart
/// final router = AIRouter();
/// final provider = router.getProviderForFeature(AIFeature.aiChat);
/// final response = await provider.complete(messages: [...]);
/// ```
class AIRouter {
  /// Cache of created providers to avoid recreating them
  final Map<String, AIProviderInterface> _providerCache = {};

  /// Get the appropriate AI provider for a specific feature
  ///
  /// This reads the configuration from environment variables and returns
  /// the correct provider instance with the configured model.
  AIProviderInterface getProviderForFeature(AIFeature feature) {
    final config = Env.getConfigForFeature(feature);
    final cacheKey = '${config.provider.name}_${config.model}';

    // Return cached provider if available
    if (_providerCache.containsKey(cacheKey)) {
      return _providerCache[cacheKey]!;
    }

    // Create new provider based on configuration
    final provider = _createProvider(config);
    _providerCache[cacheKey] = provider;

    debugPrint(
      'AIRouter: Created ${config.provider.name} provider for ${feature.envPrefix} '
      'with model ${config.model}'
    );

    return provider;
  }

  /// Create a provider instance based on configuration
  AIProviderInterface _createProvider(AIFeatureConfig config) {
    switch (config.provider) {
      case AIProvider.openai:
        return OpenAIProvider(
          apiKey: config.apiKey,
          model: config.model,
        );
      case AIProvider.openrouter:
        return OpenRouterProvider(
          apiKey: config.apiKey,
          model: config.model,
        );
      case AIProvider.google:
        return GoogleAIProvider(
          apiKey: config.apiKey,
          model: config.model,
        );
    }
  }

  /// Get configuration details for a feature (useful for debugging)
  AIFeatureConfig getConfigForFeature(AIFeature feature) {
    return Env.getConfigForFeature(feature);
  }

  /// Check if a feature is properly configured
  bool isFeatureConfigured(AIFeature feature) {
    return Env.isFeatureConfigured(feature);
  }

  /// Clear the provider cache (useful for testing or when config changes)
  void clearCache() {
    _providerCache.clear();
  }

  /// Get a summary of all feature configurations
  Map<String, Map<String, String>> getConfigurationSummary() {
    final summary = <String, Map<String, String>>{};
    for (final feature in AIFeature.values) {
      final config = Env.getConfigForFeature(feature);
      summary[feature.envPrefix] = {
        'provider': config.provider.name,
        'model': config.model,
        'configured': config.isConfigured.toString(),
      };
    }
    return summary;
  }

  /// Print configuration summary to debug log
  void debugPrintConfiguration() {
    Env.debugPrintAIConfig();
  }
}

/// Extension to make AIRouter easier to use with features
extension AIRouterFeatureExtension on AIRouter {
  /// Quick access to chat provider
  AIProviderInterface get chatProvider =>
      getProviderForFeature(AIFeature.aiChat);

  /// Quick access to chat title provider
  AIProviderInterface get chatTitleProvider =>
      getProviderForFeature(AIFeature.chatTitle);

  /// Quick access to trip welcome provider
  AIProviderInterface get tripWelcomeProvider =>
      getProviderForFeature(AIFeature.tripWelcome);

  /// Quick access to daily tip provider
  AIProviderInterface get dailyTipProvider =>
      getProviderForFeature(AIFeature.dailyTip);

  /// Quick access to journal summary provider
  AIProviderInterface get journalSummaryProvider =>
      getProviderForFeature(AIFeature.journalSummary);

  /// Quick access to recommendations provider
  AIProviderInterface get recommendationsProvider =>
      getProviderForFeature(AIFeature.recommendations);

  /// Quick access to budget estimate provider
  AIProviderInterface get budgetEstimateProvider =>
      getProviderForFeature(AIFeature.budgetEstimate);
}

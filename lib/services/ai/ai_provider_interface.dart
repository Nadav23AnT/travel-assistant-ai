import 'package:dio/dio.dart';

/// Abstract interface for AI providers.
/// All AI providers (OpenAI, OpenRouter, Google) must implement this interface.
abstract class AIProviderInterface {
  /// The base URL for the provider's API
  String get baseUrl;

  /// The API key for authentication
  String get apiKey;

  /// The configured model to use
  String get model;

  /// Check if the provider is configured (has valid API key)
  bool get isConfigured;

  /// Send a chat completion request and get a response
  Future<AICompletionResponse> complete({
    required List<Map<String, dynamic>> messages,
    double temperature = 0.7,
    int maxTokens = 1024,
  });

  /// Send a streaming chat completion request
  Stream<String> streamComplete({
    required List<Map<String, dynamic>> messages,
    double temperature = 0.7,
    int maxTokens = 1024,
  });
}

/// Response from an AI completion request
class AICompletionResponse {
  final String content;
  final int tokensUsed;
  final String? finishReason;

  const AICompletionResponse({
    required this.content,
    required this.tokensUsed,
    this.finishReason,
  });
}

/// Exception thrown by AI providers
class AIProviderException implements Exception {
  final String message;
  final int? statusCode;
  final bool isRateLimited;
  final bool isAuthError;

  const AIProviderException(
    this.message, {
    this.statusCode,
    this.isRateLimited = false,
    this.isAuthError = false,
  });

  @override
  String toString() => message;

  /// Create an exception from a DioException
  factory AIProviderException.fromDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      return AIProviderException(
        'Invalid API key or authentication error',
        statusCode: statusCode,
        isAuthError: true,
      );
    } else if (statusCode == 429) {
      return AIProviderException(
        'Rate limit exceeded. Please try again later.',
        statusCode: statusCode,
        isRateLimited: true,
      );
    } else if (statusCode == 500 || statusCode == 502 || statusCode == 503) {
      return AIProviderException(
        'AI service temporarily unavailable. Please try again.',
        statusCode: statusCode,
      );
    }
    return AIProviderException(
      e.message ?? 'Network error',
      statusCode: statusCode,
    );
  }
}

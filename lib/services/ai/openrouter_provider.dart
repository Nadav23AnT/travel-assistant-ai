import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'ai_provider_interface.dart';

/// OpenRouter API provider implementation
/// OpenRouter provides access to multiple AI models through a unified API
class OpenRouterProvider implements AIProviderInterface {
  final Dio _dio;
  final String _apiKey;
  final String _model;

  static const String _baseUrl = 'https://openrouter.ai/api/v1';

  OpenRouterProvider({
    required String apiKey,
    required String model,
    Dio? dio,
  })  : _apiKey = apiKey,
        _model = model,
        _dio = dio ?? Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
      'HTTP-Referer': 'https://waylo.app', // Required by OpenRouter
      'X-Title': 'Waylo', // Optional but recommended
    };
  }

  @override
  String get baseUrl => _baseUrl;

  @override
  String get apiKey => _apiKey;

  @override
  String get model => _model;

  @override
  bool get isConfigured => _apiKey.isNotEmpty;

  @override
  Future<AICompletionResponse> complete({
    required List<Map<String, dynamic>> messages,
    double temperature = 0.7,
    int maxTokens = 1024,
  }) async {
    if (!isConfigured) {
      throw const AIProviderException(
        'OpenRouter API key not configured',
        isAuthError: true,
      );
    }

    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': _model,
          'messages': messages,
          'temperature': temperature,
          'max_tokens': maxTokens,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final choices = data['choices'] as List;

        if (choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String;
          final tokensUsed = _extractTokensUsed(data);
          final finishReason = choices[0]['finish_reason'] as String?;

          return AICompletionResponse(
            content: content.trim(),
            tokensUsed: tokensUsed,
            finishReason: finishReason,
          );
        }
        throw const AIProviderException('No response from OpenRouter');
      } else {
        throw AIProviderException(
          'API request failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('OpenRouter Provider Error: ${e.message}');
      throw AIProviderException.fromDioException(e);
    }
  }

  @override
  Stream<String> streamComplete({
    required List<Map<String, dynamic>> messages,
    double temperature = 0.7,
    int maxTokens = 1024,
  }) async* {
    if (!isConfigured) {
      throw const AIProviderException(
        'OpenRouter API key not configured',
        isAuthError: true,
      );
    }

    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': _model,
          'messages': messages,
          'temperature': temperature,
          'max_tokens': maxTokens,
          'stream': true,
        },
        options: Options(
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += String.fromCharCodes(chunk);
        final lines = buffer.split('\n');
        buffer = lines.last;

        for (int i = 0; i < lines.length - 1; i++) {
          final line = lines[i].trim();
          if (line.startsWith('data: ') && line != 'data: [DONE]') {
            try {
              final jsonStr = line.substring(6);
              final data = jsonDecode(jsonStr) as Map<String, dynamic>;
              final content = data['choices']?[0]?['delta']?['content'];
              if (content != null && content.isNotEmpty) {
                yield content as String;
              }
            } catch (_) {
              // Skip malformed JSON
            }
          }
        }
      }
    } on DioException catch (e) {
      throw AIProviderException.fromDioException(e);
    }
  }

  /// Extract total tokens from OpenRouter API response
  int _extractTokensUsed(Map<String, dynamic> responseData) {
    try {
      final usage = responseData['usage'] as Map<String, dynamic>?;
      if (usage != null) {
        return (usage['total_tokens'] as int?) ?? 0;
      }
    } catch (e) {
      debugPrint('Failed to extract token usage: $e');
    }
    return 0;
  }

  /// Get available models from OpenRouter
  static List<String> get popularModels => [
        'openai/gpt-4o-mini',
        'openai/gpt-4o',
        'openai/gpt-4-turbo',
        'anthropic/claude-3.5-sonnet',
        'anthropic/claude-3-opus',
        'anthropic/claude-3-haiku',
        'google/gemini-pro',
        'google/gemini-pro-1.5',
        'meta-llama/llama-3.1-70b-instruct',
        'meta-llama/llama-3.1-8b-instruct',
        'mistralai/mistral-large',
        'mistralai/mistral-small',
      ];
}

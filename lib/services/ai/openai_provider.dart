import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'ai_provider_interface.dart';

/// OpenAI API provider implementation
class OpenAIProvider implements AIProviderInterface {
  final Dio _dio;
  final String _apiKey;
  final String _model;

  static const String _baseUrl = 'https://api.openai.com/v1';

  OpenAIProvider({
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
        'OpenAI API key not configured',
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
        throw const AIProviderException('No response from OpenAI');
      } else {
        throw AIProviderException(
          'API request failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('OpenAI Provider Error: ${e.message}');
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
        'OpenAI API key not configured',
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

  /// Extract total tokens from OpenAI API response
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
}

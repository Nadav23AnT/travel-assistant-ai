import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'ai_provider_interface.dart';

/// Google AI (Gemini) provider implementation
class GoogleAIProvider implements AIProviderInterface {
  final Dio _dio;
  final String _apiKey;
  final String _model;

  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  GoogleAIProvider({
    required String apiKey,
    required String model,
    Dio? dio,
  })  : _apiKey = apiKey,
        _model = model,
        _dio = dio ?? Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
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

  /// Convert OpenAI-style messages to Gemini format
  Map<String, dynamic> _convertToGeminiFormat(List<Map<String, dynamic>> messages) {
    final contents = <Map<String, dynamic>>[];
    String? systemInstruction;

    for (final message in messages) {
      final role = message['role'] as String;
      final content = message['content'] as String;

      if (role == 'system') {
        // Gemini handles system instructions differently
        systemInstruction = content;
      } else {
        // Convert 'assistant' to 'model' for Gemini
        final geminiRole = role == 'assistant' ? 'model' : 'user';
        contents.add({
          'role': geminiRole,
          'parts': [
            {'text': content}
          ],
        });
      }
    }

    final request = <String, dynamic>{
      'contents': contents,
    };

    // Add system instruction if present
    if (systemInstruction != null) {
      request['systemInstruction'] = {
        'parts': [
          {'text': systemInstruction}
        ],
      };
    }

    return request;
  }

  @override
  Future<AICompletionResponse> complete({
    required List<Map<String, dynamic>> messages,
    double temperature = 0.7,
    int maxTokens = 1024,
  }) async {
    if (!isConfigured) {
      throw const AIProviderException(
        'Google AI API key not configured',
        isAuthError: true,
      );
    }

    try {
      final requestBody = _convertToGeminiFormat(messages);
      requestBody['generationConfig'] = {
        'temperature': temperature,
        'maxOutputTokens': maxTokens,
      };

      final response = await _dio.post(
        '/models/$_model:generateContent?key=$_apiKey',
        data: requestBody,
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;

        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content']['parts'][0]['text'] as String;
          final tokensUsed = _extractTokensUsed(data);
          final finishReason = candidates[0]['finishReason'] as String?;

          return AICompletionResponse(
            content: content.trim(),
            tokensUsed: tokensUsed,
            finishReason: finishReason,
          );
        }
        throw const AIProviderException('No response from Google AI');
      } else {
        throw AIProviderException(
          'API request failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('Google AI Provider Error: ${e.message}');
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
        'Google AI API key not configured',
        isAuthError: true,
      );
    }

    try {
      final requestBody = _convertToGeminiFormat(messages);
      requestBody['generationConfig'] = {
        'temperature': temperature,
        'maxOutputTokens': maxTokens,
      };

      final response = await _dio.post(
        '/models/$_model:streamGenerateContent?key=$_apiKey&alt=sse',
        data: requestBody,
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
          if (line.startsWith('data: ')) {
            try {
              final jsonStr = line.substring(6);
              if (jsonStr.isEmpty || jsonStr == '[DONE]') continue;

              final data = _parseJson(jsonStr);
              final candidates = data['candidates'] as List?;
              if (candidates != null && candidates.isNotEmpty) {
                final parts = candidates[0]['content']?['parts'] as List?;
                if (parts != null && parts.isNotEmpty) {
                  final text = parts[0]['text'] as String?;
                  if (text != null && text.isNotEmpty) {
                    yield text;
                  }
                }
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

  Map<String, dynamic> _parseJson(String jsonStr) {
    try {
      return Map<String, dynamic>.from(
        (jsonStr.startsWith('{') ? jsonStr : '{}') as dynamic,
      );
    } catch (_) {
      return {};
    }
  }

  /// Extract total tokens from Gemini API response
  int _extractTokensUsed(Map<String, dynamic> responseData) {
    try {
      final usageMetadata = responseData['usageMetadata'] as Map<String, dynamic>?;
      if (usageMetadata != null) {
        final promptTokens = (usageMetadata['promptTokenCount'] as int?) ?? 0;
        final candidatesTokens = (usageMetadata['candidatesTokenCount'] as int?) ?? 0;
        return promptTokens + candidatesTokens;
      }
    } catch (e) {
      debugPrint('Failed to extract token usage: $e');
    }
    return 0;
  }

  /// Get available Gemini models
  static List<String> get availableModels => [
        'gemini-1.5-flash',
        'gemini-1.5-flash-8b',
        'gemini-1.5-pro',
        'gemini-1.0-pro',
      ];
}

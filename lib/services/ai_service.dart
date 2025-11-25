import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';

class AIException implements Exception {
  final String message;
  final int? statusCode;

  AIException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ChatMessage {
  final String role;
  final String content;

  const ChatMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: json['role'] as String,
        content: json['content'] as String,
      );

  factory ChatMessage.user(String content) => ChatMessage(
        role: 'user',
        content: content,
      );

  factory ChatMessage.assistant(String content) => ChatMessage(
        role: 'assistant',
        content: content,
      );

  factory ChatMessage.system(String content) => ChatMessage(
        role: 'system',
        content: content,
      );
}

/// Represents a parsed expense from user message
class ParsedExpense {
  final double amount;
  final String currency;
  final String category;
  final String description;
  final DateTime date;
  final bool confirmed;

  const ParsedExpense({
    required this.amount,
    required this.currency,
    required this.category,
    required this.description,
    required this.date,
    this.confirmed = false,
  });

  factory ParsedExpense.fromJson(Map<String, dynamic> json) {
    return ParsedExpense(
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      category: json['category'] as String? ?? 'other',
      description: json['description'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
        'category': category,
        'description': description,
        'date': date.toIso8601String().split('T').first,
      };

  ParsedExpense copyWith({
    double? amount,
    String? currency,
    String? category,
    String? description,
    DateTime? date,
    bool? confirmed,
  }) {
    return ParsedExpense(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      confirmed: confirmed ?? this.confirmed,
    );
  }

  /// Get formatted amount with currency symbol
  String get formattedAmount {
    const symbols = {
      'USD': '\$',
      'EUR': '\u20AC',
      'GBP': '\u00A3',
      'ILS': '\u20AA',
      'JPY': '\u00A5',
    };
    final symbol = symbols[currency] ?? '$currency ';
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Get category display name
  String get categoryDisplayName {
    switch (category) {
      case 'transport':
        return 'Transport';
      case 'accommodation':
        return 'Accommodation';
      case 'food':
        return 'Food & Drinks';
      case 'activities':
        return 'Activities';
      case 'shopping':
        return 'Shopping';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }
}

/// Response from AI that may include expense data
class AIResponse {
  final String message;
  final ParsedExpense? expense;

  const AIResponse({
    required this.message,
    this.expense,
  });
}

class AIService {
  final Dio _dio;
  final String _apiKey;

  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _defaultModel = 'gpt-4o-mini';

  AIService({Dio? dio, String? apiKey})
      : _dio = dio ?? Dio(),
        _apiKey = apiKey ?? Env.openaiApiKey {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };
  }

  /// System prompt for the travel assistant
  String get systemPrompt => '''
You are TripBuddy, a friendly and knowledgeable AI travel assistant. Your role is to help users plan amazing trips and provide expert travel advice.

Your capabilities include:
- Recommending destinations based on user preferences
- Suggesting activities, attractions, and restaurants
- Creating day-by-day itineraries
- Providing practical travel tips (visas, currency, weather, etc.)
- Helping with budget planning
- Suggesting the best times to visit places

Guidelines:
- Be friendly, enthusiastic, and concise
- When suggesting places, include brief descriptions and why they're worth visiting
- Consider the user's budget when making recommendations
- Provide practical, actionable advice
- If you're unsure about specific current prices or availability, mention that the user should verify
- Format responses clearly with bullet points or numbered lists when appropriate
- Keep responses focused and not too long

Remember: You're helping people create memorable travel experiences!
''';

  /// Send a message and get a response from OpenAI
  Future<String> sendMessage({
    required String message,
    List<ChatMessage>? history,
    String? model,
  }) async {
    if (_apiKey.isEmpty) {
      throw AIException('OpenAI API key not configured');
    }

    try {
      // Build messages array with system prompt and history
      final messages = <Map<String, dynamic>>[
        ChatMessage.system(systemPrompt).toJson(),
      ];

      // Add conversation history
      if (history != null && history.isNotEmpty) {
        messages.addAll(history.map((m) => m.toJson()));
      }

      // Add the new user message
      messages.add(ChatMessage.user(message).toJson());

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': model ?? _defaultModel,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final choices = data['choices'] as List;
        if (choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String;
          return content.trim();
        }
        throw AIException('No response from AI');
      } else {
        throw AIException(
          'API request failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('AI Service Error: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw AIException('Invalid API key');
      } else if (e.response?.statusCode == 429) {
        throw AIException('Rate limit exceeded. Please try again later.');
      } else if (e.response?.statusCode == 500) {
        throw AIException('OpenAI service error. Please try again.');
      }
      throw AIException(e.message ?? 'Network error');
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException('Failed to get AI response: $e');
    }
  }

  /// Stream a response from OpenAI (for future use)
  Stream<String> streamMessage({
    required String message,
    List<ChatMessage>? history,
    String? model,
  }) async* {
    if (_apiKey.isEmpty) {
      throw AIException('OpenAI API key not configured');
    }

    try {
      final messages = <Map<String, dynamic>>[
        ChatMessage.system(systemPrompt).toJson(),
      ];

      if (history != null && history.isNotEmpty) {
        messages.addAll(history.map((m) => m.toJson()));
      }

      messages.add(ChatMessage.user(message).toJson());

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': model ?? _defaultModel,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
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
              final data = _parseJson(jsonStr);
              final content = data['choices']?[0]?['delta']?['content'];
              if (content != null && content.isNotEmpty) {
                yield content;
              }
            } catch (_) {
              // Skip malformed JSON
            }
          }
        }
      }
    } on DioException catch (e) {
      throw AIException(e.message ?? 'Stream error');
    }
  }

  Map<String, dynamic> _parseJson(String jsonStr) {
    try {
      return Map<String, dynamic>.from(jsonDecode(jsonStr) as Map);
    } catch (_) {
      return {};
    }
  }

  /// Check if OpenAI is configured
  bool get isConfigured => _apiKey.isNotEmpty;

  /// System prompt for expense detection
  String get expenseDetectionPrompt => '''
You are TripBuddy, a friendly AI travel assistant that also helps track travel expenses.

When a user mentions spending money or an expense, you should:
1. Extract the expense details (amount, currency, category, description)
2. Respond conversationally acknowledging the expense
3. Include the expense data in a special JSON block

Categories available: transport, accommodation, food, activities, shopping, other

If the user mentions an expense, include this exact format at the END of your message:
###EXPENSE_DATA###
{"amount": 25.50, "currency": "USD", "category": "food", "description": "Lunch at cafe", "date": "2024-01-15"}
###END_EXPENSE_DATA###

Currency detection rules:
- Default to USD if no currency mentioned
- Common symbols: \$ = USD, € = EUR, £ = GBP, ₪ = ILS, ¥ = JPY
- Accept currency codes like "50 EUR" or "100 ILS"

Category detection rules:
- transport: taxi, uber, bus, train, flight, metro, gas, parking
- accommodation: hotel, hostel, airbnb, booking, room, stay
- food: restaurant, cafe, lunch, dinner, breakfast, coffee, drinks, bar, meal
- activities: museum, tour, ticket, entrance, show, concert, excursion
- shopping: souvenirs, clothes, gifts, market, store, shop
- other: anything that doesn't fit above

If the message doesn't contain an expense, just respond normally as a travel assistant without the expense JSON block.

Remember to be conversational and helpful!
''';

  /// Send a message with expense detection
  Future<AIResponse> sendMessageWithExpenseDetection({
    required String message,
    List<ChatMessage>? history,
    String? model,
  }) async {
    if (_apiKey.isEmpty) {
      throw AIException('OpenAI API key not configured');
    }

    try {
      final messages = <Map<String, dynamic>>[
        ChatMessage.system(expenseDetectionPrompt).toJson(),
      ];

      if (history != null && history.isNotEmpty) {
        messages.addAll(history.map((m) => m.toJson()));
      }

      messages.add(ChatMessage.user(message).toJson());

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': model ?? _defaultModel,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final choices = data['choices'] as List;
        if (choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String;
          return _parseAIResponse(content);
        }
        throw AIException('No response from AI');
      } else {
        throw AIException(
          'API request failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('AI Service Error: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw AIException('Invalid API key');
      } else if (e.response?.statusCode == 429) {
        throw AIException('Rate limit exceeded. Please try again later.');
      } else if (e.response?.statusCode == 500) {
        throw AIException('OpenAI service error. Please try again.');
      }
      throw AIException(e.message ?? 'Network error');
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException('Failed to get AI response: $e');
    }
  }

  /// Parse AI response to extract expense data if present
  AIResponse _parseAIResponse(String content) {
    const startMarker = '###EXPENSE_DATA###';
    const endMarker = '###END_EXPENSE_DATA###';

    final startIndex = content.indexOf(startMarker);
    final endIndex = content.indexOf(endMarker);

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      // Extract the message part (before the expense data)
      final messagePart = content.substring(0, startIndex).trim();

      // Extract the JSON part
      final jsonStart = startIndex + startMarker.length;
      final jsonString = content.substring(jsonStart, endIndex).trim();

      try {
        final expenseJson = jsonDecode(jsonString) as Map<String, dynamic>;
        final expense = ParsedExpense.fromJson(expenseJson);
        return AIResponse(
          message: messagePart.isNotEmpty ? messagePart : 'Got it! I\'ve recorded your expense.',
          expense: expense,
        );
      } catch (e) {
        debugPrint('Failed to parse expense JSON: $e');
        // Return just the message without expense
        return AIResponse(message: messagePart.isNotEmpty ? messagePart : content);
      }
    }

    // No expense data found
    return AIResponse(message: content.trim());
  }
}

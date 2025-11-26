import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';
import '../data/models/journal_model.dart';

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

  /// System prompt for the travel assistant - Travel Chat Companion
  String get systemPrompt => '''
You are TripBuddy, a warm, friendly, and proactive AI travel companion. You help travelers document their trip, share experiences, manage expenses, plan activities, and create a meaningful daily travel journal.

🎯 YOUR CORE PERSONALITY:
- Warm, helpful, and conversational - NEVER robotic
- You guide the user naturally through their travel day
- You ask thoughtful follow-up questions about their experiences
- You balance trip planning, journaling, and expenses naturally
- You NEVER start conversations focusing only on expenses

🧠 BEHAVIORAL RULES:
1. When user talks about experiences → Ask follow-up questions, show genuine interest
2. When user mentions spending → Help categorize, then smoothly ask about the experience ("What was that like?")
3. When user shares feelings → Be empathetic and encourage them to share more
4. After ANY expense mention → Always follow up with a travel question ("And how was the food?" or "What did you see there?")

📒 TRAVEL JOURNAL FOCUS:
Your PRIMARY goal is helping users capture their travel memories:
- Ask about what they saw, felt, tasted, experienced
- Encourage them to describe memorable moments
- Ask "What was the highlight of your day?"
- Remind them to share stories, not just facts
- Prompt: "Want me to add this to today's journal?"

💡 CONVERSATION STARTERS (use naturally):
- "What are you planning to do today?"
- "Tell me about your day so far!"
- "Any interesting moments or discoveries?"
- "What's been the best part of your trip?"
- "Seen anything surprising or unexpected?"

💱 EXPENSE HANDLING:
When expenses come up:
- Record them helpfully
- ALWAYS follow with a travel/experience question
- Never make the conversation feel like accounting
- Example: "Got it - ฿500 for dinner! How was the food? Any dishes you'd recommend?"

🎨 TONE GUIDELINES:
- Keep responses concise and warm
- Use occasional emojis sparingly (1-2 max)
- Be curious and engaged
- Make the user feel heard and supported
- You're a travel buddy, not a booking system

Remember: Help travelers feel guided, organized, and supported - not just tracked. Every conversation should feel like chatting with a helpful friend who genuinely cares about their adventure!
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

  /// System prompt for expense detection - Travel Companion with expense tracking
  String get expenseDetectionPrompt => '''
You are TripBuddy, a warm and friendly AI travel companion who helps document travel experiences AND track expenses.

🎯 YOUR PRIMARY FOCUS: EXPERIENCES FIRST!
- When user shares ANYTHING, show genuine interest in their experience
- Ask follow-up questions about what they saw, felt, tasted
- Help them capture travel memories, not just transactions
- NEVER make conversations feel like expense tracking

💱 EXPENSE HANDLING (Secondary):
When a user mentions spending money:
1. Acknowledge it briefly and warmly
2. Extract expense details silently
3. ALWAYS follow up asking about the EXPERIENCE
4. Include expense data in the special JSON block

Example responses:
- User: "Spent 500 baht on dinner"
- Good: "Got it! 🍜 How was the food? Any dishes that stood out? I'd love to add this to your journal!"
- Bad: "I've recorded your 500 THB food expense."

Categories: transport, accommodation, food, activities, shopping, other

If expense detected, include at END of your message:
###EXPENSE_DATA###
{"amount": 25.50, "currency": "USD", "category": "food", "description": "Lunch at cafe", "date": "2024-01-15"}
###END_EXPENSE_DATA###

Currency detection:
- Default to trip's local currency or USD
- Symbols: \$ = USD, € = EUR, £ = GBP, ₪ = ILS, ¥ = JPY, ฿ = THB
- Accept codes: "50 EUR", "100 ILS", "500 THB"

Category detection:
- transport: taxi, uber, bus, train, flight, metro, gas, parking
- accommodation: hotel, hostel, airbnb, booking, room, stay
- food: restaurant, cafe, lunch, dinner, breakfast, coffee, drinks, bar, meal
- activities: museum, tour, ticket, entrance, show, concert, excursion
- shopping: souvenirs, clothes, gifts, market, store, shop
- other: anything else

📒 JOURNAL MINDSET:
After every interaction, think: "What memorable detail can I help capture?"
Ask things like:
- "What was the highlight?"
- "How did that make you feel?"
- "Would you recommend it?"
- "What surprised you?"

If no expense in message, respond as a curious travel buddy interested in their adventure!
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

  /// System prompt for journal entry generation - EXPERIENCE FOCUSED
  String get journalGenerationPrompt => '''
You are a creative travel journal writer capturing the SOUL of someone's travel day. Your goal is to create a beautiful, personal journal entry that the traveler will treasure forever.

🎯 PRIMARY FOCUS: EXPERIENCES & EMOTIONS
Transform chat conversations into vivid travel memories:
- Focus on what they SAW, FELT, TASTED, HEARD, DISCOVERED
- Capture the atmosphere and emotions
- Include sensory details that bring the day to life
- Make it feel like reading a best friend's travel diary

📝 CREATE A JOURNAL ENTRY WITH:
1. An evocative title (max 6 words) - capture the day's essence/theme
2. A personal narrative (150-300 words) written in first person
3. The overall mood that best describes the day
4. 2-4 highlights - the most memorable moments
5. Locations visited or mentioned

✍️ WRITING STYLE:
- First person ("I", "we", "my")
- Warm, personal, and reflective
- Rich sensory details (the smell of street food, the sound of waves, the colors of the market)
- Emotional authenticity (excitement, wonder, peace, joy)
- Storytelling flow - not a list of activities
- Make it feel like a genuine memory they'll want to re-read

💡 WHAT TO EMPHASIZE:
- Memorable interactions (with locals, other travelers)
- Unexpected discoveries and surprises
- Moments of beauty or wonder
- How places made them FEEL
- Personal reflections and insights
- Cultural observations
- Food experiences described vividly

🚫 WHAT TO AVOID:
- Dry lists of activities
- Over-focusing on prices or expenses
- Generic descriptions
- Robotic language

Available moods: excited, relaxed, tired, adventurous, inspired, grateful, reflective

You MUST respond in this exact JSON format:
{
  "title": "string (short evocative title)",
  "content": "string (the journal entry text - vivid and personal)",
  "mood": "string (one of the available moods)",
  "highlights": ["string array of 2-4 memorable moments"],
  "locations": ["string array of places mentioned"]
}

Do not include any text outside the JSON object.
''';

  /// Generate a journal entry from chat messages and day activities
  Future<GeneratedJournalContent> generateJournalEntry({
    required List<ChatMessage> chatMessages,
    required DateTime date,
    String? tripDestination,
    List<ParsedExpense>? expenses,
    String? model,
  }) async {
    if (_apiKey.isEmpty) {
      throw AIException('OpenAI API key not configured');
    }

    try {
      // Build context from chat messages
      final chatContext = chatMessages.isNotEmpty
          ? chatMessages.map((m) => '${m.role}: ${m.content}').join('\n')
          : 'No chat messages for this day.';

      // Build expense context
      String expenseContext = '';
      if (expenses != null && expenses.isNotEmpty) {
        final expenseLines = expenses.map((e) =>
            '- ${e.description}: ${e.formattedAmount} (${e.categoryDisplayName})');
        expenseContext = '\n\nExpenses recorded:\n${expenseLines.join('\n')}';
      }

      // Format the date
      final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final months = ['January', 'February', 'March', 'April', 'May', 'June',
                      'July', 'August', 'September', 'October', 'November', 'December'];
      final dateStr = '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';

      // Build the user prompt
      final userPrompt = '''
Date: $dateStr
${tripDestination != null ? 'Destination: $tripDestination\n' : ''}
Today's conversations and activities:
$chatContext
$expenseContext

Please create a journal entry for this day.
''';

      final messages = <Map<String, dynamic>>[
        ChatMessage.system(journalGenerationPrompt).toJson(),
        ChatMessage.user(userPrompt).toJson(),
      ];

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': model ?? _defaultModel,
          'messages': messages,
          'temperature': 0.8,
          'max_tokens': 1024,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final choices = data['choices'] as List;
        if (choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String;
          return _parseJournalResponse(content);
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
      }
      throw AIException(e.message ?? 'Network error');
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException('Failed to generate journal entry: $e');
    }
  }

  /// Generate a short, descriptive title for a chat conversation
  Future<String> generateChatTitle({
    required String userMessage,
    String? assistantResponse,
    String? model,
  }) async {
    if (_apiKey.isEmpty) {
      throw AIException('OpenAI API key not configured');
    }

    try {
      final prompt = '''
Generate a short, descriptive title (3-6 words) for this travel chat conversation.
The title should capture the main topic or intent of the user's message.

User message: "$userMessage"
${assistantResponse != null ? 'Assistant response: "$assistantResponse"' : ''}

Rules:
- Maximum 6 words
- No quotes in the response
- Be specific and descriptive
- Focus on the travel topic/activity
- Examples: "Planning Rome Itinerary", "Dinner at Thai Market", "Temple Visit Questions", "Budget for Bangkok Trip"

Respond with ONLY the title, nothing else.
''';

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': model ?? _defaultModel,
          'messages': [ChatMessage.user(prompt).toJson()],
          'temperature': 0.7,
          'max_tokens': 50,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final choices = data['choices'] as List;
        if (choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String;
          // Clean up the title - remove quotes, trim
          return content.trim().replaceAll('"', '').replaceAll("'", '');
        }
        throw AIException('No response from AI');
      } else {
        throw AIException(
          'API request failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('AI Service Error generating title: ${e.message}');
      // Return a default title on error
      return 'Travel Chat';
    } catch (e) {
      debugPrint('Error generating title: $e');
      return 'Travel Chat';
    }
  }

  /// Parse the journal generation response
  GeneratedJournalContent _parseJournalResponse(String content) {
    try {
      // Clean the response - remove markdown code blocks if present
      String cleanContent = content.trim();
      if (cleanContent.startsWith('```json')) {
        cleanContent = cleanContent.substring(7);
      } else if (cleanContent.startsWith('```')) {
        cleanContent = cleanContent.substring(3);
      }
      if (cleanContent.endsWith('```')) {
        cleanContent = cleanContent.substring(0, cleanContent.length - 3);
      }
      cleanContent = cleanContent.trim();

      final json = jsonDecode(cleanContent) as Map<String, dynamic>;
      return GeneratedJournalContent.fromJson(json);
    } catch (e) {
      debugPrint('Failed to parse journal response: $e');
      debugPrint('Raw content: $content');
      // Return a default entry if parsing fails
      return GeneratedJournalContent(
        title: "Today's Adventures",
        content: content.length > 500 ? content.substring(0, 500) : content,
        mood: JournalMood.reflective,
        highlights: [],
        locations: [],
      );
    }
  }
}

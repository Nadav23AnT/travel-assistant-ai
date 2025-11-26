import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';
import '../data/models/day_tip_model.dart';
import '../data/models/journal_model.dart';
import '../data/models/travel_context.dart';

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

/// Response from AI that may include expense data and place recommendations
class AIResponse {
  final String message;
  final ParsedExpense? expense;
  final List<PlaceRecommendation> places;

  const AIResponse({
    required this.message,
    this.expense,
    this.places = const [],
  });

  /// Check if response contains place recommendations
  bool get hasPlaces => places.isNotEmpty;
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
  String buildSystemPrompt({TravelContext? context}) {
    final contextSection = context != null ? '''

📍 CURRENT TRIP CONTEXT:
${context.toContextString()}
''' : '';

    final locationGuidance = context?.destination != null ? '''

🗺️ LOCATION RECOMMENDATIONS:
When suggesting places in ${context!.destination}:
1. ALWAYS provide the full name and general location/neighborhood
2. Include a brief description of why you recommend it
3. Mention price range if relevant (\$, \$\$, \$\$\$, \$\$\$\$)
4. Suggest best time to visit (morning, afternoon, evening)
5. For restaurants/cafes: mention signature dishes or must-try items
6. For attractions: suggest how much time to allocate

When user asks "where should I..." or "what's a good place for...":
- Ask clarifying questions if needed (budget, cuisine type, mood, time of day)
- Provide 2-3 specific recommendations with details
- After giving recommendations, ask which interests them or what they're in the mood for

FORMAT for place recommendations:
"[Place Name] - [Brief description]. [Why it's great]. Best visited [time]. [Price range if applicable]."
''' : '';

    return '''
You are TripBuddy, a warm, friendly, and proactive AI travel companion. You help travelers document their trip, share experiences, manage expenses, plan activities, and create a meaningful daily travel journal.
$contextSection
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
5. When user asks for recommendations → First understand their needs (time of day, mood, budget), then suggest specific places
$locationGuidance
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
  }

  /// Legacy system prompt getter (for backwards compatibility)
  String get systemPrompt => buildSystemPrompt();

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

  /// Build expense detection prompt with context
  String buildExpenseDetectionPrompt({TravelContext? context}) {
    final contextSection = context != null ? '''

📍 CURRENT TRIP CONTEXT:
${context.toContextString()}
''' : '';

    final destination = context?.destination;
    final locationSection = destination != null ? '''

🗺️ PLACE RECOMMENDATIONS FOR $destination:
When user asks for recommendations or where to go:
1. Ask clarifying questions first (what are you in the mood for? budget? time of day?)
2. Suggest 2-3 specific places with details
3. For each place, include: Name, neighborhood/area, why it's good, price range, best time
4. After recommending, include place data in JSON block for Google Maps links

PLACE DATA FORMAT (include at END of message when recommending places):
###PLACES_DATA###
[
  {"name": "Place Name", "category": "restaurant", "address": "Neighborhood, $destination", "description": "Brief description", "price_level": "\$\$", "best_time_to_visit": "evening"},
  {"name": "Another Place", "category": "attraction", "address": "Area, $destination", "description": "Why visit", "estimated_duration": "2 hours"}
]
###END_PLACES_DATA###

Categories for places: restaurant, cafe, bar, attraction, museum, temple, market, park, beach, shopping, nightlife, activity
''' : '';

    return '''
You are TripBuddy, a warm and friendly AI travel companion who helps document travel experiences AND track expenses.
$contextSection
🎯 YOUR PRIMARY FOCUS: EXPERIENCES FIRST!
- When user shares ANYTHING, show genuine interest in their experience
- Ask follow-up questions about what they saw, felt, tasted
- Help them capture travel memories, not just transactions
- NEVER make conversations feel like expense tracking
$locationSection
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
{"amount": 25.50, "currency": "USD", "category": "food", "description": "Lunch at cafe", "date": "${DateTime.now().toIso8601String().split('T').first}"}
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
  }

  /// Legacy getter for backwards compatibility
  String get expenseDetectionPrompt => buildExpenseDetectionPrompt();

  /// Send a message with expense detection and place recommendations
  Future<AIResponse> sendMessageWithExpenseDetection({
    required String message,
    List<ChatMessage>? history,
    TravelContext? context,
    String? model,
  }) async {
    if (_apiKey.isEmpty) {
      throw AIException('OpenAI API key not configured');
    }

    try {
      final systemPrompt = buildExpenseDetectionPrompt(context: context);
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
          'max_tokens': 1500, // Increased for place recommendations
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

  /// Parse AI response to extract expense data and place recommendations if present
  AIResponse _parseAIResponse(String content) {
    String messagePart = content;
    ParsedExpense? expense;
    List<PlaceRecommendation> places = [];

    // Extract expense data
    const expenseStartMarker = '###EXPENSE_DATA###';
    const expenseEndMarker = '###END_EXPENSE_DATA###';

    final expenseStartIndex = messagePart.indexOf(expenseStartMarker);
    final expenseEndIndex = messagePart.indexOf(expenseEndMarker);

    if (expenseStartIndex != -1 && expenseEndIndex != -1 && expenseEndIndex > expenseStartIndex) {
      final beforeExpense = messagePart.substring(0, expenseStartIndex);
      final afterExpense = messagePart.substring(expenseEndIndex + expenseEndMarker.length);
      messagePart = (beforeExpense + afterExpense).trim();

      final jsonStart = expenseStartIndex + expenseStartMarker.length;
      final jsonString = content.substring(jsonStart, expenseEndIndex).trim();

      try {
        final expenseJson = jsonDecode(jsonString) as Map<String, dynamic>;
        expense = ParsedExpense.fromJson(expenseJson);
      } catch (e) {
        debugPrint('Failed to parse expense JSON: $e');
      }
    }

    // Extract place recommendations
    const placesStartMarker = '###PLACES_DATA###';
    const placesEndMarker = '###END_PLACES_DATA###';

    final placesStartIndex = messagePart.indexOf(placesStartMarker);
    final placesEndIndex = messagePart.indexOf(placesEndMarker);

    if (placesStartIndex != -1 && placesEndIndex != -1 && placesEndIndex > placesStartIndex) {
      final beforePlaces = messagePart.substring(0, placesStartIndex);
      final afterPlaces = messagePart.substring(placesEndIndex + placesEndMarker.length);
      messagePart = (beforePlaces + afterPlaces).trim();

      // Extract from original content to get correct JSON substring
      final placesJsonString = content.substring(
        content.indexOf(placesStartMarker) + placesStartMarker.length,
        content.indexOf(placesEndMarker)
      ).trim();

      try {
        final placesJson = jsonDecode(placesJsonString) as List;
        places = placesJson
            .map((p) => PlaceRecommendation.fromJson(p as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('Failed to parse places JSON: $e');
      }
    }

    // Clean up any remaining markers from message
    messagePart = messagePart
        .replaceAll(expenseStartMarker, '')
        .replaceAll(expenseEndMarker, '')
        .replaceAll(placesStartMarker, '')
        .replaceAll(placesEndMarker, '')
        .trim();

    if (messagePart.isEmpty) {
      messagePart = expense != null
          ? 'Got it! I\'ve recorded your expense.'
          : 'Here are my recommendations!';
    }

    return AIResponse(
      message: messagePart,
      expense: expense,
      places: places,
    );
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

  /// Generate a welcome message for a new trip with local tips
  Future<String> generateTripWelcome({
    required TravelContext context,
    String? model,
  }) async {
    if (_apiKey.isEmpty) {
      throw AIException('OpenAI API key not configured');
    }

    if (context.destination == null) {
      return "Welcome to TripBuddy! I'm here to help you plan and document your travels. What would you like to explore?";
    }

    try {
      final prompt = '''
Generate a warm, helpful welcome message for someone traveling to ${context.destination}.

Trip details:
${context.toContextString()}

Include in your response:
1. A warm greeting mentioning their destination
2. 2-3 practical local tips (currency, tipping, customs)
3. 1-2 safety tips if relevant
4. 1-2 must-try local experiences or foods
5. Offer to help with recommendations

Keep the tone friendly and conversational like a knowledgeable friend.
Use 1-2 emojis max.
Keep it concise (under 200 words).

Do NOT include any JSON blocks or markers.
''';

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': model ?? _defaultModel,
          'messages': [ChatMessage.user(prompt).toJson()],
          'temperature': 0.8,
          'max_tokens': 500,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final choices = data['choices'] as List;
        if (choices.isNotEmpty) {
          return (choices[0]['message']['content'] as String).trim();
        }
        throw AIException('No response from AI');
      } else {
        throw AIException(
          'API request failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('AI Service Error generating welcome: ${e.message}');
      // Return a basic welcome on error
      return "Welcome to ${context.destination}! I'm TripBuddy, your travel companion. I'm here to help you discover amazing places, document your experiences, and track expenses. What would you like to explore first?";
    } catch (e) {
      debugPrint('Error generating welcome: $e');
      return "Welcome to ${context.destination}! I'm TripBuddy, your travel companion. I'm here to help you discover amazing places, document your experiences, and track expenses. What would you like to explore first?";
    }
  }

  /// Generate location-specific recommendations
  Future<AIResponse> getRecommendations({
    required String query,
    required TravelContext context,
    String? model,
  }) async {
    if (_apiKey.isEmpty) {
      throw AIException('OpenAI API key not configured');
    }

    final destination = context.destination ?? 'your destination';

    try {
      final prompt = '''
The user is in $destination and asks: "$query"

${context.toContextString()}

Provide 3-5 specific recommendations. For each:
1. Name of the place
2. What makes it special
3. Price range (\$, \$\$, \$\$\$, or \$\$\$\$)
4. Best time to visit
5. Pro tip or must-try item

Be specific with real places. After your recommendations, ask a follow-up question to understand their preferences better.

Include place data at the end for Google Maps integration:
###PLACES_DATA###
[{"name": "Place Name", "category": "type", "address": "Location, $destination", "description": "Why visit", "price_level": "\$\$", "best_time_to_visit": "evening"}]
###END_PLACES_DATA###
''';

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': model ?? _defaultModel,
          'messages': [
            ChatMessage.system(buildSystemPrompt(context: context)).toJson(),
            ChatMessage.user(prompt).toJson(),
          ],
          'temperature': 0.8,
          'max_tokens': 1500,
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
      throw AIException(e.message ?? 'Network error');
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException('Failed to get recommendations: $e');
    }
  }

  /// System prompt for generating daily destination tips - LOCAL EXPERT
  String _buildDayTipPrompt(String destination, String category) {
    final categoryDescriptions = {
      'money': '''ATMs and currency exchange:
- Compare different ATM networks and their fees
- Explain which banks/ATMs to USE and which to AVOID (and why)
- Tips on exchange rates, hidden fees, dynamic currency conversion traps
- Card acceptance realities, cash-only situations
- Tipping norms and amounts''',
      'medical': '''Healthcare and pharmacies:
- How to find pharmacies (chain names, 24h options)
- Common medications and their local names/availability
- What requires prescription vs over-the-counter
- Hospital/clinic options for tourists (quality varies!)
- Health precautions specific to the region''',
      'connectivity': '''SIM cards and internet:
- Compare ALL major carriers (coverage, speed, price)
- Where to buy (official stores vs convenience stores - pros/cons)
- What to AVOID (tourist trap SIM deals, overpriced airport options)
- Typical data packages and realistic prices
- eSIM options if available
- WiFi availability and free hotspot locations''',
      'customs': '''Cultural etiquette:
- Greetings and physical contact norms
- Dress codes for different situations (temples, restaurants, business)
- Topics to avoid in conversation
- Gift-giving etiquette
- Religious and cultural sensitivities
- Common misunderstandings tourists make''',
      'safety': '''Safety awareness:
- Neighborhoods/areas to avoid (especially at night)
- Common petty crimes and how to prevent them
- Safe transportation options vs risky ones
- Police and emergency contacts
- What NOT to do that tourists commonly do wrong''',
      'transport': '''Getting around:
- Compare transport options (metro, bus, taxi, rideshare, motorbike)
- Which apps to download and use
- Typical prices so you don\'t get overcharged
- Tricks drivers use on tourists and how to avoid them
- Best value options for different situations''',
      'food': '''Food and dining:
- Must-try local dishes and where to find authentic versions
- Street food safety - what to look for, what to avoid
- Price ranges so you know if you\'re being overcharged
- Local dining customs and etiquette
- Vegetarian/allergy considerations
- Food scams to watch out for''',
      'scams': '''Tourist scams to avoid:
- Specific scams common in this destination
- How scammers approach tourists
- Red flags to watch for
- How to respond/escape if targeted
- Areas where scams are most common''',
      'language': '''Language tips:
- Essential phrases that actually help
- Common misunderstandings
- How to communicate when there\'s a language barrier
- Translation app tips
- Polite vs rude - words/gestures to avoid''',
      'weather': '''Weather and clothing:
- What to actually wear (not just temperature but humidity, rain, sun)
- Indoor vs outdoor temperature differences (AC!)
- Seasonal considerations
- Items tourists forget but really need
- Weather-related health tips''',
      'shopping': '''Shopping smart:
- Where locals shop vs tourist traps
- Fair prices for common items
- Quality indicators - real vs fake
- Return policies and consumer rights
- Best areas for specific items''',
      'nightlife': '''Nightlife safety:
- Safe areas for going out
- Drink safety (spiking, fake alcohol)
- Cover charges and hidden fees
- Getting home safely at night
- What to avoid''',
      'emergency': '''Emergency preparedness:
- Emergency numbers (police, ambulance, fire)
- Nearest embassy/consulate info
- What to do if passport is lost/stolen
- Hospital emergency procedures
- Insurance and payment for emergencies''',
      'water': '''Water and hygiene:
- Tap water safety (drinking, brushing teeth, ice)
- Bottled water - authentic vs refilled bottles
- Food hygiene indicators
- Hand sanitizer and hygiene tips
- Stomach issues - prevention and treatment''',
      'photography': '''Photography etiquette:
- Where photography is prohibited or frowned upon
- Asking permission - when and how
- Sensitive subjects to avoid photographing
- Drone regulations
- Best times/spots for photos''',
      'bargaining': '''Bargaining and negotiation:
- When bargaining is expected vs offensive
- Starting price strategies
- Walking away technique
- Fair prices for common tourist items
- Fixed price vs negotiable situations''',
      'general': 'practical daily tips for visitors',
    };

    final categoryFocus = categoryDescriptions[category] ?? categoryDescriptions['general']!;

    return '''
You are a SEASONED TRAVELER and LOCAL EXPERT who has lived in $destination for many years. You\'ve seen every tourist mistake, know every trick, and genuinely want to help travelers have a safe, authentic, and budget-smart experience.

Generate ONE practical daily tip for a traveler visiting $destination.

CATEGORY: $category

FOCUS AREAS FOR THIS CATEGORY:
$categoryFocus

CRITICAL REQUIREMENTS:
1. Present OPTIONS - don\'t just recommend one thing, compare alternatives
2. Explain what to AVOID and WHY - this is often more valuable than recommendations
3. Be SPECIFIC to $destination - generic advice is useless
4. Include realistic PRICES in local currency when relevant
5. Be PRACTICAL - something they can actually use
6. Keep it CONCISE - 3-4 sentences maximum, but packed with value
7. Include a SHORT catchy title (max 6 words)

EXAMPLES OF EXCELLENT TIPS:

Money: "ATM Fees: Know Before You Go"
"In Bangkok, Kasikorn (green) and Bangkok Bank (blue) ATMs charge 220 THB per withdrawal, while Aeon ATMs (in malls) are FREE for international cards. AVOID orange CIMB ATMs - they charge 250 THB AND have poor exchange rates. Always decline \'conversion to home currency\' - it\'s a 3-5% hidden fee."

Connectivity: "Skip the Airport SIM Booth"
"Airport SIM shops charge 2-3x more. Instead, any 7-Eleven sells AIS, TRUE, and DTAC SIMs for 299-399 THB with 15-30GB data. TRUE has best city coverage, AIS best for rural areas. Bring passport - required for registration. Pro tip: eSIMs via Airalo app work great and you can set up before landing."

Scams: "The Friendly Local Warning"
"If someone approaches saying \'the temple/palace is closed today\' - it\'s ALWAYS a scam to redirect you to a gem shop or tailor. Verify closures yourself. Similarly, tuk-tuk drivers offering \'20 baht tours\' will take you to commission shops. If it sounds too cheap, you\'re the product."

Water: "Ice Cube Intelligence"
"Tubular/hollow ice cubes (made in factories) are safe - they\'re made from purified water. Avoid irregular crushed ice at street stalls. Bottled water: check the seal isn\'t broken and the cap has a safety ring. Brands like Singha, Crystal, Nestle are reliable; avoid unknown brands with suspiciously low prices."

Respond in this exact JSON format:
{
  "title": "short catchy title",
  "content": "the practical tip with specific details, options, and what to avoid",
  "category": "$category"
}

Do not include any text outside the JSON object.
''';
  }

  /// Generate a daily practical tip for a destination
  Future<GeneratedTipContent> generateDayTip({
    required String destination,
    required String category,
    String? model,
  }) async {
    if (_apiKey.isEmpty) {
      throw AIException('OpenAI API key not configured');
    }

    try {
      final systemPrompt = _buildDayTipPrompt(destination, category);

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': model ?? _defaultModel,
          'messages': [
            ChatMessage.system(systemPrompt).toJson(),
            ChatMessage.user('Generate a $category tip for $destination.').toJson(),
          ],
          'temperature': 0.9,
          'max_tokens': 300,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final choices = data['choices'] as List;
        if (choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String;
          return _parseDayTipResponse(content, category);
        }
        throw AIException('No response from AI');
      } else {
        throw AIException(
          'API request failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('AI Service Error generating day tip: ${e.message}');
      // Return a default tip on error
      return GeneratedTipContent(
        title: 'Travel Tip',
        content: 'Check local guides for the best recommendations in $destination!',
        category: category,
      );
    } catch (e) {
      debugPrint('Error generating day tip: $e');
      return GeneratedTipContent(
        title: 'Travel Tip',
        content: 'Explore $destination like a local - ask hotel staff for insider tips!',
        category: category,
      );
    }
  }

  /// Parse the day tip response
  GeneratedTipContent _parseDayTipResponse(String content, String fallbackCategory) {
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
      return GeneratedTipContent.fromJson(json);
    } catch (e) {
      debugPrint('Failed to parse day tip response: $e');
      debugPrint('Raw content: $content');
      // Return the content as-is if parsing fails
      return GeneratedTipContent(
        title: 'Daily Tip',
        content: content.length > 300 ? content.substring(0, 300) : content,
        category: fallbackCategory,
      );
    }
  }

  /// Generate an AI budget estimate for a trip
  Future<BudgetEstimate> generateBudgetEstimate({
    required String destination,
    required int tripDays,
    required String currency,
    String? model,
  }) async {
    if (_apiKey.isEmpty) {
      throw AIException('OpenAI API key not configured');
    }

    try {
      final systemPrompt = '''
You are a travel budget expert with extensive knowledge of travel costs worldwide.

Generate a realistic daily budget estimate for a traveler visiting $destination for $tripDays days.

Consider ACTUAL current costs (2024-2025 prices) for:
- Accommodation: mid-range hotels/Airbnb (not hostels, not luxury)
- Food: mix of local restaurants and street food (3 meals/day)
- Local transport: public transit, occasional taxi/Uber
- Activities: 1-2 tourist attractions per day, entrance fees
- Miscellaneous: SIM card, water, snacks, tips

DO NOT include:
- International flights
- Travel insurance
- Shopping/souvenirs (varies too much)

Provide the budget in $currency.

IMPORTANT: Be realistic and specific to $destination. Costs vary dramatically by country:
- Southeast Asia: \$30-60/day
- Western Europe: \$100-180/day
- Japan: \$80-150/day
- USA major cities: \$120-200/day
- Eastern Europe: \$50-90/day

Respond ONLY in this exact JSON format:
{
  "daily_budget": 85,
  "total_budget": 850,
  "breakdown": {
    "accommodation": 45,
    "food": 25,
    "transport": 8,
    "activities": 15,
    "misc": 7
  },
  "tips": "Brief 1-sentence money-saving tip specific to this destination"
}
''';

      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': model ?? _defaultModel,
          'messages': [
            ChatMessage.system(systemPrompt).toJson(),
            ChatMessage.user('Generate a $tripDays-day budget for $destination in $currency.').toJson(),
          ],
          'temperature': 0.3,
          'max_tokens': 300,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final choices = data['choices'] as List;
        if (choices.isNotEmpty) {
          final content = choices[0]['message']['content'] as String;
          return _parseBudgetResponse(content, tripDays, currency);
        }
        throw AIException('No response from AI');
      } else {
        throw AIException(
          'API request failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      debugPrint('AI Service Error generating budget: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Error generating budget: $e');
      rethrow;
    }
  }

  /// Parse the budget response
  BudgetEstimate _parseBudgetResponse(String content, int tripDays, String currency) {
    try {
      // Clean the response
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
      return BudgetEstimate(
        dailyBudget: (json['daily_budget'] as num).toDouble(),
        totalBudget: (json['total_budget'] as num).toDouble(),
        breakdown: Map<String, double>.from(
          (json['breakdown'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toDouble())),
        ),
        tips: json['tips'] as String? ?? '',
        currency: currency,
        tripDays: tripDays,
      );
    } catch (e) {
      debugPrint('Failed to parse budget response: $e');
      debugPrint('Raw content: $content');
      rethrow;
    }
  }
}

/// Budget estimate model
class BudgetEstimate {
  final double dailyBudget;
  final double totalBudget;
  final Map<String, double> breakdown;
  final String tips;
  final String currency;
  final int tripDays;

  const BudgetEstimate({
    required this.dailyBudget,
    required this.totalBudget,
    required this.breakdown,
    required this.tips,
    required this.currency,
    required this.tripDays,
  });
}

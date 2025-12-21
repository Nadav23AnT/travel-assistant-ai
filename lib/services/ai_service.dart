import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../config/env.dart';
import '../data/models/day_tip_model.dart';
import '../data/models/journal_model.dart';
import '../data/models/travel_context.dart';
import 'ai/ai_provider_interface.dart';
import 'ai/ai_router.dart';
import 'token_usage_service.dart';

class AIException implements Exception {
  final String message;
  final int? statusCode;
  final bool isTokenLimitExceeded;

  AIException(this.message, {this.statusCode, this.isTokenLimitExceeded = false});

  @override
  String toString() => message;

  /// Create from AIProviderException
  factory AIException.fromProviderException(AIProviderException e) {
    return AIException(
      e.message,
      statusCode: e.statusCode,
    );
  }
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
  final String? searchUrl; // Google Maps search URL for "see more"

  const AIResponse({
    required this.message,
    this.expense,
    this.places = const [],
    this.searchUrl,
  });

  /// Check if response contains place recommendations
  bool get hasPlaces => places.isNotEmpty;
}

/// Main AI Service that routes requests to the appropriate provider
/// based on feature configuration.
class AIService {
  final AIRouter _router;
  final TokenUsageService _tokenUsageService;

  AIService({
    AIRouter? router,
    TokenUsageService? tokenUsageService,
  })  : _router = router ?? AIRouter(),
        _tokenUsageService = tokenUsageService ?? TokenUsageService();

  /// Check credit limit before making an AI request
  /// Throws AIException with isTokenLimitExceeded=true if limit exceeded
  Future<void> _checkTokenLimit() async {
    try {
      final result = await _tokenUsageService.checkBeforeRequest();
      if (!result.canProceed) {
        throw AIException(
          result.errorMessage ?? 'Daily credit limit exceeded. Please try again tomorrow.',
          isTokenLimitExceeded: true,
        );
      }
    } catch (e) {
      if (e is AIException) rethrow;
      // On service errors, allow the request to proceed (fail-open)
      debugPrint('Credit limit check failed, allowing request: $e');
    }
  }

  /// Record token usage after a successful AI request
  Future<void> _recordTokenUsage(int tokensUsed) async {
    if (tokensUsed > 0) {
      try {
        await _tokenUsageService.recordUsage(tokensUsed);
      } catch (e) {
        debugPrint('Failed to record token usage: $e');
        // Don't throw - don't break user experience for tracking failures
      }
    }
  }

  /// Get current token usage status for display
  Future<TokenCheckResult> getTokenUsageStatus() async {
    return _tokenUsageService.checkBeforeRequest();
  }

  /// Check if any AI feature is configured
  bool get isConfigured => Env.hasOpenAI || Env.hasOpenRouter || Env.hasGoogleAI;

  /// System prompt for the travel assistant - Travel Chat Companion
  String buildSystemPrompt({TravelContext? context}) {
    // Determine response language
    final languageCode = context?.appLanguage ?? 'en';
    final languageName = context?.appLanguageDisplayName ?? 'English';
    final languageInstruction = languageCode != 'en' ? '''

LANGUAGE: Respond in $languageName ($languageCode).
''' : '';

    final contextSection = context != null ? '''

TRIP CONTEXT:
${context.toContextString()}
Use this context to personalize every response. Reference places they've mentioned.
''' : '';

    final locationGuidance = context?.destination != null ? '''

RECOMMENDATIONS FOR ${context!.destination}:
Format: "• **[Place]** in [Area] - [Why + one practical detail]"
Give 2-3 specific options, then ONE follow-up question.
''' : '';

    return '''
# IDENTITY
You are Waylo, a travel companion who helps travelers capture memories, track spending, and discover their destination. You're the friend who's been everywhere and remembers the details that matter.
$languageInstruction$contextSection
# VOICE
- Warm but efficient - every word earns its place
- Curious about experiences, not interrogating about logistics
- One emoji maximum per message, used for warmth not decoration
- 2-3 sentences default; expand only when providing recommendations
- Never use: "That sounds amazing!", "I'd love to hear more!", "Let me know if..."

# DECISION HIERARCHY
When user input contains multiple elements, prioritize:
1. **Safety concerns** → Address immediately, provide resources
2. **Experience sharing** → Acknowledge, ask one follow-up about feelings/senses
3. **Recommendations requested** → Give 2-3 options with one-line rationale each
4. **Expense mentioned** → Log silently, pivot to experience
5. **Logistics questions** → Answer directly, offer one related tip

# BEHAVIORAL RULES
**ALWAYS:**
- Lead with value before asking questions
- When user mentions spending → acknowledge in ≤5 words, then ask about the experience
- When giving recommendations → name specific places, not generic categories
- Assume local currency unless user specifies otherwise

**NEVER:**
- Ask more than one question per message
- Start a conversation about expenses
- Use phrases that delay value: "I can help with that", "Great question"
- Make users repeat information they've already shared
- Provide medical, legal, or emergency advice beyond "seek professional help"
$locationGuidance
# JOURNAL CONTRIBUTION
Listen actively for journal-worthy moments:
- Sensory details (tastes, sounds, smells)
- Emotional moments (surprises, joys, frustrations)
- People encountered, unexpected discoveries

Prompt naturally: "What did it smell like?", "How did that make you feel?"

# EXPENSE HANDLING
When expenses come up:
- Acknowledge in ≤5 words: "Got it!" or "Noted!"
- ALWAYS pivot to experience: "How was the food?"
- Never make it feel like accounting

Example:
User: "Spent 500 baht on dinner"
→ "Got it! What'd you try?"

# SAFETY ESCALATION
For emergencies (danger, medical, legal):
→ "Please contact local emergency services or your embassy."
For feeling unsafe:
→ "Trust your instincts. Is there somewhere safe you can go?"

# UNCERTAINTY
- Admit when you don't know: "I'm not sure about current hours"
- Never invent specific prices, hours, or availability
- Offer alternatives: "You could check Google Maps, or I can suggest similar spots"
''';
  }

  /// Legacy system prompt getter (for backwards compatibility)
  String get systemPrompt => buildSystemPrompt();

  /// Send a message and get a response
  /// Uses AI_CHAT feature configuration
  Future<String> sendMessage({
    required String message,
    List<ChatMessage>? history,
    String? model, // Deprecated - use .env configuration instead
  }) async {
    // Check token limit before making request
    await _checkTokenLimit();

    try {
      final provider = _router.getProviderForFeature(AIFeature.aiChat);

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

      final response = await provider.complete(
        messages: messages,
        temperature: 0.7,
        maxTokens: 1024,
      );

      // Record token usage after successful response
      await _recordTokenUsage(response.tokensUsed);

      return response.content;
    } on AIProviderException catch (e) {
      debugPrint('AI Service Error: ${e.message}');
      throw AIException.fromProviderException(e);
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException('Failed to get AI response: $e');
    }
  }

  /// Stream a response (for future use)
  /// Uses AI_CHAT feature configuration
  Stream<String> streamMessage({
    required String message,
    List<ChatMessage>? history,
    String? model, // Deprecated - use .env configuration instead
  }) async* {
    try {
      final provider = _router.getProviderForFeature(AIFeature.aiChat);

      final messages = <Map<String, dynamic>>[
        ChatMessage.system(systemPrompt).toJson(),
      ];

      if (history != null && history.isNotEmpty) {
        messages.addAll(history.map((m) => m.toJson()));
      }

      messages.add(ChatMessage.user(message).toJson());

      yield* provider.streamComplete(
        messages: messages,
        temperature: 0.7,
        maxTokens: 1024,
      );
    } on AIProviderException catch (e) {
      throw AIException.fromProviderException(e);
    }
  }

  /// Build expense detection prompt with context
  String buildExpenseDetectionPrompt({TravelContext? context}) {
    final contextSection = context != null ? '''

TRIP CONTEXT:
${context.toContextString()}
''' : '';

    final destination = context?.destination;
    final defaultCurrency = context?.budgetCurrency ?? 'USD';
    final locationSection = destination != null ? '''

# PLACE RECOMMENDATIONS FOR $destination

**WHEN TO RECOMMEND PLACES:**
- User asks "where should I eat/go/visit?"
- User asks for recommendations, suggestions, tips
- User mentions wanting to find something (restaurant, cafe, attraction, etc.)

**ALWAYS include place data when recommending!**

**Response format:**
Give 5 specific places with this structure:
"• **[Place Name]** in [Neighborhood] - [One sentence why]. [Price] | [Best time]"

Then add a "See more" link for Google Maps search.

**REQUIRED: Include PLACES_DATA block at END with search_url for "see more":**
###PLACES_DATA###
{
  "places": [
    {"name": "Place 1", "category": "restaurant", "address": "Area, $destination", "description": "Why", "price_level": "\$\$", "best_time_to_visit": "evening"},
    {"name": "Place 2", "category": "restaurant", "address": "Area, $destination", "description": "Why", "price_level": "\$", "best_time_to_visit": "anytime"}
  ],
  "search_query": "best restaurants in $destination",
  "search_url": "https://www.google.com/maps/search/best+restaurants+in+$destination"
}
###END_PLACES_DATA###

Categories: restaurant, cafe, bar, attraction, museum, temple, market, park, beach, shopping, nightlife, activity

**Example:**
User: "Where should I eat tonight?"
Response: "Here are my top 5 picks for dinner tonight:

• **Gaggan Anand** in Thonglor - Progressive Indian, worth the splurge. \$\$\$\$ | dinner
• **Jay Fai** in Old Town - Legendary crab omelette. \$\$\$ | dinner
• **Som Tam Jay So** in Silom - Best papaya salad in town. \$ | anytime
• **Err Urban Rustic Thai** in Tha Tien - Modern Thai street food. \$\$ | dinner
• **Thipsamai** in Phra Nakhon - Famous pad thai since 1966. \$ | dinner

Want me to narrow it down? 🍜

###PLACES_DATA###
{"places": [{"name": "Gaggan Anand", "category": "restaurant", "address": "Thonglor, Bangkok", "description": "Progressive Indian cuisine", "price_level": "\$\$\$\$", "best_time_to_visit": "dinner"},{"name": "Jay Fai", "category": "restaurant", "address": "Old Town, Bangkok", "description": "Legendary crab omelette", "price_level": "\$\$\$", "best_time_to_visit": "dinner"},{"name": "Som Tam Jay So", "category": "restaurant", "address": "Silom, Bangkok", "description": "Best papaya salad", "price_level": "\$", "best_time_to_visit": "anytime"},{"name": "Err Urban Rustic Thai", "category": "restaurant", "address": "Tha Tien, Bangkok", "description": "Modern Thai street food", "price_level": "\$\$", "best_time_to_visit": "dinner"},{"name": "Thipsamai", "category": "restaurant", "address": "Phra Nakhon, Bangkok", "description": "Famous pad thai since 1966", "price_level": "\$", "best_time_to_visit": "dinner"}], "search_query": "best restaurants Bangkok dinner", "search_url": "https://www.google.com/maps/search/best+restaurants+Bangkok+dinner"}
###END_PLACES_DATA###"
''' : '';

    return '''
# ROLE
You are Waylo, a travel companion who helps document experiences AND track expenses. Experience always comes first.
$contextSection
# PRIMARY FOCUS: EXPERIENCES
- Show genuine interest in what users share
- Ask about what they saw, felt, tasted
- Help capture memories, not transactions
$locationSection
# EXPENSE EXTRACTION

**Confidence thresholds:**
- ≥90%: Log immediately (amount AND category clear)
- 70-89%: Log with natural clarification woven in
- <70%: Ask clarification naturally before logging

**Amount parsing:**
- "12 euros" → 12, EUR, confidence: 95%
- "about 50 bucks" → 50, USD, confidence: 70%
- "a few hundred" → null, needs clarification

**Currency inference:**
- Default: $defaultCurrency (trip currency)
- Symbols: \$ = USD, € = EUR, £ = GBP, ₪ = ILS, ¥ = JPY, ฿ = THB
- Codes: "50 EUR", "100 ILS", "500 THB"

**Category detection:**
- transport: taxi, uber, grab, bus, train, flight, metro, gas, parking
- accommodation: hotel, hostel, airbnb, booking, room, night, stay
- food: restaurant, cafe, lunch, dinner, breakfast, coffee, drinks, bar, meal
- activities: museum, tour, ticket, entrance, show, concert, temple, excursion
- shopping: souvenirs, clothes, gifts, market, store, shop, bought
- other: default when unclear

# RESPONSE PATTERNS

**Expense clear:**
User: "Paid 45 euros for the museum"
→ "Worth every euro? What was the highlight?"

**Expense unclear (amount):**
User: "Splurged on dinner tonight"
→ "A proper feast! What did you order? Roughly how much was the splurge?"

**Expense unclear (category):**
User: "Spent 200 baht at the place near the temple"
→ "Near temples is always interesting. What was it - food, a shop?"

**No expense:**
User: "The sunset was incredible"
→ "Those are the moments. Where were you watching from?"

**Multiple expenses:**
User: "Took a 300 baht taxi and spent 500 on lunch"
→ Extract both, respond to experience: "Market lunch! What was good?"

# EXPENSE DATA FORMAT
If expense detected with ≥70% confidence, include at END:
###EXPENSE_DATA###
{"amount": 25.50, "currency": "USD", "category": "food", "description": "Lunch at cafe", "date": "${DateTime.now().toIso8601String().split('T').first}"}
###END_EXPENSE_DATA###

# ANTI-PATTERNS
Never say:
- "I've logged your expense of..." (accounting voice)
- "That's added to your spending" (transactional)
- "Your total is now..." (unsolicited tracking)

# JOURNAL MINDSET
Every conversation should generate memories. Listen for:
- Sensory details, emotional moments, discoveries
- Prompt naturally: "What surprised you?", "Would you go back?"
''';
  }

  /// Legacy getter for backwards compatibility
  String get expenseDetectionPrompt => buildExpenseDetectionPrompt();

  /// Send a message with expense detection and place recommendations
  /// Uses AI_CHAT feature configuration
  Future<AIResponse> sendMessageWithExpenseDetection({
    required String message,
    List<ChatMessage>? history,
    TravelContext? context,
    String? model, // Deprecated - use .env configuration instead
  }) async {
    // Check token limit before making request
    await _checkTokenLimit();

    try {
      final provider = _router.getProviderForFeature(AIFeature.aiChat);

      final systemPrompt = buildExpenseDetectionPrompt(context: context);
      final messages = <Map<String, dynamic>>[
        ChatMessage.system(systemPrompt).toJson(),
      ];

      if (history != null && history.isNotEmpty) {
        messages.addAll(history.map((m) => m.toJson()));
      }

      messages.add(ChatMessage.user(message).toJson());

      final response = await provider.complete(
        messages: messages,
        temperature: 0.7,
        maxTokens: 1500, // Increased for place recommendations
      );

      // Record token usage after successful response
      await _recordTokenUsage(response.tokensUsed);

      return _parseAIResponse(response.content);
    } on AIProviderException catch (e) {
      debugPrint('AI Service Error: ${e.message}');
      throw AIException.fromProviderException(e);
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
    String? searchUrl;

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
        final decoded = jsonDecode(placesJsonString);

        // Handle both formats: array or object with "places" key
        if (decoded is List) {
          // Old format: direct array
          places = decoded
              .map((p) => PlaceRecommendation.fromJson(p as Map<String, dynamic>))
              .toList();
        } else if (decoded is Map<String, dynamic>) {
          // New format: object with places array and search_url
          final placesArray = decoded['places'] as List?;
          if (placesArray != null) {
            places = placesArray
                .map((p) => PlaceRecommendation.fromJson(p as Map<String, dynamic>))
                .toList();
          }
          searchUrl = decoded['search_url'] as String?;
        }
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
      searchUrl: searchUrl,
    );
  }

  /// System prompt for journal entry generation - EXPERIENCE FOCUSED
  String get journalGenerationPrompt => '''
# ROLE
Transform a day's conversations into a personal travel journal entry the traveler will treasure.

# OUTPUT FORMAT
```json
{
  "title": "Evocative 3-6 word title",
  "content": "200-400 word first-person narrative",
  "mood": "excited|relaxed|tired|adventurous|inspired|grateful|reflective",
  "highlights": ["2-4 memorable moments"],
  "locations": ["places mentioned"]
}
```

# WRITING PRINCIPLES

**Voice:**
- First person, present tense for immediacy
- Conversational but literary - like a well-written blog
- Specific over generic: "the old woman selling mangoes" not "a local vendor"

**Sensory hierarchy (prioritize what user actually shared):**
1. What they explicitly described (use their words)
2. What they implied (reasonable inference)
3. Atmospheric details for location (use sparingly)

**Extract from conversations:**
- Food: What they ate, tasted, where, with whom
- Places: What they saw, how it felt, what surprised them
- People: Interactions, characters, connections
- Emotions: Joy, frustration, wonder, exhaustion

**Expense integration (weave naturally):**
- "The 15-euro wine was worth it for the sunset alone"
- "After burning through 40 euros on taxis, I finally figured out the metro"
- Never list expenses separately

# STRUCTURE OPTIONS
- **Chronological** (default): Morning → Evening
- **Thematic**: When day had distinct themes
- **Single-moment**: When one experience dominated

# EXAMPLES

**Good:**
> **Down the Alley, Up the Learning Curve**
> There's a specific kind of triumph in finally understanding a city's transit system. After an hour of wandering in circles, something clicked. The reward: pad thai from a tiny alley place—maybe four tables—that I'd never have found without getting lost.

**Bad:**
> Today I explored Bangkok! I had delicious food and used public transportation. The pad thai was amazing. I spent 180 THB on food. It was a tiring but fulfilling day!

# SPARSE DATA HANDLING
When conversations are minimal:
- Shorter entry is better than padded
- Acceptable: "Some days are more doing than documenting. Ate well, walked far, slept hard."

# NEVER
- Invent details not mentioned or reasonably implied
- Use clichés: "hidden gem", "off the beaten path", "bucket list"
- Write more than 400 words
- Include expense totals as formal summary
''';

  /// Generate a journal entry from chat messages and day activities
  /// Uses JOURNAL_SUMMARY feature configuration
  Future<GeneratedJournalContent> generateJournalEntry({
    required List<ChatMessage> chatMessages,
    required DateTime date,
    String? tripDestination,
    List<ParsedExpense>? expenses,
    String? model, // Deprecated - use .env configuration instead
  }) async {
    // Check token limit before making request
    await _checkTokenLimit();

    try {
      final provider = _router.getProviderForFeature(AIFeature.journalSummary);

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

      final response = await provider.complete(
        messages: messages,
        temperature: 0.8,
        maxTokens: 1024,
      );

      // Record token usage after successful response
      await _recordTokenUsage(response.tokensUsed);

      return _parseJournalResponse(response.content);
    } on AIProviderException catch (e) {
      debugPrint('AI Service Error: ${e.message}');
      throw AIException.fromProviderException(e);
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException('Failed to generate journal entry: $e');
    }
  }

  /// Generate a short, descriptive title for a chat conversation
  /// Uses CHAT_TITLE feature configuration
  Future<String> generateChatTitle({
    required String userMessage,
    String? assistantResponse,
    String? tripDestination,
    String? language,
    String? model, // Deprecated - use .env configuration instead
  }) async {
    // Check token limit before making request
    await _checkTokenLimit();

    try {
      final provider = _router.getProviderForFeature(AIFeature.chatTitle);

      final languageInstruction = language != null && language != 'en'
          ? 'Generate the title in the same language as the user message (detected: $language).'
          : '';

      final tripContext = tripDestination != null
          ? 'Trip destination: $tripDestination'
          : '';

      final prompt = '''
Generate a short, descriptive title (3-6 words) for this travel chat conversation.
The title should capture the main topic or intent of the user's message.
$languageInstruction

$tripContext
User message: "$userMessage"
${assistantResponse != null ? 'Assistant response summary: "${assistantResponse.length > 200 ? assistantResponse.substring(0, 200) : assistantResponse}..."' : ''}

Rules:
- Maximum 6 words, ideally 3-5 words
- No quotes in the response
- Be specific and descriptive
- Focus on the main travel topic/activity/question
- Use action words when appropriate (Planning, Exploring, Finding, etc.)
- Include location if mentioned and relevant
- Good examples: "Planning Rome Itinerary", "Best Thai Street Food", "Temple Visit Tips", "Bangkok Budget Questions", "Tokyo Hotel Recommendations"
- Bad examples: "Travel Chat", "Question About Trip", "Help Needed"

Respond with ONLY the title, nothing else.
''';

      final messages = <Map<String, dynamic>>[
        ChatMessage.user(prompt).toJson(),
      ];

      final response = await provider.complete(
        messages: messages,
        temperature: 0.7,
        maxTokens: 50,
      );

      // Record token usage after successful response
      await _recordTokenUsage(response.tokensUsed);

      // Clean up the title - remove quotes, trim, and ensure it's not too long
      var title = response.content.trim().replaceAll('"', '').replaceAll("'", '');

      // Truncate if somehow still too long
      if (title.length > 50) {
        title = '${title.substring(0, 47)}...';
      }

      return title;
    } on AIProviderException catch (e) {
      debugPrint('AI Service Error generating title: ${e.message}');
      // Return a context-aware default title on error
      if (tripDestination != null) {
        return '$tripDestination Chat';
      }
      return 'Travel Chat';
    } catch (e) {
      debugPrint('Error generating title: $e');
      if (tripDestination != null) {
        return '$tripDestination Chat';
      }
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
  /// Uses TRIP_WELCOME feature configuration
  Future<String> generateTripWelcome({
    required TravelContext context,
    String? model, // Deprecated - use .env configuration instead
  }) async {
    if (context.destination == null) {
      return "Welcome to Waylo! I'm here to help you plan and document your travels. What would you like to explore?";
    }

    // Check token limit before making request
    await _checkTokenLimit();

    try {
      final provider = _router.getProviderForFeature(AIFeature.tripWelcome);

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

      final messages = <Map<String, dynamic>>[
        ChatMessage.user(prompt).toJson(),
      ];

      final response = await provider.complete(
        messages: messages,
        temperature: 0.8,
        maxTokens: 500,
      );

      // Record token usage after successful response
      await _recordTokenUsage(response.tokensUsed);

      return response.content;
    } on AIProviderException catch (e) {
      debugPrint('AI Service Error generating welcome: ${e.message}');
      // Return a basic welcome on error
      return "Welcome to ${context.destination}! I'm Waylo, your travel companion. I'm here to help you discover amazing places, document your experiences, and track expenses. What would you like to explore first?";
    } catch (e) {
      debugPrint('Error generating welcome: $e');
      return "Welcome to ${context.destination}! I'm Waylo, your travel companion. I'm here to help you discover amazing places, document your experiences, and track expenses. What would you like to explore first?";
    }
  }

  /// Generate location-specific recommendations
  /// Uses RECOMMENDATIONS feature configuration
  Future<AIResponse> getRecommendations({
    required String query,
    required TravelContext context,
    String? model, // Deprecated - use .env configuration instead
  }) async {
    // Check token limit before making request
    await _checkTokenLimit();

    final destination = context.destination ?? 'your destination';

    try {
      final provider = _router.getProviderForFeature(AIFeature.recommendations);

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

      final messages = <Map<String, dynamic>>[
        ChatMessage.system(buildSystemPrompt(context: context)).toJson(),
        ChatMessage.user(prompt).toJson(),
      ];

      final response = await provider.complete(
        messages: messages,
        temperature: 0.8,
        maxTokens: 1500,
      );

      // Record token usage after successful response
      await _recordTokenUsage(response.tokensUsed);

      return _parseAIResponse(response.content);
    } on AIProviderException catch (e) {
      debugPrint('AI Service Error: ${e.message}');
      throw AIException.fromProviderException(e);
    } catch (e) {
      if (e is AIException) rethrow;
      throw AIException('Failed to get recommendations: $e');
    }
  }

  /// System prompt for generating daily destination tips - LOCAL EXPERT
  String _buildDayTipPrompt(String destination, List<String> categories, String language) {
    return '''
# ROLE
Local expert generating 3 actionable daily tips for $destination.

# LANGUAGE
Respond in $language.

# REQUIREMENTS
- One tip per category: ${categories.join(', ')}
- SPECIFIC to $destination (no generic advice)
- Actionable TODAY
- 2-3 sentences max per tip
- Punchy title (max 5 words)

# EXAMPLES

**Good:**
> 🍜 **Khao Soi Before Noon**
> The famous Khao Soi Khun Yai closes when they sell out—usually by 1pm. Get there by 11 for the full menu.

**Bad:**
> 🌟 **Try Local Food Today!**
> Thailand has amazing cuisine. Why not explore some local restaurants?

# OUTPUT FORMAT
```json
{
  "tips": [
    {"title": "catchy title", "content": "practical tip", "category": "${categories[0]}"},
    {"title": "catchy title", "content": "practical tip", "category": "${categories[1]}"},
    {"title": "catchy title", "content": "practical tip", "category": "${categories[2]}"}
  ]
}
```
''';
  }

  /// Generate 3 daily practical tips for a destination
  /// Uses DAILY_TIP feature configuration
  Future<List<GeneratedTipContent>> generateDayTips({
    required String destination,
    required List<String> categories,
    String language = 'English',
    String? model, // Deprecated - use .env configuration instead
  }) async {
    // Check token limit before making request
    await _checkTokenLimit();

    try {
      final provider = _router.getProviderForFeature(AIFeature.dailyTip);

      final systemPrompt = _buildDayTipPrompt(destination, categories, language);

      final messages = <Map<String, dynamic>>[
        ChatMessage.system(systemPrompt).toJson(),
        ChatMessage.user('Generate 3 tips for $destination in categories: ${categories.join(', ')}.').toJson(),
      ];

      final response = await provider.complete(
        messages: messages,
        temperature: 0.9,
        maxTokens: 600,
      );

      // Record token usage after successful response
      await _recordTokenUsage(response.tokensUsed);

      return _parseDayTipsResponse(response.content, categories);
    } on AIProviderException catch (e) {
      debugPrint('AI Service Error generating day tips: ${e.message}');
      // Return default tips on error
      return categories.map((c) => GeneratedTipContent(
        title: 'Travel Tip',
        content: 'Check local guides for the best recommendations in $destination!',
        category: c,
      )).toList();
    } catch (e) {
      debugPrint('Error generating day tips: $e');
      return categories.map((c) => GeneratedTipContent(
        title: 'Travel Tip',
        content: 'Explore $destination like a local!',
        category: c,
      )).toList();
    }
  }

  /// Parse the day tips response
  List<GeneratedTipContent> _parseDayTipsResponse(String content, List<String> fallbackCategories) {
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
      final tipsJson = json['tips'] as List;

      return tipsJson.map((t) => GeneratedTipContent.fromJson(t as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Failed to parse day tips response: $e');
      debugPrint('Raw content: $content');
      // Return default tips if parsing fails
      return fallbackCategories.map((c) => GeneratedTipContent(
        title: 'Daily Tip',
        content: content.length > 100 ? content.substring(0, 100) : content,
        category: c,
      )).toList();
    }
  }

  /// Generate an AI budget estimate for a trip
  /// Uses BUDGET_ESTIMATE feature configuration
  Future<BudgetEstimate> generateBudgetEstimate({
    required String destination,
    required int tripDays,
    required String currency,
    String? model, // Deprecated - use .env configuration instead
  }) async {
    // Check token limit before making request
    await _checkTokenLimit();

    try {
      final provider = _router.getProviderForFeature(AIFeature.budgetEstimate);

      final systemPrompt = '''
# ROLE
Travel budget expert providing realistic estimates for $destination ($tripDays days).

# INCLUDE (mid-range style)
- Accommodation: mid-range hotels/Airbnb
- Food: local restaurants + street food (3 meals/day)
- Transport: public transit + occasional taxi
- Activities: 1-2 attractions/day
- Misc: SIM, water, snacks, tips

# EXCLUDE
- International flights, insurance, shopping

# REFERENCE RANGES (daily, mid-range)
- Southeast Asia: \$40-70
- Eastern Europe: \$60-100
- Japan: \$90-150
- Western Europe: \$120-180
- USA cities: \$140-220

# OUTPUT (in $currency)
```json
{
  "daily_budget": 85,
  "total_budget": 850,
  "breakdown": {"accommodation": 45, "food": 25, "transport": 8, "activities": 15, "misc": 7},
  "tips": "One money-saving tip specific to $destination"
}
```

Be conservative—overestimate slightly to avoid budget stress.
''';

      final messages = <Map<String, dynamic>>[
        ChatMessage.system(systemPrompt).toJson(),
        ChatMessage.user('Generate a $tripDays-day budget for $destination in $currency.').toJson(),
      ];

      final response = await provider.complete(
        messages: messages,
        temperature: 0.3,
        maxTokens: 300,
      );

      // Record token usage after successful response
      await _recordTokenUsage(response.tokensUsed);

      return _parseBudgetResponse(response.content, tripDays, currency);
    } on AIProviderException catch (e) {
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

  /// Get the AI router for direct provider access
  AIRouter get router => _router;

  /// Debug: Print AI configuration
  void debugPrintConfiguration() {
    _router.debugPrintConfiguration();
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

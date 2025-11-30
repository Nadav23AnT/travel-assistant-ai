/// AI Services Module
///
/// This module provides a feature-based AI routing system that allows
/// each AI feature to use a different provider and model, configured via .env.
///
/// ## Configuration
///
/// Each feature can be configured with:
/// - `<FEATURE>_PROVIDER`: The AI provider to use (openai, openrouter, google)
/// - `<FEATURE>_MODEL`: The model to use for that provider
///
/// Example .env:
/// ```
/// AI_CHAT_PROVIDER=openai
/// AI_CHAT_MODEL=gpt-4o-mini
/// DAILY_TIP_PROVIDER=google
/// DAILY_TIP_MODEL=gemini-1.5-flash
/// ```
///
/// ## Features
///
/// - `AI_CHAT`: Main travel chat with expense detection
/// - `CHAT_TITLE`: Auto-generated chat titles
/// - `TRIP_WELCOME`: Welcome messages for new trips
/// - `DAILY_TIP`: Daily destination-specific tips
/// - `JOURNAL_SUMMARY`: AI-generated travel journal entries
/// - `RECOMMENDATIONS`: Place recommendations
/// - `BUDGET_ESTIMATE`: Trip budget estimation
///
/// ## Usage
///
/// ```dart
/// final aiService = AIService();
///
/// // All methods automatically use the configured provider/model
/// final response = await aiService.sendMessageWithExpenseDetection(
///   message: 'What are the best restaurants near me?',
///   context: travelContext,
/// );
///
/// // Access the router for direct provider access
/// final provider = aiService.router.getProviderForFeature(AIFeature.dailyTip);
/// ```

export 'ai_provider_interface.dart';
export 'ai_router.dart';
export 'google_provider.dart';
export 'openai_provider.dart';
export 'openrouter_provider.dart';

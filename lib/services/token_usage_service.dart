import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../data/repositories/token_usage_repository.dart';

/// Result of a token limit check
class TokenCheckResult {
  final bool canProceed;
  final String? errorMessage;
  final int tokensUsed;
  final int dailyLimit;
  final int tokensRemaining;
  final String planType;

  const TokenCheckResult({
    required this.canProceed,
    this.errorMessage,
    required this.tokensUsed,
    required this.dailyLimit,
    required this.tokensRemaining,
    required this.planType,
  });

  factory TokenCheckResult.allowed({
    required int tokensUsed,
    required int dailyLimit,
    required int tokensRemaining,
    required String planType,
  }) {
    return TokenCheckResult(
      canProceed: true,
      tokensUsed: tokensUsed,
      dailyLimit: dailyLimit,
      tokensRemaining: tokensRemaining,
      planType: planType,
    );
  }

  factory TokenCheckResult.denied({
    required String message,
    required int tokensUsed,
    required int dailyLimit,
    required String planType,
  }) {
    return TokenCheckResult(
      canProceed: false,
      errorMessage: message,
      tokensUsed: tokensUsed,
      dailyLimit: dailyLimit,
      tokensRemaining: 0,
      planType: planType,
    );
  }
}

/// Service for managing AI token usage and limits
///
/// This service acts as middleware for AI requests, checking token limits
/// before allowing requests and recording usage after completion.
class TokenUsageService {
  final TokenUsageRepository _repository;

  // Default limits (can be overridden by environment variables)
  static const int defaultFreeDailyTokens = 10000;
  static const int defaultSubscriptionDailyTokens = 100000;

  TokenUsageService({TokenUsageRepository? repository})
      : _repository = repository ?? TokenUsageRepository();

  /// Get the daily token limit for free users from environment
  int get freeDailyLimit {
    final envValue = dotenv.env['FREE_DAILY_TOKENS'];
    if (envValue != null) {
      return int.tryParse(envValue) ?? defaultFreeDailyTokens;
    }
    return defaultFreeDailyTokens;
  }

  /// Get the daily token limit for subscription users from environment
  int get subscriptionDailyLimit {
    final envValue = dotenv.env['SUBSCRIPTION_DAILY_TOKENS'];
    if (envValue != null) {
      return int.tryParse(envValue) ?? defaultSubscriptionDailyTokens;
    }
    return defaultSubscriptionDailyTokens;
  }

  /// Check if the user can make an AI request
  ///
  /// Call this BEFORE making any AI request. If [canProceed] is false,
  /// show the [errorMessage] to the user and don't make the AI call.
  Future<TokenCheckResult> checkBeforeRequest() async {
    try {
      final result = await _repository.checkTokenLimit(
        freeDailyLimit: freeDailyLimit,
        subscriptionDailyLimit: subscriptionDailyLimit,
      );

      if (result.allowed) {
        return TokenCheckResult.allowed(
          tokensUsed: result.tokensUsed,
          dailyLimit: result.dailyLimit,
          tokensRemaining: result.tokensRemaining,
          planType: result.planType,
        );
      } else {
        final message = result.planType == 'free'
            ? 'Daily credit limit reached. Try again tomorrow or upgrade your plan.'
            : 'Daily credit limit reached. Try again tomorrow.';

        return TokenCheckResult.denied(
          message: message,
          tokensUsed: result.tokensUsed,
          dailyLimit: result.dailyLimit,
          planType: result.planType,
        );
      }
    } catch (e) {
      debugPrint('Error in checkBeforeRequest: $e');
      // On error, allow the request to proceed
      return TokenCheckResult.allowed(
        tokensUsed: 0,
        dailyLimit: freeDailyLimit,
        tokensRemaining: freeDailyLimit,
        planType: 'free',
      );
    }
  }

  /// Record token usage after an AI request completes
  ///
  /// Call this AFTER the AI request completes with the total tokens used
  /// (prompt tokens + completion tokens).
  Future<void> recordUsage(int tokensUsed) async {
    if (tokensUsed <= 0) return;

    try {
      await _repository.incrementTokenUsage(tokensUsed);
      debugPrint('Recorded token usage: $tokensUsed tokens');
    } catch (e) {
      debugPrint('Error recording token usage: $e');
      // Don't throw - we don't want to break the user experience
    }
  }

  /// Get today's usage statistics
  Future<DailyTokenUsage?> getTodayUsage() async {
    return _repository.getTodayUsage();
  }

  /// Get usage history
  Future<List<DailyTokenUsage>> getUsageHistory({int limit = 30}) async {
    return _repository.getUsageHistory(limit: limit);
  }

  /// Get the user's current plan type
  Future<String> getUserPlanType() async {
    return _repository.getUserPlanType();
  }

  /// Wrapper function to execute an AI request with token limit checking
  ///
  /// This is the recommended way to make AI requests. It handles:
  /// 1. Checking token limits before the request
  /// 2. Executing the AI request
  /// 3. Recording token usage after the request
  ///
  /// Example:
  /// ```dart
  /// final result = await tokenUsageService.executeWithLimitCheck(
  ///   aiRequest: () async {
  ///     // Your AI API call here
  ///     return AIResponse(content: '...', tokensUsed: 150);
  ///   },
  ///   getTokensUsed: (response) => response.tokensUsed,
  /// );
  /// ```
  Future<T> executeWithLimitCheck<T>({
    required Future<T> Function() aiRequest,
    required int Function(T response) getTokensUsed,
  }) async {
    // Check limit before request
    final checkResult = await checkBeforeRequest();

    if (!checkResult.canProceed) {
      throw TokenUsageException(
        checkResult.errorMessage ?? 'Token limit exceeded',
        isLimitExceeded: true,
      );
    }

    // Execute the AI request
    final response = await aiRequest();

    // Record usage after request
    final tokensUsed = getTokensUsed(response);
    await recordUsage(tokensUsed);

    return response;
  }
}

/// Exception thrown when token limit is exceeded
class TokenLimitExceededException implements Exception {
  final String message;
  final int tokensUsed;
  final int dailyLimit;
  final String planType;

  const TokenLimitExceededException({
    required this.message,
    required this.tokensUsed,
    required this.dailyLimit,
    required this.planType,
  });

  @override
  String toString() => message;
}

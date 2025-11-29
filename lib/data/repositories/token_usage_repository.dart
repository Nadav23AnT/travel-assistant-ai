import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model for token limit check result
class TokenLimitResult {
  final bool allowed;
  final int tokensUsed;
  final int dailyLimit;
  final int tokensRemaining;
  final String planType;

  const TokenLimitResult({
    required this.allowed,
    required this.tokensUsed,
    required this.dailyLimit,
    required this.tokensRemaining,
    required this.planType,
  });

  factory TokenLimitResult.fromJson(Map<String, dynamic> json) {
    return TokenLimitResult(
      allowed: json['allowed'] as bool? ?? false,
      tokensUsed: json['tokens_used'] as int? ?? 0,
      dailyLimit: json['daily_limit'] as int? ?? 0,
      tokensRemaining: json['tokens_remaining'] as int? ?? 0,
      planType: json['plan_type'] as String? ?? 'free',
    );
  }

  @override
  String toString() {
    return 'TokenLimitResult(allowed: $allowed, tokensUsed: $tokensUsed, dailyLimit: $dailyLimit, remaining: $tokensRemaining, plan: $planType)';
  }
}

/// Model for daily token usage
class DailyTokenUsage {
  final String id;
  final String userId;
  final DateTime usageDate;
  final int tokensUsed;
  final int requestCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DailyTokenUsage({
    required this.id,
    required this.userId,
    required this.usageDate,
    required this.tokensUsed,
    required this.requestCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyTokenUsage.fromJson(Map<String, dynamic> json) {
    return DailyTokenUsage(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      usageDate: DateTime.parse(json['usage_date'] as String),
      tokensUsed: json['tokens_used'] as int? ?? 0,
      requestCount: json['request_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

/// Exception for token usage operations
class TokenUsageException implements Exception {
  final String message;
  final bool isLimitExceeded;

  const TokenUsageException(this.message, {this.isLimitExceeded = false});

  @override
  String toString() => message;
}

/// Repository for managing token usage
class TokenUsageRepository {
  final SupabaseClient? _supabaseOverride;

  TokenUsageRepository({SupabaseClient? supabase}) : _supabaseOverride = supabase;

  /// Get the Supabase client (lazy initialization to avoid errors during app startup)
  SupabaseClient get _supabase => _supabaseOverride ?? Supabase.instance.client;

  String? get _currentUserId {
    try {
      return _supabase.auth.currentUser?.id;
    } catch (e) {
      debugPrint('Error getting current user ID: $e');
      return null;
    }
  }

  /// Check if user can make an AI request based on their token limit
  Future<TokenLimitResult> checkTokenLimit({
    required int freeDailyLimit,
    required int subscriptionDailyLimit,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      // User not authenticated - allow request (fail-open for better UX)
      debugPrint('Token limit check: User not authenticated, allowing request');
      return TokenLimitResult(
        allowed: true,
        tokensUsed: 0,
        dailyLimit: freeDailyLimit,
        tokensRemaining: freeDailyLimit,
        planType: 'free',
      );
    }

    try {
      final response = await _supabase.rpc('check_token_limit', params: {
        'p_user_id': userId,
        'p_free_limit': freeDailyLimit,
        'p_subscription_limit': subscriptionDailyLimit,
      });

      if (response is List && response.isNotEmpty) {
        return TokenLimitResult.fromJson(response[0] as Map<String, dynamic>);
      }

      // Default to allowed if no data
      return TokenLimitResult(
        allowed: true,
        tokensUsed: 0,
        dailyLimit: freeDailyLimit,
        tokensRemaining: freeDailyLimit,
        planType: 'free',
      );
    } catch (e) {
      debugPrint('Error checking token limit: $e');
      // On error, allow the request but log it
      return TokenLimitResult(
        allowed: true,
        tokensUsed: 0,
        dailyLimit: freeDailyLimit,
        tokensRemaining: freeDailyLimit,
        planType: 'free',
      );
    }
  }

  /// Increment token usage after an AI request
  Future<void> incrementTokenUsage(int tokensUsed) async {
    final userId = _currentUserId;
    if (userId == null) {
      // User not authenticated - silently skip tracking
      debugPrint('Token usage tracking: User not authenticated, skipping');
      return;
    }

    try {
      await _supabase.rpc('increment_token_usage', params: {
        'p_user_id': userId,
        'p_tokens': tokensUsed,
      });
    } catch (e) {
      debugPrint('Error incrementing token usage: $e');
      // Don't throw - we don't want to break the user experience
      // if usage tracking fails
    }
  }

  /// Get today's token usage for the current user
  Future<DailyTokenUsage?> getTodayUsage() async {
    final userId = _currentUserId;
    if (userId == null) {
      return null;
    }

    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      final response = await _supabase
          .from('daily_token_usage')
          .select()
          .eq('user_id', userId)
          .eq('usage_date', today)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return DailyTokenUsage.fromJson(response);
    } catch (e) {
      debugPrint('Error getting today usage: $e');
      return null;
    }
  }

  /// Get usage history for the current user
  Future<List<DailyTokenUsage>> getUsageHistory({int limit = 30}) async {
    final userId = _currentUserId;
    if (userId == null) {
      return [];
    }

    try {
      final response = await _supabase
          .from('daily_token_usage')
          .select()
          .eq('user_id', userId)
          .order('usage_date', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => DailyTokenUsage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting usage history: $e');
      return [];
    }
  }

  /// Get user's plan type
  Future<String> getUserPlanType() async {
    final userId = _currentUserId;
    if (userId == null) {
      return 'free';
    }

    try {
      final response = await _supabase
          .from('profiles')
          .select('plan_type')
          .eq('id', userId)
          .maybeSingle();

      return (response?['plan_type'] as String?) ?? 'free';
    } catch (e) {
      debugPrint('Error getting user plan type: $e');
      return 'free';
    }
  }
}

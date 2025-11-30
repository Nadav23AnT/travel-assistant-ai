import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Result of referral stats query
class ReferralStats {
  final String referralCode;
  final int referralCount;
  final int totalCreditsEarned;
  final int totalTokensEarned;

  const ReferralStats({
    required this.referralCode,
    required this.referralCount,
    required this.totalCreditsEarned,
    required this.totalTokensEarned,
  });

  factory ReferralStats.fromJson(Map<String, dynamic> json) {
    return ReferralStats(
      referralCode: json['referral_code'] as String? ?? '',
      referralCount: json['referral_count'] as int? ?? 0,
      totalCreditsEarned: json['total_credits_earned'] as int? ?? 0,
      totalTokensEarned: json['total_tokens_earned'] as int? ?? 0,
    );
  }
}

/// Result of processing a referral
class ReferralResult {
  final bool success;
  final String? error;
  final String? message;
  final int creditsAwarded;

  const ReferralResult({
    required this.success,
    this.error,
    this.message,
    this.creditsAwarded = 0,
  });

  factory ReferralResult.fromJson(Map<String, dynamic> json) {
    return ReferralResult(
      success: json['success'] as bool? ?? false,
      error: json['error'] as String?,
      message: json['message'] as String?,
      creditsAwarded: json['credits_awarded'] as int? ?? 0,
    );
  }
}

/// Service for managing referrals
class ReferralService {
  final SupabaseClient _client;

  ReferralService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Get the current user's referral stats (code, count, credits earned)
  Future<ReferralStats?> getReferralStats() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final result = await _client.rpc(
        'get_referral_stats',
        params: {'p_user_id': user.id},
      );

      if (result != null) {
        return ReferralStats.fromJson(result as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('ReferralService: Error getting stats: $e');
      return null;
    }
  }

  /// Get or generate the user's referral code
  Future<String?> getMyReferralCode() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final result = await _client.rpc(
        'ensure_referral_code',
        params: {'p_user_id': user.id},
      );

      return result as String?;
    } catch (e) {
      debugPrint('ReferralService: Error getting referral code: $e');
      return null;
    }
  }

  /// Apply a referral code for the current user (used during signup)
  Future<ReferralResult> applyReferralCode(String code) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return const ReferralResult(
          success: false,
          error: 'User not authenticated',
        );
      }

      final result = await _client.rpc(
        'process_referral',
        params: {
          'p_new_user_id': user.id,
          'p_referral_code': code.toUpperCase().trim(),
        },
      );

      if (result != null) {
        return ReferralResult.fromJson(result as Map<String, dynamic>);
      }

      return const ReferralResult(
        success: false,
        error: 'Unknown error',
      );
    } catch (e) {
      debugPrint('ReferralService: Error applying referral: $e');
      return ReferralResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Check if user has already been referred
  Future<bool> hasBeenReferred() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      final result = await _client
          .from('profiles')
          .select('referred_by')
          .eq('id', user.id)
          .maybeSingle();

      return result?['referred_by'] != null;
    } catch (e) {
      debugPrint('ReferralService: Error checking referral status: $e');
      return false;
    }
  }

  /// Generate the share message for inviting friends
  String getShareMessage(String referralCode) {
    return '''Hey! I've been using Waylo - an amazing AI travel companion app that helps plan trips, track expenses, and creates beautiful travel journals automatically.

Use my referral code: $referralCode

We'll both get 50 free AI credits when you sign up!

Download: https://waylo.app''';
  }
}

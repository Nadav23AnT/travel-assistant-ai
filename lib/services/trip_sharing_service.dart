import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/trip_member_model.dart';

/// Result of joining a trip
class JoinTripResult {
  final bool success;
  final String? error;
  final String? message;
  final String? tripId;
  final String? tripTitle;

  const JoinTripResult({
    required this.success,
    this.error,
    this.message,
    this.tripId,
    this.tripTitle,
  });

  factory JoinTripResult.fromJson(Map<String, dynamic> json) {
    return JoinTripResult(
      success: json['success'] as bool? ?? false,
      error: json['error'] as String?,
      message: json['message'] as String?,
      tripId: json['trip_id'] as String?,
      tripTitle: json['trip_title'] as String?,
    );
  }
}

/// Result of leaving/removing member from trip
class TripMemberActionResult {
  final bool success;
  final String? error;
  final String? message;

  const TripMemberActionResult({
    required this.success,
    this.error,
    this.message,
  });

  factory TripMemberActionResult.fromJson(Map<String, dynamic> json) {
    return TripMemberActionResult(
      success: json['success'] as bool? ?? false,
      error: json['error'] as String?,
      message: json['message'] as String?,
    );
  }
}

/// Service for managing trip sharing and members
class TripSharingService {
  final SupabaseClient _client;

  TripSharingService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String? get _currentUserId => _client.auth.currentUser?.id;

  /// Get or create invite code for a trip
  Future<String?> getInviteCode(String tripId) async {
    try {
      final result = await _client.rpc(
        'ensure_trip_invite_code',
        params: {'p_trip_id': tripId},
      );

      return result as String?;
    } catch (e) {
      debugPrint('TripSharingService: Error getting invite code: $e');
      return null;
    }
  }

  /// Join a trip using invite code
  Future<JoinTripResult> joinTripByCode(String inviteCode) async {
    try {
      if (_currentUserId == null) {
        return const JoinTripResult(
          success: false,
          error: 'User not authenticated',
        );
      }

      final result = await _client.rpc(
        'join_trip_by_code',
        params: {
          'p_user_id': _currentUserId,
          'p_invite_code': inviteCode.toUpperCase().trim(),
        },
      );

      if (result != null) {
        return JoinTripResult.fromJson(result as Map<String, dynamic>);
      }

      return const JoinTripResult(
        success: false,
        error: 'Unknown error',
      );
    } catch (e) {
      debugPrint('TripSharingService: Error joining trip: $e');
      return JoinTripResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Get members of a trip (including owner)
  Future<List<TripMemberModel>> getTripMembers(String tripId) async {
    try {
      final result = await _client.rpc(
        'get_trip_members',
        params: {'p_trip_id': tripId},
      );

      if (result == null) return [];

      final List<dynamic> jsonList = result as List<dynamic>;
      return jsonList
          .map((json) => TripMemberModel.fromJson(
                json as Map<String, dynamic>,
                tripId: tripId,
              ))
          .toList();
    } catch (e) {
      debugPrint('TripSharingService: Error getting members: $e');
      return [];
    }
  }

  /// Leave a trip (for non-owners)
  Future<TripMemberActionResult> leaveTrip(String tripId) async {
    try {
      if (_currentUserId == null) {
        return const TripMemberActionResult(
          success: false,
          error: 'User not authenticated',
        );
      }

      final result = await _client.rpc(
        'leave_trip',
        params: {
          'p_user_id': _currentUserId,
          'p_trip_id': tripId,
        },
      );

      if (result != null) {
        return TripMemberActionResult.fromJson(result as Map<String, dynamic>);
      }

      return const TripMemberActionResult(
        success: false,
        error: 'Unknown error',
      );
    } catch (e) {
      debugPrint('TripSharingService: Error leaving trip: $e');
      return TripMemberActionResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Remove a member from trip (owner only)
  Future<TripMemberActionResult> removeMember(String tripId, String memberUserId) async {
    try {
      if (_currentUserId == null) {
        return const TripMemberActionResult(
          success: false,
          error: 'User not authenticated',
        );
      }

      final result = await _client.rpc(
        'remove_trip_member',
        params: {
          'p_owner_id': _currentUserId,
          'p_trip_id': tripId,
          'p_member_user_id': memberUserId,
        },
      );

      if (result != null) {
        return TripMemberActionResult.fromJson(result as Map<String, dynamic>);
      }

      return const TripMemberActionResult(
        success: false,
        error: 'Unknown error',
      );
    } catch (e) {
      debugPrint('TripSharingService: Error removing member: $e');
      return TripMemberActionResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Generate shareable message with invite code
  String getShareMessage(String inviteCode, String tripTitle) {
    return '''Join my trip "$tripTitle" on Waylo!

Enter this code in the app: $inviteCode

Together we can plan, track expenses, and create memories!

Download Waylo: https://waylo.app''';
  }

  /// Check if current user is owner of the trip
  Future<bool> isOwner(String tripId) async {
    try {
      if (_currentUserId == null) return false;

      final result = await _client
          .from('trips')
          .select('owner_id')
          .eq('id', tripId)
          .maybeSingle();

      return result?['owner_id'] == _currentUserId;
    } catch (e) {
      debugPrint('TripSharingService: Error checking ownership: $e');
      return false;
    }
  }

  /// Check if current user is a member of the trip (not owner)
  Future<bool> isMember(String tripId) async {
    try {
      if (_currentUserId == null) return false;

      final result = await _client
          .from('trip_members')
          .select('id')
          .eq('trip_id', tripId)
          .eq('user_id', _currentUserId!)
          .eq('status', 'accepted')
          .maybeSingle();

      return result != null;
    } catch (e) {
      debugPrint('TripSharingService: Error checking membership: $e');
      return false;
    }
  }
}

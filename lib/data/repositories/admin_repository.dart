import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_models.dart';

/// Repository for admin-only operations
/// All methods use SECURITY DEFINER functions to bypass RLS
class AdminRepository {
  final SupabaseClient _supabase;

  AdminRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Check if current user is an admin using SECURITY DEFINER function
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Use the is_admin() function which bypasses RLS
      final response = await _supabase.rpc('is_admin');
      return response == true;
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }

  /// Get system statistics for dashboard
  Future<SystemStatsModel> getSystemStats() async {
    try {
      final response = await _supabase.rpc('get_admin_system_stats');
      return SystemStatsModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error getting system stats: $e');
      rethrow;
    }
  }

  /// Get all users with pagination and filters using SECURITY DEFINER function
  Future<List<AdminUserModel>> getAllUsers({
    int page = 0,
    int pageSize = 20,
    String? searchQuery,
    String? planFilter,
    String? sortBy,
    bool ascending = false,
  }) async {
    try {
      // Use admin_get_all_users function which bypasses RLS
      final response = await _supabase.rpc('admin_get_all_users', params: {
        'p_page': page,
        'p_limit': pageSize,
        'p_search': searchQuery,
        'p_plan_filter': planFilter,
        'p_sort_by': sortBy ?? 'created_at',
        'p_ascending': ascending,
      });

      return (response as List)
          .map((json) => AdminUserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting users: $e');
      rethrow;
    }
  }

  /// Get single user with full details using SECURITY DEFINER function
  Future<AdminUserModel?> getUserById(String userId) async {
    try {
      // Use admin_get_user_by_id function which bypasses RLS
      final response = await _supabase.rpc('admin_get_user_by_id', params: {
        'p_user_id': userId,
      });

      if (response == null || (response as List).isEmpty) return null;

      return AdminUserModel.fromJson(response[0] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error getting user details: $e');
      rethrow;
    }
  }

  /// Update user plan type
  Future<bool> updateUserPlan(String userId, String planType) async {
    try {
      await _supabase.rpc('admin_update_user_plan', params: {
        'target_user_id': userId,
        'new_plan': planType,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating user plan: $e');
      rethrow;
    }
  }

  /// Reset user's daily token usage
  Future<bool> resetUserTokens(String userId) async {
    try {
      await _supabase.rpc('admin_reset_user_tokens', params: {
        'target_user_id': userId,
      });
      return true;
    } catch (e) {
      debugPrint('Error resetting user tokens: $e');
      rethrow;
    }
  }

  /// Delete specific user data using SECURITY DEFINER function
  Future<bool> deleteUserData(String userId, UserDataType dataType) async {
    try {
      await _supabase.rpc('admin_delete_user_data', params: {
        'p_user_id': userId,
        'p_data_type': dataType.name,
      });
      return true;
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      rethrow;
    }
  }

  /// Set/remove admin status for a user using SECURITY DEFINER function
  Future<bool> setUserAdminStatus(String userId, bool isAdmin) async {
    try {
      await _supabase.rpc('admin_set_user_admin_status', params: {
        'p_user_id': userId,
        'p_is_admin': isAdmin,
      });
      return true;
    } catch (e) {
      debugPrint('Error setting admin status: $e');
      rethrow;
    }
  }

  /// Get user count by plan type using SECURITY DEFINER function
  Future<Map<String, int>> getUserCountByPlan() async {
    try {
      final response = await _supabase.rpc('admin_get_user_count_by_plan');

      final Map<String, int> result = {
        'free': 0,
        'subscription': 0,
      };

      for (final row in response as List) {
        final planType = row['plan_type'] as String?;
        final count = row['count'] as int? ?? 0;
        if (planType != null) {
          result[planType] = count;
        }
      }

      return result;
    } catch (e) {
      debugPrint('Error getting user counts: $e');
      rethrow;
    }
  }
}

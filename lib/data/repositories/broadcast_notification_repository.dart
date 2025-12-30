import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/broadcast_notification_model.dart';

/// Repository for managing broadcast notifications in Supabase
class BroadcastNotificationRepository {
  final SupabaseClient _supabase;

  BroadcastNotificationRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Get current user ID
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // ========================================
  // User-facing notification methods
  // ========================================

  /// Get all notifications for the current user
  Future<List<BroadcastNotificationModel>> getUserNotifications({
    bool includeDismissed = false,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_user_notifications',
        params: {'p_include_dismissed': includeDismissed},
      );

      if (response == null) return [];

      return (response as List)
          .map((json) => BroadcastNotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting user notifications: $e');
      return [];
    }
  }

  /// Get only unread notifications for the current user
  Future<List<BroadcastNotificationModel>> getUnreadNotifications() async {
    try {
      final notifications = await getUserNotifications(includeDismissed: false);
      return notifications.where((n) => !n.isRead).toList();
    } catch (e) {
      debugPrint('Error getting unread notifications: $e');
      return [];
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final response = await _supabase.rpc('get_unread_notification_count');
      return response as int? ?? 0;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  /// Mark a notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _supabase.rpc(
        'mark_notification_read',
        params: {'p_notification_id': notificationId},
      );
      return response == true;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  /// Dismiss a notification
  Future<bool> dismiss(String notificationId) async {
    try {
      final response = await _supabase.rpc(
        'dismiss_notification',
        params: {'p_notification_id': notificationId},
      );
      return response == true;
    } catch (e) {
      debugPrint('Error dismissing notification: $e');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<int> markAllAsRead() async {
    try {
      final response = await _supabase.rpc('mark_all_notifications_read');
      return response as int? ?? 0;
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      return 0;
    }
  }

  /// Record that user clicked the deep link
  Future<bool> recordClick(String notificationId) async {
    try {
      final response = await _supabase.rpc(
        'record_notification_click',
        params: {'p_notification_id': notificationId},
      );
      return response == true;
    } catch (e) {
      debugPrint('Error recording notification click: $e');
      return false;
    }
  }

  // ========================================
  // Admin methods
  // ========================================

  /// Send a broadcast notification to all users (admin only)
  Future<BroadcastResult?> sendBroadcast({
    required String title,
    required String message,
    NotificationPriority priority = NotificationPriority.normal,
    String? deepLink,
    String? actionButtonText,
    int autoDismissHours = 48,
    bool isRTL = false,
  }) async {
    try {
      // Call the Edge Function instead of RPC to handle FCM
      final response = await _supabase.functions.invoke(
        'send-admin-broadcast',
        body: {
          'title': title,
          'message': message,
          'priority': priority.name,
          'deep_link': deepLink,
          'action_button_text': actionButtonText ?? 'View Details',
          'auto_dismiss_hours': autoDismissHours,
          'is_rtl': isRTL,
        },
      );

      if (response.status != 200) {
        debugPrint('Error sending broadcast: ${response.data}');
        return null;
      }

      final data = response.data as Map<String, dynamic>;
      return BroadcastResult(
        notificationId: data['notification_id'] as String,
        sentCount: data['sent_count'] as int,
        pushSent: (data['push_notifications'] as Map?)?['sent'] as int? ?? 0,
        pushFailed:
            (data['push_notifications'] as Map?)?['failed'] as int? ?? 0,
        pushDisabled:
            (data['push_notifications'] as Map?)?['disabled'] as int? ?? 0,
      );
    } catch (e) {
      debugPrint('Error sending broadcast: $e');
      return null;
    }
  }

  /// Get broadcast history with stats (admin only)
  Future<List<AdminBroadcastModel>> getAdminBroadcastHistory() async {
    try {
      final response = await _supabase.rpc('get_admin_broadcast_history');

      if (response == null) return [];

      return (response as List)
          .map((json) => AdminBroadcastModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting broadcast history: $e');
      return [];
    }
  }

  /// Delete a notification (admin only)
  /// This removes the notification for ALL users via cascade delete
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _supabase.rpc(
        'delete_admin_notification',
        params: {'p_notification_id': notificationId},
      );
      return response == true;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }

  /// Subscribe to notification updates for real-time sync
  Stream<List<Map<String, dynamic>>> subscribeToNotifications() {
    final userId = _currentUserId;
    if (userId == null) {
      return const Stream.empty();
    }

    return _supabase
        .from('user_notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }
}

/// Result of sending a broadcast notification
class BroadcastResult {
  final String notificationId;
  final int sentCount;
  final int pushSent;
  final int pushFailed;
  final int pushDisabled;

  const BroadcastResult({
    required this.notificationId,
    required this.sentCount,
    required this.pushSent,
    required this.pushFailed,
    required this.pushDisabled,
  });

  @override
  String toString() {
    return 'BroadcastResult(notificationId: $notificationId, sentCount: $sentCount, pushSent: $pushSent)';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/broadcast_notification_model.dart';
import '../../data/repositories/broadcast_notification_repository.dart';

// ========================================
// Repository Provider
// ========================================

/// Provider for the broadcast notification repository
final broadcastNotificationRepositoryProvider =
    Provider<BroadcastNotificationRepository>((ref) {
  return BroadcastNotificationRepository();
});

// ========================================
// User Notification Providers
// ========================================

/// State notifier for user notifications
class UserNotificationsNotifier
    extends StateNotifier<AsyncValue<List<BroadcastNotificationModel>>> {
  final BroadcastNotificationRepository _repository;

  UserNotificationsNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final notifications =
          await _repository.getUserNotifications(includeDismissed: false);
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Refresh notifications from database
  Future<void> refresh() async {
    await _loadNotifications();
  }

  /// Mark a notification as read
  Future<bool> markAsRead(String notificationId) async {
    final currentNotifications = state.valueOrNull ?? [];

    // Optimistically update state
    final updatedNotifications = currentNotifications.map((n) {
      if (n.notificationId == notificationId) {
        return n.copyWith(isRead: true, readAt: DateTime.now());
      }
      return n;
    }).toList();

    state = AsyncValue.data(updatedNotifications);

    final success = await _repository.markAsRead(notificationId);

    if (!success) {
      // Revert on failure
      state = AsyncValue.data(currentNotifications);
    }

    return success;
  }

  /// Dismiss a notification
  Future<bool> dismiss(String notificationId) async {
    final currentNotifications = state.valueOrNull ?? [];

    // Optimistically remove from list
    final updatedNotifications =
        currentNotifications.where((n) => n.notificationId != notificationId).toList();

    state = AsyncValue.data(updatedNotifications);

    final success = await _repository.dismiss(notificationId);

    if (!success) {
      // Revert on failure
      state = AsyncValue.data(currentNotifications);
    }

    return success;
  }

  /// Mark all notifications as read
  Future<int> markAllAsRead() async {
    final currentNotifications = state.valueOrNull ?? [];

    // Optimistically update all as read
    final updatedNotifications = currentNotifications.map((n) {
      return n.copyWith(isRead: true, readAt: n.readAt ?? DateTime.now());
    }).toList();

    state = AsyncValue.data(updatedNotifications);

    final count = await _repository.markAllAsRead();

    if (count == 0 && currentNotifications.any((n) => !n.isRead)) {
      // Revert on failure if there were unread notifications
      state = AsyncValue.data(currentNotifications);
    }

    return count;
  }

  /// Record deep link click
  Future<bool> recordClick(String notificationId) async {
    return _repository.recordClick(notificationId);
  }
}

/// Provider for user notifications state
final userNotificationsProvider = StateNotifierProvider<UserNotificationsNotifier,
    AsyncValue<List<BroadcastNotificationModel>>>((ref) {
  final repository = ref.watch(broadcastNotificationRepositoryProvider);
  return UserNotificationsNotifier(repository);
});

/// Provider for unread notifications only
final unreadNotificationsProvider =
    Provider<List<BroadcastNotificationModel>>((ref) {
  final notificationsAsync = ref.watch(userNotificationsProvider);
  return notificationsAsync.valueOrNull?.where((n) => !n.isRead).toList() ?? [];
});

/// Provider for unread notification count
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(unreadNotificationsProvider).length;
});

/// Provider to check if there are any unread notifications
final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(unreadNotificationCountProvider) > 0;
});

/// Provider to control banner visibility
final showNotificationBannerProvider = StateProvider<bool>((ref) => true);

/// Provider for the current banner notification index (for stack navigation)
final currentBannerIndexProvider = StateProvider<int>((ref) => 0);

// ========================================
// Admin Providers
// ========================================

/// State notifier for admin broadcast management
class AdminBroadcastsNotifier
    extends StateNotifier<AsyncValue<List<AdminBroadcastModel>>> {
  final BroadcastNotificationRepository _repository;

  AdminBroadcastsNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    _loadBroadcasts();
  }

  Future<void> _loadBroadcasts() async {
    state = const AsyncValue.loading();
    try {
      final broadcasts = await _repository.getAdminBroadcastHistory();
      state = AsyncValue.data(broadcasts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Refresh broadcasts from database
  Future<void> refresh() async {
    await _loadBroadcasts();
  }

  /// Send a new broadcast notification
  Future<BroadcastResult?> sendBroadcast({
    required String title,
    required String message,
    NotificationPriority priority = NotificationPriority.normal,
    String? deepLink,
  }) async {
    final result = await _repository.sendBroadcast(
      title: title,
      message: message,
      priority: priority,
      deepLink: deepLink,
    );

    if (result != null) {
      // Refresh the list after sending
      await _loadBroadcasts();
    }

    return result;
  }
}

/// Provider for admin broadcasts state
final adminBroadcastsProvider = StateNotifierProvider<AdminBroadcastsNotifier,
    AsyncValue<List<AdminBroadcastModel>>>((ref) {
  final repository = ref.watch(broadcastNotificationRepositoryProvider);
  return AdminBroadcastsNotifier(repository);
});

/// Provider for total sent notifications count
final totalBroadcastsSentProvider = Provider<int>((ref) {
  final broadcastsAsync = ref.watch(adminBroadcastsProvider);
  return broadcastsAsync.valueOrNull?.length ?? 0;
});

/// Provider for average read rate across all broadcasts
final averageReadRateProvider = Provider<double>((ref) {
  final broadcastsAsync = ref.watch(adminBroadcastsProvider);
  final broadcasts = broadcastsAsync.valueOrNull ?? [];

  if (broadcasts.isEmpty) return 0;

  final totalReadPercentage =
      broadcasts.fold<double>(0, (sum, b) => sum + b.readPercentage);
  return totalReadPercentage / broadcasts.length;
});

// ========================================
// Send Broadcast State Provider
// ========================================

/// State for the send broadcast form
class SendBroadcastState {
  final bool isLoading;
  final String? error;
  final BroadcastResult? result;

  const SendBroadcastState({
    this.isLoading = false,
    this.error,
    this.result,
  });

  SendBroadcastState copyWith({
    bool? isLoading,
    String? error,
    BroadcastResult? result,
  }) {
    return SendBroadcastState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: result,
    );
  }
}

/// Notifier for send broadcast form state
class SendBroadcastNotifier extends StateNotifier<SendBroadcastState> {
  final Ref _ref;

  SendBroadcastNotifier(this._ref) : super(const SendBroadcastState());

  /// Send a broadcast notification
  Future<bool> send({
    required String title,
    required String message,
    NotificationPriority priority = NotificationPriority.normal,
    String? deepLink,
  }) async {
    state = state.copyWith(isLoading: true, error: null, result: null);

    try {
      final result =
          await _ref.read(adminBroadcastsProvider.notifier).sendBroadcast(
                title: title,
                message: message,
                priority: priority,
                deepLink: deepLink,
              );

      if (result != null) {
        state = SendBroadcastState(result: result);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to send notification',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Reset state
  void reset() {
    state = const SendBroadcastState();
  }
}

/// Provider for send broadcast state
final sendBroadcastProvider =
    StateNotifierProvider<SendBroadcastNotifier, SendBroadcastState>((ref) {
  return SendBroadcastNotifier(ref);
});

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens/liquid_glass_colors.dart';
import '../../../core/utils/notification_text_utils.dart';
import '../../../data/models/broadcast_notification_model.dart';
import '../../providers/broadcast_notification_provider.dart';
import '../../widgets/notifications/notification_banner.dart'
    show showNotificationDetail, isExternalLink, launchExternalUrl;

/// Filter options for notification list
enum NotificationFilter { all, unread, read }

/// Provider for current filter
final notificationFilterProvider =
    StateProvider<NotificationFilter>((ref) => NotificationFilter.all);

/// Notification center screen showing all notifications
class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(userNotificationsProvider);
    final currentFilter = ref.watch(notificationFilterProvider);
    final hasUnread = ref.watch(hasUnreadNotificationsProvider);

    return Scaffold(
      backgroundColor:
          isDark ? LiquidGlassColors.canvasBaseDark : LiquidGlassColors.canvasBaseLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Notifications'),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () {
                ref.read(userNotificationsProvider.notifier).markAllAsRead();
              },
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: LiquidGlassColors.auroraIndigo,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          PopupMenuButton<NotificationFilter>(
            icon: Icon(
              Icons.filter_list,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
            onSelected: (filter) {
              ref.read(notificationFilterProvider.notifier).state = filter;
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: NotificationFilter.all,
                child: Row(
                  children: [
                    Icon(
                      currentFilter == NotificationFilter.all
                          ? Icons.check
                          : Icons.list,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text('All Notifications'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: NotificationFilter.unread,
                child: Row(
                  children: [
                    Icon(
                      currentFilter == NotificationFilter.unread
                          ? Icons.check
                          : Icons.markunread,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text('Unread Only'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: NotificationFilter.read,
                child: Row(
                  children: [
                    Icon(
                      currentFilter == NotificationFilter.read
                          ? Icons.check
                          : Icons.mark_email_read,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text('Read Only'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          // Apply filter
          final filteredNotifications = _applyFilter(notifications, currentFilter);

          if (filteredNotifications.isEmpty) {
            return _EmptyState(filter: currentFilter);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(userNotificationsProvider.notifier).refresh();
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredNotifications.length,
              itemBuilder: (context, index) {
                final notification = filteredNotifications[index];
                return _NotificationListItem(
                  notification: notification,
                  onTap: () => _showDetail(context, notification, ref),
                  onDismiss: () {
                    ref
                        .read(userNotificationsProvider.notifier)
                        .dismiss(notification.notificationId);
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load notifications',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ref.read(userNotificationsProvider.notifier).refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<BroadcastNotificationModel> _applyFilter(
    List<BroadcastNotificationModel> notifications,
    NotificationFilter filter,
  ) {
    switch (filter) {
      case NotificationFilter.all:
        return notifications;
      case NotificationFilter.unread:
        return notifications.where((n) => !n.isRead).toList();
      case NotificationFilter.read:
        return notifications.where((n) => n.isRead).toList();
    }
  }

  void _showDetail(
    BuildContext context,
    BroadcastNotificationModel notification,
    WidgetRef ref,
  ) {
    // Mark as read
    ref
        .read(userNotificationsProvider.notifier)
        .markAsRead(notification.notificationId);

    showNotificationDetail(
      context,
      notification,
      onDeepLinkTap: () {
        if (notification.deepLink != null) {
          if (isExternalLink(notification.deepLink)) {
            // External link - open in browser
            launchExternalUrl(notification.deepLink!);
          } else {
            // Internal link - use GoRouter with delay to avoid navigator conflicts
            Future.delayed(const Duration(milliseconds: 100), () {
              if (context.mounted) {
                context.go(notification.deepLink!);
              }
            });
          }
        }
      },
    );
  }
}

/// Empty state widget
class _EmptyState extends StatelessWidget {
  final NotificationFilter filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final IconData icon;
    final String title;
    final String subtitle;

    switch (filter) {
      case NotificationFilter.all:
        icon = Icons.notifications_none;
        title = 'No notifications yet';
        subtitle = 'You\'re all caught up!';
        break;
      case NotificationFilter.unread:
        icon = Icons.check_circle_outline;
        title = 'All caught up!';
        subtitle = 'No unread notifications';
        break;
      case NotificationFilter.read:
        icon = Icons.mark_email_unread;
        title = 'No read notifications';
        subtitle = 'Notifications you\'ve read will appear here';
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: filter == NotificationFilter.unread
                ? Colors.green[300]
                : (isDark ? Colors.grey[600] : Colors.grey[300]),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual notification list item
class _NotificationListItem extends StatelessWidget {
  final BroadcastNotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationListItem({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = notification.priority.color;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDismiss(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? (notification.isRead
                  ? LiquidGlassColors.canvasSubtleDark
                  : LiquidGlassColors.canvasSubtleDark.withOpacity(0.8))
              : (notification.isRead
                  ? Colors.white
                  : priorityColor.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(notification.isRead ? 0.05 : 0.1)
                : (notification.isRead
                    ? Colors.grey[200]!
                    : priorityColor.withOpacity(0.2)),
          ),
          boxShadow: notification.isRead
              ? null
              : [
                  BoxShadow(
                    color: priorityColor.withOpacity(isDark ? 0.2 : 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Directionality(
              textDirection: notification.isRTL
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Priority Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: notification.isRead
                            ? (isDark ? Colors.grey[700] : Colors.grey[200])
                            : priorityColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        notification.priority.icon,
                        color: notification.isRead
                            ? (isDark ? Colors.grey[500] : Colors.grey[500])
                            : priorityColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: notification.isRTL
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          // Title with RTL/bold support
                          NotificationText(
                            text: notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: isDark ? Colors.white : Colors.grey[900],
                            ),
                            isRTL: notification.isRTL,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Message preview with RTL/bold support
                          NotificationText(
                            text: notification.message,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white60 : Colors.grey[600],
                            ),
                            isRTL: notification.isRTL,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Timestamp
                          Text(
                            notification.relativeTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Unread indicator
                    if (!notification.isRead)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: priorityColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/broadcast_notification_model.dart';
import '../../providers/broadcast_notification_provider.dart';
import 'notification_banner.dart';

/// Global overlay widget for showing notification banners on any screen
class NotificationBannerOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const NotificationBannerOverlay({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<NotificationBannerOverlay> createState() =>
      _NotificationBannerOverlayState();
}

class _NotificationBannerOverlayState
    extends ConsumerState<NotificationBannerOverlay> {
  Timer? _autoAdvanceTimer;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    // Load notifications on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userNotificationsProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  void _startAutoAdvanceTimer(List<BroadcastNotificationModel> notifications) {
    _autoAdvanceTimer?.cancel();

    // Don't auto-advance if there's only one notification
    if (notifications.length <= 1) return;

    // Don't auto-advance for urgent notifications
    final currentIndex = ref.read(currentBannerIndexProvider);
    if (currentIndex < notifications.length &&
        notifications[currentIndex].priority.isPersistent) {
      return;
    }

    _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isUserInteracting) return;

      final index = ref.read(currentBannerIndexProvider);
      if (index < notifications.length - 1) {
        ref.read(currentBannerIndexProvider.notifier).state = index + 1;
      } else {
        // Loop back to first
        ref.read(currentBannerIndexProvider.notifier).state = 0;
      }
    });
  }

  void _handleDismiss(BroadcastNotificationModel notification) {
    final notifications = ref.read(unreadNotificationsProvider);
    final currentIndex = ref.read(currentBannerIndexProvider);

    // Adjust index if needed
    if (notifications.length > 1 && currentIndex >= notifications.length - 1) {
      ref.read(currentBannerIndexProvider.notifier).state = currentIndex - 1;
    }
  }

  void _handleBannerTap(BroadcastNotificationModel notification) {
    showNotificationDetail(
      context,
      notification,
      onDeepLinkTap: () => _navigateToDeepLink(notification),
    );
  }

  void _navigateToDeepLink(BroadcastNotificationModel notification) {
    if (notification.deepLink != null && notification.deepLink!.isNotEmpty) {
      context.push(notification.deepLink!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showBanner = ref.watch(showNotificationBannerProvider);
    final unreadNotifications = ref.watch(unreadNotificationsProvider);
    final currentIndex = ref.watch(currentBannerIndexProvider);

    // Start auto-advance timer when notifications change
    if (unreadNotifications.isNotEmpty && showBanner) {
      _startAutoAdvanceTimer(unreadNotifications);
    } else {
      _autoAdvanceTimer?.cancel();
    }

    // Ensure index is within bounds
    final safeIndex = currentIndex.clamp(0,
        unreadNotifications.isEmpty ? 0 : unreadNotifications.length - 1);

    return Stack(
      children: [
        // Main content
        widget.child,

        // Notification banner
        if (showBanner && unreadNotifications.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: GestureDetector(
              onPanStart: (_) => _isUserInteracting = true,
              onPanEnd: (_) => _isUserInteracting = false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page view for notifications
                  SizedBox(
                    height: 130,
                    child: PageView.builder(
                      itemCount: unreadNotifications.length,
                      controller: PageController(
                        initialPage: safeIndex,
                        viewportFraction: 1.0,
                      ),
                      onPageChanged: (index) {
                        ref.read(currentBannerIndexProvider.notifier).state =
                            index;
                      },
                      itemBuilder: (context, index) {
                        final notification = unreadNotifications[index];
                        return NotificationBanner(
                          notification: notification,
                          onTap: () => _handleBannerTap(notification),
                          onDismiss: () => _handleDismiss(notification),
                          onDeepLinkTap: () => _navigateToDeepLink(notification),
                        );
                      },
                    ),
                  ),

                  // Page indicator (if multiple notifications)
                  if (unreadNotifications.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _PageIndicator(
                        count: unreadNotifications.length,
                        currentIndex: safeIndex,
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Page indicator dots for notification stack
class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const _PageIndicator({
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isDark ? Colors.black : Colors.white).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (index) {
          final isActive = index == currentIndex;
          return Container(
            width: isActive ? 8 : 6,
            height: isActive ? 8 : 6,
            margin: EdgeInsets.only(right: index < count - 1 ? 6 : 0),
            decoration: BoxDecoration(
              color: isActive
                  ? (isDark ? Colors.white : Colors.grey[800])
                  : (isDark ? Colors.white38 : Colors.grey[400]),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}

/// Wrapper widget that adds notification banner overlay to any screen
/// Use this in your router to wrap screens that should show notifications
class WithNotificationBanner extends StatelessWidget {
  final Widget child;

  const WithNotificationBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationBannerOverlay(child: child);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/tokens/liquid_glass_colors.dart';
import '../../../core/utils/notification_text_utils.dart';
import '../../../data/models/broadcast_notification_model.dart';
import '../../providers/broadcast_notification_provider.dart';
import 'notification_banner.dart';

/// Inline notification section for the home screen
/// Displays unread notifications in a swipeable card format
/// Returns SizedBox.shrink() when no notifications (zero height)
class InlineNotificationSection extends ConsumerStatefulWidget {
  const InlineNotificationSection({super.key});

  @override
  ConsumerState<InlineNotificationSection> createState() =>
      _InlineNotificationSectionState();
}

class _InlineNotificationSectionState
    extends ConsumerState<InlineNotificationSection> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    // Refresh notifications on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userNotificationsProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(unreadNotificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Return empty widget when no notifications
    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    // Ensure current page is within bounds
    if (_currentPage >= notifications.length) {
      _currentPage = notifications.length - 1;
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Swipeable notification cards
            SizedBox(
              height: 140,
              child: PageView.builder(
                controller: _pageController,
                itemCount: notifications.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  HapticFeedback.selectionClick();
                },
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _NotificationCard(
                    notification: notification,
                    onViewDetails: () => _handleViewDetails(notification),
                    onMarkAsRead: () => _handleMarkAsRead(notification),
                    onDismiss: () => _handleDismiss(notification),
                  );
                },
              ),
            ),
            // Page indicator (if multiple notifications)
            if (notifications.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(notifications.length, (index) {
                    final isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isActive ? 20 : 8,
                      height: 8,
                      margin: EdgeInsets.only(
                          right: index < notifications.length - 1 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: isActive
                            ? LiquidGlassColors.auroraIndigo
                            : (isDark ? Colors.white24 : Colors.grey[300]),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleViewDetails(BroadcastNotificationModel notification) {
    showNotificationDetail(
      context,
      notification,
      onDeepLinkTap: () => _navigateToDeepLink(notification),
    );
  }

  void _handleMarkAsRead(BroadcastNotificationModel notification) {
    HapticFeedback.lightImpact();
    ref
        .read(userNotificationsProvider.notifier)
        .markAsRead(notification.notificationId);
  }

  void _handleDismiss(BroadcastNotificationModel notification) {
    HapticFeedback.mediumImpact();
    ref
        .read(userNotificationsProvider.notifier)
        .dismiss(notification.notificationId);
  }

  void _navigateToDeepLink(BroadcastNotificationModel notification) {
    if (notification.deepLink != null && notification.deepLink!.isNotEmpty) {
      final deepLink = notification.deepLink!;
      ref
          .read(userNotificationsProvider.notifier)
          .recordClick(notification.notificationId);

      if (isExternalLink(deepLink)) {
        launchExternalUrl(deepLink);
      } else {
        context.push(deepLink);
      }
    }
  }
}

/// Single notification card - entire card is tappable for details
/// With icon-only mark-read button at bottom-right
class _NotificationCard extends StatefulWidget {
  final BroadcastNotificationModel notification;
  final VoidCallback onViewDetails;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.notification,
    required this.onViewDetails,
    required this.onMarkAsRead,
    required this.onDismiss,
  });

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = widget.notification.priority.color;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onViewDetails();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark ? const Color(0xFF1E2432) : Colors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.12)
                  : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: priorityColor.withOpacity(0.15),
                blurRadius: 12,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Directionality(
              textDirection: widget.notification.isRTL
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Row(
                children: [
                  // Priority bar
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      boxShadow: [
                        BoxShadow(
                          color: priorityColor.withOpacity(0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        widget.notification.isRTL ? 10 : 12,
                        10,
                        widget.notification.isRTL ? 12 : 10,
                        10,
                      ),
                      child: Column(
                        crossAxisAlignment: widget.notification.isRTL
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          // Header row
                          Row(
                            children: [
                              // Priority icon
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: priorityColor.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  widget.notification.priority.icon,
                                  size: 14,
                                  color: priorityColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Title with RTL/bold support
                              Expanded(
                                child: NotificationText(
                                  text: widget.notification.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark ? Colors.white : Colors.grey[900],
                                  ),
                                  isRTL: widget.notification.isRTL,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Timestamp
                              Text(
                                widget.notification.relativeTime,
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      isDark ? Colors.white54 : Colors.grey[500],
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Dismiss X
                              _IconButton(
                                icon: Icons.close_rounded,
                                onTap: widget.onDismiss,
                                tooltip: 'Dismiss',
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Message preview with RTL/bold support
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: widget.notification.isRTL ? 0 : 36,
                                right: widget.notification.isRTL ? 36 : 0,
                              ),
                              child: NotificationText(
                                text: widget.notification.message,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.grey[600],
                                  height: 1.3,
                                ),
                                isRTL: widget.notification.isRTL,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          // Footer row with mark-read button at right
                          Padding(
                            padding: EdgeInsets.only(
                              left: widget.notification.isRTL ? 0 : 36,
                              right: widget.notification.isRTL ? 36 : 0,
                              top: 4,
                            ),
                            child: Row(
                              children: [
                                // Tap anywhere hint
                                Icon(
                                  Icons.touch_app_outlined,
                                  size: 12,
                                  color:
                                      isDark ? Colors.white38 : Colors.grey[400],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tap for details',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.grey[400],
                                  ),
                                ),
                                const Spacer(),
                                // Mark as Read icon button
                                _IconButton(
                                  icon: Icons.check_circle_outline,
                                  onTap: widget.onMarkAsRead,
                                  tooltip: 'Mark as read',
                                  color: priorityColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon-only action button with tap isolation (stops propagation to card)
class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color? color;

  const _IconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = color ?? (isDark ? Colors.white60 : Colors.grey[600]!);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      // Stop event propagation to parent card
      behavior: HitTestBehavior.opaque,
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: buttonColor.withOpacity(isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: buttonColor,
          ),
        ),
      ),
    );
  }
}

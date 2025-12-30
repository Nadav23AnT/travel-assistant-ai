import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens/liquid_glass_colors.dart';
import '../../../core/utils/notification_text_utils.dart';
import '../../../data/models/broadcast_notification_model.dart';
import '../../providers/broadcast_notification_provider.dart';

/// Compact notification card with stacked depth effect for multiple notifications
/// Used in the inline notification section on the home screen
class NotificationStackCard extends ConsumerStatefulWidget {
  final BroadcastNotificationModel notification;
  final int totalCount;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationStackCard({
    super.key,
    required this.notification,
    required this.totalCount,
    this.onTap,
    this.onDismiss,
  });

  @override
  ConsumerState<NotificationStackCard> createState() =>
      _NotificationStackCardState();
}

class _NotificationStackCardState extends ConsumerState<NotificationStackCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _dismissController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _dismissController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0),
    ).animate(CurvedAnimation(
      parent: _dismissController,
      curve: Curves.easeIn,
    ));
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _dismissController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _dismissController.dispose();
    super.dispose();
  }

  Future<void> _handleDismiss() async {
    HapticFeedback.lightImpact();
    await _dismissController.forward();
    ref
        .read(userNotificationsProvider.notifier)
        .dismiss(widget.notification.notificationId);
    widget.onDismiss?.call();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    ref
        .read(userNotificationsProvider.notifier)
        .markAsRead(widget.notification.notificationId);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = widget.notification.priority.color;
    final hasMultiple = widget.totalCount > 1;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background stacked cards (depth effect)
            if (hasMultiple) ...[
              // Third card (deepest)
              if (widget.totalCount > 2)
                Positioned(
                  left: 8,
                  right: 8,
                  top: 8,
                  bottom: -8,
                  child: Transform.scale(
                    scale: 0.94,
                    child: _buildDepthCard(isDark, 0.2),
                  ),
                ),
              // Second card
              Positioned(
                left: 4,
                right: 4,
                top: 4,
                bottom: -4,
                child: Transform.scale(
                  scale: 0.97,
                  child: _buildDepthCard(isDark, 0.4),
                ),
              ),
            ],

            // Main card (foreground)
            GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) {
                setState(() => _isPressed = false);
                _handleTap();
              },
              onTapCancel: () => setState(() => _isPressed = false),
              child: AnimatedScale(
                scale: _isPressed ? 0.98 : 1.0,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isDark
                        ? const Color(0xFF1E2432)
                        : Colors.white,
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
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                          ),
                          // Content
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                widget.notification.isRTL ? 8 : 12,
                                12,
                                widget.notification.isRTL ? 12 : 8,
                                12,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: widget.notification.isRTL
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  // Header row: icon, title, timestamp, dismiss
                                  Row(
                                    children: [
                                      // Priority icon
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: priorityColor.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          widget.notification.priority.icon,
                                          size: 16,
                                          color: priorityColor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      // Title with RTL/bold support
                                      Expanded(
                                        child: NotificationText(
                                          text: widget.notification.title,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.grey[900],
                                            height: 1.2,
                                          ),
                                          isRTL: widget.notification.isRTL,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Timestamp
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Text(
                                          widget.notification.relativeTime,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.grey[500],
                                          ),
                                        ),
                                      ),
                                      // Dismiss button
                                      GestureDetector(
                                        onTap: _handleDismiss,
                                        child: Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white.withOpacity(0.08)
                                                : Colors.black.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 16,
                                            color: isDark
                                                ? Colors.white60
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Message preview with RTL/bold support
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: widget.notification.isRTL ? 0 : 42,
                                      right: widget.notification.isRTL ? 42 : 0,
                                    ),
                                    child: NotificationText(
                                      text: widget.notification.message,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? Colors.white.withOpacity(0.7)
                                            : Colors.grey[600],
                                        height: 1.4,
                                      ),
                                      isRTL: widget.notification.isRTL,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
            ),

            // Badge for multiple notifications
            if (hasMultiple)
              Positioned(
                right: 8,
                bottom: -10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        LiquidGlassColors.auroraIndigo,
                        LiquidGlassColors.auroraPurple,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: LiquidGlassColors.auroraIndigo.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '+${widget.totalCount - 1} more',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepthCard(bool isDark, double opacity) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.white.withOpacity(0.04 * opacity)
            : Colors.white.withOpacity(0.5 * opacity),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06 * opacity)
              : Colors.white.withOpacity(0.4 * opacity),
          width: 1,
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design/tokens/liquid_glass_colors.dart';
import '../../../core/utils/notification_text_utils.dart';
import '../../../data/models/broadcast_notification_model.dart';
import '../../providers/broadcast_notification_provider.dart';

/// Helper to check if a link is external (http/https URL)
bool isExternalLink(String? link) {
  if (link == null || link.isEmpty) return false;
  return link.startsWith('http://') || link.startsWith('https://');
}

/// Launch external URL in browser
Future<bool> launchExternalUrl(String url) async {
  try {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  } catch (e) {
    debugPrint('Error launching URL: $e');
    return false;
  }
}

/// Premium glassmorphism notification banner widget
/// Features: enhanced blur, priority stripe, multi-layer shadows, premium animations
class NotificationBanner extends ConsumerStatefulWidget {
  final BroadcastNotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final VoidCallback? onDeepLinkTap;

  const NotificationBanner({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.onDeepLinkTap,
  });

  @override
  ConsumerState<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends ConsumerState<NotificationBanner>
    with TickerProviderStateMixin {
  // Main animation controller for entry/exit
  late AnimationController _entryController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Pulse animation controller for priority glow
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Content stagger animation
  late Animation<double> _contentFadeAnimation;

  // Tap feedback
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Entry animation - 550ms multi-stage
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 550),
      vsync: this,
    );

    // Stage 1: Slide with spring physics (easeOutBack)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
    ));

    // Stage 2: Scale bounce
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.02),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.02, end: 1.0),
        weight: 40,
      ),
    ]).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    // Stage 4: Content stagger fade
    _contentFadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    // Priority-based pulse animation
    final pulseDuration = _getPulseDuration();
    _pulseController = AnimationController(
      duration: pulseDuration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _entryController.forward();

    // Start pulse after entry completes
    _entryController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  Duration _getPulseDuration() {
    switch (widget.notification.priority) {
      case NotificationPriority.urgent:
        return const Duration(milliseconds: 1000); // Rapid pulse
      case NotificationPriority.important:
        return const Duration(milliseconds: 2000); // Medium pulse
      case NotificationPriority.normal:
        return const Duration(milliseconds: 4000); // Gentle breathing
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _dismissBanner() async {
    _pulseController.stop();
    await _entryController.reverse();
    widget.onDismiss?.call();
  }

  void _handleTap() {
    ref
        .read(userNotificationsProvider.notifier)
        .markAsRead(widget.notification.notificationId);
    widget.onTap?.call();
  }

  void _handleDeepLinkTap() async {
    // Record click
    ref
        .read(userNotificationsProvider.notifier)
        .recordClick(widget.notification.notificationId);

    final deepLink = widget.notification.deepLink;
    if (deepLink != null && isExternalLink(deepLink)) {
      // External link - open in browser
      await launchExternalUrl(deepLink);
    } else {
      // Internal link - use callback for GoRouter navigation
      widget.onDeepLinkTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = widget.notification.priority.color;

    // Priority gradient for stripe
    final priorityGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        priorityColor,
        priorityColor.withOpacity(0.6),
        priorityColor,
      ],
    );

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final pulseValue = _pulseAnimation.value;
              final glowIntensity = 0.3 + (pulseValue * 0.2);

              return Dismissible(
                key: Key(widget.notification.id),
                direction: DismissDirection.up,
                onDismissed: (_) {
                  ref
                      .read(userNotificationsProvider.notifier)
                      .dismiss(widget.notification.notificationId);
                  widget.onDismiss?.call();
                },
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _isPressed = true),
                  onTapUp: (_) => setState(() => _isPressed = false),
                  onTapCancel: () => setState(() => _isPressed = false),
                  child: AnimatedScale(
                    scale: _isPressed ? 0.98 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: _isPressed ? 34 : 30, // Enhanced blur
                            sigmaY: _isPressed ? 34 : 30,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  priorityColor.withOpacity(isDark ? 0.18 : 0.14),
                                  priorityColor.withOpacity(isDark ? 0.10 : 0.06),
                                  priorityColor.withOpacity(isDark ? 0.05 : 0.02),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.12 + pulseValue * 0.05)
                                    : Colors.white.withOpacity(0.6),
                                width: 1.5,
                              ),
                              boxShadow: [
                                // Priority glow (pulsing)
                                BoxShadow(
                                  color: priorityColor.withOpacity(glowIntensity),
                                  blurRadius: 24 + (pulseValue * 8),
                                  spreadRadius: -2,
                                  offset: const Offset(0, 4),
                                ),
                                // Depth shadow
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                                // Rim highlight (top)
                                BoxShadow(
                                  color: Colors.white.withOpacity(isDark ? 0.05 : 0.3),
                                  blurRadius: 1,
                                  offset: const Offset(0, -1),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Priority Stripe (left edge)
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 4,
                                    decoration: BoxDecoration(
                                      gradient: priorityGradient,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(24),
                                        bottomLeft: Radius.circular(24),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: priorityColor.withOpacity(0.5),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Main Content
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _handleTap,
                                    borderRadius: BorderRadius.circular(24),
                                    child: Directionality(
                                      textDirection: widget.notification.isRTL
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                          widget.notification.isRTL ? 16 : 20,
                                          16,
                                          widget.notification.isRTL ? 20 : 16,
                                          16,
                                        ),
                                        child: FadeTransition(
                                          opacity: _contentFadeAnimation,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: widget.notification.isRTL
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                            children: [
                                              // Header Row
                                              Row(
                                                children: [
                                                  // Enhanced Priority Icon with glow
                                                  _buildPriorityIcon(priorityColor, pulseValue, isDark),
                                                  const SizedBox(width: 14),
                                                  // Title with enhanced typography and RTL/bold support
                                                  Expanded(
                                                    child: NotificationText(
                                                      text: widget.notification.title,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w700,
                                                        letterSpacing: -0.2,
                                                        color: isDark
                                                            ? Colors.white
                                                            : Colors.grey[900],
                                                        height: 1.3,
                                                      ),
                                                      isRTL: widget.notification.isRTL,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  // Enhanced Close Button
                                                  _buildCloseButton(isDark),
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              // Message Preview with improved typography and RTL/bold support
                                              NotificationText(
                                                text: widget.notification.message,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDark
                                                      ? Colors.white.withOpacity(0.75)
                                                      : Colors.grey[700],
                                                  height: 1.5,
                                                  letterSpacing: 0.1,
                                                ),
                                                isRTL: widget.notification.isRTL,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 14),
                                              // Footer Row
                                              _buildFooter(priorityColor, isDark),
                                            ],
                                          ),
                                        ),
                                      ),
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIcon(Color priorityColor, double pulseValue, bool isDark) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            priorityColor.withOpacity(0.3),
            priorityColor.withOpacity(0.15),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          // Outer glow
          BoxShadow(
            color: priorityColor.withOpacity(0.3 + pulseValue * 0.15),
            blurRadius: 12 + (pulseValue * 4),
            spreadRadius: 1,
          ),
          // Inner highlight
          BoxShadow(
            color: Colors.white.withOpacity(isDark ? 0.1 : 0.4),
            blurRadius: 2,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Icon(
        widget.notification.priority.icon,
        size: 22,
        color: priorityColor,
      ),
    );
  }

  Widget _buildCloseButton(bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _dismissBanner,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.close_rounded,
            size: 18,
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(Color priorityColor, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Timestamp with subtle styling
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.notification.relativeTime,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white54 : Colors.grey[500],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Action indicator with enhanced styling - wrapped in Flexible to prevent overflow
        if (widget.notification.hasDeepLink)
          Flexible(child: _buildActionButton(priorityColor, isDark))
        else
          Flexible(child: _buildReadHint(priorityColor, isDark)),
      ],
    );
  }

  Widget _buildActionButton(Color priorityColor, bool isDark) {
    final isExternal = isExternalLink(widget.notification.deepLink);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleDeepLinkTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                priorityColor.withOpacity(0.2),
                priorityColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: priorityColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isExternal ? 'Open' : 'View',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: priorityColor,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isExternal ? Icons.open_in_new_rounded : Icons.arrow_forward_rounded,
                size: 14,
                color: priorityColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadHint(Color priorityColor, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Tap to read',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: priorityColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.touch_app_rounded,
          size: 14,
          color: priorityColor.withOpacity(0.7),
        ),
      ],
    );
  }
}

/// Expanded notification detail modal
class NotificationDetailSheet extends ConsumerWidget {
  final BroadcastNotificationModel notification;
  final VoidCallback? onDeepLinkTap;

  const NotificationDetailSheet({
    super.key,
    required this.notification,
    this.onDeepLinkTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = notification.priority.color;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: isDark
              ? LiquidGlassColors.canvasSubtleDark
              : LiquidGlassColors.canvasBaseLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Directionality(
            textDirection: notification.isRTL
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: notification.isRTL
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Priority Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          notification.priority.icon,
                          size: 16,
                          color: priorityColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          notification.priority.displayName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: priorityColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title with RTL/bold support
                  NotificationText(
                    text: notification.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.grey[900],
                      height: 1.3,
                    ),
                    isRTL: notification.isRTL,
                  ),
                  const SizedBox(height: 8),
                  // Timestamp
                  Text(
                    _formatFullTimestamp(notification.sentAt),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Full Message with RTL/bold support
                  NotificationText(
                    text: notification.message,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: isDark ? Colors.white.withOpacity(0.9) : Colors.grey[800],
                    ),
                    isRTL: notification.isRTL,
                  ),
                  const SizedBox(height: 32),
                // Action Button (if deep link exists)
                if (notification.hasDeepLink) ...[
                  Builder(
                    builder: (context) {
                      final isExternal = isExternalLink(notification.deepLink);
                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () async {
                            ref
                                .read(userNotificationsProvider.notifier)
                                .recordClick(notification.notificationId);

                            if (isExternal && notification.deepLink != null) {
                              // External link - open in browser
                              await launchExternalUrl(notification.deepLink!);
                              if (context.mounted) Navigator.pop(context);
                            } else {
                              // Internal link - close modal first, then navigate
                              Navigator.pop(context);
                              // Use post-frame callback to ensure modal is closed
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                onDeepLinkTap?.call();
                              });
                            }
                          },
                          icon: Icon(isExternal ? Icons.open_in_new : Icons.arrow_forward),
                          label: Text(isExternal ? 'Open Link' : notification.actionButtonText),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            backgroundColor: priorityColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                // Dismiss Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ref
                          .read(userNotificationsProvider.notifier)
                          .dismiss(notification.notificationId);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Dismiss'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  String _formatFullTimestamp(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$month $day, $year at $hour:$minute';
  }
}

/// Show notification detail as bottom sheet
void showNotificationDetail(
  BuildContext context,
  BroadcastNotificationModel notification, {
  VoidCallback? onDeepLinkTap,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => NotificationDetailSheet(
      notification: notification,
      onDeepLinkTap: onDeepLinkTap,
    ),
  );
}

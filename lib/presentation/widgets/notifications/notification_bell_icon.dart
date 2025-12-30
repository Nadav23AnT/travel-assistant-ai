import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens/liquid_glass_colors.dart';
import '../../providers/broadcast_notification_provider.dart';

/// Notification bell icon with unread count badge
class NotificationBellIcon extends ConsumerWidget {
  final Color? iconColor;
  final double iconSize;
  final VoidCallback? onTap;

  const NotificationBellIcon({
    super.key,
    this.iconColor,
    this.iconSize = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      onPressed: onTap ?? () => context.push('/notifications'),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            unreadCount > 0
                ? Icons.notifications_active
                : Icons.notifications_outlined,
            size: iconSize,
            color: iconColor ??
                (isDark ? Colors.white : Colors.grey[800]),
          ),
          if (unreadCount > 0)
            Positioned(
              right: -6,
              top: -4,
              child: _NotificationBadge(count: unreadCount),
            ),
        ],
      ),
    );
  }
}

/// Badge showing unread notification count
class _NotificationBadge extends StatelessWidget {
  final int count;

  const _NotificationBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final displayCount = count > 99 ? '99+' : count.toString();
    final isLargeCount = count > 9;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeCount ? 6 : 4,
        vertical: 2,
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            LiquidGlassColors.sunsetOrange,
            LiquidGlassColors.sunsetRose,
          ],
        ),
        borderRadius: BorderRadius.circular(isLargeCount ? 10 : 9),
        boxShadow: [
          BoxShadow(
            color: LiquidGlassColors.sunsetRose.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          displayCount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Animated notification bell that shakes when there are new notifications
class AnimatedNotificationBellIcon extends ConsumerStatefulWidget {
  final Color? iconColor;
  final double iconSize;
  final VoidCallback? onTap;

  const AnimatedNotificationBellIcon({
    super.key,
    this.iconColor,
    this.iconSize = 24,
    this.onTap,
  });

  @override
  ConsumerState<AnimatedNotificationBellIcon> createState() =>
      _AnimatedNotificationBellIconState();
}

class _AnimatedNotificationBellIconState
    extends ConsumerState<AnimatedNotificationBellIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.1),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.1, end: -0.1),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.1, end: 0.08),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.08, end: -0.08),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -0.08, end: 0.0),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _controller.forward().then((_) => _controller.reset());
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Shake when count increases
    if (unreadCount > _previousCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _triggerShake());
    }
    _previousCount = unreadCount;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _shakeAnimation.value,
          child: child,
        );
      },
      child: IconButton(
        onPressed: widget.onTap ?? () => context.push('/notifications'),
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              unreadCount > 0
                  ? Icons.notifications_active
                  : Icons.notifications_outlined,
              size: widget.iconSize,
              color: widget.iconColor ??
                  (isDark ? Colors.white : Colors.grey[800]),
            ),
            if (unreadCount > 0)
              Positioned(
                right: -6,
                top: -4,
                child: _NotificationBadge(count: unreadCount),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/design/effects/glass_container.dart' show GlassCard;
import '../../../core/design/tokens/liquid_glass_colors.dart';

/// An expandable notification category section with glassmorphism styling
class NotificationCategorySection extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color accentColor;
  final List<Widget> children;
  final bool initiallyExpanded;
  final bool enabled;

  const NotificationCategorySection({
    super.key,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.children,
    this.initiallyExpanded = false,
    this.enabled = true,
  });

  @override
  State<NotificationCategorySection> createState() =>
      _NotificationCategorySectionState();
}

class _NotificationCategorySectionState
    extends State<NotificationCategorySection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconRotation;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );
    _iconRotation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedOpacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 300),
      child: GlassCard(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon Container with accent color
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.accentColor
                            .withOpacity(isDark ? 0.2 : 0.15),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isDark
                            ? [
                                BoxShadow(
                                  color: widget.accentColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset.zero,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.accentColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Title
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Animated Chevron
                    AnimatedBuilder(
                      animation: _iconRotation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _iconRotation.value * 2 * 3.14159,
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Expandable Content
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                children: widget.children.map((child) {
                  return Column(
                    children: [
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: 56,
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.06),
                      ),
                      IgnorePointer(
                        ignoring: !widget.enabled,
                        child: child,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category configuration for notification sections
class NotificationCategory {
  final String title;
  final IconData icon;
  final Color color;

  const NotificationCategory({
    required this.title,
    required this.icon,
    required this.color,
  });

  static const general = NotificationCategory(
    title: 'General',
    icon: Icons.notifications_rounded,
    color: LiquidGlassColors.sunsetOrange,
  );

  static const trips = NotificationCategory(
    title: 'Trips',
    icon: Icons.flight_rounded,
    color: LiquidGlassColors.oceanTeal,
  );

  static const expenses = NotificationCategory(
    title: 'Expense & Budget',
    icon: Icons.account_balance_wallet_rounded,
    color: LiquidGlassColors.mintEmerald,
  );

  static const journal = NotificationCategory(
    title: 'Journal & Memories',
    icon: Icons.auto_stories_rounded,
    color: LiquidGlassColors.auroraPurple,
  );

  static const engagement = NotificationCategory(
    title: 'App & Engagement',
    icon: Icons.stars_rounded,
    color: LiquidGlassColors.auroraIndigo,
  );

  static const support = NotificationCategory(
    title: 'Support',
    icon: Icons.support_agent_rounded,
    color: LiquidGlassColors.oceanCyan,
  );
}

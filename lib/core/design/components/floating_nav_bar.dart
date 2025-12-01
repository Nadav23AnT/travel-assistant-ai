import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/liquid_glass_colors.dart';

/// A premium floating navigation bar with glassmorphism effect
/// Features morphing blob indicator and neon glow in dark mode
class FloatingNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> items;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

/// Navigation item data class
class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _FloatingNavBarState extends State<FloatingNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.1), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(FloatingNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _activeColor => LiquidGlassColors.getNavColor(widget.currentIndex);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              color: isDark
                  ? Colors.white.withAlpha(20) // 0.08
                  : Colors.white.withAlpha(179), // 0.7
              border: Border.all(
                width: 1.5,
                color: isDark
                    ? Colors.white.withAlpha(38) // 0.15
                    : Colors.white.withAlpha(102), // 0.4
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? const Color(0x50000000)
                      : const Color(0x18000000),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                // Colored shadow from active item
                BoxShadow(
                  color: _activeColor.withAlpha(isDark ? 77 : 38), // 0.3 : 0.15
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                widget.items.length,
                (index) => _buildNavItem(index, isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, bool isDark) {
    final isActive = index == widget.currentIndex;
    final item = widget.items[index];
    final itemColor = LiquidGlassColors.getNavColor(index);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap(index);
        },
        child: Container(
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Active indicator blob
              if (isActive)
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              itemColor,
                              itemColor.withAlpha(179), // 0.7
                            ],
                          ),
                          boxShadow: isDark
                              ? [
                                  BoxShadow(
                                    color: itemColor.withAlpha(
                                        (128 * _glowAnimation.value).toInt()),
                                    blurRadius: 16 + (8 * _glowAnimation.value),
                                    offset: Offset.zero,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    );
                  },
                ),

              // Icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  key: ValueKey(isActive),
                  size: 24,
                  color: isActive
                      ? Colors.white
                      : (isDark
                          ? Colors.white.withAlpha(153) // 0.6
                          : Colors.black.withAlpha(153)), // 0.6
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Standalone floating nav bar widget that can be used in a Stack
class FloatingNavBarOverlay extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingNavBarOverlay({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingNavBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'Home',
        ),
        NavItem(
          icon: Icons.luggage_outlined,
          activeIcon: Icons.luggage,
          label: 'Trips',
        ),
        NavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long,
          label: 'Expenses',
        ),
        NavItem(
          icon: Icons.chat_outlined,
          activeIcon: Icons.chat,
          label: 'AI',
        ),
        NavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'Profile',
        ),
      ],
    );
  }
}

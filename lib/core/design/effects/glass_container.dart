import 'dart:ui';
import 'package:flutter/material.dart';

/// A premium glassmorphism container with frosted effect
/// Works in both light and dark mode with appropriate styling
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool elevated;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.elevated = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(24);

    Widget content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: isDark ? 24.0 : 20.0,
          sigmaY: isDark ? 24.0 : 20.0,
        ),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: radius,
            color: isDark
                ? Colors.white.withAlpha(20) // 0.08
                : Colors.white.withAlpha(64), // 0.25
            border: Border.all(
              width: 1.5,
              color: isDark
                  ? Colors.white.withAlpha(31) // 0.12
                  : Colors.white.withAlpha(64), // 0.25
            ),
            boxShadow: isDark
                ? [
                    // Outer shadow - deeper in dark mode
                    BoxShadow(
                      color: const Color(0x40000000),
                      blurRadius: elevated ? 40 : 32,
                      offset: Offset(0, elevated ? 16 : 12),
                    ),
                    // Neon glow for elevated cards
                    if (elevated)
                      BoxShadow(
                        color: const Color(0xFF6366F1).withAlpha(51), // 0.2
                        blurRadius: 24,
                        offset: Offset.zero,
                      ),
                    // Inner glow
                    BoxShadow(
                      color: const Color(0x0AFFFFFF),
                      blurRadius: 1,
                      offset: const Offset(0, 0.5),
                      spreadRadius: 0,
                    ),
                  ]
                : [
                    // Light mode shadows
                    BoxShadow(
                      color: const Color(0x14000000),
                      blurRadius: elevated ? 28 : 20,
                      offset: Offset(0, elevated ? 12 : 8),
                    ),
                    // Inner highlight
                    const BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                      spreadRadius: -1,
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}

/// A glass card variant with gradient border for premium elements
class GlassCardGradientBorder extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final List<Color> gradientColors;
  final double borderWidth;
  final VoidCallback? onTap;

  const GlassCardGradientBorder({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    required this.gradientColors,
    this.borderWidth = 2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(24);
    final innerRadius = BorderRadius.circular(24 - borderWidth);

    Widget content = Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: gradientColors.first.withAlpha(77), // 0.3
                  blurRadius: 24,
                  offset: Offset.zero,
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: ClipRRect(
          borderRadius: innerRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: isDark ? 24 : 20,
              sigmaY: isDark ? 24 : 20,
            ),
            child: Container(
              padding: padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: innerRadius,
                color: isDark
                    ? Colors.white.withAlpha(20) // 0.08
                    : Colors.white.withAlpha(64), // 0.25
              ),
              child: child,
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}

/// Animated glass card with hover effects
class AnimatedGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool enableHover;

  const AnimatedGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.enableHover = true,
  });

  @override
  State<AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<AnimatedGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(begin: 8.0, end: 20.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = widget.borderRadius ?? BorderRadius.circular(24);

    return MouseRegion(
      onEnter: widget.enableHover
          ? (_) {
              setState(() => _isHovered = true);
              _controller.forward();
            }
          : null,
      onExit: widget.enableHover
          ? (_) {
              setState(() => _isHovered = false);
              _controller.reverse();
            }
          : null,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final scale = _isPressed ? 0.98 : _scaleAnimation.value;

            return Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withAlpha(128) // 0.5
                          : Colors.black.withAlpha(26), // 0.1
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value * 0.5),
                    ),
                    if (isDark && _isHovered)
                      BoxShadow(
                        color: const Color(0xFF6366F1).withAlpha(77), // 0.3
                        blurRadius: 24,
                        offset: Offset.zero,
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 20 + (_controller.value * 10),
                      sigmaY: 20 + (_controller.value * 10),
                    ),
                    child: Container(
                      padding: widget.padding ?? const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        color: isDark
                            ? Colors.white
                                .withAlpha(20 + (_controller.value * 10).toInt())
                            : Colors.white
                                .withAlpha(64 + (_controller.value * 38).toInt()),
                        border: Border.all(
                          width: 1.5,
                          color: isDark
                              ? Colors.white.withAlpha(
                                  31 + (_controller.value * 20).toInt())
                              : Colors.white.withAlpha(
                                  64 + (_controller.value * 38).toInt()),
                        ),
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

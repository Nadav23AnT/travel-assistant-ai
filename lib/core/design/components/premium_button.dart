import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/liquid_glass_colors.dart';

/// A premium button with gradient, glow effects, and fluid animations
class PremiumButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? color;
  final double? width;
  final double height;
  final bool gradient;
  final bool isLoading;
  final bool disabled;

  const PremiumButton({
    super.key,
    required this.child,
    this.onPressed,
    this.color,
    this.width,
    this.height = 56,
    this.gradient = false,
    this.isLoading = false,
    this.disabled = false,
  });

  /// Creates a primary gradient button
  factory PremiumButton.gradient({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    double? width,
    double height = 56,
    bool isLoading = false,
    bool disabled = false,
  }) {
    return PremiumButton(
      key: key,
      onPressed: onPressed,
      width: width,
      height: height,
      gradient: true,
      isLoading: isLoading,
      disabled: disabled,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Creates a solid color button
  factory PremiumButton.solid({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    Color color = LiquidGlassColors.auroraIndigo,
    double? width,
    double height = 56,
    bool isLoading = false,
    bool disabled = false,
  }) {
    return PremiumButton(
      key: key,
      onPressed: onPressed,
      color: color,
      width: width,
      height: height,
      isLoading: isLoading,
      disabled: disabled,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  bool get _isDisabled => widget.disabled || widget.isLoading;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (_isDisabled) return;
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isDisabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (_isDisabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = widget.color ?? LiquidGlassColors.auroraIndigo;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isDisabled ? 0.5 : 1.0,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: widget.gradient
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            LiquidGlassColors.auroraIndigo,
                            LiquidGlassColors.auroraViolet,
                            LiquidGlassColors.auroraPurple,
                          ],
                        )
                      : null,
                  color: widget.gradient ? null : buttonColor,
                  boxShadow: isDark
                      ? [
                          // Neon glow effect
                          BoxShadow(
                            color: (widget.gradient
                                    ? LiquidGlassColors.auroraIndigo
                                    : buttonColor)
                                .withAlpha(
                                    (102 * _glowAnimation.value).toInt()),
                            blurRadius: 20 * _glowAnimation.value,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: (widget.gradient
                                    ? LiquidGlassColors.auroraViolet
                                    : buttonColor)
                                .withAlpha((51 * _glowAnimation.value).toInt()),
                            blurRadius: 40 * _glowAnimation.value,
                            offset: Offset.zero,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: (widget.gradient
                                    ? LiquidGlassColors.auroraIndigo
                                    : buttonColor)
                                .withAlpha(77),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: Center(
                  child: widget.isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : widget.child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A ghost/outline button with glass effect
class GhostButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final double? width;
  final double height;
  final bool isLoading;
  final bool disabled;

  const GhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.width,
    this.height = 48,
    this.isLoading = false,
    this.disabled = false,
  });

  @override
  State<GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<GhostButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _isDisabled => widget.disabled || widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = widget.color ?? LiquidGlassColors.auroraIndigo;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) {
          if (!_isDisabled) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (!_isDisabled) {
            setState(() => _isPressed = false);
            HapticFeedback.lightImpact();
            widget.onPressed?.call();
          }
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: widget.width,
          height: widget.height,
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.96 : 1.0, _isPressed ? 0.96 : 1.0, 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _isHovered
                ? buttonColor.withAlpha(26) // 0.1
                : Colors.transparent,
            border: Border.all(
              width: 1.5,
              color: _isHovered ? buttonColor : buttonColor.withAlpha(128),
            ),
            boxShadow: isDark && _isHovered
                ? [
                    BoxShadow(
                      color: buttonColor.withAlpha(51), // 0.2
                      blurRadius: 16,
                      offset: Offset.zero,
                    ),
                  ]
                : [],
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isDisabled ? 0.5 : 1.0,
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(buttonColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: buttonColor, size: 18),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: TextStyle(
                            color: buttonColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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

/// A circular icon button with glow effects
class GlowingIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final bool disabled;

  const GlowingIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 48,
    this.disabled = false,
  });

  @override
  State<GlowingIconButton> createState() => _GlowingIconButtonState();
}

class _GlowingIconButtonState extends State<GlowingIconButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = widget.color ?? LiquidGlassColors.auroraIndigo;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) {
          if (!widget.disabled) setState(() => _isPressed = true);
        },
        onTapUp: (_) {
          if (!widget.disabled) {
            setState(() => _isPressed = false);
            HapticFeedback.lightImpact();
            widget.onPressed?.call();
          }
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: widget.size,
          height: widget.size,
          transform: Matrix4.identity()
            ..scale(_isPressed ? 0.9 : (_isHovered ? 1.1 : 1.0),
                _isPressed ? 0.9 : (_isHovered ? 1.1 : 1.0), 1.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withAlpha(35) // 0.14 - increased for better visibility
                : Colors.white.withAlpha(200), // 0.78 - increased for better visibility
            border: Border.all(
              width: 1.5,
              color: _isHovered
                  ? buttonColor.withAlpha(128)
                  : (isDark
                      ? Colors.white.withAlpha(50) // increased
                      : Colors.black.withAlpha(15)), // subtle dark border for light mode
            ),
            boxShadow: [
              if (_isHovered && isDark)
                BoxShadow(
                  color: buttonColor.withAlpha(102), // 0.4
                  blurRadius: 20,
                  offset: Offset.zero,
                ),
              BoxShadow(
                color: isDark
                    ? const Color(0x40000000)
                    : const Color(0x14000000),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: widget.disabled ? 0.5 : 1.0,
            child: Icon(
              widget.icon,
              size: widget.size * 0.45,
              color: _isHovered
                  ? buttonColor
                  : (isDark ? Colors.white : Colors.black87),
              shadows: isDark
                  ? [
                      const Shadow(
                        color: Color(0x60000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

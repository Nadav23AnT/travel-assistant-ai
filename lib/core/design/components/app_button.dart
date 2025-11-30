import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// Button variant types
enum AppButtonVariant {
  primary,
  secondary,
  text,
  icon,
  gradient,
}

/// Button size options
enum AppButtonSize {
  small,
  medium,
  large,
}

/// A modern button component with gradient support and animations
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.isLoading = false,
    this.isFullWidth = true,
    this.disabled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconPosition iconPosition;
  final bool isLoading;
  final bool isFullWidth;
  final bool disabled;

  @override
  State<AppButton> createState() => _AppButtonState();
}

enum IconPosition { leading, trailing }

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  double get _height {
    switch (widget.size) {
      case AppButtonSize.small:
        return 40;
      case AppButtonSize.medium:
        return 52;
      case AppButtonSize.large:
        return 60;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 18);
    }
  }

  TextStyle get _textStyle {
    switch (widget.size) {
      case AppButtonSize.small:
        return AppTypography.labelSmall;
      case AppButtonSize.medium:
        return AppTypography.labelLarge;
      case AppButtonSize.large:
        return AppTypography.titleMedium;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }

  bool get _isDisabled => widget.disabled || widget.isLoading;

  @override
  Widget build(BuildContext context) {
    switch (widget.variant) {
      case AppButtonVariant.gradient:
        return _buildGradientButton(context);
      case AppButtonVariant.primary:
        return _buildPrimaryButton(context);
      case AppButtonVariant.secondary:
        return _buildSecondaryButton(context);
      case AppButtonVariant.text:
        return _buildTextButton(context);
      case AppButtonVariant.icon:
        return _buildIconButton(context);
    }
  }

  Widget _buildGradientButton(BuildContext context) {
    final gradient = AppColors.getPrimaryGradient(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: _isDisabled ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? AppAnimation.scalePressed : 1.0,
        duration: AppAnimation.instant,
        curve: AppAnimation.easeOut,
        child: AnimatedOpacity(
          opacity: _isDisabled ? 0.5 : 1.0,
          duration: AppAnimation.fast,
          child: Container(
            height: _height,
            width: widget.isFullWidth ? double.infinity : null,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: AppRadius.radiusFull,
              boxShadow: _isPressed
                  ? []
                  : AppShadows.coloredShadow(AppColors.primary, alpha: 77),
            ),
            padding: _padding,
            child: Center(
              child: widget.isLoading
                  ? _buildLoadingIndicator(Colors.white)
                  : _buildContent(Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return SizedBox(
      height: _height,
      width: widget.isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: _isDisabled ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          padding: _padding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusFull,
          ),
        ),
        child: widget.isLoading
            ? _buildLoadingIndicator(Colors.white)
            : _buildContent(Colors.white),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context) {
    return SizedBox(
      height: _height,
      width: widget.isFullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: _isDisabled ? null : widget.onPressed,
        style: OutlinedButton.styleFrom(
          padding: _padding,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusFull,
          ),
        ),
        child: widget.isLoading
            ? _buildLoadingIndicator(AppColors.primary)
            : _buildContent(AppColors.primary),
      ),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    return TextButton(
      onPressed: _isDisabled ? null : widget.onPressed,
      style: TextButton.styleFrom(
        padding: _padding,
      ),
      child: widget.isLoading
          ? _buildLoadingIndicator(AppColors.primary)
          : _buildContent(AppColors.primary),
    );
  }

  Widget _buildIconButton(BuildContext context) {
    return IconButton(
      onPressed: _isDisabled ? null : widget.onPressed,
      icon: widget.isLoading
          ? _buildLoadingIndicator(AppColors.textSecondary)
          : Icon(widget.icon, size: _iconSize),
      iconSize: _iconSize,
      style: IconButton.styleFrom(
        minimumSize: Size(_height, _height),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildContent(Color color) {
    final textWidget = Text(
      widget.label,
      style: _textStyle.copyWith(color: color),
    );

    if (widget.icon == null) {
      return textWidget;
    }

    final iconWidget = Icon(
      widget.icon,
      size: _iconSize,
      color: color,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.iconPosition == IconPosition.leading
          ? [
              iconWidget,
              const SizedBox(width: 8),
              textWidget,
            ]
          : [
              textWidget,
              const SizedBox(width: 8),
              iconWidget,
            ],
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    return SizedBox(
      width: _iconSize,
      height: _iconSize,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

/// Floating Action Button with gradient support
class AppFab extends StatefulWidget {
  const AppFab({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.useGradient = true,
    this.size = 56,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final bool useGradient;
  final double size;

  @override
  State<AppFab> createState() => _AppFabState();
}

class _AppFabState extends State<AppFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimation.spring,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.label != null) {
      return _buildExtendedFab(context);
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isPressed ? AppAnimation.fabPressScale : 1.0,
          duration: AppAnimation.instant,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: widget.useGradient
                  ? AppColors.getPrimaryGradient(context)
                  : null,
              color: widget.useGradient ? null : AppColors.primary,
              borderRadius: AppRadius.radiusLg,
              boxShadow: AppShadows.elevation3,
            ),
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExtendedFab(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isPressed ? AppAnimation.fabPressScale : 1.0,
          duration: AppAnimation.instant,
          child: Container(
            height: widget.size,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: widget.useGradient
                  ? AppColors.getPrimaryGradient(context)
                  : null,
              color: widget.useGradient ? null : AppColors.primary,
              borderRadius: AppRadius.radiusFull,
              boxShadow: AppShadows.elevation3,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label!,
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

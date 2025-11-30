import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// A modern card component with hover effects and customizable styling
/// Follows the design system specifications for cards
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.elevation = 1,
    this.enableHoverEffect = true,
    this.gradient,
    this.leftBorderColor,
    this.leftBorderWidth = 4,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final int elevation;
  final bool enableHoverEffect;
  final Gradient? gradient;
  final Color? leftBorderColor;
  final double leftBorderWidth;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine background color
    final bgColor = widget.backgroundColor ??
        (isDark ? AppColors.surfaceDarkMode : AppColors.surface);

    // Determine shadow based on hover/press state
    final shadows = widget.enableHoverEffect && (_isHovered || _isPressed)
        ? AppShadows.getElevation(context, widget.elevation + 1)
        : AppShadows.getElevation(context, widget.elevation);

    // Calculate transform for hover effect
    final translateY = widget.enableHoverEffect && _isHovered
        ? AppAnimation.cardHoverTranslateY
        : 0.0;

    // Scale for press effect
    final scale = _isPressed ? AppAnimation.scalePressed : 1.0;

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: AnimatedContainer(
            duration: AppAnimation.fast,
            curve: AppAnimation.easeInOut,
            transform: Matrix4.identity()
              ..translate(0.0, translateY, 0.0)
              ..scale(scale, scale, 1.0),
            decoration: BoxDecoration(
              color: widget.gradient == null ? bgColor : null,
              gradient: widget.gradient,
              borderRadius: widget.borderRadius ?? AppRadius.radiusLg,
              border: _buildBorder(),
              boxShadow: shadows,
            ),
            child: ClipRRect(
              borderRadius: widget.borderRadius ?? AppRadius.radiusLg,
              child: widget.leftBorderColor != null
                  ? _buildCardWithLeftBorder()
                  : Padding(
                      padding: widget.padding ?? AppSpacing.cardPadding,
                      child: widget.child,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Border? _buildBorder() {
    if (widget.borderColor != null || widget.borderWidth != null) {
      return Border.all(
        color: widget.borderColor ?? AppColors.border,
        width: widget.borderWidth ?? 1,
      );
    }
    return null;
  }

  Widget _buildCardWithLeftBorder() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: widget.leftBorderWidth,
          color: widget.leftBorderColor,
        ),
        Expanded(
          child: Padding(
            padding: widget.padding ?? AppSpacing.cardPadding,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

/// A featured card variant with gradient header
class AppFeaturedCard extends StatelessWidget {
  const AppFeaturedCard({
    super.key,
    required this.header,
    required this.body,
    this.footer,
    this.onTap,
    this.headerHeight = 120,
    this.headerGradient,
    this.borderRadius,
    this.margin,
  });

  final Widget header;
  final Widget body;
  final Widget? footer;
  final VoidCallback? onTap;
  final double headerHeight;
  final Gradient? headerGradient;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.radiusXl;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderRadius: radius,
      elevation: 2,
      margin: margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with gradient overlay
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: radius.topLeft,
              topRight: radius.topRight,
            ),
            child: SizedBox(
              height: headerHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  header,
                  if (headerGradient != null)
                    Container(
                      decoration: BoxDecoration(gradient: headerGradient),
                    ),
                ],
              ),
            ),
          ),
          // Body
          Padding(
            padding: AppSpacing.cardPadding,
            child: body,
          ),
          // Footer (optional)
          if (footer != null)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.lg,
              ),
              child: footer!,
            ),
        ],
      ),
    );
  }
}

/// A stat card variant for displaying metrics
class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.trend,
    this.trendPositive,
    this.width = 140,
  });

  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? trend;
  final bool? trendPositive;
  final double width;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;
    final bgColor = backgroundColor ?? color.withAlpha(25);

    return SizedBox(
      width: width,
      child: AppCard(
        onTap: onTap,
        padding: AppSpacing.cardPaddingCompact,
        backgroundColor: bgColor,
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(51),
                borderRadius: AppRadius.radiusFull,
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            AppSpacing.verticalSm,
            // Value
            Text(
              value,
              style: AppTypography.headlineMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.verticalXs,
            // Label
            Text(
              label,
              style: AppTypography.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Trend (optional)
            if (trend != null) ...[
              AppSpacing.verticalXs,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    trendPositive == true
                        ? Icons.trending_up
                        : Icons.trending_down,
                    size: 14,
                    color: trendPositive == true
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  AppSpacing.horizontalXs,
                  Text(
                    trend!,
                    style: AppTypography.labelSmall.copyWith(
                      color: trendPositive == true
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

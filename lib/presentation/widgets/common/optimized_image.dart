import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Optimized image widget with caching, placeholder, and error handling
class OptimizedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder(context);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? _buildShimmer(context),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildErrorWidget(context),
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 200),
        memCacheWidth: width?.toInt(),
        memCacheHeight: height?.toInt(),
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: backgroundColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!),
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.image_outlined,
        size: (width ?? height ?? 48) * 0.4,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(
        Icons.broken_image_outlined,
        size: (width ?? height ?? 48) * 0.4,
        color: theme.colorScheme.onErrorContainer,
      ),
    );
  }
}

/// Avatar image with optimized loading
class OptimizedAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? fallbackText;
  final double radius;
  final Color? backgroundColor;

  const OptimizedAvatar({
    super.key,
    this.imageUrl,
    this.fallbackText,
    this.radius = 24,
  }) : backgroundColor = null;

  const OptimizedAvatar.sized({
    super.key,
    this.imageUrl,
    this.fallbackText,
    required this.radius,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = radius * 2;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallback(context, theme);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
        backgroundColor: backgroundColor ?? theme.colorScheme.primaryContainer,
      ),
      placeholder: (context, url) => _buildShimmer(context, size),
      errorWidget: (context, url, error) => _buildFallback(context, theme),
      memCacheWidth: size.toInt() * 2, // 2x for retina
      memCacheHeight: size.toInt() * 2,
    );
  }

  Widget _buildShimmer(BuildContext context, double size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildFallback(BuildContext context, ThemeData theme) {
    final initials = _getInitials(fallbackText);

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? theme.colorScheme.primaryContainer,
      child: Text(
        initials,
        style: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }

  String _getInitials(String? text) {
    if (text == null || text.isEmpty) return '?';

    final words = text.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return text.substring(0, text.length.clamp(0, 2)).toUpperCase();
  }
}

/// Hero image for trip/destination cards
class HeroImage extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double borderRadius;
  final List<Color>? gradientColors;
  final Widget? overlay;

  const HeroImage({
    super.key,
    required this.imageUrl,
    this.height = 200,
    this.borderRadius = 16,
    this.gradientColors,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        children: [
          OptimizedImage(
            imageUrl: imageUrl,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
          ),
          // Gradient overlay for better text readability
          if (gradientColors != null || overlay != null)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: gradientColors ??
                        [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                  ),
                ),
              ),
            ),
          if (overlay != null)
            Positioned.fill(child: overlay!),
        ],
      ),
    );
  }
}

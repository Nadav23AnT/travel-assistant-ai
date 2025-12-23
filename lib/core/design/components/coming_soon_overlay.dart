import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/radius.dart';

/// Reusable overlay widget to block features that are "coming soon"
///
/// Wraps any widget with a semi-transparent overlay and a "Soon" badge.
/// Use this to visually indicate and block MVP features not yet available.
///
/// Example:
/// ```dart
/// ComingSoonOverlay(
///   child: MyFeatureWidget(),
/// )
/// ```
class ComingSoonOverlay extends StatelessWidget {
  /// The widget to overlay
  final Widget child;

  /// Whether the overlay is enabled (default: true)
  final bool enabled;

  /// Label text for the badge (default: "Soon")
  final String label;

  /// Border radius for the overlay - should match the child widget's radius
  final double borderRadius;

  const ComingSoonOverlay({
    super.key,
    required this.child,
    this.enabled = true,
    this.label = 'Soon',
    this.borderRadius = AppRadius.lg,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    return Stack(
      children: [
        // Original widget
        child,
        // Overlay + badge (blocks interactions)
        Positioned.fill(
          child: IgnorePointer(
            ignoring: false, // Capture and block taps
            child: GestureDetector(
              onTap: () {}, // Absorb taps
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadius.radiusFull,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

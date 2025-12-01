import 'package:flutter/material.dart';

/// Design System Shadow & Elevation Tokens
class AppShadows {
  AppShadows._();

  // ============================================
  // LIGHT MODE SHADOWS
  // ============================================

  /// No shadow - Flat elements
  static const List<BoxShadow> elevation0 = [];

  /// Cards - Subtle shadow
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Color(0x14000000), // ~8% opacity
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0F000000), // ~6% opacity
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  /// Hovering cards - Medium shadow
  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Color(0x12000000), // ~7% opacity
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0F000000), // ~6% opacity
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  /// Modals - Strong shadow
  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Color(0x1A000000), // ~10% opacity
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0D000000), // ~5% opacity
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  /// Floating elements - Maximum shadow
  static const List<BoxShadow> elevation4 = [
    BoxShadow(
      color: Color(0x1A000000), // ~10% opacity
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000), // ~4% opacity
      offset: Offset(0, 10),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];

  // ============================================
  // DARK MODE SHADOWS
  // ============================================

  /// Cards - Dark mode
  static const List<BoxShadow> elevation1Dark = [
    BoxShadow(
      color: Color(0x4D000000), // ~30% opacity
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];

  /// Hovering cards - Dark mode
  static const List<BoxShadow> elevation2Dark = [
    BoxShadow(
      color: Color(0x66000000), // ~40% opacity
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  /// Modals - Dark mode
  static const List<BoxShadow> elevation3Dark = [
    BoxShadow(
      color: Color(0x80000000), // ~50% opacity
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: 0,
    ),
  ];

  /// Floating elements - Dark mode
  static const List<BoxShadow> elevation4Dark = [
    BoxShadow(
      color: Color(0x99000000), // ~60% opacity
      offset: Offset(0, 20),
      blurRadius: 25,
      spreadRadius: 0,
    ),
  ];

  // ============================================
  // COLORED SHADOWS (for category highlights)
  // ============================================

  /// Creates a colored shadow for category cards
  static List<BoxShadow> coloredShadow(Color color, {int alpha = 51}) {
    return [
      BoxShadow(
        color: color.withAlpha(alpha),
        offset: const Offset(0, 4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ];
  }

  /// Creates a glow effect for highlighted elements
  static List<BoxShadow> glow(Color color, {int alpha = 77}) {
    return [
      BoxShadow(
        color: color.withAlpha(alpha),
        offset: Offset.zero,
        blurRadius: 12,
        spreadRadius: 2,
      ),
    ];
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get elevation shadow based on brightness
  static List<BoxShadow> getElevation(BuildContext context, int level) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (level) {
      case 0:
        return elevation0;
      case 1:
        return isDark ? elevation1Dark : elevation1;
      case 2:
        return isDark ? elevation2Dark : elevation2;
      case 3:
        return isDark ? elevation3Dark : elevation3;
      case 4:
        return isDark ? elevation4Dark : elevation4;
      default:
        return isDark ? elevation1Dark : elevation1;
    }
  }
}

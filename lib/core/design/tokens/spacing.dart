import 'package:flutter/material.dart';

/// Design System Spacing Tokens
/// Base Unit: 4px
class AppSpacing {
  AppSpacing._();

  // ============================================
  // SPACING VALUES
  // ============================================

  /// 4px - Icon gaps, micro-spacing
  static const double xs = 4.0;

  /// 8px - Internal component spacing
  static const double sm = 8.0;

  /// 12px - Between related elements
  static const double md = 12.0;

  /// 16px - Card padding, between cards
  static const double lg = 16.0;

  /// 24px - Section spacing, screen padding
  static const double xl = 24.0;

  /// 32px - Major section gaps
  static const double xxl = 32.0;

  /// 48px - Page-level spacing
  static const double xxxl = 48.0;

  // ============================================
  // EDGE INSETS PRESETS
  // ============================================

  /// Screen padding (24px horizontal)
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: lg,
  );

  /// Card padding (16px all)
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  /// Card padding compact (12px all)
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(md);

  /// Section padding (24px horizontal, 12px vertical)
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: md,
  );

  /// List item padding (16px horizontal, 12px vertical)
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  /// Button padding (24px horizontal, 16px vertical)
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: lg,
  );

  /// Icon button padding (12px all)
  static const EdgeInsets iconButtonPadding = EdgeInsets.all(md);

  /// Input padding (16px horizontal)
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: lg,
  );

  // ============================================
  // SIZED BOX PRESETS
  // ============================================

  /// Vertical spacing widgets
  static const SizedBox verticalXs = SizedBox(height: xs);
  static const SizedBox verticalSm = SizedBox(height: sm);
  static const SizedBox verticalMd = SizedBox(height: md);
  static const SizedBox verticalLg = SizedBox(height: lg);
  static const SizedBox verticalXl = SizedBox(height: xl);
  static const SizedBox verticalXxl = SizedBox(height: xxl);
  static const SizedBox verticalXxxl = SizedBox(height: xxxl);

  /// Horizontal spacing widgets
  static const SizedBox horizontalXs = SizedBox(width: xs);
  static const SizedBox horizontalSm = SizedBox(width: sm);
  static const SizedBox horizontalMd = SizedBox(width: md);
  static const SizedBox horizontalLg = SizedBox(width: lg);
  static const SizedBox horizontalXl = SizedBox(width: xl);
  static const SizedBox horizontalXxl = SizedBox(width: xxl);

  // ============================================
  // GAP PRESETS (for Flex layouts)
  // ============================================

  /// Gap values for Row/Column mainAxisAlignment: spaceBetween
  static const double gapXs = xs;
  static const double gapSm = sm;
  static const double gapMd = md;
  static const double gapLg = lg;
  static const double gapXl = xl;
}

import 'package:flutter/material.dart';

/// Design System Border Radius Tokens
class AppRadius {
  AppRadius._();

  // ============================================
  // RADIUS VALUES
  // ============================================

  /// 0px - Sharp edges
  static const double none = 0;

  /// 8px - Small buttons, chips
  static const double sm = 8;

  /// 12px - Inputs, secondary cards
  static const double md = 12;

  /// 16px - Primary cards, modals
  static const double lg = 16;

  /// 20px - Feature cards, hero elements
  static const double xl = 20;

  /// 24px - Bottom sheets
  static const double xxl = 24;

  /// 9999px - Pills, avatars, circular FABs
  static const double full = 9999;

  // ============================================
  // BORDER RADIUS PRESETS
  // ============================================

  /// No radius
  static const BorderRadius radiusNone = BorderRadius.zero;

  /// Small radius (8px) - chips, small buttons
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));

  /// Medium radius (12px) - inputs, secondary cards
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));

  /// Large radius (16px) - primary cards, modals
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));

  /// Extra large radius (20px) - feature cards
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));

  /// Extra extra large radius (24px) - bottom sheets
  static const BorderRadius radiusXxl = BorderRadius.all(Radius.circular(xxl));

  /// Full radius (pill shape)
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(full));

  // ============================================
  // TOP-ONLY RADIUS (for bottom sheets, modals)
  // ============================================

  static const BorderRadius topLg = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );

  static const BorderRadius topXl = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  static const BorderRadius topXxl = BorderRadius.only(
    topLeft: Radius.circular(xxl),
    topRight: Radius.circular(xxl),
  );

  // ============================================
  // ROUNDED RECTANGLE SHAPE BORDERS
  // ============================================

  static RoundedRectangleBorder shapeSm = const RoundedRectangleBorder(
    borderRadius: radiusSm,
  );

  static RoundedRectangleBorder shapeMd = const RoundedRectangleBorder(
    borderRadius: radiusMd,
  );

  static RoundedRectangleBorder shapeLg = const RoundedRectangleBorder(
    borderRadius: radiusLg,
  );

  static RoundedRectangleBorder shapeXl = const RoundedRectangleBorder(
    borderRadius: radiusXl,
  );

  static RoundedRectangleBorder shapeFull = const RoundedRectangleBorder(
    borderRadius: radiusFull,
  );
}

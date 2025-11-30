import 'package:flutter/material.dart';

/// Design System Color Tokens
/// Inspired by Google Wallet, Revolut, Airbnb, and Apple design language
class AppColors {
  AppColors._();

  // ============================================
  // PRIMARY COLORS (Blue Gradient System)
  // ============================================

  // Light Mode Primary
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFDBEAFE);
  static const Color primaryGradientStart = Color(0xFF2563EB);
  static const Color primaryGradientEnd = Color(0xFF7C3AED);

  // Dark Mode Primary
  static const Color primaryDarkMode = Color(0xFF3B82F6);
  static const Color primaryDarkDarkMode = Color(0xFF2563EB);
  static const Color primaryLightDarkMode = Color(0xFF1E3A5F);
  static const Color primaryGradientStartDarkMode = Color(0xFF3B82F6);
  static const Color primaryGradientEndDarkMode = Color(0xFF8B5CF6);

  // Primary Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryGradientStart, primaryGradientEnd],
  );

  static const LinearGradient primaryGradientDarkMode = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryGradientStartDarkMode, primaryGradientEndDarkMode],
  );

  // ============================================
  // SECONDARY COLORS
  // ============================================

  static const Color secondary = Color(0xFF7C3AED);
  static const Color teal = Color(0xFF14B8A6);
  static const Color amber = Color(0xFFF59E0B);

  // ============================================
  // CATEGORY COLORS (Expense Types)
  // ============================================

  static const Color categoryTransport = Color(0xFF3B82F6);
  static const Color categoryAccommodation = Color(0xFF8B5CF6);
  static const Color categoryFood = Color(0xFFF97316);
  static const Color categoryActivities = Color(0xFF22C55E);
  static const Color categoryShopping = Color(0xFFEC4899);
  static const Color categoryOther = Color(0xFF64748B);

  static const Map<String, Color> categoryColors = {
    'transport': categoryTransport,
    'accommodation': categoryAccommodation,
    'food': categoryFood,
    'activities': categoryActivities,
    'shopping': categoryShopping,
    'other': categoryOther,
  };

  static Color getCategoryColor(String category) {
    return categoryColors[category.toLowerCase()] ?? categoryOther;
  }

  // ============================================
  // SEMANTIC COLORS
  // ============================================

  // Light Mode
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0EA5E9);

  // Dark Mode
  static const Color successDarkMode = Color(0xFF4ADE80);
  static const Color warningDarkMode = Color(0xFFFBBF24);
  static const Color errorDarkMode = Color(0xFFF87171);
  static const Color infoDarkMode = Color(0xFF38BDF8);

  // ============================================
  // NEUTRAL COLORS - LIGHT MODE
  // ============================================

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ============================================
  // NEUTRAL COLORS - DARK MODE
  // ============================================

  static const Color backgroundDarkMode = Color(0xFF0F172A);
  static const Color surfaceDarkMode = Color(0xFF1E293B);
  static const Color surfaceElevatedDarkMode = Color(0xFF334155);
  static const Color borderDarkMode = Color(0xFF334155);
  static const Color dividerDarkMode = Color(0xFF334155);
  static const Color textPrimaryDarkMode = Color(0xFFF1F5F9);
  static const Color textSecondaryDarkMode = Color(0xFF94A3B8);
  static const Color textTertiaryDarkMode = Color(0xFF64748B);
  static const Color textOnPrimaryDarkMode = Color(0xFFFFFFFF);

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Returns the appropriate color based on brightness
  static Color adaptive(
    BuildContext context, {
    required Color light,
    required Color dark,
  }) {
    return Theme.of(context).brightness == Brightness.light ? light : dark;
  }

  /// Get primary color for current theme
  static Color getPrimary(BuildContext context) {
    return adaptive(context, light: primary, dark: primaryDarkMode);
  }

  /// Get background color for current theme
  static Color getBackground(BuildContext context) {
    return adaptive(context, light: background, dark: backgroundDarkMode);
  }

  /// Get surface color for current theme
  static Color getSurface(BuildContext context) {
    return adaptive(context, light: surface, dark: surfaceDarkMode);
  }

  /// Get text primary color for current theme
  static Color getTextPrimary(BuildContext context) {
    return adaptive(context, light: textPrimary, dark: textPrimaryDarkMode);
  }

  /// Get text secondary color for current theme
  static Color getTextSecondary(BuildContext context) {
    return adaptive(
      context,
      light: textSecondary,
      dark: textSecondaryDarkMode,
    );
  }

  /// Get border color for current theme
  static Color getBorder(BuildContext context) {
    return adaptive(context, light: border, dark: borderDarkMode);
  }

  /// Get the primary gradient for current theme
  static LinearGradient getPrimaryGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? primaryGradient
        : primaryGradientDarkMode;
  }

  /// Get success color for current theme
  static Color getSuccess(BuildContext context) {
    return adaptive(context, light: success, dark: successDarkMode);
  }

  /// Get error color for current theme
  static Color getError(BuildContext context) {
    return adaptive(context, light: error, dark: errorDarkMode);
  }

  /// Get warning color for current theme
  static Color getWarning(BuildContext context) {
    return adaptive(context, light: warning, dark: warningDarkMode);
  }
}

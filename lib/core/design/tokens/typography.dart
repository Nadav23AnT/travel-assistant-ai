import 'package:flutter/material.dart';
import 'colors.dart';

/// Design System Typography Tokens
/// Font Family: Inter (with system fallbacks)
class AppTypography {
  AppTypography._();

  // ============================================
  // FONT FAMILY
  // ============================================

  static const String fontFamily = 'Inter';
  static const List<String> fontFamilyFallback = [
    '-apple-system',
    'SF Pro Text',
    'SF Pro Display',
    'Roboto',
    'sans-serif',
  ];

  // ============================================
  // FONT WEIGHTS
  // ============================================

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ============================================
  // TEXT STYLES - LIGHT MODE
  // ============================================

  /// Hero titles - 32px Bold
  static TextStyle displayLarge = const TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 32,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  /// Page titles - 28px Bold
  static TextStyle displayMedium = const TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 28,
    fontWeight: bold,
    height: 1.25,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
  );

  /// Section headers - 24px SemiBold
  static TextStyle displaySmall = const TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Card titles - 20px SemiBold
  static TextStyle headlineMedium = const TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 20,
    fontWeight: semiBold,
    height: 1.35,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Subsection titles - 18px SemiBold
  static TextStyle headlineSmall = const TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 18,
    fontWeight: semiBold,
    height: 1.4,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  /// Component headers - 16px SemiBold
  static TextStyle titleLarge = const TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  /// Labels - 14px Medium
  static TextStyle titleMedium = const TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: medium,
    height: 1.5,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  /// Primary body - 16px Regular
  static TextStyle bodyLarge = const TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 16,
    fontWeight: regular,
    height: 1.6,
    letterSpacing: 0.25,
    color: AppColors.textPrimary,
  );

  /// Secondary body - 14px Regular
  static TextStyle bodyMedium = const TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.textSecondary,
  );

  /// Captions - 12px Regular
  static TextStyle bodySmall = const TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 12,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  /// Buttons - 14px SemiBold
  static TextStyle labelLarge = const TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 14,
    fontWeight: semiBold,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  /// Overlines, badges - 11px Medium
  static TextStyle labelSmall = const TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFamilyFallback,
    fontSize: 11,
    fontWeight: medium,
    height: 1.3,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  // ============================================
  // TEXT THEME FOR MATERIAL 3
  // ============================================

  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelSmall: labelSmall,
  );

  /// Dark mode text theme with inverted colors
  static TextTheme get textThemeDark => TextTheme(
    displayLarge: displayLarge.copyWith(color: AppColors.textPrimaryDarkMode),
    displayMedium: displayMedium.copyWith(color: AppColors.textPrimaryDarkMode),
    displaySmall: displaySmall.copyWith(color: AppColors.textPrimaryDarkMode),
    headlineMedium: headlineMedium.copyWith(color: AppColors.textPrimaryDarkMode),
    headlineSmall: headlineSmall.copyWith(color: AppColors.textPrimaryDarkMode),
    titleLarge: titleLarge.copyWith(color: AppColors.textPrimaryDarkMode),
    titleMedium: titleMedium.copyWith(color: AppColors.textPrimaryDarkMode),
    bodyLarge: bodyLarge.copyWith(color: AppColors.textPrimaryDarkMode),
    bodyMedium: bodyMedium.copyWith(color: AppColors.textSecondaryDarkMode),
    bodySmall: bodySmall.copyWith(color: AppColors.textSecondaryDarkMode),
    labelLarge: labelLarge.copyWith(color: AppColors.textPrimaryDarkMode),
    labelSmall: labelSmall.copyWith(color: AppColors.textSecondaryDarkMode),
  );
}

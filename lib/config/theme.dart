import 'package:flutter/material.dart';
import '../core/design/design_system.dart';

/// App Theme Configuration
/// Uses the new Design System tokens for a modern, unified look
/// Inspired by Google Wallet, Revolut, Airbnb, and Apple design language
class AppTheme {
  AppTheme._();

  // ============================================
  // LEGACY COLOR ACCESSORS (for backward compatibility)
  // ============================================

  static const Color primaryColor = AppColors.primary;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color accentColor = AppColors.secondary;
  static const Color errorColor = AppColors.error;
  static const Color successColor = AppColors.success;
  static const Color warningColor = AppColors.warning;

  static const Color backgroundColor = AppColors.background;
  static const Color surfaceColor = AppColors.surface;
  static const Color cardColor = AppColors.surface;
  static const Color dividerColor = AppColors.divider;

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textHint = AppColors.textTertiary;

  // Category colors - maintained for backward compatibility
  static const Map<String, Color> categoryColors = {
    'transport': AppColors.categoryTransport,
    'accommodation': AppColors.categoryAccommodation,
    'food': AppColors.categoryFood,
    'activities': AppColors.categoryActivities,
    'shopping': AppColors.categoryShopping,
    'other': AppColors.categoryOther,
  };

  // ============================================
  // LIGHT THEME
  // ============================================

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textOnPrimary,
      tertiary: AppColors.teal,
      error: AppColors.error,
      onError: AppColors.textOnPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceElevated,
      outline: AppColors.border,
    ),

    // Scaffold
    scaffoldBackgroundColor: AppColors.background,

    // Card Theme - Modern rounded cards
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLg,
      ),
      shadowColor: Colors.black.withAlpha(20),
      margin: EdgeInsets.zero,
    ),

    // AppBar Theme - Clean, transparent
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.headlineSmall,
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
    ),

    // Bottom Navigation - Modern with pill indicator
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: AppTypography.labelSmall.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTypography.labelSmall,
    ),

    // Navigation Bar (Material 3)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryLight,
      elevation: 0,
      height: 80,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.labelSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          );
        }
        return AppTypography.labelSmall.copyWith(
          color: AppColors.textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(
            color: AppColors.primary,
            size: 24,
          );
        }
        return const IconThemeData(
          color: AppColors.textSecondary,
          size: 24,
        );
      }),
    ),

    // Input Decoration - Modern with floating labels
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: AppSpacing.inputPadding,
      border: OutlineInputBorder(
        borderRadius: AppRadius.radiusMd,
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusMd,
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusMd,
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusMd,
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusMd,
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: AppTypography.bodyMedium,
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textTertiary,
      ),
      errorStyle: AppTypography.bodySmall.copyWith(
        color: AppColors.error,
      ),
    ),

    // Elevated Button - Gradient pill style
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        minimumSize: const Size(double.infinity, 52),
        padding: AppSpacing.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusFull,
        ),
        elevation: 0,
        textStyle: AppTypography.labelLarge.copyWith(
          color: AppColors.textOnPrimary,
        ),
      ),
    ),

    // Outlined Button - Pill with border
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 52),
        padding: AppSpacing.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusFull,
        ),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        textStyle: AppTypography.labelLarge,
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTypography.labelLarge,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),
    ),

    // FAB - Modern rounded square
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLg,
      ),
    ),

    // Chip - Pill style
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primaryLight,
      selectedColor: AppColors.primary,
      disabledColor: AppColors.border,
      labelStyle: AppTypography.labelSmall.copyWith(
        color: AppColors.primary,
      ),
      secondaryLabelStyle: AppTypography.labelSmall.copyWith(
        color: AppColors.textOnPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusSm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusXl,
      ),
      titleTextStyle: AppTypography.headlineMedium,
      contentTextStyle: AppTypography.bodyMedium,
    ),

    // Bottom Sheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      modalBackgroundColor: AppColors.surface,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.topXxl,
      ),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.surface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMd,
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // List Tile
    listTileTheme: ListTileThemeData(
      contentPadding: AppSpacing.listItemPadding,
      titleTextStyle: AppTypography.titleMedium,
      subtitleTextStyle: AppTypography.bodySmall,
      iconColor: AppColors.textSecondary,
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLight;
        }
        return AppColors.border;
      }),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.textSecondary,
      size: 24,
    ),

    // Text Theme
    textTheme: AppTypography.textTheme,
  );

  // ============================================
  // DARK THEME
  // ============================================

  // Legacy dark colors for backward compatibility
  static const Color darkBackground = AppColors.backgroundDarkMode;
  static const Color darkSurface = AppColors.surfaceDarkMode;
  static const Color darkCard = AppColors.surfaceElevatedDarkMode;
  static const Color darkDivider = AppColors.dividerDarkMode;
  static const Color darkTextPrimary = AppColors.textPrimaryDarkMode;
  static const Color darkTextSecondary = AppColors.textSecondaryDarkMode;
  static const Color darkTextHint = AppColors.textTertiaryDarkMode;

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDarkMode,

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDarkMode,
      onPrimary: AppColors.textOnPrimaryDarkMode,
      primaryContainer: AppColors.primaryLightDarkMode,
      secondary: AppColors.secondary,
      onSecondary: AppColors.textOnPrimaryDarkMode,
      tertiary: AppColors.teal,
      error: AppColors.errorDarkMode,
      onError: AppColors.textOnPrimaryDarkMode,
      surface: AppColors.surfaceDarkMode,
      onSurface: AppColors.textPrimaryDarkMode,
      surfaceContainerHighest: AppColors.surfaceElevatedDarkMode,
      outline: AppColors.borderDarkMode,
    ),

    // Scaffold
    scaffoldBackgroundColor: AppColors.backgroundDarkMode,

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.surfaceDarkMode,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLg,
      ),
      shadowColor: Colors.black.withAlpha(77),
      margin: EdgeInsets.zero,
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimaryDarkMode,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.headlineSmall.copyWith(
        color: AppColors.textPrimaryDarkMode,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryDarkMode,
        size: 24,
      ),
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDarkMode,
      selectedItemColor: AppColors.primaryDarkMode,
      unselectedItemColor: AppColors.textSecondaryDarkMode,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: AppTypography.labelSmall.copyWith(
        color: AppColors.primaryDarkMode,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTypography.labelSmall.copyWith(
        color: AppColors.textSecondaryDarkMode,
      ),
    ),

    // Navigation Bar (Material 3)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceDarkMode,
      indicatorColor: AppColors.primaryLightDarkMode,
      elevation: 0,
      height: 80,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.labelSmall.copyWith(
            color: AppColors.primaryDarkMode,
            fontWeight: FontWeight.w600,
          );
        }
        return AppTypography.labelSmall.copyWith(
          color: AppColors.textSecondaryDarkMode,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(
            color: AppColors.primaryDarkMode,
            size: 24,
          );
        }
        return const IconThemeData(
          color: AppColors.textSecondaryDarkMode,
          size: 24,
        );
      }),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceElevatedDarkMode,
      contentPadding: AppSpacing.inputPadding,
      border: OutlineInputBorder(
        borderRadius: AppRadius.radiusMd,
        borderSide: const BorderSide(color: AppColors.borderDarkMode, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusMd,
        borderSide: const BorderSide(color: AppColors.borderDarkMode, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusMd,
        borderSide: const BorderSide(color: AppColors.primaryDarkMode, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusMd,
        borderSide: const BorderSide(color: AppColors.errorDarkMode, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusMd,
        borderSide: const BorderSide(color: AppColors.errorDarkMode, width: 2),
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondaryDarkMode,
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textTertiaryDarkMode,
      ),
      errorStyle: AppTypography.bodySmall.copyWith(
        color: AppColors.errorDarkMode,
      ),
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDarkMode,
        foregroundColor: AppColors.textOnPrimaryDarkMode,
        minimumSize: const Size(double.infinity, 52),
        padding: AppSpacing.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusFull,
        ),
        elevation: 0,
        textStyle: AppTypography.labelLarge.copyWith(
          color: AppColors.textOnPrimaryDarkMode,
        ),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryDarkMode,
        minimumSize: const Size(double.infinity, 52),
        padding: AppSpacing.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusFull,
        ),
        side: const BorderSide(color: AppColors.primaryDarkMode, width: 1.5),
        textStyle: AppTypography.labelLarge,
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryDarkMode,
        textStyle: AppTypography.labelLarge,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
      ),
    ),

    // FAB
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryDarkMode,
      foregroundColor: AppColors.textOnPrimaryDarkMode,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLg,
      ),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.primaryLightDarkMode,
      selectedColor: AppColors.primaryDarkMode,
      disabledColor: AppColors.borderDarkMode,
      labelStyle: AppTypography.labelSmall.copyWith(
        color: AppColors.primaryDarkMode,
      ),
      secondaryLabelStyle: AppTypography.labelSmall.copyWith(
        color: AppColors.textOnPrimaryDarkMode,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusSm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerDarkMode,
      thickness: 1,
      space: 1,
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceElevatedDarkMode,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusXl,
      ),
      titleTextStyle: AppTypography.headlineMedium.copyWith(
        color: AppColors.textPrimaryDarkMode,
      ),
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondaryDarkMode,
      ),
    ),

    // Bottom Sheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surfaceElevatedDarkMode,
      modalBackgroundColor: AppColors.surfaceElevatedDarkMode,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.topXxl,
      ),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceElevatedDarkMode,
      contentTextStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textPrimaryDarkMode,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMd,
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // List Tile
    listTileTheme: ListTileThemeData(
      contentPadding: AppSpacing.listItemPadding,
      titleTextStyle: AppTypography.titleMedium.copyWith(
        color: AppColors.textPrimaryDarkMode,
      ),
      subtitleTextStyle: AppTypography.bodySmall.copyWith(
        color: AppColors.textSecondaryDarkMode,
      ),
      iconColor: AppColors.textSecondaryDarkMode,
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryDarkMode;
        }
        return AppColors.textTertiaryDarkMode;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryLightDarkMode;
        }
        return AppColors.borderDarkMode;
      }),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.textSecondaryDarkMode,
      size: 24,
    ),

    // Text Theme
    textTheme: AppTypography.textThemeDark,
  );

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get category color by name
  static Color getCategoryColor(String category) {
    return AppColors.getCategoryColor(category);
  }

  /// Get primary gradient for buttons
  static LinearGradient getPrimaryGradient(BuildContext context) {
    return AppColors.getPrimaryGradient(context);
  }
}

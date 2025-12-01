import 'package:flutter/material.dart';

/// Ultra-premium "Liquid Glass" color palette
/// Featuring Aurora, Ocean, and Sunset gradients
class LiquidGlassColors {
  LiquidGlassColors._();

  // ============================================
  // PRIMARY AURORA GRADIENT (Indigo → Violet → Purple)
  // ============================================
  static const auroraIndigo = Color(0xFF6366F1);
  static const auroraViolet = Color(0xFF8B5CF6);
  static const auroraPurple = Color(0xFFA855F7);

  static const auroraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [auroraIndigo, auroraViolet, auroraPurple],
  );

  static const auroraGradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [auroraIndigo, auroraViolet, auroraPurple],
  );

  // ============================================
  // SECONDARY OCEAN GRADIENT (Sky → Cyan → Teal)
  // ============================================
  static const oceanSky = Color(0xFF0EA5E9);
  static const oceanCyan = Color(0xFF06B6D4);
  static const oceanTeal = Color(0xFF14B8A6);

  static const oceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [oceanSky, oceanCyan, oceanTeal],
  );

  static const oceanGradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [oceanSky, oceanCyan, oceanTeal],
  );

  // ============================================
  // ACCENT SUNSET GRADIENT (Orange → Rose → Pink)
  // ============================================
  static const sunsetOrange = Color(0xFFF97316);
  static const sunsetRose = Color(0xFFF43F5E);
  static const sunsetPink = Color(0xFFEC4899);

  static const sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sunsetOrange, sunsetRose, sunsetPink],
  );

  static const sunsetGradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [sunsetOrange, sunsetRose, sunsetPink],
  );

  // ============================================
  // SUCCESS MINT GRADIENT
  // ============================================
  static const mintEmerald = Color(0xFF10B981);
  static const mintLight = Color(0xFF34D399);
  static const mintPale = Color(0xFF6EE7B7);

  static const mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mintEmerald, mintLight, mintPale],
  );

  // ============================================
  // CANVAS BACKGROUNDS
  // ============================================

  // Light Mode - "Cloud"
  static const canvasBaseLight = Color(0xFFFAFBFF);
  static const canvasSubtleLight = Color(0xFFF1F5F9);
  static const glassWhite = Color(0xB8FFFFFF); // rgba(255,255,255,0.72)
  static const glassBorderLight = Color(0x80FFFFFF); // rgba(255,255,255,0.5)
  static const accentGlowLight = Color(0x266366F1); // rgba(99,102,241,0.15)

  // Dark Mode - "Obsidian"
  static const canvasBaseDark = Color(0xFF030712);
  static const canvasSubtleDark = Color(0xFF0F172A);
  static const glassDark = Color(0xB80F172A); // rgba(15,23,42,0.72)
  static const glassBorderDark = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const neonGlowDark = Color(0x668B5CF6); // rgba(139,92,246,0.4)

  // ============================================
  // GLASS OPACITY LEVELS
  // ============================================
  static const double glassLightOpacity = 0.25;
  static const double glassMediumOpacity = 0.15;
  static const double glassDarkOpacity = 0.08;

  // ============================================
  // NEON GLOW OPACITY LEVELS (dark mode only)
  // ============================================
  static const double neonSubtle = 0.2;
  static const double neonMedium = 0.4;
  static const double neonStrong = 0.6;
  static const double neonMax = 0.8;

  // ============================================
  // BLUR VALUES
  // ============================================
  static const double blurLight = 20.0;
  static const double blurMedium = 24.0;
  static const double blurHeavy = 30.0;

  // ============================================
  // CATEGORY COLORS (with neon capability)
  // ============================================
  static const categoryTransport = Color(0xFF0EA5E9);
  static const categoryAccommodation = Color(0xFF8B5CF6);
  static const categoryFood = Color(0xFFF97316);
  static const categoryActivities = Color(0xFF14B8A6);
  static const categoryShopping = Color(0xFFEC4899);
  static const categoryOther = Color(0xFF64748B);

  // ============================================
  // NAV BAR COLORS (per tab)
  // ============================================
  static const navHome = Color(0xFF6366F1); // Indigo
  static const navTrips = Color(0xFF8B5CF6); // Violet
  static const navExpenses = Color(0xFF0EA5E9); // Sky
  static const navAI = Color(0xFF14B8A6); // Teal
  static const navProfile = Color(0xFFF43F5E); // Rose

  /// Get nav color by index
  static Color getNavColor(int index) {
    switch (index) {
      case 0:
        return navHome;
      case 1:
        return navTrips;
      case 2:
        return navExpenses;
      case 3:
        return navAI;
      case 4:
        return navProfile;
      default:
        return navHome;
    }
  }

  /// Get gradient by type
  static LinearGradient getGradient(String type) {
    switch (type) {
      case 'aurora':
        return auroraGradient;
      case 'ocean':
        return oceanGradient;
      case 'sunset':
        return sunsetGradient;
      case 'mint':
        return mintGradient;
      default:
        return auroraGradient;
    }
  }

  /// Create a neon glow shadow
  static List<BoxShadow> neonGlow(Color color, {double intensity = 0.4, double blur = 20}) {
    return [
      BoxShadow(
        color: color.withAlpha((intensity * 255).toInt()),
        blurRadius: blur,
        offset: Offset.zero,
      ),
    ];
  }

  /// Create layered glass shadows
  static List<BoxShadow> glassShadow(bool isDark, {bool elevated = false}) {
    if (isDark) {
      return [
        BoxShadow(
          color: const Color(0x40000000),
          blurRadius: elevated ? 40 : 32,
          offset: Offset(0, elevated ? 16 : 12),
        ),
        if (elevated)
          BoxShadow(
            color: auroraIndigo.withAlpha(51),
            blurRadius: 24,
            offset: Offset.zero,
          ),
      ];
    } else {
      return [
        BoxShadow(
          color: const Color(0x14000000),
          blurRadius: elevated ? 28 : 20,
          offset: Offset(0, elevated ? 12 : 8),
        ),
        const BoxShadow(
          color: Color(0x08000000),
          blurRadius: 2,
          offset: Offset(0, 1),
          spreadRadius: -1,
        ),
      ];
    }
  }
}

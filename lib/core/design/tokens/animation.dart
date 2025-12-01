import 'package:flutter/material.dart';

/// Design System Animation Tokens
class AppAnimation {
  AppAnimation._();

  // ============================================
  // DURATIONS
  // ============================================

  /// 100ms - Micro-feedback (button press, toggle)
  static const Duration instant = Duration(milliseconds: 100);

  /// 200ms - Hover states, quick transitions
  static const Duration fast = Duration(milliseconds: 200);

  /// 300ms - Standard transitions, page animations
  static const Duration normal = Duration(milliseconds: 300);

  /// 400ms - Modal open/close, complex animations
  static const Duration slow = Duration(milliseconds: 400);

  /// 500ms - Bouncy/spring animations
  static const Duration spring = Duration(milliseconds: 500);

  // ============================================
  // CURVES
  // ============================================

  /// Standard easing for most animations
  static const Curve easeInOut = Curves.easeInOut;

  /// For elements exiting or completing
  static const Curve easeOut = Curves.easeOut;

  /// For elements entering
  static const Curve easeIn = Curves.easeIn;

  /// Bouncy effect for playful animations
  static const Curve elasticOut = Curves.elasticOut;

  /// Deceleration curve for natural movement
  static const Curve decelerate = Curves.decelerate;

  /// Fast out, slow in for emphasis
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  // ============================================
  // SCALE VALUES
  // ============================================

  /// Button press scale (pressed state)
  static const double scalePressed = 0.98;

  /// Button release scale (normal state)
  static const double scaleNormal = 1.0;

  /// Hover lift for cards
  static const double cardHoverTranslateY = -2.0;

  /// FAB press scale
  static const double fabPressScale = 0.95;

  // ============================================
  // PAGE TRANSITIONS
  // ============================================

  /// Standard page transition
  static PageRouteBuilder<T> fadeSlideTransition<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.05, 0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: fastOutSlowIn),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: normal,
      reverseTransitionDuration: normal,
    );
  }

  /// Bottom sheet style transition (slide up)
  static PageRouteBuilder<T> slideUpTransition<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0, 0.1);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: fastOutSlowIn),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: normal,
      reverseTransitionDuration: normal,
    );
  }

  // ============================================
  // ANIMATION BUILDERS
  // ============================================

  /// Creates a scale animation for button press effect
  static AnimatedScale scaleOnPress({
    required Widget child,
    required bool isPressed,
  }) {
    return AnimatedScale(
      scale: isPressed ? scalePressed : scaleNormal,
      duration: instant,
      curve: easeOut,
      child: child,
    );
  }

  /// Creates a hover lift animation for cards
  static AnimatedContainer cardHoverEffect({
    required Widget child,
    required bool isHovered,
    required BoxDecoration decoration,
    required BoxDecoration hoverDecoration,
  }) {
    return AnimatedContainer(
      duration: fast,
      curve: easeInOut,
      transform: Matrix4.translationValues(
        0,
        isHovered ? cardHoverTranslateY : 0,
        0,
      ),
      decoration: isHovered ? hoverDecoration : decoration,
      child: child,
    );
  }

  // ============================================
  // STAGGERED ANIMATION HELPERS
  // ============================================

  /// Calculate delay for staggered list animations
  static Duration staggeredDelay(int index, {int delayMs = 50}) {
    return Duration(milliseconds: index * delayMs);
  }

  /// Calculate interval for staggered animations
  static Interval staggeredInterval(
    int index, {
    int totalItems = 10,
    double overlap = 0.3,
  }) {
    final start = (index / totalItems) * (1 - overlap);
    final end = start + overlap;
    return Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: easeOut);
  }
}

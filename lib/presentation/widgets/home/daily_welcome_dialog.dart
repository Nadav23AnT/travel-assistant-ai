import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design_system.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/welcome_banner_provider.dart';

/// Shows the daily welcome dialog
Future<void> showDailyWelcomeDialog(BuildContext context, WidgetRef ref) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (context) => DailyWelcomeDialog(ref: ref),
  );
}

/// Daily welcome dialog showcasing app features with premium animations
class DailyWelcomeDialog extends StatefulWidget {
  final WidgetRef ref;

  const DailyWelcomeDialog({super.key, required this.ref});

  @override
  State<DailyWelcomeDialog> createState() => _DailyWelcomeDialogState();
}

class _DailyWelcomeDialogState extends State<DailyWelcomeDialog>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _entranceController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _entranceAnimation;

  @override
  void initState() {
    super.initState();

    // Floating animation (icon bobbing)
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Pulse animation (icon scale)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Shimmer effect on gradient
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    // Entrance animation
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    )..forward();
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: _entranceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * _entranceAnimation.value),
          child: Opacity(
            opacity: _entranceAnimation.value,
            child: child,
          ),
        );
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: isDark
                    ? const Color(0xFF1A1F2E).withAlpha(240)
                    : Colors.white.withAlpha(245),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withAlpha(38)
                      : Colors.white.withAlpha(153),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(64),
                    blurRadius: 48,
                    offset: const Offset(0, 24),
                    spreadRadius: -4,
                  ),
                  BoxShadow(
                    color: const Color(0xFF667EEA).withAlpha(77),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Header
                  _buildAnimatedHeader(l10n, isDark),

                  // Features list with staggered animation (scrollable)
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _InteractiveFeatureCard(
                            icon: Icons.auto_awesome_rounded,
                            gradient: LiquidGlassColors.sunsetGradient,
                            title: l10n.dailyTipsFeature,
                            description: l10n.dailyTipsDescription,
                            isDark: isDark,
                            index: 0,
                            isNew: true,
                          ),
                          _InteractiveFeatureCard(
                            icon: Icons.payments_rounded,
                            gradient: LiquidGlassColors.oceanGradient,
                            title: l10n.multiCurrencyFeature,
                            description: l10n.multiCurrencyDescription,
                            isDark: isDark,
                            index: 1,
                          ),
                          _InteractiveFeatureCard(
                            icon: Icons.smart_toy_rounded,
                            gradient: LiquidGlassColors.mintGradient,
                            title: l10n.aiChatFeature,
                            description: l10n.aiChatDescription,
                            isDark: isDark,
                            index: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Premium Action Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                    child: _PremiumActionButton(
                      label: l10n.startExploring,
                      onPressed: () {
                        widget.ref.read(markWelcomeBannerShownProvider)();
                        Navigator.of(context).pop();
                      },
                      shimmerAnimation: _shimmerAnimation,
                    ),
                  ),

                  // Maybe later link
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextButton(
                      onPressed: () {
                        widget.ref.read(markWelcomeBannerShownProvider)();
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: isDark
                            ? Colors.white.withAlpha(153)
                            : Colors.black.withAlpha(128),
                      ),
                      child: Text(
                        l10n.maybeLater,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader(AppLocalizations l10n, bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatController,
        _pulseController,
        _shimmerController,
      ]),
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _shimmerAnimation.value, -1.0),
              end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
              colors: const [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
                Color(0xFFF093FB),
                Color(0xFF667EEA),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              // Animated Icon
              Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withAlpha(77),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(38),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withAlpha(128),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.flight_takeoff_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                l10n.welcomeBackExplorer,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.8,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // Subtitle chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(64),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withAlpha(77),
                    width: 1,
                  ),
                ),
                child: Text(
                  l10n.journeyStartsHere,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withAlpha(230),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Interactive feature card with animations
class _InteractiveFeatureCard extends StatefulWidget {
  final IconData icon;
  final LinearGradient gradient;
  final String title;
  final String description;
  final bool isDark;
  final int index;
  final bool isNew;

  const _InteractiveFeatureCard({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.description,
    required this.isDark,
    required this.index,
    this.isNew = false,
  });

  @override
  State<_InteractiveFeatureCard> createState() =>
      _InteractiveFeatureCardState();
}

class _InteractiveFeatureCardState extends State<_InteractiveFeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(30 * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withAlpha(13)
                      : Colors.white.withAlpha(153),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isPressed
                        ? widget.gradient.colors.first.withAlpha(128)
                        : (widget.isDark
                            ? Colors.white.withAlpha(20)
                            : Colors.white.withAlpha(102)),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.colors.first.withAlpha(38),
                      blurRadius: _isPressed ? 20 : 12,
                      offset: Offset(0, _isPressed ? 6 : 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon container
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: widget.gradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: widget.gradient.colors.first.withAlpha(102),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: widget.isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              if (widget.isNew)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: widget.gradient,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'NEW',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: widget.isDark
                                  ? Colors.white.withAlpha(191)
                                  : Colors.black.withAlpha(153),
                              height: 1.4,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Premium action button with shimmer effect
class _PremiumActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Animation<double> shimmerAnimation;

  const _PremiumActionButton({
    required this.label,
    required this.onPressed,
    required this.shimmerAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 700),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: AnimatedBuilder(
        animation: shimmerAnimation,
        builder: (context, _) {
          return Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment(shimmerAnimation.value - 1, 0),
                end: Alignment(shimmerAnimation.value + 1, 0),
                colors: const [
                  Color(0xFF667EEA),
                  Color(0xFF764BA2),
                  Color(0xFFF093FB),
                  Color(0xFF667EEA),
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withAlpha(102),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFFF093FB).withAlpha(77),
                  blurRadius: 40,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.zero,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

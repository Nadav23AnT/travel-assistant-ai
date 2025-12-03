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

/// Daily welcome dialog showcasing app features
class DailyWelcomeDialog extends StatelessWidget {
  final WidgetRef ref;

  const DailyWelcomeDialog({super.key, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: isDark
                  ? const Color(0xFF1A1F2E).withAlpha(240)
                  : Colors.white.withAlpha(240),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(31)
                    : Colors.white.withAlpha(128),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(51),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
                if (isDark)
                  BoxShadow(
                    color: LiquidGlassColors.auroraIndigo.withAlpha(51),
                    blurRadius: 24,
                  ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LiquidGlassColors.auroraGradient,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.wb_sunny_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.welcomeBack,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.discoverFeatures,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withAlpha(204),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Features list
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _FeatureItem(
                        icon: Icons.lightbulb_rounded,
                        gradient: LiquidGlassColors.sunsetGradient,
                        title: l10n.dailyTipsFeature,
                        description: l10n.dailyTipsDescription,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _FeatureItem(
                        icon: Icons.currency_exchange_rounded,
                        gradient: LiquidGlassColors.oceanGradient,
                        title: l10n.multiCurrencyFeature,
                        description: l10n.multiCurrencyDescription,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _FeatureItem(
                        icon: Icons.chat_bubble_rounded,
                        gradient: LiquidGlassColors.mintGradient,
                        title: l10n.aiChatFeature,
                        description: l10n.aiChatDescription,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                // Action button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Mark as shown and close
                        ref.read(markWelcomeBannerShownProvider)();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LiquidGlassColors.auroraIndigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.getStarted,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual feature item widget
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final LinearGradient gradient;
  final String title;
  final String description;
  final bool isDark;

  const _FeatureItem({
    required this.icon,
    required this.gradient,
    required this.title,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withAlpha(77),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

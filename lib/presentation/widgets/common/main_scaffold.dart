import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../../core/design/design_system.dart';
import '../../../l10n/app_localizations.dart';

/// Main scaffold with floating glass navigation bar
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/trips')) return 1;
    if (location.startsWith('/expenses')) return 2;
    if (location.startsWith('/chat')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.trips);
        break;
      case 2:
        context.go(AppRoutes.expenses);
        break;
      case 3:
        context.go(AppRoutes.chat);
        break;
      case 4:
        context.go(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    LiquidGlassColors.canvasBaseDark,
                    const Color(0xFF0D1321),
                    LiquidGlassColors.canvasSubtleDark,
                  ]
                : [
                    LiquidGlassColors.canvasBaseLight,
                    const Color(0xFFF0F4FF),
                    const Color(0xFFFAF5FF),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Main content
            child,

            // Floating navigation bar
            FloatingNavBar(
              currentIndex: _calculateSelectedIndex(context),
              onTap: (index) => _onItemTapped(context, index),
              items: [
                NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: l10n.home,
                ),
                NavItem(
                  icon: Icons.luggage_outlined,
                  activeIcon: Icons.luggage_rounded,
                  label: l10n.trips,
                ),
                NavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: l10n.expenses,
                ),
                NavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: l10n.aiChat,
                ),
                NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: l10n.profile,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

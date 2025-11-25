import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constants.dart';
import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Short delay for splash display
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Check if user is authenticated
    final authService = ref.read(authServiceProvider);
    final isAuthenticated = authService.isAuthenticated;

    if (!isAuthenticated) {
      // Not authenticated, go to login
      context.go(AppRoutes.login);
      return;
    }

    // User is authenticated, check if onboarding is needed
    try {
      final needsOnboarding = await authService.needsOnboarding();

      if (!mounted) return;

      if (needsOnboarding) {
        // Needs onboarding, go to language selection
        context.go(AppRoutes.onboardingLanguages);
      } else {
        // Onboarding complete, go to home
        context.go(AppRoutes.home);
      }
    } catch (e) {
      // On error, go to home anyway
      if (!mounted) return;
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.flight_takeoff,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your AI Travel Buddy',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

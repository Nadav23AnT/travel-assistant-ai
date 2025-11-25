import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/routes.dart';
import 'config/theme.dart';

class TripBuddyApp extends ConsumerWidget {
  const TripBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Get authentication state from provider
    const isAuthenticated = false;

    return MaterialApp.router(
      title: 'TripBuddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRoutes.router(isAuthenticated: isAuthenticated),
    );
  }
}

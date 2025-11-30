import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';

import 'config/routes.dart';
import 'config/theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/providers/settings_provider.dart';

class TripBuddyApp extends ConsumerWidget {
  const TripBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the authentication state from provider
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    // Watch the current locale
    final locale = ref.watch(localeProvider);

    // Watch theme mode from settings
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Waylo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRoutes.router(isAuthenticated: isAuthenticated),

      // Localization configuration
      locale: locale,
      supportedLocales: AppLocales.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

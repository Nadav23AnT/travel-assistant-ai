import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported locales in the app
class AppLocales {
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('fr'), // French
    Locale('de'), // German
    Locale('he'), // Hebrew (RTL)
    Locale('ja'), // Japanese
    Locale('zh'), // Chinese
    Locale('ko'), // Korean
    Locale('it'), // Italian
    Locale('pt'), // Portuguese
    Locale('ru'), // Russian
    Locale('ar'), // Arabic (RTL)
  ];

  /// RTL languages
  static const List<String> rtlLanguages = ['he', 'ar'];

  /// Check if a locale is RTL
  static bool isRtl(Locale locale) {
    return rtlLanguages.contains(locale.languageCode);
  }

  /// Get locale display name
  static String getDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Espanol';
      case 'fr':
        return 'Francais';
      case 'de':
        return 'Deutsch';
      case 'he':
        return 'Hebrew';
      case 'ja':
        return 'Japanese';
      case 'zh':
        return 'Chinese';
      case 'ko':
        return 'Korean';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Portugues';
      case 'ru':
        return 'Russian';
      case 'ar':
        return 'Arabic';
      default:
        return languageCode;
    }
  }

  /// Get locale native name (in its own language)
  static String getNativeName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Espanol';
      case 'fr':
        return 'Francais';
      case 'de':
        return 'Deutsch';
      case 'he':
        return 'Hebrew';
      case 'ja':
        return 'Japanese';
      case 'zh':
        return 'Chinese';
      case 'ko':
        return 'Korean';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Portugues';
      case 'ru':
        return 'Russian';
      case 'ar':
        return 'Arabic';
      default:
        return languageCode;
    }
  }

  /// Get flag emoji for locale
  static String getFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '\u{1F1FA}\u{1F1F8}'; // US flag
      case 'es':
        return '\u{1F1EA}\u{1F1F8}'; // Spain flag
      case 'fr':
        return '\u{1F1EB}\u{1F1F7}'; // France flag
      case 'de':
        return '\u{1F1E9}\u{1F1EA}'; // Germany flag
      case 'he':
        return '\u{1F1EE}\u{1F1F1}'; // Israel flag
      case 'ja':
        return '\u{1F1EF}\u{1F1F5}'; // Japan flag
      case 'zh':
        return '\u{1F1E8}\u{1F1F3}'; // China flag
      case 'ko':
        return '\u{1F1F0}\u{1F1F7}'; // South Korea flag
      case 'it':
        return '\u{1F1EE}\u{1F1F9}'; // Italy flag
      case 'pt':
        return '\u{1F1E7}\u{1F1F7}'; // Brazil flag
      case 'ru':
        return '\u{1F1F7}\u{1F1FA}'; // Russia flag
      case 'ar':
        return '\u{1F1F8}\u{1F1E6}'; // Saudi Arabia flag
      default:
        return '\u{1F30D}'; // Globe
    }
  }
}

/// Key for storing locale preference
const _localePrefsKey = 'app_locale';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Provider for the current app locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

/// Notifier for managing the app locale
class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences _prefs;

  LocaleNotifier(this._prefs) : super(_loadLocale(_prefs));

  /// Load saved locale from preferences
  static Locale _loadLocale(SharedPreferences prefs) {
    final savedLocale = prefs.getString(_localePrefsKey);
    if (savedLocale != null) {
      return Locale(savedLocale);
    }
    // Default to English
    return const Locale('en');
  }

  /// Set a new locale
  Future<void> setLocale(Locale locale) async {
    if (!AppLocales.supportedLocales.contains(locale)) {
      return;
    }
    await _prefs.setString(_localePrefsKey, locale.languageCode);
    state = locale;
  }

  /// Set locale by language code
  Future<void> setLocaleByCode(String languageCode) async {
    await setLocale(Locale(languageCode));
  }

  /// Check if current locale is RTL
  bool get isRtl => AppLocales.isRtl(state);
}

/// Provider for checking if current locale is RTL
final isRtlProvider = Provider<bool>((ref) {
  final locale = ref.watch(localeProvider);
  return AppLocales.isRtl(locale);
});

/// Provider for the current language code
final currentLanguageCodeProvider = Provider<String>((ref) {
  final locale = ref.watch(localeProvider);
  return locale.languageCode;
});

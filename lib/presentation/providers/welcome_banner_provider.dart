import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'locale_provider.dart';

/// Key for storing the last shown date of the welcome banner
const String _welcomeBannerLastShownKey = 'welcome_banner_last_shown_date';

/// Provider to check if the welcome banner should be shown today
final shouldShowWelcomeBannerProvider = FutureProvider<bool>((ref) async {
  try {
    final prefs = ref.watch(sharedPreferencesProvider);
    final lastShown = prefs.getString(_welcomeBannerLastShownKey);

    if (lastShown == null) {
      // Never shown before - show it
      return true;
    }

    final lastDate = DateTime.parse(lastShown);
    final now = DateTime.now();

    // Check if it's a new day
    final isNewDay = lastDate.year != now.year ||
        lastDate.month != now.month ||
        lastDate.day != now.day;

    return isNewDay;
  } catch (e) {
    // On error, show the banner
    return true;
  }
});

/// Provider to mark the welcome banner as shown for today
final markWelcomeBannerShownProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(
        _welcomeBannerLastShownKey,
        DateTime.now().toIso8601String(),
      );
      // Invalidate the check provider to update state
      ref.invalidate(shouldShowWelcomeBannerProvider);
    } catch (e) {
      // Silently fail - not critical
    }
  };
});

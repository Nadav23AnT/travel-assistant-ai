import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/user_settings_model.dart';
import '../../data/repositories/settings_repository.dart';

/// Provider for the settings repository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

/// Main settings state notifier
class UserSettingsNotifier extends StateNotifier<AsyncValue<UserSettingsModel?>> {
  final SettingsRepository _repository;

  UserSettingsNotifier(this._repository)
      : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final settings = await _repository.ensureSettings(user.id);
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Reload settings from database
  Future<void> refresh() async {
    await _loadSettings();
  }

  /// Update dark mode
  Future<bool> updateDarkMode(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    final success = await _repository.updateDarkMode(
      currentSettings.userId,
      enabled,
    );

    if (success) {
      state = AsyncValue.data(currentSettings.copyWith(darkMode: enabled));
    }

    return success;
  }

  /// Update date format
  Future<bool> updateDateFormat(DateFormatOption format) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    final success = await _repository.updateDateFormat(
      currentSettings.userId,
      format,
    );

    if (success) {
      state = AsyncValue.data(currentSettings.copyWith(dateFormat: format));
    }

    return success;
  }

  /// Update distance unit
  Future<bool> updateDistanceUnit(DistanceUnit unit) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    final success = await _repository.updateDistanceUnit(
      currentSettings.userId,
      unit,
    );

    if (success) {
      state = AsyncValue.data(currentSettings.copyWith(distanceUnit: unit));
    }

    return success;
  }

  /// Update push notifications
  Future<bool> updatePushNotifications(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    final success = await _repository.updateNotificationSettings(
      currentSettings.userId,
      pushNotifications: enabled,
    );

    if (success) {
      state = AsyncValue.data(
        currentSettings.copyWith(pushNotifications: enabled),
      );
    }

    return success;
  }

  /// Update email notifications
  Future<bool> updateEmailNotifications(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    final success = await _repository.updateNotificationSettings(
      currentSettings.userId,
      emailNotifications: enabled,
    );

    if (success) {
      state = AsyncValue.data(
        currentSettings.copyWith(emailNotifications: enabled),
      );
    }

    return success;
  }

  /// Update trip reminders
  Future<bool> updateTripReminders(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    final success = await _repository.updateNotificationSettings(
      currentSettings.userId,
      tripReminders: enabled,
    );

    if (success) {
      state = AsyncValue.data(
        currentSettings.copyWith(tripReminders: enabled),
      );
    }

    return success;
  }

  /// Update share analytics
  Future<bool> updateShareAnalytics(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    final success = await _repository.updatePrivacySettings(
      currentSettings.userId,
      shareAnalytics: enabled,
    );

    if (success) {
      state = AsyncValue.data(
        currentSettings.copyWith(shareAnalytics: enabled),
      );
    }

    return success;
  }

  /// Update location tracking
  Future<bool> updateLocationTracking(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    final success = await _repository.updatePrivacySettings(
      currentSettings.userId,
      locationTracking: enabled,
    );

    if (success) {
      state = AsyncValue.data(
        currentSettings.copyWith(locationTracking: enabled),
      );
    }

    return success;
  }
}

/// Main provider for user settings
final userSettingsProvider =
    StateNotifierProvider<UserSettingsNotifier, AsyncValue<UserSettingsModel?>>(
  (ref) {
    final repository = ref.watch(settingsRepositoryProvider);
    return UserSettingsNotifier(repository);
  },
);

/// Provider for dark mode state
final darkModeProvider = Provider<bool>((ref) {
  final settings = ref.watch(userSettingsProvider);
  return settings.valueOrNull?.darkMode ?? false;
});

/// Provider for theme mode (used by MaterialApp)
final themeModeProvider = Provider<ThemeMode>((ref) {
  final isDarkMode = ref.watch(darkModeProvider);
  return isDarkMode ? ThemeMode.dark : ThemeMode.light;
});

/// Provider for date format
final dateFormatProvider = Provider<DateFormatOption>((ref) {
  final settings = ref.watch(userSettingsProvider);
  return settings.valueOrNull?.dateFormat ?? DateFormatOption.ddMmYyyy;
});

/// Provider for distance unit
final distanceUnitProvider = Provider<DistanceUnit>((ref) {
  final settings = ref.watch(userSettingsProvider);
  return settings.valueOrNull?.distanceUnit ?? DistanceUnit.kilometers;
});

/// Provider for push notifications enabled
final pushNotificationsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(userSettingsProvider);
  return settings.valueOrNull?.pushNotifications ?? true;
});

/// Provider for email notifications enabled
final emailNotificationsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(userSettingsProvider);
  return settings.valueOrNull?.emailNotifications ?? true;
});

/// Provider for trip reminders enabled
final tripRemindersEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(userSettingsProvider);
  return settings.valueOrNull?.tripReminders ?? true;
});

/// Provider for share analytics enabled
final shareAnalyticsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(userSettingsProvider);
  return settings.valueOrNull?.shareAnalytics ?? true;
});

/// Provider for location tracking enabled
final locationTrackingEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(userSettingsProvider);
  return settings.valueOrNull?.locationTracking ?? true;
});

/// Provider to refresh settings
final refreshSettingsProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    await ref.read(userSettingsProvider.notifier).refresh();
  };
});

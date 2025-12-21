import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/notification_settings_model.dart';
import '../../data/repositories/notification_settings_repository.dart';

/// Provider for the notification settings repository
final notificationSettingsRepositoryProvider =
    Provider<NotificationSettingsRepository>((ref) {
  return NotificationSettingsRepository();
});

/// Main notification settings state notifier
class NotificationSettingsNotifier
    extends StateNotifier<AsyncValue<NotificationSettingsModel?>> {
  final NotificationSettingsRepository _repository;

  NotificationSettingsNotifier(this._repository)
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

  /// Update master enabled
  Future<bool> updateMasterEnabled(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    // Optimistically update state
    state = AsyncValue.data(currentSettings.copyWith(masterEnabled: enabled));

    final success = await _repository.updateMasterEnabled(
      currentSettings.userId,
      enabled,
    );

    if (!success) {
      // Revert on failure
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update push notifications
  Future<bool> updatePushNotifications(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state =
        AsyncValue.data(currentSettings.copyWith(pushNotifications: enabled));

    final success = await _repository.updatePushNotifications(
      currentSettings.userId,
      enabled,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update email notifications
  Future<bool> updateEmailNotifications(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state =
        AsyncValue.data(currentSettings.copyWith(emailNotifications: enabled));

    final success = await _repository.updateEmailNotifications(
      currentSettings.userId,
      enabled,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update Do Not Disturb schedule
  Future<bool> updateDndSchedule(DoNotDisturbSchedule schedule) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state = AsyncValue.data(currentSettings.copyWith(dndSchedule: schedule));

    final success = await _repository.updateDndSchedule(
      currentSettings.userId,
      schedule,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update trip reminders
  Future<bool> updateTripReminders(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state = AsyncValue.data(currentSettings.copyWith(tripReminders: enabled));

    final success = await _repository.updateTripNotifications(
      currentSettings.userId,
      tripReminders: enabled,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update trip reminder days before
  Future<bool> updateTripReminderDays(int days) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state =
        AsyncValue.data(currentSettings.copyWith(tripReminderDaysBefore: days));

    final success = await _repository.updateTripNotifications(
      currentSettings.userId,
      tripReminderDaysBefore: days,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update trip status changes
  Future<bool> updateTripStatusChanges(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state =
        AsyncValue.data(currentSettings.copyWith(tripStatusChanges: enabled));

    final success = await _repository.updateTripNotifications(
      currentSettings.userId,
      tripStatusChanges: enabled,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update weather warnings
  Future<bool> updateWeatherWarnings(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state = AsyncValue.data(currentSettings.copyWith(weatherWarnings: enabled));

    final success = await _repository.updateTripNotifications(
      currentSettings.userId,
      weatherWarnings: enabled,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update daily trip summary
  Future<bool> updateDailyTripSummary(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state =
        AsyncValue.data(currentSettings.copyWith(dailyTripSummary: enabled));

    final success = await _repository.updateTripNotifications(
      currentSettings.userId,
      dailyTripSummary: enabled,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update daily trip summary time
  Future<bool> updateDailyTripSummaryTime(TimeOfDay time) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state =
        AsyncValue.data(currentSettings.copyWith(dailyTripSummaryTime: time));

    final success = await _repository.updateTripNotifications(
      currentSettings.userId,
      dailyTripSummaryTime: time,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update expense reminder
  Future<bool> updateExpenseReminder(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state = AsyncValue.data(currentSettings.copyWith(expenseReminder: enabled));

    final success = await _repository.updateExpenseNotifications(
      currentSettings.userId,
      expenseReminder: enabled,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update expense reminder time
  Future<bool> updateExpenseReminderTime(TimeOfDay time) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state =
        AsyncValue.data(currentSettings.copyWith(expenseReminderTime: time));

    final success = await _repository.updateExpenseNotifications(
      currentSettings.userId,
      expenseReminderTime: time,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update budget alerts
  Future<bool> updateBudgetAlerts(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state = AsyncValue.data(currentSettings.copyWith(budgetAlerts: enabled));

    final success = await _repository.updateExpenseNotifications(
      currentSettings.userId,
      budgetAlerts: enabled,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update budget alert threshold
  Future<bool> updateBudgetAlertThreshold(double threshold) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state = AsyncValue.data(
        currentSettings.copyWith(budgetAlertThreshold: threshold));

    final success = await _repository.updateExpenseNotifications(
      currentSettings.userId,
      budgetAlertThreshold: threshold,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update weekly spending summary
  Future<bool> updateWeeklySpendingSummary(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state = AsyncValue.data(
        currentSettings.copyWith(weeklySpendingSummary: enabled));

    final success = await _repository.updateExpenseNotifications(
      currentSettings.userId,
      weeklySpendingSummary: enabled,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update journal ready
  Future<bool> updateJournalReady(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state = AsyncValue.data(currentSettings.copyWith(journalReady: enabled));

    final success = await _repository.updateJournalNotifications(
      currentSettings.userId,
      journalReady: enabled,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update daily journal prompt
  Future<bool> updateDailyJournalPrompt(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state =
        AsyncValue.data(currentSettings.copyWith(dailyJournalPrompt: enabled));

    final success = await _repository.updateJournalNotifications(
      currentSettings.userId,
      dailyJournalPrompt: enabled,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update daily journal time
  Future<bool> updateDailyJournalTime(TimeOfDay time) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state = AsyncValue.data(currentSettings.copyWith(dailyJournalTime: time));

    final success = await _repository.updateJournalNotifications(
      currentSettings.userId,
      dailyJournalTime: time,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update rate app reminder
  Future<bool> updateRateAppReminder(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state = AsyncValue.data(currentSettings.copyWith(rateAppReminder: enabled));

    final success = await _repository.updateEngagementNotifications(
      currentSettings.userId,
      rateAppReminder: enabled,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update new feature announcements
  Future<bool> updateNewFeatureAnnouncements(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state = AsyncValue.data(
        currentSettings.copyWith(newFeatureAnnouncements: enabled));

    final success = await _repository.updateEngagementNotifications(
      currentSettings.userId,
      newFeatureAnnouncements: enabled,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update tips and recommendations
  Future<bool> updateTipsAndRecommendations(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state = AsyncValue.data(
        currentSettings.copyWith(tipsAndRecommendations: enabled));

    final success = await _repository.updateEngagementNotifications(
      currentSettings.userId,
      tipsAndRecommendations: enabled,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update support reply notifications
  Future<bool> updateSupportReplyNotifications(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state = AsyncValue.data(
        currentSettings.copyWith(supportReplyNotifications: enabled));

    final success = await _repository.updateSupportNotifications(
      currentSettings.userId,
      supportReplyNotifications: enabled,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }

  /// Update ticket status updates
  Future<bool> updateTicketStatusUpdates(bool enabled) async {
    final currentSettings = state.valueOrNull;
    if (currentSettings == null) return false;

    state =
        AsyncValue.data(currentSettings.copyWith(ticketStatusUpdates: enabled));

    final success = await _repository.updateSupportNotifications(
      currentSettings.userId,
      ticketStatusUpdates: enabled,
    );

    if (!success) {
      state = AsyncValue.data(currentSettings);
    }

    return success;
  }
}

/// Main provider for notification settings
final notificationSettingsProvider = StateNotifierProvider<
    NotificationSettingsNotifier, AsyncValue<NotificationSettingsModel?>>(
  (ref) {
    final repository = ref.watch(notificationSettingsRepositoryProvider);
    return NotificationSettingsNotifier(repository);
  },
);

/// Provider for master notifications enabled
final masterNotificationsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.valueOrNull?.masterEnabled ?? true;
});

/// Provider for push notifications enabled (from notification settings)
final notificationPushEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.valueOrNull?.pushNotifications ?? true;
});

/// Provider for email notifications enabled (from notification settings)
final notificationEmailEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.valueOrNull?.emailNotifications ?? true;
});

/// Provider for DND schedule
final dndScheduleProvider = Provider<DoNotDisturbSchedule>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.valueOrNull?.dndSchedule ?? const DoNotDisturbSchedule();
});

/// Provider for trip reminders enabled (from notification settings)
final notificationTripRemindersProvider = Provider<bool>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.valueOrNull?.tripReminders ?? true;
});

/// Provider for expense reminder time
final expenseReminderTimeProvider = Provider<TimeOfDay>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.valueOrNull?.expenseReminderTime ??
      const TimeOfDay(hour: 20, minute: 0);
});

/// Provider for daily journal time
final dailyJournalTimeProvider = Provider<TimeOfDay>((ref) {
  final settings = ref.watch(notificationSettingsProvider);
  return settings.valueOrNull?.dailyJournalTime ??
      const TimeOfDay(hour: 21, minute: 0);
});

/// Provider to refresh notification settings
final refreshNotificationSettingsProvider =
    Provider<Future<void> Function()>((ref) {
  return () async {
    await ref.read(notificationSettingsProvider.notifier).refresh();
  };
});

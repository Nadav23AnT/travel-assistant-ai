import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_settings_model.dart';

/// Repository for managing notification settings in Supabase
class NotificationSettingsRepository {
  final SupabaseClient _supabase;

  NotificationSettingsRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Get notification settings for a specific user
  Future<NotificationSettingsModel?> getSettings(String userId) async {
    try {
      final response = await _supabase
          .from('notification_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return NotificationSettingsModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting notification settings: $e');
      return null;
    }
  }

  /// Get notification settings for the current authenticated user
  Future<NotificationSettingsModel?> getCurrentUserSettings() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }
    return getSettings(user.id);
  }

  /// Update multiple notification settings at once
  Future<NotificationSettingsModel?> updateSettings(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Add updated_at timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('notification_settings')
          .update(updates)
          .eq('user_id', userId)
          .select()
          .single();

      return NotificationSettingsModel.fromJson(response);
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      return null;
    }
  }

  /// Update a single notification setting
  Future<bool> updateSingleSetting(
    String userId,
    String key,
    dynamic value,
  ) async {
    try {
      await _supabase.from('notification_settings').update({
        key: value,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);

      return true;
    } catch (e) {
      debugPrint('Error updating notification setting $key: $e');
      return false;
    }
  }

  /// Update master enabled setting
  Future<bool> updateMasterEnabled(String userId, bool enabled) async {
    return updateSingleSetting(userId, 'master_enabled', enabled);
  }

  /// Update push notifications setting
  Future<bool> updatePushNotifications(String userId, bool enabled) async {
    return updateSingleSetting(userId, 'push_notifications', enabled);
  }

  /// Update email notifications setting
  Future<bool> updateEmailNotifications(String userId, bool enabled) async {
    return updateSingleSetting(userId, 'email_notifications', enabled);
  }

  /// Update Do Not Disturb schedule
  Future<bool> updateDndSchedule(
    String userId,
    DoNotDisturbSchedule schedule,
  ) async {
    final updates = schedule.toJson();
    final result = await updateSettings(userId, updates);
    return result != null;
  }

  /// Update trip notifications
  Future<bool> updateTripNotifications(
    String userId, {
    bool? tripReminders,
    int? tripReminderDaysBefore,
    bool? tripStatusChanges,
    bool? weatherWarnings,
    bool? dailyTripSummary,
    TimeOfDay? dailyTripSummaryTime,
  }) async {
    final updates = <String, dynamic>{};

    if (tripReminders != null) {
      updates['trip_reminders'] = tripReminders;
    }
    if (tripReminderDaysBefore != null) {
      updates['trip_reminder_days_before'] = tripReminderDaysBefore;
    }
    if (tripStatusChanges != null) {
      updates['trip_status_changes'] = tripStatusChanges;
    }
    if (weatherWarnings != null) {
      updates['weather_warnings'] = weatherWarnings;
    }
    if (dailyTripSummary != null) {
      updates['daily_trip_summary'] = dailyTripSummary;
    }
    if (dailyTripSummaryTime != null) {
      updates['daily_trip_summary_time'] = _formatTime(dailyTripSummaryTime);
    }

    if (updates.isEmpty) return true;

    final result = await updateSettings(userId, updates);
    return result != null;
  }

  /// Update expense & budget notifications
  Future<bool> updateExpenseNotifications(
    String userId, {
    bool? expenseReminder,
    TimeOfDay? expenseReminderTime,
    bool? budgetAlerts,
    double? budgetAlertThreshold,
    bool? weeklySpendingSummary,
  }) async {
    final updates = <String, dynamic>{};

    if (expenseReminder != null) {
      updates['expense_reminder'] = expenseReminder;
    }
    if (expenseReminderTime != null) {
      updates['expense_reminder_time'] = _formatTime(expenseReminderTime);
    }
    if (budgetAlerts != null) {
      updates['budget_alerts'] = budgetAlerts;
    }
    if (budgetAlertThreshold != null) {
      updates['budget_alert_threshold'] = budgetAlertThreshold;
    }
    if (weeklySpendingSummary != null) {
      updates['weekly_spending_summary'] = weeklySpendingSummary;
    }

    if (updates.isEmpty) return true;

    final result = await updateSettings(userId, updates);
    return result != null;
  }

  /// Update journal notifications
  Future<bool> updateJournalNotifications(
    String userId, {
    bool? journalReady,
    bool? dailyJournalPrompt,
    TimeOfDay? dailyJournalTime,
  }) async {
    final updates = <String, dynamic>{};

    if (journalReady != null) {
      updates['journal_ready'] = journalReady;
    }
    if (dailyJournalPrompt != null) {
      updates['daily_journal_prompt'] = dailyJournalPrompt;
    }
    if (dailyJournalTime != null) {
      updates['daily_journal_time'] = _formatTime(dailyJournalTime);
    }

    if (updates.isEmpty) return true;

    final result = await updateSettings(userId, updates);
    return result != null;
  }

  /// Update app & engagement notifications
  Future<bool> updateEngagementNotifications(
    String userId, {
    bool? dailyTips,
    bool? newFeatureAnnouncements,
    bool? tipsAndRecommendations,
  }) async {
    final updates = <String, dynamic>{};

    if (dailyTips != null) {
      updates['daily_tips'] = dailyTips;
    }
    if (newFeatureAnnouncements != null) {
      updates['new_feature_announcements'] = newFeatureAnnouncements;
    }
    if (tipsAndRecommendations != null) {
      updates['tips_and_recommendations'] = tipsAndRecommendations;
    }

    if (updates.isEmpty) return true;

    final result = await updateSettings(userId, updates);
    return result != null;
  }

  /// Update support notifications
  Future<bool> updateSupportNotifications(
    String userId, {
    bool? supportReplyNotifications,
    bool? ticketStatusUpdates,
  }) async {
    final updates = <String, dynamic>{};

    if (supportReplyNotifications != null) {
      updates['support_reply_notifications'] = supportReplyNotifications;
    }
    if (ticketStatusUpdates != null) {
      updates['ticket_status_updates'] = ticketStatusUpdates;
    }

    if (updates.isEmpty) return true;

    final result = await updateSettings(userId, updates);
    return result != null;
  }

  /// Save FCM token for push notifications
  Future<bool> saveFcmToken(String userId, String token) async {
    try {
      await _supabase.from('profiles').update({
        'fcm_token': token,
        'fcm_token_updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return true;
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
      return false;
    }
  }

  /// Clear FCM token (on logout)
  Future<bool> clearFcmToken(String userId) async {
    try {
      await _supabase.from('profiles').update({
        'fcm_token': null,
        'fcm_token_updated_at': null,
      }).eq('id', userId);

      return true;
    } catch (e) {
      debugPrint('Error clearing FCM token: $e');
      return false;
    }
  }

  /// Create default notification settings for a new user
  Future<NotificationSettingsModel?> createDefaultSettings(String userId) async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('notification_settings')
          .insert({
            'user_id': userId,
            'master_enabled': true,
            'push_notifications': true,
            'email_notifications': true,
            'dnd_enabled': false,
            'dnd_start_time': '22:00:00',
            'dnd_end_time': '07:00:00',
            'dnd_active_days': [1, 2, 3, 4, 5, 6, 7],
            'trip_reminders': true,
            'trip_reminder_days_before': 3,
            'trip_status_changes': true,
            'weather_warnings': true,
            'daily_trip_summary': true,
            'daily_trip_summary_time': '20:00:00',
            'expense_reminder': true,
            'expense_reminder_time': '20:00:00',
            'budget_alerts': true,
            'budget_alert_threshold': 0.90,
            'weekly_spending_summary': true,
            'journal_ready': true,
            'daily_journal_prompt': false,
            'daily_journal_time': '21:00:00',
            'daily_tips': true,
            'new_feature_announcements': true,
            'tips_and_recommendations': true,
            'support_reply_notifications': true,
            'ticket_status_updates': true,
            'created_at': now,
            'updated_at': now,
          })
          .select()
          .single();

      return NotificationSettingsModel.fromJson(response);
    } catch (e) {
      debugPrint('Error creating default notification settings: $e');
      return null;
    }
  }

  /// Ensure notification settings exist for user (get or create)
  Future<NotificationSettingsModel?> ensureSettings(String userId) async {
    var settings = await getSettings(userId);
    if (settings == null) {
      settings = await createDefaultSettings(userId);
    }
    return settings;
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }
}

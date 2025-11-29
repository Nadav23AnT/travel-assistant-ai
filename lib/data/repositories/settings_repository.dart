import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_settings_model.dart';

/// Repository for managing user settings in Supabase
class SettingsRepository {
  final SupabaseClient _supabase;

  SettingsRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Get settings for a specific user
  Future<UserSettingsModel?> getSettings(String userId) async {
    try {
      final response = await _supabase
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return UserSettingsModel.fromJson(response);
    } catch (e) {
      print('Error getting settings: $e');
      return null;
    }
  }

  /// Get settings for the current authenticated user
  Future<UserSettingsModel?> getCurrentUserSettings() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }
    return getSettings(user.id);
  }

  /// Update multiple settings at once
  Future<UserSettingsModel?> updateSettings(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Add updated_at timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('user_settings')
          .update(updates)
          .eq('user_id', userId)
          .select()
          .single();

      return UserSettingsModel.fromJson(response);
    } catch (e) {
      print('Error updating settings: $e');
      return null;
    }
  }

  /// Update a single setting
  Future<bool> updateSingleSetting(
    String userId,
    String key,
    dynamic value,
  ) async {
    try {
      await _supabase
          .from('user_settings')
          .update({
            key: value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('Error updating setting $key: $e');
      return false;
    }
  }

  /// Update dark mode setting
  Future<bool> updateDarkMode(String userId, bool enabled) async {
    return updateSingleSetting(userId, 'dark_mode', enabled);
  }

  /// Update date format setting
  Future<bool> updateDateFormat(String userId, DateFormatOption format) async {
    return updateSingleSetting(userId, 'date_format', format.value);
  }

  /// Update distance unit setting
  Future<bool> updateDistanceUnit(String userId, DistanceUnit unit) async {
    return updateSingleSetting(userId, 'distance_unit', unit.value);
  }

  /// Update notification settings
  Future<bool> updateNotificationSettings(
    String userId, {
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? tripReminders,
  }) async {
    final updates = <String, dynamic>{};

    if (notificationsEnabled != null) {
      updates['notifications_enabled'] = notificationsEnabled;
    }
    if (emailNotifications != null) {
      updates['email_notifications'] = emailNotifications;
    }
    if (pushNotifications != null) {
      updates['push_notifications'] = pushNotifications;
    }
    if (tripReminders != null) {
      updates['trip_reminders'] = tripReminders;
    }

    if (updates.isEmpty) return true;

    final result = await updateSettings(userId, updates);
    return result != null;
  }

  /// Update privacy settings
  Future<bool> updatePrivacySettings(
    String userId, {
    bool? shareAnalytics,
    bool? locationTracking,
  }) async {
    final updates = <String, dynamic>{};

    if (shareAnalytics != null) {
      updates['share_analytics'] = shareAnalytics;
    }
    if (locationTracking != null) {
      updates['location_tracking'] = locationTracking;
    }

    if (updates.isEmpty) return true;

    final result = await updateSettings(userId, updates);
    return result != null;
  }

  /// Update AI provider settings
  Future<bool> updateAISettings(
    String userId, {
    String? aiProvider,
    String? aiModel,
  }) async {
    final updates = <String, dynamic>{};

    if (aiProvider != null) {
      updates['ai_provider'] = aiProvider;
    }
    if (aiModel != null) {
      updates['ai_model'] = aiModel;
    }

    if (updates.isEmpty) return true;

    final result = await updateSettings(userId, updates);
    return result != null;
  }

  /// Create default settings for a new user (if not auto-created by trigger)
  Future<UserSettingsModel?> createDefaultSettings(String userId) async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('user_settings')
          .insert({
            'user_id': userId,
            'ai_provider': 'openai',
            'ai_model': 'gpt-4',
            'date_format': 'DD/MM/YYYY',
            'distance_unit': 'km',
            'dark_mode': false,
            'notifications_enabled': true,
            'email_notifications': true,
            'push_notifications': true,
            'trip_reminders': true,
            'share_analytics': true,
            'location_tracking': true,
            'preferred_languages': ['en'],
            'onboarding_completed': false,
            'created_at': now,
            'updated_at': now,
          })
          .select()
          .single();

      return UserSettingsModel.fromJson(response);
    } catch (e) {
      print('Error creating default settings: $e');
      return null;
    }
  }

  /// Ensure settings exist for user (get or create)
  Future<UserSettingsModel?> ensureSettings(String userId) async {
    var settings = await getSettings(userId);
    if (settings == null) {
      settings = await createDefaultSettings(userId);
    }
    return settings;
  }
}

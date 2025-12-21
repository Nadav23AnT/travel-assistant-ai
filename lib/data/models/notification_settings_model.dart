import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Do Not Disturb schedule configuration
@immutable
class DoNotDisturbSchedule {
  final bool enabled;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<int> activeDays; // 1=Monday to 7=Sunday

  const DoNotDisturbSchedule({
    this.enabled = false,
    this.startTime = const TimeOfDay(hour: 22, minute: 0),
    this.endTime = const TimeOfDay(hour: 7, minute: 0),
    this.activeDays = const [1, 2, 3, 4, 5, 6, 7],
  });

  factory DoNotDisturbSchedule.fromJson(Map<String, dynamic> json) {
    return DoNotDisturbSchedule(
      enabled: json['dnd_enabled'] as bool? ?? false,
      startTime: _parseTime(json['dnd_start_time'] as String?),
      endTime: _parseTime(json['dnd_end_time'] as String?),
      activeDays: (json['dnd_active_days'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [1, 2, 3, 4, 5, 6, 7],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dnd_enabled': enabled,
      'dnd_start_time': _formatTime(startTime),
      'dnd_end_time': _formatTime(endTime),
      'dnd_active_days': activeDays,
    };
  }

  DoNotDisturbSchedule copyWith({
    bool? enabled,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    List<int>? activeDays,
  }) {
    return DoNotDisturbSchedule(
      enabled: enabled ?? this.enabled,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      activeDays: activeDays ?? this.activeDays,
    );
  }

  static TimeOfDay _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) {
      return const TimeOfDay(hour: 22, minute: 0);
    }
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 22,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  static String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  String get displayRange {
    final startStr =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$startStr - $endStr';
  }

  bool isActiveOn(int day) => activeDays.contains(day);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoNotDisturbSchedule &&
        other.enabled == enabled &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        listEquals(other.activeDays, activeDays);
  }

  @override
  int get hashCode => Object.hash(enabled, startTime, endTime, activeDays);
}

/// Comprehensive notification settings model
@immutable
class NotificationSettingsModel {
  final String id;
  final String userId;

  // Master control
  final bool masterEnabled;

  // General notifications
  final bool pushNotifications;
  final bool emailNotifications;
  final DoNotDisturbSchedule dndSchedule;

  // Trip notifications
  final bool tripReminders;
  final int tripReminderDaysBefore;
  final bool tripStatusChanges;
  final bool weatherWarnings;
  final bool dailyTripSummary;
  final TimeOfDay dailyTripSummaryTime;

  // Expense & Budget notifications
  final bool expenseReminder;
  final TimeOfDay expenseReminderTime;
  final bool budgetAlerts;
  final double budgetAlertThreshold;
  final bool weeklySpendingSummary;

  // Journal & Memories notifications
  final bool journalReady;
  final bool dailyJournalPrompt;
  final TimeOfDay dailyJournalTime;

  // App & Engagement notifications
  final bool dailyTips;
  final bool newFeatureAnnouncements;
  final bool tipsAndRecommendations;

  // Support notifications
  final bool supportReplyNotifications;
  final bool ticketStatusUpdates;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationSettingsModel({
    required this.id,
    required this.userId,
    this.masterEnabled = true,
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.dndSchedule = const DoNotDisturbSchedule(),
    this.tripReminders = true,
    this.tripReminderDaysBefore = 3,
    this.tripStatusChanges = true,
    this.weatherWarnings = true,
    this.dailyTripSummary = true,
    this.dailyTripSummaryTime = const TimeOfDay(hour: 20, minute: 0),
    this.expenseReminder = true,
    this.expenseReminderTime = const TimeOfDay(hour: 20, minute: 0),
    this.budgetAlerts = true,
    this.budgetAlertThreshold = 0.90,
    this.weeklySpendingSummary = true,
    this.journalReady = true,
    this.dailyJournalPrompt = false,
    this.dailyJournalTime = const TimeOfDay(hour: 21, minute: 0),
    this.dailyTips = true,
    this.newFeatureAnnouncements = true,
    this.tipsAndRecommendations = true,
    this.supportReplyNotifications = true,
    this.ticketStatusUpdates = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Supabase JSON response
  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      masterEnabled: json['master_enabled'] as bool? ?? true,
      pushNotifications: json['push_notifications'] as bool? ?? true,
      emailNotifications: json['email_notifications'] as bool? ?? true,
      dndSchedule: DoNotDisturbSchedule.fromJson(json),
      tripReminders: json['trip_reminders'] as bool? ?? true,
      tripReminderDaysBefore: json['trip_reminder_days_before'] as int? ?? 3,
      tripStatusChanges: json['trip_status_changes'] as bool? ?? true,
      weatherWarnings: json['weather_warnings'] as bool? ?? true,
      dailyTripSummary: json['daily_trip_summary'] as bool? ?? true,
      dailyTripSummaryTime:
          _parseTime(json['daily_trip_summary_time'] as String?),
      expenseReminder: json['expense_reminder'] as bool? ?? true,
      expenseReminderTime:
          _parseTime(json['expense_reminder_time'] as String?),
      budgetAlerts: json['budget_alerts'] as bool? ?? true,
      budgetAlertThreshold:
          (json['budget_alert_threshold'] as num?)?.toDouble() ?? 0.90,
      weeklySpendingSummary: json['weekly_spending_summary'] as bool? ?? true,
      journalReady: json['journal_ready'] as bool? ?? true,
      dailyJournalPrompt: json['daily_journal_prompt'] as bool? ?? false,
      dailyJournalTime: _parseTime(json['daily_journal_time'] as String?),
      dailyTips: json['daily_tips'] as bool? ?? true,
      newFeatureAnnouncements:
          json['new_feature_announcements'] as bool? ?? true,
      tipsAndRecommendations:
          json['tips_and_recommendations'] as bool? ?? true,
      supportReplyNotifications:
          json['support_reply_notifications'] as bool? ?? true,
      ticketStatusUpdates: json['ticket_status_updates'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to JSON for Supabase update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'master_enabled': masterEnabled,
      'push_notifications': pushNotifications,
      'email_notifications': emailNotifications,
      ...dndSchedule.toJson(),
      'trip_reminders': tripReminders,
      'trip_reminder_days_before': tripReminderDaysBefore,
      'trip_status_changes': tripStatusChanges,
      'weather_warnings': weatherWarnings,
      'daily_trip_summary': dailyTripSummary,
      'daily_trip_summary_time': _formatTime(dailyTripSummaryTime),
      'expense_reminder': expenseReminder,
      'expense_reminder_time': _formatTime(expenseReminderTime),
      'budget_alerts': budgetAlerts,
      'budget_alert_threshold': budgetAlertThreshold,
      'weekly_spending_summary': weeklySpendingSummary,
      'journal_ready': journalReady,
      'daily_journal_prompt': dailyJournalPrompt,
      'daily_journal_time': _formatTime(dailyJournalTime),
      'daily_tips': dailyTips,
      'new_feature_announcements': newFeatureAnnouncements,
      'tips_and_recommendations': tipsAndRecommendations,
      'support_reply_notifications': supportReplyNotifications,
      'ticket_status_updates': ticketStatusUpdates,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  NotificationSettingsModel copyWith({
    String? id,
    String? userId,
    bool? masterEnabled,
    bool? pushNotifications,
    bool? emailNotifications,
    DoNotDisturbSchedule? dndSchedule,
    bool? tripReminders,
    int? tripReminderDaysBefore,
    bool? tripStatusChanges,
    bool? weatherWarnings,
    bool? dailyTripSummary,
    TimeOfDay? dailyTripSummaryTime,
    bool? expenseReminder,
    TimeOfDay? expenseReminderTime,
    bool? budgetAlerts,
    double? budgetAlertThreshold,
    bool? weeklySpendingSummary,
    bool? journalReady,
    bool? dailyJournalPrompt,
    TimeOfDay? dailyJournalTime,
    bool? dailyTips,
    bool? newFeatureAnnouncements,
    bool? tipsAndRecommendations,
    bool? supportReplyNotifications,
    bool? ticketStatusUpdates,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationSettingsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      masterEnabled: masterEnabled ?? this.masterEnabled,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      dndSchedule: dndSchedule ?? this.dndSchedule,
      tripReminders: tripReminders ?? this.tripReminders,
      tripReminderDaysBefore:
          tripReminderDaysBefore ?? this.tripReminderDaysBefore,
      tripStatusChanges: tripStatusChanges ?? this.tripStatusChanges,
      weatherWarnings: weatherWarnings ?? this.weatherWarnings,
      dailyTripSummary: dailyTripSummary ?? this.dailyTripSummary,
      dailyTripSummaryTime: dailyTripSummaryTime ?? this.dailyTripSummaryTime,
      expenseReminder: expenseReminder ?? this.expenseReminder,
      expenseReminderTime: expenseReminderTime ?? this.expenseReminderTime,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      budgetAlertThreshold: budgetAlertThreshold ?? this.budgetAlertThreshold,
      weeklySpendingSummary:
          weeklySpendingSummary ?? this.weeklySpendingSummary,
      journalReady: journalReady ?? this.journalReady,
      dailyJournalPrompt: dailyJournalPrompt ?? this.dailyJournalPrompt,
      dailyJournalTime: dailyJournalTime ?? this.dailyJournalTime,
      dailyTips: dailyTips ?? this.dailyTips,
      newFeatureAnnouncements:
          newFeatureAnnouncements ?? this.newFeatureAnnouncements,
      tipsAndRecommendations:
          tipsAndRecommendations ?? this.tipsAndRecommendations,
      supportReplyNotifications:
          supportReplyNotifications ?? this.supportReplyNotifications,
      ticketStatusUpdates: ticketStatusUpdates ?? this.ticketStatusUpdates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Default settings for a new user
  static NotificationSettingsModel defaultSettings(String userId) {
    final now = DateTime.now();
    return NotificationSettingsModel(
      id: '',
      userId: userId,
      createdAt: now,
      updatedAt: now,
    );
  }

  static TimeOfDay _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) {
      return const TimeOfDay(hour: 20, minute: 0);
    }
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 20,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  static String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationSettingsModel &&
        other.id == id &&
        other.userId == userId &&
        other.masterEnabled == masterEnabled;
  }

  @override
  int get hashCode => Object.hash(id, userId, masterEnabled);
}

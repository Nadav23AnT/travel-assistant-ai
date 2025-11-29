import 'package:flutter/foundation.dart';

/// Available date format options
enum DateFormatOption {
  ddMmYyyy('DD/MM/YYYY'),
  mmDdYyyy('MM/DD/YYYY'),
  yyyyMmDd('YYYY-MM-DD');

  final String value;
  const DateFormatOption(this.value);

  static DateFormatOption fromString(String? value) {
    return DateFormatOption.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DateFormatOption.ddMmYyyy,
    );
  }

  String get displayName {
    switch (this) {
      case DateFormatOption.ddMmYyyy:
        return '31/12/2025';
      case DateFormatOption.mmDdYyyy:
        return '12/31/2025';
      case DateFormatOption.yyyyMmDd:
        return '2025-12-31';
    }
  }
}

/// Available distance unit options
enum DistanceUnit {
  kilometers('km'),
  miles('mi');

  final String value;
  const DistanceUnit(this.value);

  static DistanceUnit fromString(String? value) {
    return DistanceUnit.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DistanceUnit.kilometers,
    );
  }
}

/// User settings model representing all user preferences
@immutable
class UserSettingsModel {
  final String id;
  final String userId;

  // AI preferences
  final String aiProvider;
  final String aiModel;

  // Display preferences
  final DateFormatOption dateFormat;
  final DistanceUnit distanceUnit;
  final bool darkMode;

  // Notification settings
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool tripReminders;

  // Privacy settings
  final bool shareAnalytics;
  final bool locationTracking;

  // User preferences
  final List<String> preferredLanguages;

  // Onboarding state
  final bool onboardingCompleted;
  final DateTime? onboardingCompletedAt;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSettingsModel({
    required this.id,
    required this.userId,
    this.aiProvider = 'openai',
    this.aiModel = 'gpt-4',
    this.dateFormat = DateFormatOption.ddMmYyyy,
    this.distanceUnit = DistanceUnit.kilometers,
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.tripReminders = true,
    this.shareAnalytics = true,
    this.locationTracking = true,
    this.preferredLanguages = const ['en'],
    this.onboardingCompleted = false,
    this.onboardingCompletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Supabase JSON response
  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      aiProvider: json['ai_provider'] as String? ?? 'openai',
      aiModel: json['ai_model'] as String? ?? 'gpt-4',
      dateFormat: DateFormatOption.fromString(json['date_format'] as String?),
      distanceUnit: DistanceUnit.fromString(json['distance_unit'] as String?),
      darkMode: json['dark_mode'] as bool? ?? false,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      emailNotifications: json['email_notifications'] as bool? ?? true,
      pushNotifications: json['push_notifications'] as bool? ?? true,
      tripReminders: json['trip_reminders'] as bool? ?? true,
      shareAnalytics: json['share_analytics'] as bool? ?? true,
      locationTracking: json['location_tracking'] as bool? ?? true,
      preferredLanguages: (json['preferred_languages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          ['en'],
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      onboardingCompletedAt: json['onboarding_completed_at'] != null
          ? DateTime.parse(json['onboarding_completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'ai_provider': aiProvider,
      'ai_model': aiModel,
      'date_format': dateFormat.value,
      'distance_unit': distanceUnit.value,
      'dark_mode': darkMode,
      'notifications_enabled': notificationsEnabled,
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'trip_reminders': tripReminders,
      'share_analytics': shareAnalytics,
      'location_tracking': locationTracking,
      'preferred_languages': preferredLanguages,
      'onboarding_completed': onboardingCompleted,
      'onboarding_completed_at': onboardingCompletedAt?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  UserSettingsModel copyWith({
    String? id,
    String? userId,
    String? aiProvider,
    String? aiModel,
    DateFormatOption? dateFormat,
    DistanceUnit? distanceUnit,
    bool? darkMode,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? tripReminders,
    bool? shareAnalytics,
    bool? locationTracking,
    List<String>? preferredLanguages,
    bool? onboardingCompleted,
    DateTime? onboardingCompletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettingsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      aiProvider: aiProvider ?? this.aiProvider,
      aiModel: aiModel ?? this.aiModel,
      dateFormat: dateFormat ?? this.dateFormat,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      tripReminders: tripReminders ?? this.tripReminders,
      shareAnalytics: shareAnalytics ?? this.shareAnalytics,
      locationTracking: locationTracking ?? this.locationTracking,
      preferredLanguages: preferredLanguages ?? this.preferredLanguages,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      onboardingCompletedAt: onboardingCompletedAt ?? this.onboardingCompletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Default settings for a new user
  static UserSettingsModel defaultSettings(String userId) {
    final now = DateTime.now();
    return UserSettingsModel(
      id: '',
      userId: userId,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettingsModel &&
        other.id == id &&
        other.userId == userId &&
        other.darkMode == darkMode &&
        other.dateFormat == dateFormat &&
        other.distanceUnit == distanceUnit;
  }

  @override
  int get hashCode => Object.hash(id, userId, darkMode, dateFormat, distanceUnit);
}

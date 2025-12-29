import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Priority levels for broadcast notifications
enum NotificationPriority {
  normal,
  important,
  urgent;

  /// Parse priority from string
  static NotificationPriority fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'important':
        return NotificationPriority.important;
      case 'urgent':
        return NotificationPriority.urgent;
      default:
        return NotificationPriority.normal;
    }
  }

  /// Get display name for priority
  String get displayName {
    switch (this) {
      case NotificationPriority.normal:
        return 'Normal';
      case NotificationPriority.important:
        return 'Important';
      case NotificationPriority.urgent:
        return 'Urgent';
    }
  }

  /// Get color for priority
  Color get color {
    switch (this) {
      case NotificationPriority.normal:
        return const Color(0xFF2196F3); // Blue
      case NotificationPriority.important:
        return const Color(0xFFFF9800); // Amber/Orange
      case NotificationPriority.urgent:
        return const Color(0xFFF44336); // Red
    }
  }

  /// Get icon for priority
  IconData get icon {
    switch (this) {
      case NotificationPriority.normal:
        return Icons.info_outline;
      case NotificationPriority.important:
        return Icons.priority_high;
      case NotificationPriority.urgent:
        return Icons.warning_amber;
    }
  }

  /// Whether this priority should persist until explicitly dismissed
  bool get isPersistent => this == NotificationPriority.urgent;
}

/// User-facing broadcast notification model
@immutable
class BroadcastNotificationModel {
  final String id;
  final String notificationId;
  final String title;
  final String message;
  final NotificationPriority priority;
  final String? deepLink;
  final DateTime sentAt;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? dismissedAt;

  const BroadcastNotificationModel({
    required this.id,
    required this.notificationId,
    required this.title,
    required this.message,
    required this.priority,
    this.deepLink,
    required this.sentAt,
    this.isRead = false,
    this.readAt,
    this.dismissedAt,
  });

  /// Create from JSON (Supabase response)
  factory BroadcastNotificationModel.fromJson(Map<String, dynamic> json) {
    return BroadcastNotificationModel(
      id: json['id'] as String,
      notificationId: json['notification_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      priority: NotificationPriority.fromString(json['priority'] as String?),
      deepLink: json['deep_link'] as String?,
      sentAt: DateTime.parse(json['sent_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      dismissedAt: json['dismissed_at'] != null
          ? DateTime.parse(json['dismissed_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_id': notificationId,
      'title': title,
      'message': message,
      'priority': priority.name,
      'deep_link': deepLink,
      'sent_at': sentAt.toIso8601String(),
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'dismissed_at': dismissedAt?.toIso8601String(),
    };
  }

  /// Copy with modified fields
  BroadcastNotificationModel copyWith({
    String? id,
    String? notificationId,
    String? title,
    String? message,
    NotificationPriority? priority,
    String? deepLink,
    DateTime? sentAt,
    bool? isRead,
    DateTime? readAt,
    DateTime? dismissedAt,
  }) {
    return BroadcastNotificationModel(
      id: id ?? this.id,
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      message: message ?? this.message,
      priority: priority ?? this.priority,
      deepLink: deepLink ?? this.deepLink,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      dismissedAt: dismissedAt ?? this.dismissedAt,
    );
  }

  /// Check if notification has a deep link
  bool get hasDeepLink => deepLink != null && deepLink!.isNotEmpty;

  /// Check if notification is dismissed
  bool get isDismissed => dismissedAt != null;

  /// Get relative time string (e.g., "2 hours ago")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(sentAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BroadcastNotificationModel &&
        other.id == id &&
        other.notificationId == notificationId &&
        other.isRead == isRead &&
        other.dismissedAt == dismissedAt;
  }

  @override
  int get hashCode => Object.hash(id, notificationId, isRead, dismissedAt);

  @override
  String toString() {
    return 'BroadcastNotificationModel(id: $id, title: $title, priority: $priority, isRead: $isRead)';
  }
}

/// Admin view of broadcast notification with stats
@immutable
class AdminBroadcastModel {
  final String id;
  final String title;
  final String message;
  final NotificationPriority priority;
  final String? deepLink;
  final String? sentBy;
  final String? sentByEmail;
  final DateTime sentAt;
  final DateTime expiresAt;
  final int sentCount;
  final int readCount;
  final int dismissedCount;
  final int clickCount;

  const AdminBroadcastModel({
    required this.id,
    required this.title,
    required this.message,
    required this.priority,
    this.deepLink,
    this.sentBy,
    this.sentByEmail,
    required this.sentAt,
    required this.expiresAt,
    required this.sentCount,
    required this.readCount,
    required this.dismissedCount,
    required this.clickCount,
  });

  /// Create from JSON (Supabase response)
  factory AdminBroadcastModel.fromJson(Map<String, dynamic> json) {
    return AdminBroadcastModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      priority: NotificationPriority.fromString(json['priority'] as String?),
      deepLink: json['deep_link'] as String?,
      sentBy: json['sent_by'] as String?,
      sentByEmail: json['sent_by_email'] as String?,
      sentAt: DateTime.parse(json['sent_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      sentCount: (json['sent_count'] as num?)?.toInt() ?? 0,
      readCount: (json['read_count'] as num?)?.toInt() ?? 0,
      dismissedCount: (json['dismissed_count'] as num?)?.toInt() ?? 0,
      clickCount: (json['click_count'] as num?)?.toInt() ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'priority': priority.name,
      'deep_link': deepLink,
      'sent_by': sentBy,
      'sent_by_email': sentByEmail,
      'sent_at': sentAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'sent_count': sentCount,
      'read_count': readCount,
      'dismissed_count': dismissedCount,
      'click_count': clickCount,
    };
  }

  /// Get read percentage
  double get readPercentage {
    if (sentCount == 0) return 0;
    return (readCount / sentCount * 100);
  }

  /// Get read percentage as formatted string
  String get readPercentageFormatted => '${readPercentage.toStringAsFixed(1)}%';

  /// Check if notification has a deep link
  bool get hasDeepLink => deepLink != null && deepLink!.isNotEmpty;

  /// Check if notification is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Get relative time string
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(sentAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminBroadcastModel &&
        other.id == id &&
        other.sentCount == sentCount &&
        other.readCount == readCount;
  }

  @override
  int get hashCode => Object.hash(id, sentCount, readCount);

  @override
  String toString() {
    return 'AdminBroadcastModel(id: $id, title: $title, sentCount: $sentCount, readCount: $readCount)';
  }
}

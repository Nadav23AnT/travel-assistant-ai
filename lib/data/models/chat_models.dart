import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../core/design/tokens/colors.dart';

/// Chat subject types for categorizing conversations
enum ChatSubject {
  day,
  expense,
  activity,
  journal,
  general;

  /// Display name for the subject
  String get displayName {
    switch (this) {
      case ChatSubject.day:
        return 'Tell About Day';
      case ChatSubject.expense:
        return 'Expense Tracking';
      case ChatSubject.activity:
        return 'Activity Planning';
      case ChatSubject.journal:
        return 'Journal Entry';
      case ChatSubject.general:
        return 'General Chat';
    }
  }

  /// Icon for the subject
  IconData get icon {
    switch (this) {
      case ChatSubject.day:
        return Icons.wb_sunny_rounded;
      case ChatSubject.expense:
        return Icons.receipt_long_rounded;
      case ChatSubject.activity:
        return Icons.explore_rounded;
      case ChatSubject.journal:
        return Icons.auto_stories_rounded;
      case ChatSubject.general:
        return Icons.smart_toy_rounded;
    }
  }

  /// Color for the subject
  Color get color {
    switch (this) {
      case ChatSubject.day:
        return LiquidGlassColors.sunsetOrange;
      case ChatSubject.expense:
        return LiquidGlassColors.mintEmerald;
      case ChatSubject.activity:
        return LiquidGlassColors.oceanSky;
      case ChatSubject.journal:
        return LiquidGlassColors.auroraViolet;
      case ChatSubject.general:
        return LiquidGlassColors.oceanTeal;
    }
  }

  /// Parse subject from string value
  static ChatSubject fromString(String? value) {
    if (value == null) return ChatSubject.general;
    try {
      return ChatSubject.values.firstWhere(
        (e) => e.name == value.toLowerCase(),
      );
    } catch (_) {
      return ChatSubject.general;
    }
  }
}

/// Represents a chat session
class ChatSession extends Equatable {
  final String id;
  final String userId;
  final String? tripId;
  final String title;
  final String aiProvider;
  final String aiModel;
  final Map<String, dynamic> context;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? tripFlagEmoji; // Optional: fetched from trip relation
  final String? tripDestination; // Optional: fetched from trip relation
  final ChatSubject subject; // Chat subject/type

  const ChatSession({
    required this.id,
    required this.userId,
    this.tripId,
    required this.title,
    required this.aiProvider,
    required this.aiModel,
    required this.context,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.tripFlagEmoji,
    this.tripDestination,
    this.subject = ChatSubject.general,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    // Handle trip relation data if joined
    String? flagEmoji;
    String? destination;
    if (json['trips'] != null && json['trips'] is Map) {
      final tripData = json['trips'] as Map<String, dynamic>;
      flagEmoji = tripData['flag_emoji'] as String?;
      destination = tripData['destination'] as String?;
    }

    return ChatSession(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tripId: json['trip_id'] as String?,
      title: json['title'] as String? ?? 'New Chat',
      aiProvider: json['ai_provider'] as String? ?? 'openai',
      aiModel: json['ai_model'] as String? ?? 'gpt-4',
      context: json['context'] as Map<String, dynamic>? ?? {},
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      tripFlagEmoji: flagEmoji,
      tripDestination: destination,
      subject: ChatSubject.fromString(json['subject'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'trip_id': tripId,
      'title': title,
      'ai_provider': aiProvider,
      'ai_model': aiModel,
      'context': context,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'subject': subject.name,
    };
  }

  ChatSession copyWith({
    String? id,
    String? userId,
    String? tripId,
    String? title,
    String? aiProvider,
    String? aiModel,
    Map<String, dynamic>? context,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? tripFlagEmoji,
    String? tripDestination,
    ChatSubject? subject,
  }) {
    return ChatSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      aiProvider: aiProvider ?? this.aiProvider,
      aiModel: aiModel ?? this.aiModel,
      context: context ?? this.context,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tripFlagEmoji: tripFlagEmoji ?? this.tripFlagEmoji,
      tripDestination: tripDestination ?? this.tripDestination,
      subject: subject ?? this.subject,
    );
  }

  @override
  List<Object?> get props => [id, userId, tripId, title, isActive, subject];
}

/// Represents a chat message
class ChatMessageModel extends Equatable {
  final String id;
  final String sessionId;
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final Map<String, dynamic> metadata;
  final int? tokensUsed;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.metadata,
    this.tokensUsed,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      tokensUsed: json['tokens_used'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'role': role,
      'content': content,
      'metadata': metadata,
      'tokens_used': tokensUsed,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get isSystem => role == 'system';

  @override
  List<Object?> get props => [id, sessionId, role, content, createdAt];
}

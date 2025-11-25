import 'package:equatable/equatable.dart';

/// Mood options for journal entries
enum JournalMood {
  excited,
  relaxed,
  tired,
  adventurous,
  inspired,
  grateful,
  reflective;

  String get displayName {
    switch (this) {
      case JournalMood.excited:
        return 'Excited';
      case JournalMood.relaxed:
        return 'Relaxed';
      case JournalMood.tired:
        return 'Tired';
      case JournalMood.adventurous:
        return 'Adventurous';
      case JournalMood.inspired:
        return 'Inspired';
      case JournalMood.grateful:
        return 'Grateful';
      case JournalMood.reflective:
        return 'Reflective';
    }
  }

  String get emoji {
    switch (this) {
      case JournalMood.excited:
        return '🎉';
      case JournalMood.relaxed:
        return '😌';
      case JournalMood.tired:
        return '😴';
      case JournalMood.adventurous:
        return '🏔️';
      case JournalMood.inspired:
        return '✨';
      case JournalMood.grateful:
        return '🙏';
      case JournalMood.reflective:
        return '🤔';
    }
  }

  static JournalMood? fromString(String? value) {
    if (value == null) return null;
    try {
      return JournalMood.values.firstWhere(
        (e) => e.name == value.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Represents a journal entry for a trip day
class JournalModel extends Equatable {
  final String id;
  final String tripId;
  final String userId;
  final DateTime entryDate;
  final String? title;
  final String content;
  final bool aiGenerated;
  final Map<String, dynamic> sourceData;
  final List<String> photos;
  final JournalMood? mood;
  final List<String> locations;
  final String? weather;
  final List<String> highlights;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalModel({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.entryDate,
    this.title,
    required this.content,
    this.aiGenerated = true,
    this.sourceData = const {},
    this.photos = const [],
    this.mood,
    this.locations = const [],
    this.weather,
    this.highlights = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      userId: json['user_id'] as String,
      entryDate: DateTime.parse(json['entry_date'] as String),
      title: json['title'] as String?,
      content: json['content'] as String,
      aiGenerated: json['ai_generated'] as bool? ?? true,
      sourceData: json['source_data'] as Map<String, dynamic>? ?? {},
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      mood: JournalMood.fromString(json['mood'] as String?),
      locations: (json['locations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      weather: json['weather'] as String?,
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'user_id': userId,
      'entry_date': entryDate.toIso8601String().split('T').first,
      'title': title,
      'content': content,
      'ai_generated': aiGenerated,
      'source_data': sourceData,
      'photos': photos,
      'mood': mood?.name,
      'locations': locations,
      'weather': weather,
      'highlights': highlights,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a new journal entry for insertion (without id, timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'trip_id': tripId,
      'user_id': userId,
      'entry_date': entryDate.toIso8601String().split('T').first,
      'title': title,
      'content': content,
      'ai_generated': aiGenerated,
      'source_data': sourceData,
      'photos': photos,
      'mood': mood?.name,
      'locations': locations,
      'weather': weather,
      'highlights': highlights,
    };
  }

  JournalModel copyWith({
    String? id,
    String? tripId,
    String? userId,
    DateTime? entryDate,
    String? title,
    String? content,
    bool? aiGenerated,
    Map<String, dynamic>? sourceData,
    List<String>? photos,
    JournalMood? mood,
    List<String>? locations,
    String? weather,
    List<String>? highlights,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      userId: userId ?? this.userId,
      entryDate: entryDate ?? this.entryDate,
      title: title ?? this.title,
      content: content ?? this.content,
      aiGenerated: aiGenerated ?? this.aiGenerated,
      sourceData: sourceData ?? this.sourceData,
      photos: photos ?? this.photos,
      mood: mood ?? this.mood,
      locations: locations ?? this.locations,
      weather: weather ?? this.weather,
      highlights: highlights ?? this.highlights,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get a formatted date string
  String get formattedDate {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return '${weekdays[entryDate.weekday - 1]}, ${months[entryDate.month - 1]} ${entryDate.day}';
  }

  /// Get day number in trip (requires trip start date)
  int getDayNumber(DateTime tripStartDate) {
    return entryDate.difference(tripStartDate).inDays + 1;
  }

  @override
  List<Object?> get props => [id, tripId, entryDate, content];
}

/// Data class for AI-generated journal content
class GeneratedJournalContent {
  final String title;
  final String content;
  final JournalMood? mood;
  final List<String> highlights;
  final List<String> locations;

  const GeneratedJournalContent({
    required this.title,
    required this.content,
    this.mood,
    this.highlights = const [],
    this.locations = const [],
  });

  factory GeneratedJournalContent.fromJson(Map<String, dynamic> json) {
    return GeneratedJournalContent(
      title: json['title'] as String? ?? 'Day\'s Adventures',
      content: json['content'] as String,
      mood: JournalMood.fromString(json['mood'] as String?),
      highlights: (json['highlights'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      locations: (json['locations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

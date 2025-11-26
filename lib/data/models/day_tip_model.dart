/// Model for daily travel tips from AI destination expert
class DayTip {
  final String id;
  final String category;
  final String title;
  final String content;
  final String destination;
  final DateTime generatedAt;
  final DateTime expiresAt;

  const DayTip({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
    required this.destination,
    required this.generatedAt,
    required this.expiresAt,
  });

  /// Categories for tips - expanded for variety
  static const List<String> categories = [
    'money',
    'medical',
    'connectivity',
    'customs',
    'safety',
    'transport',
    'food',
    'scams',
    'language',
    'weather',
    'shopping',
    'nightlife',
    'emergency',
    'water',
    'photography',
    'bargaining',
  ];

  /// Get icon for category
  static String getCategoryIcon(String category) {
    switch (category) {
      case 'money':
        return 'atm';
      case 'medical':
        return 'medical_services';
      case 'connectivity':
        return 'sim_card';
      case 'customs':
        return 'handshake';
      case 'safety':
        return 'security';
      case 'transport':
        return 'directions_transit';
      case 'food':
        return 'restaurant';
      case 'general':
      default:
        return 'lightbulb';
    }
  }

  /// Get category display name
  static String getCategoryDisplayName(String category) {
    switch (category) {
      case 'money':
        return 'Money & ATMs';
      case 'medical':
        return 'Medical';
      case 'connectivity':
        return 'SIM & Internet';
      case 'customs':
        return 'Local Customs';
      case 'safety':
        return 'Safety';
      case 'transport':
        return 'Transport';
      case 'food':
        return 'Food Tips';
      case 'scams':
        return 'Scam Alert';
      case 'language':
        return 'Language Tips';
      case 'weather':
        return 'Weather & Clothing';
      case 'shopping':
        return 'Shopping';
      case 'nightlife':
        return 'Nightlife';
      case 'emergency':
        return 'Emergency Info';
      case 'water':
        return 'Water & Hygiene';
      case 'photography':
        return 'Photo Tips';
      case 'bargaining':
        return 'Bargaining';
      case 'general':
      default:
        return 'Daily Tip';
    }
  }

  /// Check if tip is still valid
  bool get isValid => DateTime.now().isBefore(expiresAt);

  /// Create from JSON
  factory DayTip.fromJson(Map<String, dynamic> json) {
    return DayTip(
      id: json['id'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      destination: json['destination'] as String,
      generatedAt: DateTime.parse(json['generated_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'title': title,
        'content': content,
        'destination': destination,
        'generated_at': generatedAt.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
      };

  /// Create a new tip from AI response
  factory DayTip.create({
    required String category,
    required String title,
    required String content,
    required String destination,
  }) {
    final now = DateTime.now();
    return DayTip(
      id: '${destination}_${category}_${now.millisecondsSinceEpoch}',
      category: category,
      title: title,
      content: content,
      destination: destination,
      generatedAt: now,
      // Tips expire at midnight
      expiresAt: DateTime(now.year, now.month, now.day + 1),
    );
  }
}

/// Generated tip content from AI
class GeneratedTipContent {
  final String title;
  final String content;
  final String category;

  const GeneratedTipContent({
    required this.title,
    required this.content,
    required this.category,
  });

  factory GeneratedTipContent.fromJson(Map<String, dynamic> json) {
    return GeneratedTipContent(
      title: json['title'] as String? ?? 'Travel Tip',
      content: json['content'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
    );
  }
}

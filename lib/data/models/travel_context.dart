/// Travel context for AI personalization
/// This provides rich context to the AI for personalized recommendations
class TravelContext {
  final String? destination;
  final double? destinationLat;
  final double? destinationLng;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? budget;
  final String budgetCurrency;
  final List<String> spokenLanguages;
  final String homeCurrency;
  final int? currentDayOfTrip;
  final int? totalTripDays;
  final int? remainingDays;
  final String? tripStatus; // planning, active, completed

  const TravelContext({
    this.destination,
    this.destinationLat,
    this.destinationLng,
    this.startDate,
    this.endDate,
    this.budget,
    this.budgetCurrency = 'USD',
    this.spokenLanguages = const ['English'],
    this.homeCurrency = 'USD',
    this.currentDayOfTrip,
    this.totalTripDays,
    this.remainingDays,
    this.tripStatus,
  });

  /// Check if user is currently on the trip
  bool get isOnTrip {
    if (startDate == null || endDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
    final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
    return !today.isBefore(start) && !today.isAfter(end);
  }

  /// Check if trip is upcoming
  bool get isUpcoming {
    if (startDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
    return today.isBefore(start);
  }

  /// Get formatted date range
  String get dateRangeFormatted {
    if (startDate == null || endDate == null) return 'Dates not set';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[startDate!.month - 1]} ${startDate!.day} - ${months[endDate!.month - 1]} ${endDate!.day}, ${endDate!.year}';
  }

  /// Get languages as comma-separated string
  String get languagesFormatted {
    if (spokenLanguages.isEmpty) return 'English';
    return spokenLanguages.join(', ');
  }

  /// Get budget formatted
  String get budgetFormatted {
    if (budget == null) return 'Not set';
    return '${budget!.toStringAsFixed(0)} $budgetCurrency';
  }

  /// Generate context string for AI system prompt
  String toContextString() {
    final buffer = StringBuffer();

    if (destination != null) {
      buffer.writeln('Current destination: $destination');
    }

    if (startDate != null && endDate != null) {
      buffer.writeln('Trip dates: $dateRangeFormatted');
      if (totalTripDays != null) {
        buffer.writeln('Trip duration: $totalTripDays days');
      }
      if (isOnTrip && currentDayOfTrip != null) {
        buffer.writeln('Currently on Day $currentDayOfTrip of the trip');
        if (remainingDays != null && remainingDays! > 0) {
          buffer.writeln('$remainingDays days remaining');
        }
      } else if (isUpcoming) {
        final daysUntil = startDate!.difference(DateTime.now()).inDays;
        buffer.writeln('Trip starts in $daysUntil days');
      }
    }

    if (budget != null) {
      buffer.writeln('Budget: $budgetFormatted');
    }

    buffer.writeln('User speaks: $languagesFormatted');
    buffer.writeln('Home currency: $homeCurrency');

    return buffer.toString();
  }

  /// Create from trip model and user settings
  factory TravelContext.fromTripAndSettings({
    required String? destination,
    double? destinationLat,
    double? destinationLng,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    String budgetCurrency = 'USD',
    List<String>? spokenLanguages,
    String homeCurrency = 'USD',
  }) {
    int? currentDay;
    int? totalDays;
    int? remaining;

    if (startDate != null && endDate != null) {
      totalDays = endDate.difference(startDate).inDays + 1;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day);

      if (!today.isBefore(start) && !today.isAfter(end)) {
        currentDay = today.difference(start).inDays + 1;
        remaining = end.difference(today).inDays;
      }
    }

    return TravelContext(
      destination: destination,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      startDate: startDate,
      endDate: endDate,
      budget: budget,
      budgetCurrency: budgetCurrency,
      spokenLanguages: spokenLanguages ?? ['English'],
      homeCurrency: homeCurrency,
      currentDayOfTrip: currentDay,
      totalTripDays: totalDays,
      remainingDays: remaining,
    );
  }
}

/// Represents a place recommendation from AI
class PlaceRecommendation {
  final String name;
  final String? description;
  final String? category; // restaurant, attraction, activity, cafe, bar, etc.
  final String? address;
  final double? lat;
  final double? lng;
  final String? priceLevel; // $, $$, $$$, $$$$
  final String? estimatedDuration; // "1-2 hours", "30 mins", etc.
  final String? bestTimeToVisit; // "morning", "evening", "any"
  final List<String> tags; // "romantic", "family-friendly", "local favorite", etc.
  final String? googleMapsUrl;
  final String? googleMapsSearchUrl;

  const PlaceRecommendation({
    required this.name,
    this.description,
    this.category,
    this.address,
    this.lat,
    this.lng,
    this.priceLevel,
    this.estimatedDuration,
    this.bestTimeToVisit,
    this.tags = const [],
    this.googleMapsUrl,
    this.googleMapsSearchUrl,
  });

  /// Generate Google Maps URL for the place
  String get mapsUrl {
    if (googleMapsUrl != null) return googleMapsUrl!;

    // If we have coordinates, use them
    if (lat != null && lng != null) {
      return 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    }

    // Otherwise, search by name and address
    final query = address != null
        ? Uri.encodeComponent('$name, $address')
        : Uri.encodeComponent(name);
    return 'https://www.google.com/maps/search/?api=1&query=$query';
  }

  /// Generate Google Maps directions URL
  String directionsUrl({double? fromLat, double? fromLng}) {
    final destination = lat != null && lng != null
        ? '$lat,$lng'
        : Uri.encodeComponent(address ?? name);

    if (fromLat != null && fromLng != null) {
      return 'https://www.google.com/maps/dir/?api=1&origin=$fromLat,$fromLng&destination=$destination';
    }
    return 'https://www.google.com/maps/dir/?api=1&destination=$destination';
  }

  factory PlaceRecommendation.fromJson(Map<String, dynamic> json) {
    return PlaceRecommendation(
      name: json['name'] as String? ?? 'Unknown Place',
      description: json['description'] as String?,
      category: json['category'] as String?,
      address: json['address'] as String?,
      lat: json['lat'] != null ? (json['lat'] as num).toDouble() : null,
      lng: json['lng'] != null ? (json['lng'] as num).toDouble() : null,
      priceLevel: json['price_level'] as String?,
      estimatedDuration: json['estimated_duration'] as String?,
      bestTimeToVisit: json['best_time_to_visit'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'category': category,
    'address': address,
    'lat': lat,
    'lng': lng,
    'price_level': priceLevel,
    'estimated_duration': estimatedDuration,
    'best_time_to_visit': bestTimeToVisit,
    'tags': tags,
  };
}

/// Response containing recommendations with interactive elements
class RecommendationResponse {
  final String message;
  final List<PlaceRecommendation> places;
  final String? localTip;
  final ParsedExpenseData? expense;

  const RecommendationResponse({
    required this.message,
    this.places = const [],
    this.localTip,
    this.expense,
  });
}

/// Parsed expense data (duplicated here for isolation, used in AIResponse too)
class ParsedExpenseData {
  final double amount;
  final String currency;
  final String category;
  final String description;
  final DateTime date;

  const ParsedExpenseData({
    required this.amount,
    required this.currency,
    required this.category,
    required this.description,
    required this.date,
  });

  factory ParsedExpenseData.fromJson(Map<String, dynamic> json) {
    return ParsedExpenseData(
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      category: json['category'] as String? ?? 'other',
      description: json['description'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

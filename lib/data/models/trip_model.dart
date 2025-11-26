import 'package:equatable/equatable.dart';

import '../../utils/country_currency_helper.dart';

/// Represents a trip
class TripModel extends Equatable {
  final String id;
  final String ownerId;
  final String title;
  final String destination; // Original destination (might be city or country)
  final String? destinationPlaceId;
  final double? destinationLat;
  final double? destinationLng;
  final String? coverImageUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? budget;
  final String budgetCurrency;
  final String? description;
  final String status; // planning, active, completed, canceled
  final DateTime createdAt;
  final DateTime updatedAt;

  const TripModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.destination,
    this.destinationPlaceId,
    this.destinationLat,
    this.destinationLng,
    this.coverImageUrl,
    this.startDate,
    this.endDate,
    this.budget,
    this.budgetCurrency = 'USD',
    this.description,
    this.status = 'planning',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get the country name from the destination
  /// This converts cities like "Bangkok" to "Thailand"
  String get country => CountryCurrencyHelper.extractCountryFromDestination(destination);

  /// Get the display name (always shows country)
  String get displayDestination => country;

  /// Get display title - replaces city names in title with country names
  /// e.g., "Trip to Bangkok" -> "Trip to Thailand"
  String get displayTitle {
    // Check if title contains a city name and replace with country
    String result = title;
    for (final entry in CountryCurrencyHelper.cityToCountry.entries) {
      if (title.contains(entry.key)) {
        result = title.replaceAll(entry.key, entry.value);
        break;
      }
    }
    return result;
  }

  /// Get the currency symbol for this trip's budget currency
  String get currencySymbol => CountryCurrencyHelper.getSymbolForCurrency(budgetCurrency);

  /// Get the flag emoji for this trip's destination country
  String get flagEmoji => CountryCurrencyHelper.getFlagForDestination(destination);

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String,
      destination: json['destination'] as String,
      destinationPlaceId: json['destination_place_id'] as String?,
      destinationLat: json['destination_lat'] != null
          ? double.tryParse(json['destination_lat'].toString())
          : null,
      destinationLng: json['destination_lng'] != null
          ? double.tryParse(json['destination_lng'].toString())
          : null,
      coverImageUrl: json['cover_image_url'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      budget: json['budget'] != null
          ? double.tryParse(json['budget'].toString())
          : null,
      budgetCurrency: json['budget_currency'] as String? ?? 'USD',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'planning',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'destination': destination,
      'destination_place_id': destinationPlaceId,
      'destination_lat': destinationLat,
      'destination_lng': destinationLng,
      'cover_image_url': coverImageUrl,
      'start_date': startDate?.toIso8601String().split('T').first,
      'end_date': endDate?.toIso8601String().split('T').first,
      'budget': budget,
      'budget_currency': budgetCurrency,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TripModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? destination,
    String? destinationPlaceId,
    double? destinationLat,
    double? destinationLng,
    String? coverImageUrl,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    String? budgetCurrency,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      destinationPlaceId: destinationPlaceId ?? this.destinationPlaceId,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      budgetCurrency: budgetCurrency ?? this.budgetCurrency,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if trip is currently active (within date range)
  bool get isActive {
    if (startDate == null || endDate == null) return false;
    final now = DateTime.now();
    return now.isAfter(startDate!) && now.isBefore(endDate!.add(const Duration(days: 1)));
  }

  /// Check if trip is upcoming
  bool get isUpcoming {
    if (startDate == null) return false;
    return DateTime.now().isBefore(startDate!);
  }

  /// Check if trip is completed
  bool get isCompleted {
    if (endDate == null) return status == 'completed';
    return DateTime.now().isAfter(endDate!.add(const Duration(days: 1))) || status == 'completed';
  }

  /// Get number of days for the trip
  int? get durationDays {
    if (startDate == null || endDate == null) return null;
    return endDate!.difference(startDate!).inDays + 1;
  }

  /// Get days until trip starts
  int? get daysUntilStart {
    if (startDate == null) return null;
    final diff = startDate!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : null;
  }

  @override
  List<Object?> get props => [id, ownerId, title, destination, status];
}

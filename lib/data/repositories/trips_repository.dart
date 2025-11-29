import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/trip_model.dart';

class TripsRepositoryException implements Exception {
  final String message;

  TripsRepositoryException(this.message);

  @override
  String toString() => message;
}

class TripsRepository {
  final SupabaseClient _supabase;

  TripsRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // ============================================
  // READ OPERATIONS
  // ============================================

  /// Get all trips for the current user (owned + shared)
  Future<List<TripModel>> getUserTrips() async {
    if (_currentUserId == null) {
      throw TripsRepositoryException('User not authenticated');
    }

    try {
      // Use the database function to get both owned and shared trips
      final response = await _supabase.rpc(
        'get_user_all_trips',
        params: {'p_user_id': _currentUserId},
      );

      if (response == null) return [];

      final List<dynamic> jsonList = response as List<dynamic>;
      return jsonList
          .map((json) => TripModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching trips: $e');
      // Fallback to owner-only trips if RPC fails
      try {
        final response = await _supabase
            .from('trips')
            .select()
            .eq('owner_id', _currentUserId!)
            .order('start_date', ascending: true);

        return (response as List)
            .map((json) => TripModel.fromJson(json, isOwner: true))
            .toList();
      } catch (e2) {
        debugPrint('Fallback also failed: $e2');
        throw TripsRepositoryException('Failed to fetch trips');
      }
    }
  }

  /// Get active or planning trip (most recent)
  Future<TripModel?> getActiveTrip() async {
    if (_currentUserId == null) {
      throw TripsRepositoryException('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('trips')
          .select()
          .eq('owner_id', _currentUserId!)
          .inFilter('status', ['planning', 'active'])
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return TripModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching active trip: $e');
      throw TripsRepositoryException('Failed to fetch active trip');
    }
  }

  /// Get a specific trip by ID
  Future<TripModel?> getTrip(String tripId) async {
    try {
      final response = await _supabase
          .from('trips')
          .select()
          .eq('id', tripId)
          .maybeSingle();

      if (response == null) return null;
      return TripModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching trip: $e');
      throw TripsRepositoryException('Failed to fetch trip');
    }
  }

  /// Get trips by status
  Future<List<TripModel>> getTripsByStatus(String status) async {
    if (_currentUserId == null) {
      throw TripsRepositoryException('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('trips')
          .select()
          .eq('owner_id', _currentUserId!)
          .eq('status', status)
          .order('start_date', ascending: true);

      return (response as List)
          .map((json) => TripModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching trips by status: $e');
      throw TripsRepositoryException('Failed to fetch trips');
    }
  }

  // ============================================
  // WRITE OPERATIONS
  // ============================================

  /// Create a new trip
  Future<TripModel> createTrip({
    required String title,
    required String destination,
    String? destinationPlaceId,
    double? destinationLat,
    double? destinationLng,
    String? coverImageUrl,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    String budgetCurrency = 'USD',
    String? description,
    String status = 'planning',
  }) async {
    if (_currentUserId == null) {
      throw TripsRepositoryException('User not authenticated');
    }

    try {
      final response = await _supabase.from('trips').insert({
        'owner_id': _currentUserId,
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
      }).select().single();

      return TripModel.fromJson(response);
    } catch (e) {
      debugPrint('Error creating trip: $e');
      throw TripsRepositoryException('Failed to create trip');
    }
  }

  /// Update an existing trip
  Future<TripModel> updateTrip(String tripId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('trips')
          .update(updates)
          .eq('id', tripId)
          .select()
          .single();

      return TripModel.fromJson(response);
    } catch (e) {
      debugPrint('Error updating trip: $e');
      throw TripsRepositoryException('Failed to update trip');
    }
  }

  /// Update trip status
  Future<void> updateTripStatus(String tripId, String status) async {
    try {
      await _supabase
          .from('trips')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', tripId);
    } catch (e) {
      debugPrint('Error updating trip status: $e');
      throw TripsRepositoryException('Failed to update trip status');
    }
  }

  /// Delete a trip
  Future<void> deleteTrip(String tripId) async {
    try {
      await _supabase.from('trips').delete().eq('id', tripId);
    } catch (e) {
      debugPrint('Error deleting trip: $e');
      throw TripsRepositoryException('Failed to delete trip');
    }
  }
}

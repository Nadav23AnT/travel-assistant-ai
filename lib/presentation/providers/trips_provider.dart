import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/trip_model.dart';
import '../../data/repositories/trips_repository.dart';

// ============================================
// REPOSITORY PROVIDER
// ============================================

/// Trips Repository provider
final tripsRepositoryProvider = Provider<TripsRepository>((ref) {
  return TripsRepository();
});

// ============================================
// DATA PROVIDERS
// ============================================

/// Provider to fetch all user trips
final userTripsProvider = FutureProvider<List<TripModel>>((ref) async {
  final repository = ref.watch(tripsRepositoryProvider);
  return repository.getUserTrips();
});

/// Provider to fetch the active/planning trip
final activeTripProvider = FutureProvider<TripModel?>((ref) async {
  final repository = ref.watch(tripsRepositoryProvider);
  return repository.getActiveTrip();
});

/// Provider to refresh trips
final tripsRefreshProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(userTripsProvider);
    ref.invalidate(activeTripProvider);
  };
});

// ============================================
// TRIPS BY STATUS PROVIDERS
// ============================================

/// Provider for planning trips
final planningTripsProvider = FutureProvider<List<TripModel>>((ref) async {
  final repository = ref.watch(tripsRepositoryProvider);
  return repository.getTripsByStatus('planning');
});

/// Provider for completed trips
final completedTripsProvider = FutureProvider<List<TripModel>>((ref) async {
  final repository = ref.watch(tripsRepositoryProvider);
  return repository.getTripsByStatus('completed');
});

// ============================================
// SINGLE TRIP PROVIDER
// ============================================

/// Provider to fetch a specific trip by ID
final tripByIdProvider = FutureProvider.family<TripModel?, String>((ref, tripId) async {
  final repository = ref.watch(tripsRepositoryProvider);
  return repository.getTrip(tripId);
});

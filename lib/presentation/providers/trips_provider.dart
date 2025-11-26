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

// ============================================
// TRIP OPERATION STATE NOTIFIER
// ============================================

/// State for trip operations
class TripOperationState {
  final bool isLoading;
  final String? error;
  final TripModel? lastCreatedTrip;

  const TripOperationState({
    this.isLoading = false,
    this.error,
    this.lastCreatedTrip,
  });

  TripOperationState copyWith({
    bool? isLoading,
    String? error,
    TripModel? lastCreatedTrip,
    bool clearError = false,
  }) {
    return TripOperationState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastCreatedTrip: lastCreatedTrip ?? this.lastCreatedTrip,
    );
  }
}

/// Notifier for trip operations (create, update, delete)
class TripOperationNotifier extends StateNotifier<TripOperationState> {
  final TripsRepository _repository;
  final Ref _ref;

  TripOperationNotifier(this._repository, this._ref)
      : super(const TripOperationState());

  /// Create a new trip
  Future<TripModel?> createTrip({
    required String title,
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
    double? budgetAmount,
    String budgetCurrency = 'USD',
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final trip = await _repository.createTrip(
        title: title,
        destination: destination,
        startDate: startDate,
        endDate: endDate,
        budget: budgetAmount,
        budgetCurrency: budgetCurrency,
        description: description,
      );

      state = state.copyWith(
        isLoading: false,
        lastCreatedTrip: trip,
      );

      // Refresh providers
      _ref.read(tripsRefreshProvider)();

      return trip;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Update a trip
  Future<TripModel?> updateTrip(String tripId, Map<String, dynamic> updates) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final trip = await _repository.updateTrip(tripId, updates);
      state = state.copyWith(isLoading: false);

      // Refresh providers
      _ref.read(tripsRefreshProvider)();
      _ref.invalidate(tripByIdProvider(tripId));

      return trip;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Delete a trip
  Future<bool> deleteTrip(String tripId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.deleteTrip(tripId);
      state = state.copyWith(isLoading: false);

      // Refresh providers
      _ref.read(tripsRefreshProvider)();

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for trip operations
final tripOperationProvider =
    StateNotifierProvider<TripOperationNotifier, TripOperationState>((ref) {
  final repository = ref.watch(tripsRepositoryProvider);
  return TripOperationNotifier(repository, ref);
});

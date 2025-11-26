import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/travel_context.dart';
import 'currency_provider.dart';
import 'trips_provider.dart';

/// Provider for the current travel context
/// This combines trip data and user settings for AI personalization
final travelContextProvider = FutureProvider<TravelContext?>((ref) async {
  final activeTrip = await ref.watch(activeTripProvider.future);
  final homeCurrency = ref.watch(userHomeCurrencyProvider);

  // Get user languages from settings
  final languages = await _getUserLanguages();

  if (activeTrip == null) {
    // No active trip, return minimal context
    return TravelContext(
      spokenLanguages: languages,
      homeCurrency: homeCurrency,
    );
  }

  return TravelContext.fromTripAndSettings(
    destination: activeTrip.destination,
    destinationLat: activeTrip.destinationLat,
    destinationLng: activeTrip.destinationLng,
    startDate: activeTrip.startDate,
    endDate: activeTrip.endDate,
    budget: activeTrip.budget,
    budgetCurrency: activeTrip.budgetCurrency,
    spokenLanguages: languages,
    homeCurrency: homeCurrency,
  );
});

/// Get user's preferred languages from settings
Future<List<String>> _getUserLanguages() async {
  try {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return ['English'];

    final response = await supabase
        .from('user_settings')
        .select('preferred_languages')
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null || response['preferred_languages'] == null) {
      return ['English'];
    }

    final languages = response['preferred_languages'];
    if (languages is List) {
      return List<String>.from(languages);
    }

    return ['English'];
  } catch (e) {
    return ['English'];
  }
}

/// Provider for synchronous access to travel context (uses cached value)
final currentTravelContextProvider = Provider<TravelContext?>((ref) {
  final asyncContext = ref.watch(travelContextProvider);
  return asyncContext.valueOrNull;
});

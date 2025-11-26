import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../data/models/day_tip_model.dart';
import '../../data/models/trip_model.dart';
import '../../services/ai_service.dart';
import 'chat_provider.dart';
import 'trips_provider.dart';

/// Provider for the current day's tip
final dayTipProvider = StateNotifierProvider<DayTipNotifier, AsyncValue<DayTip?>>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  final activeTrip = ref.watch(activeTripProvider);
  return DayTipNotifier(ref, aiService, activeTrip);
});

/// State notifier for Day Tip
class DayTipNotifier extends StateNotifier<AsyncValue<DayTip?>> {
  final Ref _ref;
  final AIService _aiService;
  final AsyncValue<TripModel?> _activeTrip;

  static const String _cacheKey = 'cached_day_tip';

  DayTipNotifier(this._ref, this._aiService, this._activeTrip) : super(const AsyncValue.loading()) {
    _loadTip();
  }

  /// Load tip from cache or generate new one
  Future<void> _loadTip() async {
    final trip = _activeTrip.valueOrNull;
    if (trip == null) {
      state = const AsyncValue.data(null);
      return;
    }

    try {
      // Try to load from cache first
      final cachedTip = await _getCachedTip(trip.destination);
      if (cachedTip != null && cachedTip.isValid) {
        state = AsyncValue.data(cachedTip);
        return;
      }

      // Generate new tip
      await generateNewTip();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Generate a new day tip
  Future<void> generateNewTip({String? specificCategory}) async {
    final trip = _activeTrip.valueOrNull;
    if (trip == null) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();

    try {
      // Pick a category - rotate through categories or use specific
      final category = specificCategory ?? _selectCategory();

      final tipContent = await _aiService.generateDayTip(
        destination: trip.destination,
        category: category,
      );

      final tip = DayTip.create(
        category: tipContent.category,
        title: tipContent.title,
        content: tipContent.content,
        destination: trip.destination,
      );

      // Cache the tip
      await _cacheTip(tip);

      state = AsyncValue.data(tip);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Select a random category for the tip
  /// Uses a combination of day seed + random for variety but consistency within a day
  String _selectCategory() {
    // Use day as seed for some consistency, but add randomness
    final now = DateTime.now();
    final daySeed = now.year * 1000 + now.month * 100 + now.day;
    final random = Random(daySeed);
    final categoryIndex = random.nextInt(DayTip.categories.length);
    return DayTip.categories[categoryIndex];
  }

  /// Get cached tip
  Future<DayTip?> _getCachedTip(String destination) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached == null) return null;

      final tip = DayTip.fromJson(jsonDecode(cached) as Map<String, dynamic>);

      // Check if tip is for same destination and still valid
      if (tip.destination == destination && tip.isValid) {
        return tip;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cache a tip
  Future<void> _cacheTip(DayTip tip) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(tip.toJson()));
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Refresh the tip (force regenerate)
  Future<void> refresh({String? category}) async {
    await generateNewTip(specificCategory: category);
  }
}

/// Provider to check if we have an active trip for showing day tips
final hasDayTipProvider = Provider<bool>((ref) {
  final activeTrip = ref.watch(activeTripProvider);
  return activeTrip.valueOrNull != null;
});

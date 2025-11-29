import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../data/models/day_tip_model.dart';
import '../../data/models/trip_model.dart';
import '../../services/ai_service.dart';
import 'chat_provider.dart';
import 'trips_provider.dart';
import 'locale_provider.dart';

/// Provider for the current day's tips (list of 3)
final dayTipProvider = StateNotifierProvider<DayTipNotifier, AsyncValue<List<DayTip>>>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  final activeTrip = ref.watch(activeTripProvider);
  return DayTipNotifier(ref, aiService, activeTrip);
});

/// State notifier for Day Tips
class DayTipNotifier extends StateNotifier<AsyncValue<List<DayTip>>> {
  final Ref _ref;
  final AIService _aiService;
  final AsyncValue<TripModel?> _activeTrip;

  static const String _cacheKeyPrefix = 'cached_day_tips_v3'; // v3: includes language

  DayTipNotifier(this._ref, this._aiService, this._activeTrip) : super(const AsyncValue.loading()) {
    _loadTips();
  }

  /// Get cache key including language
  String _getCacheKey() {
    final locale = _ref.read(localeProvider);
    return '${_cacheKeyPrefix}_${locale.languageCode}';
  }

  /// Load tips from cache or generate new ones
  Future<void> _loadTips() async {
    final trip = _activeTrip.valueOrNull;
    if (trip == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      // Try to load from cache first (language-specific)
      final cachedTips = await _getCachedTips(trip.destination);
      if (cachedTips != null && cachedTips.isNotEmpty && cachedTips.first.isValid) {
        state = AsyncValue.data(cachedTips);
        return;
      }

      // Generate new tips
      await generateNewTips();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Generate new day tips
  Future<void> generateNewTips() async {
    final trip = _activeTrip.valueOrNull;
    if (trip == null) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    try {
      // Pick 3 random categories
      final categories = _selectRandomCategories(3);
      
      // Get current language
      final locale = _ref.read(localeProvider);
      final languageName = AppLocales.getDisplayName(locale.languageCode);

      final tipsContent = await _aiService.generateDayTips(
        destination: trip.destination,
        categories: categories,
        language: languageName,
      );

      final tips = tipsContent.map((content) => DayTip.create(
        category: content.category,
        title: content.title,
        content: content.content,
        destination: trip.destination,
      )).toList();

      // Cache the tips
      await _cacheTips(tips);

      state = AsyncValue.data(tips);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Select random categories for the tips
  List<String> _selectRandomCategories(int count) {
    // Use day as seed for some consistency, but add randomness
    final now = DateTime.now();
    final daySeed = now.year * 1000 + now.month * 100 + now.day;
    final random = Random(daySeed);
    
    final allCategories = List<String>.from(DayTip.categories);
    allCategories.shuffle(random);
    
    return allCategories.take(count).toList();
  }

  /// Get cached tips (language-specific)
  Future<List<DayTip>?> _getCachedTips(String destination) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey();
      final cached = prefs.getString(cacheKey);
      if (cached == null) return null;

      final List<dynamic> jsonList = jsonDecode(cached);
      final tips = jsonList.map((json) => DayTip.fromJson(json)).toList();

      if (tips.isEmpty) return null;

      // Check if tips are for same destination and still valid
      if (tips.first.destination == destination && tips.first.isValid) {
        return tips;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cache tips (language-specific)
  Future<void> _cacheTips(List<DayTip> tips) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey();
      final jsonList = tips.map((t) => t.toJson()).toList();
      await prefs.setString(cacheKey, jsonEncode(jsonList));
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Refresh the tips (force regenerate)
  Future<void> refresh() async {
    await generateNewTips();
  }
}

/// Provider to check if we have an active trip for showing day tips
final hasDayTipProvider = Provider<bool>((ref) {
  final activeTrip = ref.watch(activeTripProvider);
  return activeTrip.valueOrNull != null;
});

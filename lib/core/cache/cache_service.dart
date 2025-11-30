import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Entry in the cache with expiration
class CacheEntry<T> {
  final T data;
  final DateTime createdAt;
  final Duration ttl;

  CacheEntry({
    required this.data,
    required this.ttl,
  }) : createdAt = DateTime.now();

  bool get isExpired => DateTime.now().difference(createdAt) > ttl;

  /// Time remaining before expiration
  Duration get timeRemaining {
    final elapsed = DateTime.now().difference(createdAt);
    final remaining = ttl - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

/// In-memory cache service for API responses
class CacheService {
  final Map<String, CacheEntry<dynamic>> _cache = {};
  final Map<String, Completer<dynamic>> _pendingRequests = {};

  /// Default TTL for cached data
  static const defaultTtl = Duration(minutes: 5);

  /// Short TTL for frequently changing data
  static const shortTtl = Duration(minutes: 1);

  /// Long TTL for static data
  static const longTtl = Duration(minutes: 30);

  /// Get data from cache or fetch it
  Future<T> getOrFetch<T>({
    required String key,
    required Future<T> Function() fetch,
    Duration ttl = defaultTtl,
    bool forceRefresh = false,
  }) async {
    // Check if we have valid cached data
    if (!forceRefresh) {
      final cached = get<T>(key);
      if (cached != null) {
        debugPrint('Cache HIT: $key');
        return cached;
      }
    }

    // Check if there's already a pending request for this key
    if (_pendingRequests.containsKey(key)) {
      debugPrint('Cache PENDING: $key');
      return await _pendingRequests[key]!.future as T;
    }

    // Create a completer for this request
    final completer = Completer<T>();
    _pendingRequests[key] = completer;

    try {
      debugPrint('Cache MISS: $key');
      final data = await fetch();
      set(key, data, ttl: ttl);
      completer.complete(data);
      return data;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _pendingRequests.remove(key);
    }
  }

  /// Get data from cache
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.data as T;
  }

  /// Set data in cache
  void set<T>(String key, T data, {Duration ttl = defaultTtl}) {
    _cache[key] = CacheEntry<T>(data: data, ttl: ttl);
  }

  /// Remove item from cache
  void remove(String key) {
    _cache.remove(key);
  }

  /// Remove items matching a prefix
  void removeByPrefix(String prefix) {
    _cache.removeWhere((key, _) => key.startsWith(prefix));
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
    debugPrint('Cache cleared');
  }

  /// Clear expired entries
  void clearExpired() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }

  /// Check if cache contains a key
  bool contains(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  /// Invalidate cache for specific entities
  void invalidateTrips() => removeByPrefix('trips:');
  void invalidateExpenses(String tripId) => removeByPrefix('expenses:$tripId');
  void invalidateJournals(String tripId) => removeByPrefix('journals:$tripId');
  void invalidateChats(String tripId) => removeByPrefix('chats:$tripId');
  void invalidateUser() => removeByPrefix('user:');
}

/// Cache keys for different data types
class CacheKeys {
  // Trips
  static String trips(String userId) => 'trips:$userId';
  static String trip(String tripId) => 'trips:detail:$tripId';
  static String tripMembers(String tripId) => 'trips:members:$tripId';

  // Expenses
  static String expenses(String tripId) => 'expenses:$tripId';
  static String expenseStats(String tripId) => 'expenses:stats:$tripId';

  // Journals
  static String journals(String tripId) => 'journals:$tripId';
  static String journal(String journalId) => 'journals:detail:$journalId';

  // Chats
  static String chats(String tripId) => 'chats:$tripId';
  static String chatMessages(String chatId) => 'chats:messages:$chatId';

  // User
  static String userProfile(String userId) => 'user:profile:$userId';
  static String userSettings(String userId) => 'user:settings:$userId';
  static String tokenUsage(String userId) => 'user:tokens:$userId';

  // Misc
  static String countries() => 'static:countries';
  static String currencies() => 'static:currencies';
}

/// Provider for cache service
final cacheServiceProvider = Provider<CacheService>((ref) {
  final service = CacheService();

  // Periodically clear expired entries
  Timer.periodic(const Duration(minutes: 5), (_) {
    service.clearExpired();
  });

  return service;
});

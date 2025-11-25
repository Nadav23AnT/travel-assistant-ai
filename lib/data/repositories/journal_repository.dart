import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/journal_model.dart';

class JournalRepositoryException implements Exception {
  final String message;

  JournalRepositoryException(this.message);

  @override
  String toString() => message;
}

class JournalRepository {
  final SupabaseClient _supabase;

  JournalRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // ============================================
  // READ OPERATIONS
  // ============================================

  /// Get all journal entries for a specific trip
  Future<List<JournalModel>> getTripJournalEntries(String tripId) async {
    try {
      final response = await _supabase
          .from('journal_entries')
          .select()
          .eq('trip_id', tripId)
          .order('entry_date', ascending: true);

      return (response as List)
          .map((json) => JournalModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching trip journal entries: $e');
      throw JournalRepositoryException('Failed to fetch journal entries');
    }
  }

  /// Get all journal entries for the current user
  Future<List<JournalModel>> getUserJournalEntries() async {
    if (_currentUserId == null) {
      throw JournalRepositoryException('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('journal_entries')
          .select()
          .eq('user_id', _currentUserId!)
          .order('entry_date', ascending: false);

      return (response as List)
          .map((json) => JournalModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching user journal entries: $e');
      throw JournalRepositoryException('Failed to fetch journal entries');
    }
  }

  /// Get a specific journal entry by ID
  Future<JournalModel?> getJournalEntry(String entryId) async {
    try {
      final response = await _supabase
          .from('journal_entries')
          .select()
          .eq('id', entryId)
          .maybeSingle();

      if (response == null) return null;
      return JournalModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching journal entry: $e');
      throw JournalRepositoryException('Failed to fetch journal entry');
    }
  }

  /// Get journal entry for a specific date
  Future<JournalModel?> getJournalEntryByDate(
    String tripId,
    DateTime date,
  ) async {
    if (_currentUserId == null) {
      throw JournalRepositoryException('User not authenticated');
    }

    try {
      final dateString = date.toIso8601String().split('T').first;
      final response = await _supabase
          .from('journal_entries')
          .select()
          .eq('trip_id', tripId)
          .eq('user_id', _currentUserId!)
          .eq('entry_date', dateString)
          .maybeSingle();

      if (response == null) return null;
      return JournalModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching journal entry by date: $e');
      throw JournalRepositoryException('Failed to fetch journal entry');
    }
  }

  /// Check if user has a journal entry for today
  Future<bool> hasEntryForToday(String tripId) async {
    final entry = await getJournalEntryByDate(tripId, DateTime.now());
    return entry != null;
  }

  /// Get recent journal entries (last N)
  Future<List<JournalModel>> getRecentJournalEntries({int limit = 5}) async {
    if (_currentUserId == null) {
      throw JournalRepositoryException('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('journal_entries')
          .select()
          .eq('user_id', _currentUserId!)
          .order('entry_date', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => JournalModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching recent journal entries: $e');
      throw JournalRepositoryException('Failed to fetch journal entries');
    }
  }

  // ============================================
  // WRITE OPERATIONS
  // ============================================

  /// Create a new journal entry
  Future<JournalModel> createJournalEntry({
    required String tripId,
    required DateTime entryDate,
    required String content,
    String? title,
    bool aiGenerated = true,
    Map<String, dynamic>? sourceData,
    List<String>? photos,
    JournalMood? mood,
    List<String>? locations,
    String? weather,
    List<String>? highlights,
  }) async {
    if (_currentUserId == null) {
      throw JournalRepositoryException('User not authenticated');
    }

    try {
      final response = await _supabase.from('journal_entries').insert({
        'trip_id': tripId,
        'user_id': _currentUserId,
        'entry_date': entryDate.toIso8601String().split('T').first,
        'title': title,
        'content': content,
        'ai_generated': aiGenerated,
        'source_data': sourceData ?? {},
        'photos': photos ?? [],
        'mood': mood?.name,
        'locations': locations ?? [],
        'weather': weather,
        'highlights': highlights ?? [],
      }).select().single();

      return JournalModel.fromJson(response);
    } catch (e) {
      debugPrint('Error creating journal entry: $e');
      // Check for unique constraint violation
      if (e.toString().contains('duplicate key') ||
          e.toString().contains('unique constraint')) {
        throw JournalRepositoryException(
            'A journal entry already exists for this date');
      }
      throw JournalRepositoryException('Failed to create journal entry');
    }
  }

  /// Create or update journal entry for a specific date (upsert)
  Future<JournalModel> upsertJournalEntry({
    required String tripId,
    required DateTime entryDate,
    required String content,
    String? title,
    bool aiGenerated = true,
    Map<String, dynamic>? sourceData,
    List<String>? photos,
    JournalMood? mood,
    List<String>? locations,
    String? weather,
    List<String>? highlights,
  }) async {
    if (_currentUserId == null) {
      throw JournalRepositoryException('User not authenticated');
    }

    try {
      final response = await _supabase.from('journal_entries').upsert(
        {
          'trip_id': tripId,
          'user_id': _currentUserId,
          'entry_date': entryDate.toIso8601String().split('T').first,
          'title': title,
          'content': content,
          'ai_generated': aiGenerated,
          'source_data': sourceData ?? {},
          'photos': photos ?? [],
          'mood': mood?.name,
          'locations': locations ?? [],
          'weather': weather,
          'highlights': highlights ?? [],
        },
        onConflict: 'trip_id,entry_date,user_id',
      ).select().single();

      return JournalModel.fromJson(response);
    } catch (e) {
      debugPrint('Error upserting journal entry: $e');
      throw JournalRepositoryException('Failed to save journal entry');
    }
  }

  /// Update an existing journal entry
  Future<JournalModel> updateJournalEntry(
    String entryId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _supabase
          .from('journal_entries')
          .update(updates)
          .eq('id', entryId)
          .select()
          .single();

      return JournalModel.fromJson(response);
    } catch (e) {
      debugPrint('Error updating journal entry: $e');
      throw JournalRepositoryException('Failed to update journal entry');
    }
  }

  /// Delete a journal entry
  Future<void> deleteJournalEntry(String entryId) async {
    try {
      await _supabase.from('journal_entries').delete().eq('id', entryId);
    } catch (e) {
      debugPrint('Error deleting journal entry: $e');
      throw JournalRepositoryException('Failed to delete journal entry');
    }
  }

  /// Delete all journal entries for a trip
  Future<void> deleteAllTripJournalEntries(String tripId) async {
    try {
      await _supabase.from('journal_entries').delete().eq('trip_id', tripId);
    } catch (e) {
      debugPrint('Error deleting trip journal entries: $e');
      throw JournalRepositoryException('Failed to delete journal entries');
    }
  }

  // ============================================
  // PHOTO OPERATIONS
  // ============================================

  /// Add a photo to a journal entry
  Future<JournalModel> addPhoto(String entryId, String photoUrl) async {
    try {
      // First get current photos
      final entry = await getJournalEntry(entryId);
      if (entry == null) {
        throw JournalRepositoryException('Journal entry not found');
      }

      final updatedPhotos = [...entry.photos, photoUrl];

      return updateJournalEntry(entryId, {'photos': updatedPhotos});
    } catch (e) {
      if (e is JournalRepositoryException) rethrow;
      debugPrint('Error adding photo: $e');
      throw JournalRepositoryException('Failed to add photo');
    }
  }

  /// Remove a photo from a journal entry
  Future<JournalModel> removePhoto(String entryId, String photoUrl) async {
    try {
      final entry = await getJournalEntry(entryId);
      if (entry == null) {
        throw JournalRepositoryException('Journal entry not found');
      }

      final updatedPhotos = entry.photos.where((p) => p != photoUrl).toList();

      return updateJournalEntry(entryId, {'photos': updatedPhotos});
    } catch (e) {
      if (e is JournalRepositoryException) rethrow;
      debugPrint('Error removing photo: $e');
      throw JournalRepositoryException('Failed to remove photo');
    }
  }
}

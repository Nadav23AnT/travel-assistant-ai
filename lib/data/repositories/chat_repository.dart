import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_models.dart';

class ChatRepositoryException implements Exception {
  final String message;

  ChatRepositoryException(this.message);

  @override
  String toString() => message;
}

class ChatRepository {
  final SupabaseClient _supabase;

  ChatRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // ============================================
  // SESSIONS
  // ============================================

  /// Create a new chat session
  Future<ChatSession> createSession({
    String? tripId,
    String title = 'New Chat',
    String aiProvider = 'openai',
    String aiModel = 'gpt-4o-mini',
  }) async {
    if (_currentUserId == null) {
      throw ChatRepositoryException('User not authenticated');
    }

    try {
      final response = await _supabase.from('chat_sessions').insert({
        'user_id': _currentUserId,
        'trip_id': tripId,
        'title': title,
        'ai_provider': aiProvider,
        'ai_model': aiModel,
        'context': {},
        'is_active': true,
      }).select().single();

      return ChatSession.fromJson(response);
    } catch (e) {
      debugPrint('Error creating chat session: $e');
      throw ChatRepositoryException('Failed to create chat session');
    }
  }

  /// Get all chat sessions for the current user
  Future<List<ChatSession>> getUserSessions() async {
    if (_currentUserId == null) {
      throw ChatRepositoryException('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('chat_sessions')
          .select()
          .eq('user_id', _currentUserId!)
          .eq('is_active', true)
          .order('updated_at', ascending: false);

      return (response as List)
          .map((json) => ChatSession.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching chat sessions: $e');
      throw ChatRepositoryException('Failed to fetch chat sessions');
    }
  }

  /// Get a specific chat session
  Future<ChatSession?> getSession(String sessionId) async {
    try {
      final response = await _supabase
          .from('chat_sessions')
          .select()
          .eq('id', sessionId)
          .maybeSingle();

      if (response == null) return null;
      return ChatSession.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching chat session: $e');
      throw ChatRepositoryException('Failed to fetch chat session');
    }
  }

  /// Update a chat session's title
  Future<void> updateSessionTitle(String sessionId, String title) async {
    try {
      await _supabase
          .from('chat_sessions')
          .update({'title': title, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', sessionId);
    } catch (e) {
      debugPrint('Error updating session title: $e');
      throw ChatRepositoryException('Failed to update session title');
    }
  }

  /// Soft delete a chat session (set is_active to false)
  Future<void> deleteSession(String sessionId) async {
    try {
      await _supabase
          .from('chat_sessions')
          .update({'is_active': false})
          .eq('id', sessionId);
    } catch (e) {
      debugPrint('Error deleting chat session: $e');
      throw ChatRepositoryException('Failed to delete chat session');
    }
  }

  /// Hard delete a chat session and all its messages
  Future<void> permanentlyDeleteSession(String sessionId) async {
    try {
      await _supabase.from('chat_sessions').delete().eq('id', sessionId);
    } catch (e) {
      debugPrint('Error permanently deleting chat session: $e');
      throw ChatRepositoryException('Failed to delete chat session');
    }
  }

  // ============================================
  // MESSAGES
  // ============================================

  /// Save a message to a session
  Future<ChatMessageModel> saveMessage({
    required String sessionId,
    required String role,
    required String content,
    Map<String, dynamic>? metadata,
    int? tokensUsed,
  }) async {
    try {
      final response = await _supabase.from('chat_messages').insert({
        'session_id': sessionId,
        'role': role,
        'content': content,
        'metadata': metadata ?? {},
        'tokens_used': tokensUsed,
      }).select().single();

      // Update session's updated_at timestamp
      await _supabase
          .from('chat_sessions')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', sessionId);

      return ChatMessageModel.fromJson(response);
    } catch (e) {
      debugPrint('Error saving message: $e');
      throw ChatRepositoryException('Failed to save message');
    }
  }

  /// Get all messages for a session
  Future<List<ChatMessageModel>> getSessionMessages(String sessionId) async {
    try {
      final response = await _supabase
          .from('chat_messages')
          .select()
          .eq('session_id', sessionId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => ChatMessageModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      throw ChatRepositoryException('Failed to fetch messages');
    }
  }

  /// Delete a specific message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _supabase.from('chat_messages').delete().eq('id', messageId);
    } catch (e) {
      debugPrint('Error deleting message: $e');
      throw ChatRepositoryException('Failed to delete message');
    }
  }

  /// Get the count of messages in a session
  Future<int> getMessageCount(String sessionId) async {
    try {
      final response = await _supabase
          .from('chat_messages')
          .select()
          .eq('session_id', sessionId)
          .count();

      return response.count;
    } catch (e) {
      debugPrint('Error getting message count: $e');
      return 0;
    }
  }

  /// Get chat messages for a specific trip and date
  /// This fetches all messages from chat sessions associated with the trip
  /// that were created on the specified date
  Future<List<ChatMessageModel>> getTripMessagesByDate(
    String tripId,
    DateTime date,
  ) async {
    try {
      // First get all sessions for this trip
      final sessions = await _supabase
          .from('chat_sessions')
          .select('id')
          .eq('trip_id', tripId);

      if ((sessions as List).isEmpty) {
        return [];
      }

      final sessionIds = sessions.map((s) => s['id'] as String).toList();

      // Get messages from these sessions created on the specific date
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabase
          .from('chat_messages')
          .select()
          .inFilter('session_id', sessionIds)
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String())
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => ChatMessageModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching trip messages by date: $e');
      return [];
    }
  }

  /// Get all chat messages for a trip (for journal generation context)
  Future<List<ChatMessageModel>> getTripMessages(String tripId) async {
    try {
      // First get all sessions for this trip
      final sessions = await _supabase
          .from('chat_sessions')
          .select('id')
          .eq('trip_id', tripId);

      if ((sessions as List).isEmpty) {
        return [];
      }

      final sessionIds = sessions.map((s) => s['id'] as String).toList();

      final response = await _supabase
          .from('chat_messages')
          .select()
          .inFilter('session_id', sessionIds)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => ChatMessageModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching trip messages: $e');
      return [];
    }
  }

  // ============================================
  // UTILITIES
  // ============================================

  /// Generate a title from the first user message
  String generateTitleFromMessage(String message) {
    // Take first 50 characters or first sentence
    final trimmed = message.trim();
    if (trimmed.length <= 40) return trimmed;

    // Try to find a natural break point
    final punctuation = ['.', '?', '!', ','];
    for (final p in punctuation) {
      final index = trimmed.indexOf(p);
      if (index > 0 && index < 40) {
        return trimmed.substring(0, index + 1);
      }
    }

    // Otherwise just truncate
    return '${trimmed.substring(0, 37)}...';
  }
}

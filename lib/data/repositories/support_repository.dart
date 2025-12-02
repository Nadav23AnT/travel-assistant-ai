import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_models.dart';

/// Repository for support chat functionality
/// Handles both user and admin operations for support sessions
class SupportRepository {
  final SupabaseClient _supabase;

  SupportRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  // ============================================
  // Session Management
  // ============================================

  /// Create a new support session (user creates ticket)
  Future<SupportSessionModel> createSession({
    required String subject,
    SupportPriority priority = SupportPriority.normal,
    FeedbackType feedbackType = FeedbackType.generalSupport,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('support_sessions')
          .insert({
            'user_id': userId,
            'subject': subject,
            'priority': priority.value,
            'feedback_type': feedbackType.value,
            'status': SupportStatus.open.value,
          })
          .select('''
            *,
            user:profiles!support_sessions_user_id_fkey(email, full_name, avatar_url),
            admin:profiles!support_sessions_admin_id_fkey(email, full_name)
          ''')
          .single();

      return SupportSessionModel.fromJson(response);
    } catch (e) {
      debugPrint('Error creating support session: $e');
      rethrow;
    }
  }

  /// Get all support sessions (admin view) with filters
  Future<List<SupportSessionModel>> getAllSessions({
    SupportStatus? statusFilter,
    SupportPriority? priorityFilter,
    FeedbackType? feedbackTypeFilter,
    String? searchQuery,
    int page = 0,
    int pageSize = 20,
    String? sortBy,
    bool ascending = false,
  }) async {
    try {
      var query = _supabase.from('support_sessions').select('''
        *,
        user:profiles!support_sessions_user_id_fkey(email, full_name, avatar_url),
        admin:profiles!support_sessions_admin_id_fkey(email, full_name)
      ''');

      // Apply status filter
      if (statusFilter != null) {
        query = query.eq('status', statusFilter.value);
      }

      // Apply priority filter
      if (priorityFilter != null) {
        query = query.eq('priority', priorityFilter.value);
      }

      // Apply feedback type filter
      if (feedbackTypeFilter != null) {
        query = query.eq('feedback_type', feedbackTypeFilter.value);
      }

      // Apply sorting and pagination
      final orderBy = sortBy ?? 'last_message_at';
      final start = page * pageSize;
      final response = await query
          .order(orderBy, ascending: ascending)
          .range(start, start + pageSize - 1);

      return (response as List)
          .map((json) => SupportSessionModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting all sessions: $e');
      rethrow;
    }
  }

  /// Get support sessions for current user
  Future<List<SupportSessionModel>> getUserSessions() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('support_sessions')
          .select('''
            *,
            user:profiles!support_sessions_user_id_fkey(email, full_name, avatar_url),
            admin:profiles!support_sessions_admin_id_fkey(email, full_name)
          ''')
          .eq('user_id', userId)
          .order('last_message_at', ascending: false);

      return (response as List)
          .map((json) => SupportSessionModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting user sessions: $e');
      rethrow;
    }
  }

  /// Get a single session by ID
  Future<SupportSessionModel?> getSessionById(String sessionId) async {
    try {
      final response = await _supabase
          .from('support_sessions')
          .select('''
            *,
            user:profiles!support_sessions_user_id_fkey(email, full_name, avatar_url),
            admin:profiles!support_sessions_admin_id_fkey(email, full_name)
          ''')
          .eq('id', sessionId)
          .maybeSingle();

      if (response == null) return null;
      return SupportSessionModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting session: $e');
      rethrow;
    }
  }

  /// Update session status (admin operation)
  Future<SupportSessionModel> updateSessionStatus(
    String sessionId,
    SupportStatus status,
  ) async {
    try {
      final updates = <String, dynamic>{
        'status': status.value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Set resolved_at timestamp when marking as resolved
      if (status == SupportStatus.resolved || status == SupportStatus.closed) {
        updates['resolved_at'] = DateTime.now().toIso8601String();
      }

      final response = await _supabase
          .from('support_sessions')
          .update(updates)
          .eq('id', sessionId)
          .select('''
            *,
            user:profiles!support_sessions_user_id_fkey(email, full_name, avatar_url),
            admin:profiles!support_sessions_admin_id_fkey(email, full_name)
          ''')
          .single();

      return SupportSessionModel.fromJson(response);
    } catch (e) {
      debugPrint('Error updating session status: $e');
      rethrow;
    }
  }

  /// Update session priority (admin operation)
  Future<SupportSessionModel> updateSessionPriority(
    String sessionId,
    SupportPriority priority,
  ) async {
    try {
      final response = await _supabase
          .from('support_sessions')
          .update({
            'priority': priority.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', sessionId)
          .select('''
            *,
            user:profiles!support_sessions_user_id_fkey(email, full_name, avatar_url),
            admin:profiles!support_sessions_admin_id_fkey(email, full_name)
          ''')
          .single();

      return SupportSessionModel.fromJson(response);
    } catch (e) {
      debugPrint('Error updating session priority: $e');
      rethrow;
    }
  }

  /// Assign admin to session
  Future<SupportSessionModel> assignAdmin(
    String sessionId,
    String adminId,
  ) async {
    try {
      final response = await _supabase
          .from('support_sessions')
          .update({
            'admin_id': adminId,
            'status': SupportStatus.inProgress.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', sessionId)
          .select('''
            *,
            user:profiles!support_sessions_user_id_fkey(email, full_name, avatar_url),
            admin:profiles!support_sessions_admin_id_fkey(email, full_name)
          ''')
          .single();

      return SupportSessionModel.fromJson(response);
    } catch (e) {
      debugPrint('Error assigning admin: $e');
      rethrow;
    }
  }

  /// Unassign admin from session
  Future<SupportSessionModel> unassignAdmin(String sessionId) async {
    try {
      final response = await _supabase
          .from('support_sessions')
          .update({
            'admin_id': null,
            'status': SupportStatus.open.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', sessionId)
          .select('''
            *,
            user:profiles!support_sessions_user_id_fkey(email, full_name, avatar_url),
            admin:profiles!support_sessions_admin_id_fkey(email, full_name)
          ''')
          .single();

      return SupportSessionModel.fromJson(response);
    } catch (e) {
      debugPrint('Error unassigning admin: $e');
      rethrow;
    }
  }

  // ============================================
  // Message Management
  // ============================================

  /// Send a message in a support session
  Future<SupportMessageModel> sendMessage({
    required String sessionId,
    required String content,
    required SenderRole role,
  }) async {
    try {
      final senderId = _supabase.auth.currentUser?.id;
      if (senderId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('support_messages')
          .insert({
            'session_id': sessionId,
            'sender_id': senderId,
            'sender_role': role.value,
            'content': content,
          })
          .select('''
            *,
            sender:profiles!support_messages_sender_id_fkey(email, full_name, avatar_url)
          ''')
          .single();

      return SupportMessageModel.fromJson(response);
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
    }
  }

  /// Get all messages for a session
  Future<List<SupportMessageModel>> getSessionMessages(String sessionId) async {
    try {
      final response = await _supabase
          .from('support_messages')
          .select('''
            *,
            sender:profiles!support_messages_sender_id_fkey(email, full_name, avatar_url)
          ''')
          .eq('session_id', sessionId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => SupportMessageModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting messages: $e');
      rethrow;
    }
  }

  /// Stream messages for real-time updates
  Stream<List<SupportMessageModel>> streamMessages(String sessionId) {
    return _supabase
        .from('support_messages')
        .stream(primaryKey: ['id'])
        .eq('session_id', sessionId)
        .order('created_at', ascending: true)
        .map((data) => data
            .map((json) => SupportMessageModel.fromJson(json))
            .toList());
  }

  /// Stream session updates for real-time status changes
  Stream<SupportSessionModel> streamSession(String sessionId) {
    return _supabase
        .from('support_sessions')
        .stream(primaryKey: ['id'])
        .eq('id', sessionId)
        .map((data) {
          if (data.isEmpty) {
            throw Exception('Session not found');
          }
          return SupportSessionModel.fromJson(data.first);
        });
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String sessionId, SenderRole readerRole) async {
    try {
      await _supabase.rpc('mark_support_messages_read', params: {
        'p_session_id': sessionId,
        'p_role': readerRole.value,
      });
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
      rethrow;
    }
  }

  // ============================================
  // Statistics and Counts
  // ============================================

  /// Get count of open support tickets (for admin dashboard)
  Future<int> getOpenTicketsCount() async {
    try {
      final response = await _supabase
          .from('support_sessions')
          .select()
          .inFilter('status', ['open', 'in_progress'])
          .count(CountOption.exact);

      return response.count;
    } catch (e) {
      debugPrint('Error getting open tickets count: $e');
      return 0;
    }
  }

  /// Get count of unread messages for current user's sessions
  Future<int> getUserUnreadCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      final response = await _supabase
          .from('support_sessions')
          .select('unread_user_count')
          .eq('user_id', userId);

      int total = 0;
      for (final session in response as List) {
        total += (session['unread_user_count'] as int? ?? 0);
      }
      return total;
    } catch (e) {
      debugPrint('Error getting user unread count: $e');
      return 0;
    }
  }

  /// Get count of unread messages for admin (across all sessions)
  Future<int> getAdminUnreadCount() async {
    try {
      final response = await _supabase
          .from('support_sessions')
          .select('unread_admin_count')
          .inFilter('status', ['open', 'in_progress']);

      int total = 0;
      for (final session in response as List) {
        total += (session['unread_admin_count'] as int? ?? 0);
      }
      return total;
    } catch (e) {
      debugPrint('Error getting admin unread count: $e');
      return 0;
    }
  }

  /// Get sessions assigned to a specific admin
  Future<List<SupportSessionModel>> getAdminAssignedSessions(String adminId) async {
    try {
      final response = await _supabase
          .from('support_sessions')
          .select('''
            *,
            user:profiles!support_sessions_user_id_fkey(email, full_name, avatar_url),
            admin:profiles!support_sessions_admin_id_fkey(email, full_name)
          ''')
          .eq('admin_id', adminId)
          .inFilter('status', ['open', 'in_progress'])
          .order('last_message_at', ascending: false);

      return (response as List)
          .map((json) => SupportSessionModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting admin assigned sessions: $e');
      rethrow;
    }
  }

  /// Get unassigned open sessions
  Future<List<SupportSessionModel>> getUnassignedSessions() async {
    try {
      final response = await _supabase
          .from('support_sessions')
          .select('''
            *,
            user:profiles!support_sessions_user_id_fkey(email, full_name, avatar_url),
            admin:profiles!support_sessions_admin_id_fkey(email, full_name)
          ''')
          .isFilter('admin_id', null)
          .eq('status', 'open')
          .order('priority', ascending: true) // Urgent first
          .order('created_at', ascending: true); // Oldest first

      return (response as List)
          .map((json) => SupportSessionModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error getting unassigned sessions: $e');
      rethrow;
    }
  }
}

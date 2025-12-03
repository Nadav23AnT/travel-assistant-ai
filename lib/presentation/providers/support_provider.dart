import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_models.dart';
import '../../data/repositories/support_repository.dart';
import 'auth_provider.dart';

// ============================================
// Repository Provider
// ============================================

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepository();
});

// ============================================
// Session List Providers
// ============================================

/// Filter state for support sessions (admin view)
class SupportSessionFilters {
  final SupportStatus? status;
  final SupportPriority? priority;
  final FeedbackType? feedbackType;
  final String? searchQuery;
  final int page;

  const SupportSessionFilters({
    this.status,
    this.priority,
    this.feedbackType,
    this.searchQuery,
    this.page = 0,
  });

  SupportSessionFilters copyWith({
    SupportStatus? status,
    SupportPriority? priority,
    FeedbackType? feedbackType,
    String? searchQuery,
    int? page,
    bool clearStatus = false,
    bool clearPriority = false,
    bool clearFeedbackType = false,
  }) {
    return SupportSessionFilters(
      status: clearStatus ? null : (status ?? this.status),
      priority: clearPriority ? null : (priority ?? this.priority),
      feedbackType: clearFeedbackType ? null : (feedbackType ?? this.feedbackType),
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
    );
  }
}

final supportSessionFiltersProvider = StateProvider<SupportSessionFilters>((ref) {
  return const SupportSessionFilters();
});

/// All support sessions (admin view)
final allSupportSessionsProvider =
    FutureProvider<List<SupportSessionModel>>((ref) async {
  final repository = ref.watch(supportRepositoryProvider);
  final filters = ref.watch(supportSessionFiltersProvider);

  return await repository.getAllSessions(
    statusFilter: filters.status,
    priorityFilter: filters.priority,
    feedbackTypeFilter: filters.feedbackType,
    searchQuery: filters.searchQuery,
    page: filters.page,
  );
});

/// Current user's support sessions
final userSupportSessionsProvider =
    FutureProvider<List<SupportSessionModel>>((ref) async {
  final repository = ref.watch(supportRepositoryProvider);
  return await repository.getUserSessions();
});

/// Single session by ID
final supportSessionProvider =
    FutureProvider.family<SupportSessionModel?, String>((ref, sessionId) async {
  final repository = ref.watch(supportRepositoryProvider);
  return await repository.getSessionById(sessionId);
});

/// Unassigned sessions (for admin to pick up)
final unassignedSessionsProvider =
    FutureProvider<List<SupportSessionModel>>((ref) async {
  final repository = ref.watch(supportRepositoryProvider);
  return await repository.getUnassignedSessions();
});

/// Sessions assigned to current admin
final myAssignedSessionsProvider =
    FutureProvider<List<SupportSessionModel>>((ref) async {
  final repository = ref.watch(supportRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) return [];
  return await repository.getAdminAssignedSessions(user.id);
});

// ============================================
// Unread Counts
// ============================================

/// Unread count for user
final userUnreadCountProvider = FutureProvider<int>((ref) async {
  try {
    final repository = ref.watch(supportRepositoryProvider);
    return await repository.getUserUnreadCount();
  } catch (e) {
    // Return 0 if support_sessions table doesn't exist or has RLS issues
    return 0;
  }
});

/// Unread count for admin (all open sessions)
final adminUnreadCountProvider = FutureProvider<int>((ref) async {
  try {
    final repository = ref.watch(supportRepositoryProvider);
    return await repository.getAdminUnreadCount();
  } catch (e) {
    return 0;
  }
});

/// Open tickets count
final openTicketsCountProvider = FutureProvider<int>((ref) async {
  try {
    final repository = ref.watch(supportRepositoryProvider);
    return await repository.getOpenTicketsCount();
  } catch (e) {
    return 0;
  }
});

// ============================================
// Support Chat Notifier
// ============================================

/// State for a support chat session
class SupportChatState {
  final SupportSessionModel? session;
  final List<SupportMessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const SupportChatState({
    this.session,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  SupportChatState copyWith({
    SupportSessionModel? session,
    List<SupportMessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
  }) {
    return SupportChatState(
      session: session ?? this.session,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

class SupportChatNotifier extends StateNotifier<SupportChatState> {
  final SupportRepository _repository;
  final Ref _ref;
  final String sessionId;
  final SenderRole senderRole;

  StreamSubscription? _messagesSubscription;
  StreamSubscription? _sessionSubscription;

  SupportChatNotifier({
    required SupportRepository repository,
    required Ref ref,
    required this.sessionId,
    required this.senderRole,
  })  : _repository = repository,
        _ref = ref,
        super(const SupportChatState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    try {
      // Load initial data
      final session = await _repository.getSessionById(sessionId);
      final messages = await _repository.getSessionMessages(sessionId);

      if (!mounted) return;
      state = state.copyWith(
        session: session,
        messages: messages,
        isLoading: false,
      );

      // Mark messages as read
      await _repository.markMessagesAsRead(sessionId, senderRole);

      // Subscribe to real-time updates
      _messagesSubscription = _repository.streamMessages(sessionId).listen(
        (messages) {
          if (!mounted) return;
          state = state.copyWith(messages: messages);
          // Mark new messages as read
          _repository.markMessagesAsRead(sessionId, senderRole);
        },
        onError: (e) {
          if (!mounted) return;
          state = state.copyWith(error: e.toString());
        },
      );

      _sessionSubscription = _repository.streamSession(sessionId).listen(
        (session) {
          if (!mounted) return;
          state = state.copyWith(session: session);
        },
        onError: (e) {
          // Session errors are less critical, just log them
        },
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Send a message
  Future<bool> sendMessage(String content) async {
    if (content.trim().isEmpty) return false;
    if (!mounted) return false;

    state = state.copyWith(isSending: true, error: null);
    try {
      await _repository.sendMessage(
        sessionId: sessionId,
        content: content.trim(),
        role: senderRole,
      );
      if (!mounted) return true;
      state = state.copyWith(isSending: false);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(isSending: false, error: e.toString());
      return false;
    }
  }

  /// Update session status (admin only)
  Future<bool> updateStatus(SupportStatus status) async {
    if (!mounted) return false;
    try {
      final session = await _repository.updateSessionStatus(sessionId, status);
      if (!mounted) return true;
      state = state.copyWith(session: session);
      _ref.invalidate(allSupportSessionsProvider);
      _ref.invalidate(openTicketsCountProvider);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Update session priority (admin only)
  Future<bool> updatePriority(SupportPriority priority) async {
    if (!mounted) return false;
    try {
      final session = await _repository.updateSessionPriority(sessionId, priority);
      if (!mounted) return true;
      state = state.copyWith(session: session);
      _ref.invalidate(allSupportSessionsProvider);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Assign session to current admin
  Future<bool> assignToMe() async {
    if (!mounted) return false;
    final user = _ref.read(currentUserProvider);
    if (user == null) return false;

    try {
      final session = await _repository.assignAdmin(sessionId, user.id);
      if (!mounted) return true;
      state = state.copyWith(session: session);
      _ref.invalidate(allSupportSessionsProvider);
      _ref.invalidate(unassignedSessionsProvider);
      _ref.invalidate(myAssignedSessionsProvider);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Unassign session
  Future<bool> unassign() async {
    if (!mounted) return false;
    try {
      final session = await _repository.unassignAdmin(sessionId);
      if (!mounted) return true;
      state = state.copyWith(session: session);
      _ref.invalidate(allSupportSessionsProvider);
      _ref.invalidate(unassignedSessionsProvider);
      _ref.invalidate(myAssignedSessionsProvider);
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _sessionSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for support chat, parameterized by session ID and role
final supportChatProvider = StateNotifierProvider.autoDispose
    .family<SupportChatNotifier, SupportChatState, (String, SenderRole)>(
  (ref, params) {
    final (sessionId, role) = params;
    final repository = ref.watch(supportRepositoryProvider);
    return SupportChatNotifier(
      repository: repository,
      ref: ref,
      sessionId: sessionId,
      senderRole: role,
    );
  },
);

// ============================================
// Create Session Notifier
// ============================================

class CreateSessionState {
  final bool isCreating;
  final String? error;
  final SupportSessionModel? createdSession;

  const CreateSessionState({
    this.isCreating = false,
    this.error,
    this.createdSession,
  });

  CreateSessionState copyWith({
    bool? isCreating,
    String? error,
    SupportSessionModel? createdSession,
  }) {
    return CreateSessionState(
      isCreating: isCreating ?? this.isCreating,
      error: error,
      createdSession: createdSession,
    );
  }
}

class CreateSessionNotifier extends StateNotifier<CreateSessionState> {
  final SupportRepository _repository;
  final Ref _ref;

  CreateSessionNotifier(this._repository, this._ref)
      : super(const CreateSessionState());

  Future<SupportSessionModel?> createSession({
    required String subject,
    SupportPriority priority = SupportPriority.normal,
    FeedbackType feedbackType = FeedbackType.generalSupport,
  }) async {
    state = state.copyWith(isCreating: true, error: null);
    try {
      final session = await _repository.createSession(
        subject: subject,
        priority: priority,
        feedbackType: feedbackType,
      );
      state = state.copyWith(isCreating: false, createdSession: session);
      _ref.invalidate(userSupportSessionsProvider);
      _ref.invalidate(allSupportSessionsProvider);
      _ref.invalidate(openTicketsCountProvider);
      return session;
    } catch (e) {
      state = state.copyWith(isCreating: false, error: e.toString());
      return null;
    }
  }

  void reset() {
    state = const CreateSessionState();
  }
}

final createSessionProvider =
    StateNotifierProvider<CreateSessionNotifier, CreateSessionState>((ref) {
  final repository = ref.watch(supportRepositoryProvider);
  return CreateSessionNotifier(repository, ref);
});

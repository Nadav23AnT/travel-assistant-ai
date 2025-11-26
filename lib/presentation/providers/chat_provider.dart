import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/chat_models.dart';
import '../../data/models/travel_context.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/expenses_repository.dart';
import '../../services/ai_service.dart';
import 'travel_context_provider.dart';
import 'trips_provider.dart';

// ============================================
// SERVICE PROVIDERS
// ============================================

/// AI Service provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

/// Chat Repository provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

// ============================================
// SESSION LIST PROVIDERS
// ============================================

/// Provider for list of chat sessions
final chatSessionsProvider = FutureProvider<List<ChatSession>>((ref) async {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getUserSessions();
});

/// Provider to refresh sessions
final chatSessionsRefreshProvider = Provider<void Function()>((ref) {
  return () => ref.invalidate(chatSessionsProvider);
});

// ============================================
// CURRENT CHAT STATE
// ============================================

/// State for the current chat
class ChatState {
  final ChatSession? session;
  final List<ChatMessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;
  final ParsedExpense? pendingExpense;
  final bool isCreatingExpense;
  final List<PlaceRecommendation> pendingPlaces;

  const ChatState({
    this.session,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
    this.pendingExpense,
    this.isCreatingExpense = false,
    this.pendingPlaces = const [],
  });

  ChatState copyWith({
    ChatSession? session,
    List<ChatMessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
    bool clearError = false,
    ParsedExpense? pendingExpense,
    bool clearPendingExpense = false,
    bool? isCreatingExpense,
    List<PlaceRecommendation>? pendingPlaces,
    bool clearPendingPlaces = false,
  }) {
    return ChatState(
      session: session ?? this.session,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
      pendingExpense: clearPendingExpense ? null : (pendingExpense ?? this.pendingExpense),
      isCreatingExpense: isCreatingExpense ?? this.isCreatingExpense,
      pendingPlaces: clearPendingPlaces ? const [] : (pendingPlaces ?? this.pendingPlaces),
    );
  }
}

/// Notifier for current chat
class ChatNotifier extends StateNotifier<ChatState> {
  final AIService _aiService;
  final ChatRepository _repository;
  final Ref _ref;

  ChatNotifier(this._aiService, this._repository, this._ref)
      : super(const ChatState());

  /// Create a new chat session
  Future<String> createNewSession({String? tripId, bool withWelcome = true}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = await _repository.createSession(tripId: tripId);
      state = state.copyWith(
        session: session,
        messages: [],
        isLoading: false,
      );

      // Refresh the sessions list
      _ref.invalidate(chatSessionsProvider);

      // Generate proactive welcome message if there's an active trip
      if (withWelcome) {
        _generateWelcomeMessage(session.id);
      }

      return session.id;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Generate a welcome message with local tips for the current trip
  Future<void> _generateWelcomeMessage(String sessionId) async {
    try {
      final travelContext = _ref.read(currentTravelContextProvider);

      // Only generate welcome if there's an active trip with a destination
      if (travelContext == null || travelContext.destination == null) {
        return;
      }

      // Generate welcome message in background (don't block UI)
      final welcomeMessage = await _aiService.generateTripWelcome(
        context: travelContext,
      );

      // Save welcome message to database
      final assistantMessage = await _repository.saveMessage(
        sessionId: sessionId,
        role: 'assistant',
        content: welcomeMessage,
      );

      // Update local state with welcome message
      if (state.session?.id == sessionId) {
        state = state.copyWith(
          messages: [...state.messages, assistantMessage],
        );
      }
    } catch (e) {
      // Silently fail - welcome message is not critical
      // debugPrint('Failed to generate welcome message: $e');
    }
  }

  /// Load an existing session
  Future<void> loadSession(String sessionId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final session = await _repository.getSession(sessionId);
      if (session == null) {
        throw ChatRepositoryException('Session not found');
      }

      final messages = await _repository.getSessionMessages(sessionId);

      state = state.copyWith(
        session: session,
        messages: messages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Send a message and get AI response with expense detection
  Future<void> sendMessage(String content) async {
    if (state.session == null) {
      throw ChatRepositoryException('No active session');
    }

    if (content.trim().isEmpty) return;

    state = state.copyWith(
      isSending: true,
      clearError: true,
      clearPendingExpense: true,
      clearPendingPlaces: true,
    );

    try {
      final sessionId = state.session!.id;

      // Save user message to database
      final userMessage = await _repository.saveMessage(
        sessionId: sessionId,
        role: 'user',
        content: content,
      );

      // Update local state with user message
      state = state.copyWith(
        messages: [...state.messages, userMessage],
      );

      // Build conversation history for AI
      final history = state.messages
          .where((m) => m.role != 'system')
          .map((m) => ChatMessage(role: m.role, content: m.content))
          .toList();

      // Remove the last message (we're sending it as the new message)
      if (history.isNotEmpty) {
        history.removeLast();
      }

      // Get travel context for personalized recommendations
      final travelContext = _ref.read(currentTravelContextProvider);

      // Get AI response with expense detection and place recommendations
      final aiResponse = await _aiService.sendMessageWithExpenseDetection(
        message: content,
        history: history,
        context: travelContext,
      );

      // Save AI response to database
      final assistantMessage = await _repository.saveMessage(
        sessionId: sessionId,
        role: 'assistant',
        content: aiResponse.message,
      );

      // Update local state with AI response, pending expense, and places
      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isSending: false,
        pendingExpense: aiResponse.expense,
        pendingPlaces: aiResponse.places,
      );

      // Generate AI title after first message exchange (user + assistant)
      if (state.messages.length == 2) {
        _generateAndUpdateTitle(sessionId, content, aiResponse.message);
      }
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
      rethrow;
    }
  }

  /// Generate and update chat title using AI (runs in background)
  Future<void> _generateAndUpdateTitle(
    String sessionId,
    String userMessage,
    String assistantResponse,
  ) async {
    try {
      final title = await _aiService.generateChatTitle(
        userMessage: userMessage,
        assistantResponse: assistantResponse,
      );

      await _repository.updateSessionTitle(sessionId, title);

      if (state.session?.id == sessionId) {
        state = state.copyWith(
          session: state.session!.copyWith(title: title),
        );
      }

      _ref.invalidate(chatSessionsProvider);
    } catch (e) {
      // Silently fail - title generation is not critical
      // debugPrint('Failed to generate chat title: $e');
    }
  }

  /// Confirm and save the pending expense
  Future<bool> confirmPendingExpense() async {
    if (state.pendingExpense == null) return false;

    state = state.copyWith(isCreatingExpense: true);

    try {
      // Get active trip ID
      final activeTrip = _ref.read(activeTripProvider).valueOrNull;
      if (activeTrip == null) {
        state = state.copyWith(
          isCreatingExpense: false,
          error: 'No active trip. Please create a trip first.',
        );
        return false;
      }

      final expense = state.pendingExpense!;
      final repository = ExpensesRepository();

      await repository.createExpense(
        tripId: activeTrip.id,
        amount: expense.amount,
        currency: expense.currency,
        category: expense.category,
        description: expense.description,
        expenseDate: expense.date,
      );

      // Add confirmation message
      if (state.session != null) {
        final confirmMessage = await _repository.saveMessage(
          sessionId: state.session!.id,
          role: 'assistant',
          content: 'Added ${expense.formattedAmount} for "${expense.description}" to your ${expense.categoryDisplayName} expenses.',
        );
        state = state.copyWith(
          messages: [...state.messages, confirmMessage],
        );
      }

      state = state.copyWith(
        isCreatingExpense: false,
        clearPendingExpense: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isCreatingExpense: false,
        error: 'Failed to save expense: ${e.toString()}',
      );
      return false;
    }
  }

  /// Dismiss the pending expense
  void dismissPendingExpense() {
    state = state.copyWith(clearPendingExpense: true);
  }

  /// Update the pending expense (for editing)
  void updatePendingExpense(ParsedExpense expense) {
    state = state.copyWith(pendingExpense: expense);
  }

  /// Dismiss the pending places (after user interacts with them)
  void dismissPendingPlaces() {
    state = state.copyWith(clearPendingPlaces: true);
  }

  /// Delete current session
  Future<void> deleteCurrentSession() async {
    if (state.session == null) return;

    try {
      await _repository.deleteSession(state.session!.id);
      state = const ChatState();
      _ref.invalidate(chatSessionsProvider);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reset state
  void reset() {
    state = const ChatState();
  }
}

/// Provider for current chat notifier
final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  final repository = ref.watch(chatRepositoryProvider);
  return ChatNotifier(aiService, repository, ref);
});

// ============================================
// CONVENIENCE PROVIDERS
// ============================================

/// Provider for checking if AI is configured
final isAIConfiguredProvider = Provider<bool>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return aiService.isConfigured;
});

/// Provider for current session messages
final currentChatMessagesProvider = Provider<List<ChatMessageModel>>((ref) {
  final state = ref.watch(chatNotifierProvider);
  return state.messages;
});

/// Provider for current session
final currentChatSessionProvider = Provider<ChatSession?>((ref) {
  final state = ref.watch(chatNotifierProvider);
  return state.session;
});

/// Provider for chat loading state
final isChatLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(chatNotifierProvider);
  return state.isLoading;
});

/// Provider for chat sending state
final isChatSendingProvider = Provider<bool>((ref) {
  final state = ref.watch(chatNotifierProvider);
  return state.isSending;
});

/// Provider for pending expense
final pendingExpenseProvider = Provider<ParsedExpense?>((ref) {
  final state = ref.watch(chatNotifierProvider);
  return state.pendingExpense;
});

/// Provider for expense creation loading state
final isCreatingExpenseProvider = Provider<bool>((ref) {
  final state = ref.watch(chatNotifierProvider);
  return state.isCreatingExpense;
});

/// Provider for pending place recommendations
final pendingPlacesProvider = Provider<List<PlaceRecommendation>>((ref) {
  final state = ref.watch(chatNotifierProvider);
  return state.pendingPlaces;
});

/// Provider for checking if there are pending places
final hasPendingPlacesProvider = Provider<bool>((ref) {
  final places = ref.watch(pendingPlacesProvider);
  return places.isNotEmpty;
});

/// Provider for recent chat sessions (for dashboard)
final recentChatsProvider = FutureProvider<List<ChatSession>>((ref) async {
  final repository = ref.watch(chatRepositoryProvider);
  final sessions = await repository.getUserSessions();
  // Return last 5 sessions, sorted by most recent
  final sorted = List<ChatSession>.from(sessions)
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return sorted.take(5).toList();
});

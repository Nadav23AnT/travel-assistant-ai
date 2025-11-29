import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/chat_models.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/journal_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/expenses_repository.dart';
import '../../data/repositories/journal_repository.dart';
import '../../services/ai_service.dart';
import '../../services/journal_auto_generator.dart';
import 'trips_provider.dart';

// ============================================
// REPOSITORY PROVIDER
// ============================================

/// Journal Repository provider
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository();
});

// ============================================
// DATA PROVIDERS
// ============================================

/// Provider to fetch all journal entries for a specific trip
final tripJournalEntriesProvider =
    FutureProvider.family<List<JournalModel>, String>((ref, tripId) async {
  final repository = ref.watch(journalRepositoryProvider);
  return repository.getTripJournalEntries(tripId);
});

/// Provider to fetch all journal entries for current user
final userJournalEntriesProvider =
    FutureProvider<List<JournalModel>>((ref) async {
  final repository = ref.watch(journalRepositoryProvider);
  return repository.getUserJournalEntries();
});

/// Provider to fetch a specific journal entry by ID
final journalEntryByIdProvider =
    FutureProvider.family<JournalModel?, String>((ref, entryId) async {
  final repository = ref.watch(journalRepositoryProvider);
  return repository.getJournalEntry(entryId);
});

/// Provider to check if there's an entry for today
final hasEntryForTodayProvider =
    FutureProvider.family<bool, String>((ref, tripId) async {
  final repository = ref.watch(journalRepositoryProvider);
  return repository.hasEntryForToday(tripId);
});

/// Provider to get recent journal entries
final recentJournalEntriesProvider =
    FutureProvider.family<List<JournalModel>, int>((ref, limit) async {
  final repository = ref.watch(journalRepositoryProvider);
  return repository.getRecentJournalEntries(limit: limit);
});

// ============================================
// STATE NOTIFIER FOR JOURNAL OPERATIONS
// ============================================

/// State for journal operations
class JournalOperationState {
  final bool isLoading;
  final bool isGenerating;
  final String? error;
  final JournalModel? lastCreatedEntry;

  const JournalOperationState({
    this.isLoading = false,
    this.isGenerating = false,
    this.error,
    this.lastCreatedEntry,
  });

  JournalOperationState copyWith({
    bool? isLoading,
    bool? isGenerating,
    String? error,
    JournalModel? lastCreatedEntry,
    bool clearError = false,
  }) {
    return JournalOperationState(
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      error: clearError ? null : (error ?? this.error),
      lastCreatedEntry: lastCreatedEntry ?? this.lastCreatedEntry,
    );
  }
}

/// Notifier for journal operations (create, update, delete, generate)
class JournalOperationNotifier extends StateNotifier<JournalOperationState> {
  final JournalRepository _repository;
  final Ref _ref;

  JournalOperationNotifier(this._repository, this._ref)
      : super(const JournalOperationState());

  /// Create a new journal entry manually
  Future<JournalModel?> createEntry({
    required String tripId,
    required DateTime entryDate,
    required String content,
    String? title,
    JournalMood? mood,
    List<String>? photos,
    List<String>? locations,
    List<String>? highlights,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final entry = await _repository.createJournalEntry(
        tripId: tripId,
        entryDate: entryDate,
        content: content,
        title: title,
        aiGenerated: false,
        mood: mood,
        photos: photos,
        locations: locations,
        highlights: highlights,
      );

      state = state.copyWith(
        isLoading: false,
        lastCreatedEntry: entry,
      );

      // Refresh providers
      _ref.invalidate(tripJournalEntriesProvider(tripId));
      _ref.invalidate(userJournalEntriesProvider);

      return entry;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Create or update a journal entry for a specific date
  Future<JournalModel?> saveEntry({
    required String tripId,
    required DateTime entryDate,
    required String content,
    String? title,
    bool aiGenerated = false,
    JournalMood? mood,
    List<String>? photos,
    List<String>? locations,
    List<String>? highlights,
    Map<String, dynamic>? sourceData,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final entry = await _repository.upsertJournalEntry(
        tripId: tripId,
        entryDate: entryDate,
        content: content,
        title: title,
        aiGenerated: aiGenerated,
        mood: mood,
        photos: photos,
        locations: locations,
        highlights: highlights,
        sourceData: sourceData,
      );

      state = state.copyWith(
        isLoading: false,
        lastCreatedEntry: entry,
      );

      // Refresh providers
      _ref.invalidate(tripJournalEntriesProvider(tripId));
      _ref.invalidate(userJournalEntriesProvider);

      return entry;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Generate and save an AI journal entry
  Future<JournalModel?> generateAndSaveEntry({
    required String tripId,
    required DateTime entryDate,
    required GeneratedJournalContent generatedContent,
    Map<String, dynamic>? sourceData,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final entry = await _repository.upsertJournalEntry(
        tripId: tripId,
        entryDate: entryDate,
        content: generatedContent.content,
        title: generatedContent.title,
        aiGenerated: true,
        mood: generatedContent.mood,
        locations: generatedContent.locations,
        highlights: generatedContent.highlights,
        sourceData: sourceData,
      );

      state = state.copyWith(
        isLoading: false,
        lastCreatedEntry: entry,
      );

      // Refresh providers
      _ref.invalidate(tripJournalEntriesProvider(tripId));
      _ref.invalidate(userJournalEntriesProvider);
      _ref.invalidate(hasEntryForTodayProvider(tripId));

      return entry;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Update an existing entry
  Future<JournalModel?> updateEntry(
    String entryId,
    String tripId, {
    String? content,
    String? title,
    JournalMood? mood,
    List<String>? photos,
    List<String>? locations,
    List<String>? highlights,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final updates = <String, dynamic>{};
      if (content != null) updates['content'] = content;
      if (title != null) updates['title'] = title;
      if (mood != null) updates['mood'] = mood.name;
      if (photos != null) updates['photos'] = photos;
      if (locations != null) updates['locations'] = locations;
      if (highlights != null) updates['highlights'] = highlights;
      updates['ai_generated'] = false; // Mark as manually edited

      final entry = await _repository.updateJournalEntry(entryId, updates);

      state = state.copyWith(isLoading: false);

      // Refresh providers
      _ref.invalidate(tripJournalEntriesProvider(tripId));
      _ref.invalidate(journalEntryByIdProvider(entryId));

      return entry;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Delete an entry
  Future<bool> deleteEntry(String entryId, String tripId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.deleteJournalEntry(entryId);
      state = state.copyWith(isLoading: false);

      // Refresh providers
      _ref.invalidate(tripJournalEntriesProvider(tripId));
      _ref.invalidate(userJournalEntriesProvider);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Add a photo to an entry
  Future<JournalModel?> addPhoto(
    String entryId,
    String tripId,
    String photoUrl,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final entry = await _repository.addPhoto(entryId, photoUrl);
      state = state.copyWith(isLoading: false);

      // Refresh providers
      _ref.invalidate(journalEntryByIdProvider(entryId));
      _ref.invalidate(tripJournalEntriesProvider(tripId));

      return entry;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Set generating state (when AI is working)
  void setGenerating(bool generating) {
    state = state.copyWith(isGenerating: generating);
  }
}

/// Provider for journal operations
final journalOperationProvider =
    StateNotifierProvider<JournalOperationNotifier, JournalOperationState>(
        (ref) {
  final repository = ref.watch(journalRepositoryProvider);
  return JournalOperationNotifier(repository, ref);
});

// ============================================
// COMPUTED PROVIDERS
// ============================================

/// Provider to get journal entries grouped by date for a trip
final tripJournalByDateProvider =
    Provider.family<Map<DateTime, JournalModel>, String>((ref, tripId) {
  final entriesAsync = ref.watch(tripJournalEntriesProvider(tripId));

  return entriesAsync.when(
    data: (entries) {
      final map = <DateTime, JournalModel>{};
      for (final entry in entries) {
        final dateKey = DateTime(
          entry.entryDate.year,
          entry.entryDate.month,
          entry.entryDate.day,
        );
        map[dateKey] = entry;
      }
      return map;
    },
    loading: () => {},
    error: (_, _) => {},
  );
});

/// Provider to get journal entry count for a trip
final tripJournalCountProvider =
    Provider.family<int, String>((ref, tripId) {
  final entriesAsync = ref.watch(tripJournalEntriesProvider(tripId));
  return entriesAsync.when(
    data: (entries) => entries.length,
    loading: () => 0,
    error: (_, _) => 0,
  );
});

/// Provider to check if journal prompt should be shown
/// (user is on active trip and hasn't logged today)
final shouldShowJournalPromptProvider = Provider<bool>((ref) {
  final activeTrip = ref.watch(activeTripProvider);

  return activeTrip.when(
    data: (trip) {
      if (trip == null || !trip.isActive) return false;

      final hasEntry = ref.watch(hasEntryForTodayProvider(trip.id));
      return hasEntry.when(
        data: (has) => !has,
        loading: () => false,
        error: (_, _) => false,
      );
    },
    loading: () => false,
    error: (_, _) => false,
  );
});

// ============================================
// REFRESH PROVIDER
// ============================================

/// Refresh all journal data for a trip
final journalRefreshProvider =
    Provider.family<void Function(), String>((ref, tripId) {
  return () {
    ref.invalidate(tripJournalEntriesProvider(tripId));
    ref.invalidate(hasEntryForTodayProvider(tripId));
    ref.invalidate(tripJournalByDateProvider(tripId));
    ref.invalidate(tripJournalCountProvider(tripId));
  };
});

// ============================================
// AUTO-GENERATION PROVIDERS
// ============================================

/// Provider for chat repository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

/// Provider for expenses repository
final expensesRepositoryForJournalProvider = Provider<ExpensesRepository>((ref) {
  return ExpensesRepository();
});

/// Provider for AI service
final aiServiceForJournalProvider = Provider<AIService>((ref) {
  return AIService();
});

/// Data class to hold day context for journal generation
class JournalDayContext {
  final List<ChatMessageModel> chatMessages;
  final List<ExpenseModel> expenses;
  final DateTime date;
  final String? tripDestination;

  const JournalDayContext({
    required this.chatMessages,
    required this.expenses,
    required this.date,
    this.tripDestination,
  });

  bool get hasData => chatMessages.isNotEmpty || expenses.isNotEmpty;

  /// Get chat messages as AI service format
  List<ChatMessage> get chatMessagesForAI {
    return chatMessages.map((m) => ChatMessage(
      role: m.role,
      content: m.content,
    )).toList();
  }

  /// Get expenses as parsed expenses for AI service
  List<ParsedExpense> get expensesForAI {
    return expenses.map((e) => ParsedExpense(
      amount: e.amount,
      currency: e.currency,
      category: e.category,
      description: e.description,
      date: e.expenseDate ?? DateTime.now(),
    )).toList();
  }
}

/// Provider to fetch day context (chat + expenses) for journal generation
final journalDayContextProvider = FutureProvider.family<JournalDayContext, ({String tripId, DateTime date})>(
  (ref, params) async {
    final chatRepo = ref.watch(chatRepositoryProvider);
    final expensesRepo = ref.watch(expensesRepositoryForJournalProvider);

    // Get trip for destination
    final tripAsync = ref.watch(tripByIdProvider(params.tripId));
    String? destination;
    tripAsync.whenData((trip) {
      destination = trip?.destination;
    });

    // Fetch chat messages and expenses for the date in parallel
    final results = await Future.wait([
      chatRepo.getTripMessagesByDate(params.tripId, params.date),
      expensesRepo.getExpensesByDate(params.tripId, params.date),
    ]);

    return JournalDayContext(
      chatMessages: results[0] as List<ChatMessageModel>,
      expenses: results[1] as List<ExpenseModel>,
      date: params.date,
      tripDestination: destination,
    );
  },
);

/// Provider to auto-generate a journal entry from day data
/// Returns the generated content, caller should save it
final autoGenerateJournalProvider = FutureProvider.family<GeneratedJournalContent?, ({String tripId, DateTime date})>(
  (ref, params) async {
    final dayContext = await ref.watch(journalDayContextProvider(params).future);

    if (!dayContext.hasData) {
      return null;
    }

    final aiService = ref.watch(aiServiceForJournalProvider);

    try {
      final generatedContent = await aiService.generateJournalEntry(
        chatMessages: dayContext.chatMessagesForAI,
        date: dayContext.date,
        tripDestination: dayContext.tripDestination,
        expenses: dayContext.expensesForAI,
      );

      return generatedContent;
    } catch (e) {
      return null;
    }
  },
);

// ============================================
// AUTO JOURNAL GENERATION PROVIDERS
// ============================================

/// Provider for JournalAutoGenerator service
final journalAutoGeneratorProvider = Provider<JournalAutoGenerator>((ref) {
  return JournalAutoGenerator();
});

/// Provider that triggers auto-generation for the active trip
/// This should be watched on app startup (home screen)
/// Returns null if no active trip, or the generation result
final journalAutoGenResultProvider = FutureProvider.autoDispose<AutoGenResult?>((ref) async {
  final generator = ref.watch(journalAutoGeneratorProvider);
  return generator.generateForActiveTrip();
});

/// State provider to track if the journal ready notification has been dismissed
final journalNotificationDismissedProvider = StateProvider<bool>((ref) => false);

/// Provider to check if we should show the "Journal Ready" notification card
/// Returns true if:
/// - Auto-generation just completed
/// - Trip just ended (within last 7 days)
/// - Generated at least 1 entry
/// - User hasn't dismissed the notification
final shouldShowJournalReadyProvider = Provider<bool>((ref) {
  final dismissed = ref.watch(journalNotificationDismissedProvider);
  if (dismissed) return false;

  final resultAsync = ref.watch(journalAutoGenResultProvider);
  return resultAsync.maybeWhen(
    data: (result) => result?.shouldShowNotification ?? false,
    orElse: () => false,
  );
});

/// Provider to get the auto-gen result data (for showing in UI)
final journalReadyDataProvider = Provider<AutoGenResult?>((ref) {
  final resultAsync = ref.watch(journalAutoGenResultProvider);
  return resultAsync.maybeWhen(
    data: (result) => result,
    orElse: () => null,
  );
});

/// Provider to dismiss the journal ready notification
final dismissJournalNotificationProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(journalNotificationDismissedProvider.notifier).state = true;
  };
});

/// Provider to manually refresh/re-run auto journal generation
final refreshAutoJournalProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(journalAutoGenResultProvider);
    ref.read(journalNotificationDismissedProvider.notifier).state = false;
  };
});

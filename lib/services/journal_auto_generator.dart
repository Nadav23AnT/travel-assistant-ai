import 'package:flutter/foundation.dart';

import '../data/models/trip_model.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/expenses_repository.dart';
import '../data/repositories/journal_repository.dart';
import '../data/repositories/trips_repository.dart';
import 'ai_service.dart';

/// Result of auto journal generation
class AutoGenResult {
  final int generatedCount;
  final int skippedCount;
  final List<String> errors;
  final bool tripJustEnded;
  final TripModel? trip;

  const AutoGenResult({
    required this.generatedCount,
    required this.skippedCount,
    required this.errors,
    required this.tripJustEnded,
    this.trip,
  });

  bool get hasGeneratedEntries => generatedCount > 0;
  bool get shouldShowNotification => tripJustEnded && generatedCount > 0;
}

/// Service to automatically generate journal entries for trips
class JournalAutoGenerator {
  final AIService _aiService;
  final JournalRepository _journalRepository;
  final ChatRepository _chatRepository;
  final ExpensesRepository _expensesRepository;
  final TripsRepository _tripsRepository;

  JournalAutoGenerator({
    AIService? aiService,
    JournalRepository? journalRepository,
    ChatRepository? chatRepository,
    ExpensesRepository? expensesRepository,
    TripsRepository? tripsRepository,
  })  : _aiService = aiService ?? AIService(),
        _journalRepository = journalRepository ?? JournalRepository(),
        _chatRepository = chatRepository ?? ChatRepository(),
        _expensesRepository = expensesRepository ?? ExpensesRepository(),
        _tripsRepository = tripsRepository ?? TripsRepository();

  /// Generate missing journal entries for the active trip
  ///
  /// This method:
  /// 1. Gets the active trip
  /// 2. Determines which days are missing journal entries
  /// 3. For each missing day with activity, generates and saves an entry
  /// 4. Returns the result with count of generated entries
  Future<AutoGenResult?> generateForActiveTrip() async {
    try {
      final trip = await _tripsRepository.getActiveTrip();
      if (trip == null) {
        debugPrint('JournalAutoGenerator: No active trip found');
        return null;
      }

      return generateMissingEntries(trip);
    } catch (e) {
      debugPrint('JournalAutoGenerator: Error getting active trip: $e');
      return null;
    }
  }

  /// Generate missing journal entries for a specific trip
  Future<AutoGenResult> generateMissingEntries(TripModel trip) async {
    final errors = <String>[];
    int generatedCount = 0;
    int skippedCount = 0;

    try {
      // Determine date range
      final startDate = trip.startDate;
      final endDate = trip.endDate;

      if (startDate == null) {
        debugPrint('JournalAutoGenerator: Trip has no start date');
        return AutoGenResult(
          generatedCount: 0,
          skippedCount: 0,
          errors: ['Trip has no start date'],
          tripJustEnded: false,
          trip: trip,
        );
      }

      // Calculate end of range: min(trip end date, today)
      final today = DateTime.now();
      final yesterday = DateTime(today.year, today.month, today.day - 1);
      final rangeEnd = endDate != null && endDate.isBefore(yesterday)
          ? endDate
          : yesterday;

      // Check if trip just ended (end date was yesterday or before)
      final tripJustEnded = endDate != null &&
          endDate.isBefore(today) &&
          endDate.isAfter(today.subtract(const Duration(days: 7)));

      // Get existing journal entries for this trip
      final existingEntries = await _journalRepository.getTripJournalEntries(trip.id);
      final existingDates = existingEntries
          .map((e) => _normalizeDate(e.entryDate))
          .toSet();

      // Iterate through each day in the range
      DateTime currentDate = startDate;
      while (!currentDate.isAfter(rangeEnd)) {
        final normalizedDate = _normalizeDate(currentDate);

        // Skip if entry already exists
        if (existingDates.contains(normalizedDate)) {
          currentDate = currentDate.add(const Duration(days: 1));
          continue;
        }

        // Try to generate entry for this day
        final result = await _generateEntryForDay(trip, currentDate);

        if (result == _GenerationResult.generated) {
          generatedCount++;
          // Add delay between API calls to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 500));
        } else if (result == _GenerationResult.skipped) {
          skippedCount++;
        } else if (result == _GenerationResult.error) {
          errors.add('Failed to generate entry for ${currentDate.toIso8601String().split('T').first}');
        }

        currentDate = currentDate.add(const Duration(days: 1));
      }

      debugPrint('JournalAutoGenerator: Generated $generatedCount entries, skipped $skippedCount days');

      return AutoGenResult(
        generatedCount: generatedCount,
        skippedCount: skippedCount,
        errors: errors,
        tripJustEnded: tripJustEnded,
        trip: trip,
      );
    } catch (e) {
      debugPrint('JournalAutoGenerator: Error generating entries: $e');
      return AutoGenResult(
        generatedCount: generatedCount,
        skippedCount: skippedCount,
        errors: [...errors, e.toString()],
        tripJustEnded: false,
        trip: trip,
      );
    }
  }

  /// Generate a single journal entry for a specific day
  Future<_GenerationResult> _generateEntryForDay(TripModel trip, DateTime date) async {
    try {
      // Fetch chat messages and expenses for this day
      final messages = await _chatRepository.getTripMessagesByDate(trip.id, date);
      final expenses = await _expensesRepository.getExpensesByDate(trip.id, date);

      // Skip if no activity
      if (messages.isEmpty && expenses.isEmpty) {
        debugPrint('JournalAutoGenerator: No activity for ${date.toIso8601String().split('T').first}');
        return _GenerationResult.skipped;
      }

      debugPrint('JournalAutoGenerator: Generating for ${date.toIso8601String().split('T').first} '
          '(${messages.length} messages, ${expenses.length} expenses)');

      // Convert messages to AI format
      final chatMessages = messages.map((m) => ChatMessage(
        role: m.role,
        content: m.content,
      )).toList();

      // Convert expenses to AI format
      final parsedExpenses = expenses.map((e) => ParsedExpense(
        amount: e.amount,
        currency: e.currency,
        description: e.description,
        category: e.category,
        date: e.expenseDate ?? DateTime.now(),
      )).toList();

      // Generate journal content via AI
      final generated = await _aiService.generateJournalEntry(
        chatMessages: chatMessages,
        date: date,
        tripDestination: trip.destination,
        expenses: parsedExpenses,
      );

      // Save the entry
      await _journalRepository.createJournalEntry(
        tripId: trip.id,
        entryDate: date,
        content: generated.content,
        title: generated.title,
        aiGenerated: true,
        mood: generated.mood,
        highlights: generated.highlights,
        locations: generated.locations,
        sourceData: {
          'chatMessageIds': messages.map((m) => m.id).toList(),
          'expenseIds': expenses.map((e) => e.id).toList(),
          'autoGenerated': true,
          'generatedAt': DateTime.now().toIso8601String(),
        },
      );

      return _GenerationResult.generated;
    } catch (e) {
      debugPrint('JournalAutoGenerator: Error generating entry for $date: $e');
      return _GenerationResult.error;
    }
  }

  /// Normalize a DateTime to just the date (no time component)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

enum _GenerationResult {
  generated,
  skipped,
  error,
}

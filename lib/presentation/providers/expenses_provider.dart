import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/expense_model.dart';
import '../../data/models/expense_stats.dart';
import '../../data/models/trip_model.dart';
import '../../data/repositories/expenses_repository.dart';
import 'currency_provider.dart';
import 'trips_provider.dart';

// ============================================
// REPOSITORY PROVIDER
// ============================================

/// Expenses Repository provider
final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return ExpensesRepository();
});

// ============================================
// DATA PROVIDERS
// ============================================

/// Provider to fetch all expenses for the current user
final userExpensesProvider = FutureProvider<List<ExpenseModel>>((ref) async {
  final repository = ref.watch(expensesRepositoryProvider);
  return repository.getUserExpenses();
});

/// Provider to fetch expenses for a specific trip
final tripExpensesProvider =
    FutureProvider.family<List<ExpenseModel>, String>((ref, tripId) async {
  final repository = ref.watch(expensesRepositoryProvider);
  return repository.getTripExpenses(tripId);
});

/// Provider to fetch a specific expense by ID
final expenseByIdProvider =
    FutureProvider.family<ExpenseModel?, String>((ref, expenseId) async {
  final repository = ref.watch(expensesRepositoryProvider);
  return repository.getExpense(expenseId);
});

/// Provider to fetch recent expenses
final recentExpensesProvider =
    FutureProvider.family<List<ExpenseModel>, int>((ref, limit) async {
  final repository = ref.watch(expensesRepositoryProvider);
  return repository.getRecentExpenses(limit: limit);
});

/// Default recent expenses (last 5)
final defaultRecentExpensesProvider =
    FutureProvider<List<ExpenseModel>>((ref) async {
  final repository = ref.watch(expensesRepositoryProvider);
  return repository.getRecentExpenses(limit: 5);
});

// ============================================
// AGGREGATION PROVIDERS
// ============================================

/// Provider to get total expenses for a trip by currency
final tripExpenseTotalsProvider =
    FutureProvider.family<Map<String, double>, String>((ref, tripId) async {
  final repository = ref.watch(expensesRepositoryProvider);
  return repository.getTripExpenseTotals(tripId);
});

/// Provider to get expenses grouped by category for a trip
final tripExpensesByCategoryProvider =
    FutureProvider.family<Map<String, double>, String>((ref, tripId) async {
  final repository = ref.watch(expensesRepositoryProvider);
  return repository.getExpensesByCategories(tripId);
});

// ============================================
// REFRESH PROVIDER
// ============================================

/// Provider to refresh expenses data
final expensesRefreshProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(userExpensesProvider);
    ref.invalidate(defaultRecentExpensesProvider);
  };
});

/// Provider to refresh expenses for a specific trip
final tripExpensesRefreshProvider =
    Provider.family<void Function(), String>((ref, tripId) {
  return () {
    ref.invalidate(tripExpensesProvider(tripId));
    ref.invalidate(tripExpenseTotalsProvider(tripId));
    ref.invalidate(tripExpensesByCategoryProvider(tripId));
    ref.invalidate(userExpensesProvider);
    ref.invalidate(defaultRecentExpensesProvider);
  };
});

// ============================================
// STATE NOTIFIER FOR EXPENSE OPERATIONS
// ============================================

/// State for expense operations
class ExpenseOperationState {
  final bool isLoading;
  final String? error;
  final ExpenseModel? lastCreatedExpense;

  const ExpenseOperationState({
    this.isLoading = false,
    this.error,
    this.lastCreatedExpense,
  });

  ExpenseOperationState copyWith({
    bool? isLoading,
    String? error,
    ExpenseModel? lastCreatedExpense,
    bool clearError = false,
  }) {
    return ExpenseOperationState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastCreatedExpense: lastCreatedExpense ?? this.lastCreatedExpense,
    );
  }
}

/// Notifier for expense operations (create, update, delete)
class ExpenseOperationNotifier extends StateNotifier<ExpenseOperationState> {
  final ExpensesRepository _repository;
  final Ref _ref;

  ExpenseOperationNotifier(this._repository, this._ref)
      : super(const ExpenseOperationState());

  /// Create a new expense
  Future<ExpenseModel?> createExpense({
    required String tripId,
    required double amount,
    required String currency,
    required String category,
    required String description,
    DateTime? expenseDate,
    String? receiptUrl,
    bool isSplit = false,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final expense = await _repository.createExpense(
        tripId: tripId,
        amount: amount,
        currency: currency,
        category: category,
        description: description,
        expenseDate: expenseDate,
        receiptUrl: receiptUrl,
        isSplit: isSplit,
        notes: notes,
      );

      state = state.copyWith(
        isLoading: false,
        lastCreatedExpense: expense,
      );

      // Refresh providers
      _ref.read(tripExpensesRefreshProvider(tripId))();

      return expense;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Update an expense
  Future<ExpenseModel?> updateExpense(
    String expenseId,
    String tripId,
    Map<String, dynamic> updates,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final expense = await _repository.updateExpense(expenseId, updates);
      state = state.copyWith(isLoading: false);

      // Refresh providers
      _ref.read(tripExpensesRefreshProvider(tripId))();
      _ref.invalidate(expenseByIdProvider(expenseId));

      return expense;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Delete an expense
  Future<bool> deleteExpense(String expenseId, String tripId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.deleteExpense(expenseId);
      state = state.copyWith(isLoading: false);

      // Refresh providers
      _ref.read(tripExpensesRefreshProvider(tripId))();

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for expense operations
final expenseOperationProvider =
    StateNotifierProvider<ExpenseOperationNotifier, ExpenseOperationState>(
        (ref) {
  final repository = ref.watch(expensesRepositoryProvider);
  return ExpenseOperationNotifier(repository, ref);
});

// ============================================
// DASHBOARD PROVIDERS
// ============================================

/// Toggle for showing amounts in home currency vs local currency
final showInHomeCurrencyProvider = StateProvider<bool>((ref) => true);

/// User-selected trip for expenses dashboard (null = use default)
final selectedExpensesTripIdProvider = StateProvider<String?>((ref) => null);

/// Effective trip ID - uses user selection if set, otherwise defaults to active trip
final effectiveTripIdProvider = Provider<String?>((ref) {
  final userSelection = ref.watch(selectedExpensesTripIdProvider);
  if (userSelection != null) {
    return userSelection;
  }
  // Default to active trip
  final activeTrip = ref.watch(activeTripProvider);
  return activeTrip.valueOrNull?.id;
});

/// Combined dashboard data provider
class ExpensesDashboardData {
  final List<ExpenseModel> expenses;
  final ExpenseStats stats;
  final List<CategoryTotal> categoryTotals;
  final List<DailySpending> dailySpending;
  final TripModel? trip;
  final String displayCurrency;

  const ExpensesDashboardData({
    required this.expenses,
    required this.stats,
    required this.categoryTotals,
    required this.dailySpending,
    this.trip,
    required this.displayCurrency,
  });
}

/// Main dashboard data provider
final expensesDashboardProvider =
    FutureProvider<ExpensesDashboardData>((ref) async {
  final tripId = ref.watch(effectiveTripIdProvider);
  final showInHome = ref.watch(showInHomeCurrencyProvider);
  final homeCurrency = ref.watch(userHomeCurrencyProvider);
  // Watch exchange rates so we rebuild when they change (rates loaded via home_screen)
  ref.watch(exchangeRatesProvider);
  final repository = ref.watch(expensesRepositoryProvider);

  // Get trip info if selected
  TripModel? trip;
  if (tripId != null) {
    trip = await ref.watch(tripByIdProvider(tripId).future);
  }

  // Get expenses
  List<ExpenseModel> expenses;
  if (tripId != null) {
    expenses = await repository.getTripExpenses(tripId);
  } else {
    expenses = await repository.getUserExpenses();
  }

  // Determine display currency
  final displayCurrency = showInHome ? homeCurrency : _getPrimaryCurrency(expenses);

  // Currency conversion function
  double convertAmount(double amount, String fromCurrency) {
    if (!showInHome || fromCurrency == homeCurrency) {
      return amount;
    }
    return ref.read(exchangeRatesProvider.notifier).convert(
          amount,
          fromCurrency,
          homeCurrency,
        );
  }

  // Compute stats
  final stats = ExpenseStats.compute(
    expenses: expenses,
    displayCurrency: displayCurrency,
    convertAmount: convertAmount,
    tripStartDate: trip?.startDate,
    tripEndDate: trip?.endDate,
  );

  // Compute category totals
  final categoryTotals = expenses.computeCategoryTotals(
    displayCurrency,
    convertAmount,
  );

  // Compute daily spending
  final dailySpending = expenses.computeDailySpending(
    displayCurrency,
    convertAmount,
  );

  return ExpensesDashboardData(
    expenses: expenses,
    stats: stats,
    categoryTotals: categoryTotals,
    dailySpending: dailySpending,
    trip: trip,
    displayCurrency: displayCurrency,
  );
});

/// Provider for expenses in a specific category
final expensesByCategoryProvider =
    Provider.family<List<ExpenseModel>, String>((ref, category) {
  final dashboardData = ref.watch(expensesDashboardProvider);
  return dashboardData.when(
    data: (data) =>
        data.expenses.where((e) => e.category == category).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});

/// Refresh all expense dashboard data
final expensesDashboardRefreshProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final tripId = ref.read(effectiveTripIdProvider);
    if (tripId != null) {
      ref.invalidate(tripExpensesProvider(tripId));
      ref.invalidate(tripExpenseTotalsProvider(tripId));
      ref.invalidate(tripExpensesByCategoryProvider(tripId));
    }
    ref.invalidate(userExpensesProvider);
    ref.invalidate(expensesDashboardProvider);
  };
});

/// Helper to get primary currency from expenses
String _getPrimaryCurrency(List<ExpenseModel> expenses) {
  if (expenses.isEmpty) return 'USD';

  final currencyCounts = <String, int>{};
  for (final expense in expenses) {
    currencyCounts[expense.currency] =
        (currencyCounts[expense.currency] ?? 0) + 1;
  }

  String primaryCurrency = 'USD';
  int maxCount = 0;
  for (final entry in currencyCounts.entries) {
    if (entry.value > maxCount) {
      maxCount = entry.value;
      primaryCurrency = entry.key;
    }
  }

  return primaryCurrency;
}

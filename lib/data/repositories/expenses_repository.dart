import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/expense_model.dart';
import '../models/expense_split_model.dart';

class ExpensesRepositoryException implements Exception {
  final String message;

  ExpensesRepositoryException(this.message);

  @override
  String toString() => message;
}

class ExpensesRepository {
  final SupabaseClient _supabase;

  ExpensesRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  // ============================================
  // READ OPERATIONS
  // ============================================

  /// Get all expenses for a specific trip
  Future<List<ExpenseModel>> getTripExpenses(String tripId) async {
    try {
      final response = await _supabase
          .from('expenses')
          .select()
          .eq('trip_id', tripId)
          .order('expense_date', ascending: false);

      return (response as List)
          .map((json) => ExpenseModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching trip expenses: $e');
      throw ExpensesRepositoryException('Failed to fetch expenses');
    }
  }

  /// Get all expenses for the current user across all trips
  Future<List<ExpenseModel>> getUserExpenses() async {
    if (_currentUserId == null) {
      throw ExpensesRepositoryException('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('expenses')
          .select()
          .eq('paid_by', _currentUserId!)
          .order('expense_date', ascending: false);

      return (response as List)
          .map((json) => ExpenseModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching user expenses: $e');
      throw ExpensesRepositoryException('Failed to fetch expenses');
    }
  }

  /// Get a specific expense by ID
  Future<ExpenseModel?> getExpense(String expenseId) async {
    try {
      final response = await _supabase
          .from('expenses')
          .select()
          .eq('id', expenseId)
          .maybeSingle();

      if (response == null) return null;
      return ExpenseModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching expense: $e');
      throw ExpensesRepositoryException('Failed to fetch expense');
    }
  }

  /// Get expenses by category for a trip
  Future<List<ExpenseModel>> getExpensesByCategory(
    String tripId,
    String category,
  ) async {
    try {
      final response = await _supabase
          .from('expenses')
          .select()
          .eq('trip_id', tripId)
          .eq('category', category)
          .order('expense_date', ascending: false);

      return (response as List)
          .map((json) => ExpenseModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching expenses by category: $e');
      throw ExpensesRepositoryException('Failed to fetch expenses');
    }
  }

  /// Get recent expenses (last N)
  Future<List<ExpenseModel>> getRecentExpenses({int limit = 5}) async {
    if (_currentUserId == null) {
      throw ExpensesRepositoryException('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('expenses')
          .select()
          .eq('paid_by', _currentUserId!)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => ExpenseModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching recent expenses: $e');
      throw ExpensesRepositoryException('Failed to fetch expenses');
    }
  }

  /// Get total expenses for a trip
  Future<Map<String, double>> getTripExpenseTotals(String tripId) async {
    try {
      final expenses = await getTripExpenses(tripId);

      final totals = <String, double>{};
      for (final expense in expenses) {
        final currency = expense.currency;
        totals[currency] = (totals[currency] ?? 0) + expense.amount;
      }

      return totals;
    } catch (e) {
      debugPrint('Error calculating expense totals: $e');
      throw ExpensesRepositoryException('Failed to calculate totals');
    }
  }

  /// Get expenses grouped by category for a trip
  Future<Map<String, double>> getExpensesByCategories(String tripId) async {
    try {
      final expenses = await getTripExpenses(tripId);

      final categoryTotals = <String, double>{};
      for (final expense in expenses) {
        categoryTotals[expense.category] =
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }

      return categoryTotals;
    } catch (e) {
      debugPrint('Error calculating category totals: $e');
      throw ExpensesRepositoryException('Failed to calculate category totals');
    }
  }

  /// Get expenses grouped by date for daily spending chart
  Future<Map<DateTime, List<ExpenseModel>>> getDailySpendingData(
      String tripId) async {
    try {
      final expenses = await getTripExpenses(tripId);

      final grouped = <DateTime, List<ExpenseModel>>{};
      for (final expense in expenses) {
        if (expense.expenseDate != null) {
          final dateKey = DateTime(
            expense.expenseDate!.year,
            expense.expenseDate!.month,
            expense.expenseDate!.day,
          );
          grouped.putIfAbsent(dateKey, () => []).add(expense);
        }
      }

      return grouped;
    } catch (e) {
      debugPrint('Error fetching daily spending data: $e');
      throw ExpensesRepositoryException('Failed to fetch daily spending data');
    }
  }

  /// Get expenses for a specific date range
  Future<List<ExpenseModel>> getExpensesByDateRange(
    String tripId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabase
          .from('expenses')
          .select()
          .eq('trip_id', tripId)
          .gte('expense_date', startDate.toIso8601String().split('T').first)
          .lte('expense_date', endDate.toIso8601String().split('T').first)
          .order('expense_date', ascending: false);

      return (response as List)
          .map((json) => ExpenseModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching expenses by date range: $e');
      throw ExpensesRepositoryException('Failed to fetch expenses');
    }
  }

  /// Get expenses for a specific date (for journal generation)
  Future<List<ExpenseModel>> getExpensesByDate(
    String tripId,
    DateTime date,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T').first;
      final response = await _supabase
          .from('expenses')
          .select()
          .eq('trip_id', tripId)
          .eq('expense_date', dateStr)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => ExpenseModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching expenses by date: $e');
      return [];
    }
  }

  // ============================================
  // WRITE OPERATIONS
  // ============================================

  /// Create a new expense
  Future<ExpenseModel> createExpense({
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
    if (_currentUserId == null) {
      throw ExpensesRepositoryException('User not authenticated');
    }

    try {
      final response = await _supabase.from('expenses').insert({
        'trip_id': tripId,
        'paid_by': _currentUserId,
        'amount': amount,
        'currency': currency,
        'category': category,
        'description': description,
        'expense_date': expenseDate?.toIso8601String().split('T').first ??
            DateTime.now().toIso8601String().split('T').first,
        'receipt_url': receiptUrl,
        'is_split': isSplit,
        'notes': notes,
      }).select().single();

      return ExpenseModel.fromJson(response);
    } catch (e) {
      debugPrint('Error creating expense: $e');
      throw ExpensesRepositoryException('Failed to create expense');
    }
  }

  /// Update an existing expense
  Future<ExpenseModel> updateExpense(
    String expenseId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('expenses')
          .update(updates)
          .eq('id', expenseId)
          .select()
          .single();

      return ExpenseModel.fromJson(response);
    } catch (e) {
      debugPrint('Error updating expense: $e');
      throw ExpensesRepositoryException('Failed to update expense');
    }
  }

  /// Delete an expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _supabase.from('expenses').delete().eq('id', expenseId);
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      throw ExpensesRepositoryException('Failed to delete expense');
    }
  }

  /// Bulk delete expenses for a trip
  Future<void> deleteAllTripExpenses(String tripId) async {
    try {
      await _supabase.from('expenses').delete().eq('trip_id', tripId);
    } catch (e) {
      debugPrint('Error deleting trip expenses: $e');
      throw ExpensesRepositoryException('Failed to delete expenses');
    }
  }

  // ============================================
  // EXPENSE SPLITS OPERATIONS
  // ============================================

  /// Get all splits for an expense
  Future<List<ExpenseSplitModel>> getExpenseSplits(String expenseId) async {
    try {
      final response = await _supabase
          .from('expense_splits')
          .select('''
            *,
            profiles:user_id (
              full_name,
              avatar_url,
              email
            )
          ''')
          .eq('expense_id', expenseId)
          .order('created_at');

      return (response as List)
          .map((json) => ExpenseSplitModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching expense splits: $e');
      throw ExpensesRepositoryException('Failed to fetch expense splits');
    }
  }

  /// Get all splits where the current user owes money
  Future<List<ExpenseSplitModel>> getUserOwedSplits() async {
    if (_currentUserId == null) {
      throw ExpensesRepositoryException('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('expense_splits')
          .select('''
            *,
            profiles:user_id (
              full_name,
              avatar_url,
              email
            )
          ''')
          .eq('user_id', _currentUserId!)
          .eq('is_settled', false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ExpenseSplitModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching user owed splits: $e');
      throw ExpensesRepositoryException('Failed to fetch splits');
    }
  }

  /// Create expense splits for multiple users
  Future<List<ExpenseSplitModel>> createExpenseSplits({
    required String expenseId,
    required List<Map<String, dynamic>> splits,
  }) async {
    try {
      final splitsWithExpenseId = splits.map((split) => {
            ...split,
            'expense_id': expenseId,
          }).toList();

      final response = await _supabase
          .from('expense_splits')
          .insert(splitsWithExpenseId)
          .select('''
            *,
            profiles:user_id (
              full_name,
              avatar_url,
              email
            )
          ''');

      return (response as List)
          .map((json) => ExpenseSplitModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error creating expense splits: $e');
      throw ExpensesRepositoryException('Failed to create expense splits');
    }
  }

  /// Create a single expense split
  Future<ExpenseSplitModel> createExpenseSplit({
    required String expenseId,
    required String userId,
    required double amount,
  }) async {
    try {
      final response = await _supabase.from('expense_splits').insert({
        'expense_id': expenseId,
        'user_id': userId,
        'amount': amount,
        'is_settled': false,
      }).select('''
            *,
            profiles:user_id (
              full_name,
              avatar_url,
              email
            )
          ''').single();

      return ExpenseSplitModel.fromJson(response);
    } catch (e) {
      debugPrint('Error creating expense split: $e');
      throw ExpensesRepositoryException('Failed to create expense split');
    }
  }

  /// Mark a split as settled
  Future<ExpenseSplitModel> markSplitAsSettled(String splitId) async {
    try {
      final response = await _supabase
          .from('expense_splits')
          .update({
            'is_settled': true,
            'settled_at': DateTime.now().toIso8601String(),
          })
          .eq('id', splitId)
          .select('''
            *,
            profiles:user_id (
              full_name,
              avatar_url,
              email
            )
          ''')
          .single();

      return ExpenseSplitModel.fromJson(response);
    } catch (e) {
      debugPrint('Error marking split as settled: $e');
      throw ExpensesRepositoryException('Failed to settle split');
    }
  }

  /// Mark a split as unsettled
  Future<ExpenseSplitModel> markSplitAsUnsettled(String splitId) async {
    try {
      final response = await _supabase
          .from('expense_splits')
          .update({
            'is_settled': false,
            'settled_at': null,
          })
          .eq('id', splitId)
          .select('''
            *,
            profiles:user_id (
              full_name,
              avatar_url,
              email
            )
          ''')
          .single();

      return ExpenseSplitModel.fromJson(response);
    } catch (e) {
      debugPrint('Error unsettling split: $e');
      throw ExpensesRepositoryException('Failed to unsettle split');
    }
  }

  /// Delete all splits for an expense
  Future<void> deleteExpenseSplits(String expenseId) async {
    try {
      await _supabase
          .from('expense_splits')
          .delete()
          .eq('expense_id', expenseId);
    } catch (e) {
      debugPrint('Error deleting expense splits: $e');
      throw ExpensesRepositoryException('Failed to delete expense splits');
    }
  }

  /// Get trip balances using the database function
  Future<List<MemberBalanceModel>> getTripBalances(String tripId) async {
    try {
      final response = await _supabase.rpc(
        'get_trip_balances',
        params: {'p_trip_id': tripId},
      );

      return (response as List)
          .map((json) => MemberBalanceModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching trip balances: $e');
      throw ExpensesRepositoryException('Failed to fetch trip balances');
    }
  }

  /// Get all unsettled splits for a trip
  Future<List<ExpenseSplitModel>> getTripUnsettledSplits(String tripId) async {
    try {
      final response = await _supabase
          .from('expense_splits')
          .select('''
            *,
            profiles:user_id (
              full_name,
              avatar_url,
              email
            ),
            expenses!inner (
              trip_id,
              paid_by,
              description,
              amount,
              currency
            )
          ''')
          .eq('expenses.trip_id', tripId)
          .eq('is_settled', false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ExpenseSplitModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching trip unsettled splits: $e');
      throw ExpensesRepositoryException('Failed to fetch unsettled splits');
    }
  }

  /// Create expense with splits in a transaction
  Future<ExpenseModel> createExpenseWithSplits({
    required String tripId,
    required double amount,
    required String currency,
    required String category,
    required String description,
    required List<String> splitWithUserIds,
    DateTime? expenseDate,
    String? receiptUrl,
    String? notes,
    bool equalSplit = true,
    Map<String, double>? customAmounts,
  }) async {
    if (_currentUserId == null) {
      throw ExpensesRepositoryException('User not authenticated');
    }

    try {
      // Create the expense first
      final expense = await createExpense(
        tripId: tripId,
        amount: amount,
        currency: currency,
        category: category,
        description: description,
        expenseDate: expenseDate,
        receiptUrl: receiptUrl,
        isSplit: splitWithUserIds.isNotEmpty,
        notes: notes,
      );

      // If there are users to split with, create the splits
      if (splitWithUserIds.isNotEmpty) {
        final splits = <Map<String, dynamic>>[];

        if (equalSplit) {
          // Equal split among all users (excluding the payer)
          final splitAmount = amount / (splitWithUserIds.length + 1);
          for (final userId in splitWithUserIds) {
            splits.add({
              'user_id': userId,
              'amount': splitAmount,
            });
          }
        } else if (customAmounts != null) {
          // Custom amounts per user
          for (final userId in splitWithUserIds) {
            if (customAmounts.containsKey(userId)) {
              splits.add({
                'user_id': userId,
                'amount': customAmounts[userId]!,
              });
            }
          }
        }

        if (splits.isNotEmpty) {
          await createExpenseSplits(
            expenseId: expense.id,
            splits: splits,
          );
        }
      }

      return expense;
    } catch (e) {
      debugPrint('Error creating expense with splits: $e');
      throw ExpensesRepositoryException('Failed to create expense with splits');
    }
  }
}

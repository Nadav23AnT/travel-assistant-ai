import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/expense_model.dart';

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
}

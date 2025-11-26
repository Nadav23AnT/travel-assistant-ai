import 'package:flutter/material.dart';

import '../../config/theme.dart';
import '../../utils/country_currency_helper.dart';
import 'expense_model.dart';

/// Represents computed statistics for expenses
class ExpenseStats {
  final double totalSpent;
  final double dailyAverage;
  final double estimatedTripTotal;
  final String displayCurrency;
  final int totalExpenseCount;
  final int tripDays;
  final int elapsedDays;
  final int remainingDays;

  const ExpenseStats({
    required this.totalSpent,
    required this.dailyAverage,
    required this.estimatedTripTotal,
    required this.displayCurrency,
    required this.totalExpenseCount,
    required this.tripDays,
    required this.elapsedDays,
    required this.remainingDays,
  });

  /// Create empty stats
  factory ExpenseStats.empty(String currency) {
    return ExpenseStats(
      totalSpent: 0,
      dailyAverage: 0,
      estimatedTripTotal: 0,
      displayCurrency: currency,
      totalExpenseCount: 0,
      tripDays: 0,
      elapsedDays: 0,
      remainingDays: 0,
    );
  }

  /// Compute stats from a list of expenses
  /// [convertAmount] is a function to convert expense amount to display currency
  factory ExpenseStats.compute({
    required List<ExpenseModel> expenses,
    required String displayCurrency,
    required double Function(double amount, String fromCurrency) convertAmount,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
  }) {
    if (expenses.isEmpty) {
      return ExpenseStats.empty(displayCurrency);
    }

    // Calculate total in display currency
    double total = 0;
    for (final expense in expenses) {
      total += convertAmount(expense.amount, expense.currency);
    }

    // Calculate trip duration info
    final now = DateTime.now();
    int tripDays = 0;
    int elapsedDays = 0;
    int remainingDays = 0;

    if (tripStartDate != null && tripEndDate != null) {
      tripDays = tripEndDate.difference(tripStartDate).inDays + 1;

      if (now.isBefore(tripStartDate)) {
        elapsedDays = 0;
        remainingDays = tripDays;
      } else if (now.isAfter(tripEndDate)) {
        elapsedDays = tripDays;
        remainingDays = 0;
      } else {
        elapsedDays = now.difference(tripStartDate).inDays + 1;
        remainingDays = tripEndDate.difference(now).inDays;
      }
    } else {
      // If no trip dates, calculate from expense dates
      final dates = expenses
          .where((e) => e.expenseDate != null)
          .map((e) => e.expenseDate!)
          .toList();
      if (dates.isNotEmpty) {
        dates.sort();
        elapsedDays = dates.last.difference(dates.first).inDays + 1;
        tripDays = elapsedDays;
      } else {
        elapsedDays = 1;
        tripDays = 1;
      }
    }

    // Calculate daily average
    final dailyAverage = elapsedDays > 0 ? total / elapsedDays : total;

    // Estimate trip total
    final estimatedTotal = tripDays > 0 ? dailyAverage * tripDays : total;

    return ExpenseStats(
      totalSpent: total,
      dailyAverage: dailyAverage,
      estimatedTripTotal: estimatedTotal,
      displayCurrency: displayCurrency,
      totalExpenseCount: expenses.length,
      tripDays: tripDays,
      elapsedDays: elapsedDays,
      remainingDays: remainingDays,
    );
  }

  /// Get formatted total with currency symbol
  String get formattedTotal => _formatCurrency(totalSpent, displayCurrency);

  /// Get formatted daily average with currency symbol
  String get formattedDailyAverage =>
      _formatCurrency(dailyAverage, displayCurrency);

  /// Get formatted estimated total with currency symbol
  String get formattedEstimatedTotal =>
      _formatCurrency(estimatedTripTotal, displayCurrency);

  static String _formatCurrency(double amount, String currency) {
    // Use the centralized helper for currency symbols
    return CountryCurrencyHelper.formatAmount(amount, currency);
  }
}

/// Represents daily spending data for charts
class DailySpending {
  final DateTime date;
  final double amount;
  final String currency;

  const DailySpending({
    required this.date,
    required this.amount,
    required this.currency,
  });

  /// Create from a list of expenses on the same date
  factory DailySpending.fromExpenses(
    DateTime date,
    List<ExpenseModel> expenses,
    String displayCurrency,
    double Function(double amount, String fromCurrency) convertAmount,
  ) {
    double total = 0;
    for (final expense in expenses) {
      total += convertAmount(expense.amount, expense.currency);
    }
    return DailySpending(
      date: date,
      amount: total,
      currency: displayCurrency,
    );
  }

  String get formattedAmount => ExpenseStats._formatCurrency(amount, currency);
}

/// Represents category totals for charts and display
class CategoryTotal {
  final String category;
  final double amount;
  final double percentage;
  final int count;
  final Color color;

  const CategoryTotal({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.count,
    required this.color,
  });

  /// Create from expenses in a category
  factory CategoryTotal.fromExpenses(
    String category,
    List<ExpenseModel> expenses,
    double totalAllCategories,
    String displayCurrency,
    double Function(double amount, String fromCurrency) convertAmount,
  ) {
    double total = 0;
    for (final expense in expenses) {
      total += convertAmount(expense.amount, expense.currency);
    }

    final percentage =
        totalAllCategories > 0 ? (total / totalAllCategories) * 100 : 0.0;

    return CategoryTotal(
      category: category,
      amount: total,
      percentage: percentage,
      count: expenses.length,
      color: AppTheme.categoryColors[category] ?? AppTheme.textSecondary,
    );
  }

  /// Get display name for category
  String get displayName {
    switch (category) {
      case 'transport':
        return 'Transport';
      case 'accommodation':
        return 'Accommodation';
      case 'food':
        return 'Food & Drinks';
      case 'activities':
        return 'Activities';
      case 'shopping':
        return 'Shopping';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }

  /// Get icon for category
  IconData get icon {
    switch (category) {
      case 'transport':
        return Icons.directions_car;
      case 'accommodation':
        return Icons.hotel;
      case 'food':
        return Icons.restaurant;
      case 'activities':
        return Icons.attractions;
      case 'shopping':
        return Icons.shopping_bag;
      case 'other':
        return Icons.receipt_long;
      default:
        return Icons.receipt;
    }
  }

  String formattedAmount(String currency) =>
      ExpenseStats._formatCurrency(amount, currency);
}

/// Extension to compute category totals from expenses
extension ExpenseCategoryComputation on List<ExpenseModel> {
  /// Group expenses by category and compute totals
  List<CategoryTotal> computeCategoryTotals(
    String displayCurrency,
    double Function(double amount, String fromCurrency) convertAmount,
  ) {
    // Group by category
    final grouped = <String, List<ExpenseModel>>{};
    for (final expense in this) {
      grouped.putIfAbsent(expense.category, () => []).add(expense);
    }

    // Calculate total for percentage computation
    double total = 0;
    for (final expense in this) {
      total += convertAmount(expense.amount, expense.currency);
    }

    // Create category totals
    final categories = <CategoryTotal>[];
    final allCategories = [
      'transport',
      'accommodation',
      'food',
      'activities',
      'shopping',
      'other'
    ];

    for (final category in allCategories) {
      final expenses = grouped[category] ?? [];
      if (expenses.isNotEmpty) {
        categories.add(CategoryTotal.fromExpenses(
          category,
          expenses,
          total,
          displayCurrency,
          convertAmount,
        ));
      }
    }

    // Sort by amount descending
    categories.sort((a, b) => b.amount.compareTo(a.amount));

    return categories;
  }

  /// Group expenses by date for daily spending chart
  List<DailySpending> computeDailySpending(
    String displayCurrency,
    double Function(double amount, String fromCurrency) convertAmount,
  ) {
    // Group by date
    final grouped = <DateTime, List<ExpenseModel>>{};
    for (final expense in this) {
      if (expense.expenseDate != null) {
        final dateKey = DateTime(
          expense.expenseDate!.year,
          expense.expenseDate!.month,
          expense.expenseDate!.day,
        );
        grouped.putIfAbsent(dateKey, () => []).add(expense);
      }
    }

    // Create daily spending entries
    final dailyList = grouped.entries
        .map((entry) => DailySpending.fromExpenses(
              entry.key,
              entry.value,
              displayCurrency,
              convertAmount,
            ))
        .toList();

    // Sort by date ascending
    dailyList.sort((a, b) => a.date.compareTo(b.date));

    return dailyList;
  }
}

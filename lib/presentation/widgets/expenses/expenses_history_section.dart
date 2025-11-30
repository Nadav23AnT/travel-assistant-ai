import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme.dart';
import '../../../data/models/expense_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/expenses_provider.dart';
import 'edit_expense_dialog.dart';
import 'expense_history_card.dart';

class ExpensesHistorySection extends ConsumerWidget {
  final List<ExpenseModel> expenses;
  final String displayCurrency;
  final Map<String, double>? convertedAmounts;

  const ExpensesHistorySection({
    super.key,
    required this.expenses,
    required this.displayCurrency,
    this.convertedAmounts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Sort expenses by date (most recent first)
    final sortedExpenses = List<ExpenseModel>.from(expenses)
      ..sort((a, b) {
        final dateA = a.expenseDate ?? a.createdAt;
        final dateB = b.expenseDate ?? b.createdAt;
        return dateB.compareTo(dateA);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.expenseHistory,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${expenses.length} ${l10n.expensesLabel}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),

        // Expenses list
        if (sortedExpenses.isEmpty)
          _buildEmptyState(context)
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedExpenses.length,
            itemBuilder: (context, index) {
              final expense = sortedExpenses[index];
              final convertedAmount = convertedAmounts?[expense.id];

              return ExpenseHistoryCard(
                expense: expense,
                displayCurrency: displayCurrency,
                convertedAmount: convertedAmount,
                onEdit: () => _handleEdit(context, ref, expense),
                onDelete: () => _handleDelete(context, ref, expense),
              );
            },
          ),

        // Bottom spacing
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textHint.withAlpha(51),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppTheme.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noExpenseHistory,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noExpenseHistoryDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textHint,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _handleEdit(
    BuildContext context,
    WidgetRef ref,
    ExpenseModel expense,
  ) async {
    final result = await showEditExpenseDialog(context, expense);
    if (result == true) {
      // Expense was updated, refresh will happen automatically via provider
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    ExpenseModel expense,
  ) async {
    final l10n = AppLocalizations.of(context);

    // Delete expense via provider
    final success = await ref.read(expenseOperationProvider.notifier).deleteExpense(
      expense.id,
      expense.tripId,
    );

    if (success) {
      // Refresh the expenses dashboard
      await ref.read(expensesDashboardRefreshProvider)();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.expenseDeletedSuccess),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } else {
      if (context.mounted) {
        final error = ref.read(expenseOperationProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? l10n.failedToDeleteExpense),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}

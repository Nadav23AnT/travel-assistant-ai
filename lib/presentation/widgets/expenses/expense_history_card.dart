import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/theme.dart';
import '../../../data/models/expense_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/expenses_provider.dart';

class ExpenseHistoryCard extends ConsumerWidget {
  final ExpenseModel expense;
  final String? displayCurrency;
  final double? convertedAmount;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpenseHistoryCard({
    super.key,
    required this.expense,
    this.displayCurrency,
    this.convertedAmount,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryColor =
        AppTheme.categoryColors[expense.category] ?? AppTheme.textSecondary;
    final l10n = AppLocalizations.of(context);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Category icon + Name + Amount
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: categoryColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: categoryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Name and category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          expense.categoryDisplayName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: categoryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      convertedAmount != null && displayCurrency != null
                          ? _formatAmount(convertedAmount!, displayCurrency!)
                          : expense.formattedAmount,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    if (convertedAmount != null &&
                        displayCurrency != expense.currency) ...[
                      const SizedBox(height: 2),
                      Text(
                        expense.formattedAmount,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textHint,
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Divider
            Divider(
              color: AppTheme.textHint.withAlpha(51),
              height: 1,
            ),

            const SizedBox(height: 12),

            // Date and time row
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDateFull(expense.expenseDate),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),

            // Notes (if present)
            if (expense.notes != null && expense.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notes_outlined,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      expense.notes!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // Split info (if expense is split)
            if (expense.isSplit) ...[
              const SizedBox(height: 12),
              _buildSplitSection(context, ref, currentUserId),
            ],

            const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Edit button
                TextButton.icon(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                  label: Text(
                    l10n.edit,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button
                TextButton.icon(
                  onPressed: () => _showDeleteConfirmation(context),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppTheme.errorColor,
                  ),
                  label: Text(
                    l10n.delete,
                    style: TextStyle(
                      color: AppTheme.errorColor,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitSection(BuildContext context, WidgetRef ref, String? currentUserId) {
    final splitsAsync = ref.watch(expenseSplitsProvider(expense.id));

    return splitsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (splits) {
        if (splits.isEmpty) return const SizedBox.shrink();

        // Calculate conversion ratio for currency display
        final conversionRatio = (convertedAmount != null && expense.amount > 0)
            ? convertedAmount! / expense.amount
            : 1.0;
        final currency = displayCurrency ?? expense.currency;

        // Check if current user is the payer
        final isPayer = expense.paidBy == currentUserId;

        // Filter and limit splits to display
        final unsettledSplits = splits.where((s) => !s.isSettled).toList();
        final displaySplits = unsettledSplits.take(3).toList();
        final remainingCount = unsettledSplits.length - displaySplits.length;

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withAlpha(13),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.primaryColor.withAlpha(26),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Split expense',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Split items
              ...displaySplits.map((split) {
                final convertedSplitAmount = split.amount * conversionRatio;
                final formattedAmount = _formatAmount(convertedSplitAmount, currency);

                if (isPayer) {
                  // Current user paid - show who owes them
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                  ),
                              children: [
                                TextSpan(
                                  text: split.displayName,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const TextSpan(text: ' owes you '),
                                TextSpan(
                                  text: formattedAmount,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.successColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (split.userId == currentUserId) {
                  // Current user owes money
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                  ),
                              children: [
                                const TextSpan(text: 'You owe '),
                                TextSpan(
                                  text: formattedAmount,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.errorColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              // Show "+N more" if there are more splits
              if (remainingCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 20),
                  child: Text(
                    '+$remainingCount more',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: AppTheme.textHint,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteExpense),
        content: Text(l10n.deleteExpenseConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (expense.category) {
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

  String _formatDateFull(DateTime? date) {
    if (date == null) return 'No date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    String dateStr;
    if (dateOnly == today) {
      dateStr = 'Today';
    } else if (dateOnly == yesterday) {
      dateStr = 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      dateStr = DateFormat('EEEE').format(date);
    } else {
      dateStr = DateFormat('MMM d, yyyy').format(date);
    }

    return '$dateStr at ${DateFormat('HH:mm').format(date)}';
  }

  String _formatAmount(double amount, String currency) {
    const symbols = {
      'USD': '\$',
      'EUR': '\u20AC',
      'GBP': '\u00A3',
      'ILS': '\u20AA',
      'JPY': '\u00A5',
    };
    final symbol = symbols[currency] ?? '$currency ';
    return '$symbol${amount.toStringAsFixed(2)}';
  }
}

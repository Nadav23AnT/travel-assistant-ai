import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../data/models/expense_model.dart';
import '../../../l10n/app_localizations.dart';

class ExpenseListTile extends StatelessWidget {
  final ExpenseModel expense;
  final String? displayCurrency;
  final double? convertedAmount;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ExpenseListTile({
    super.key,
    required this.expense,
    this.displayCurrency,
    this.convertedAmount,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor =
        AppTheme.categoryColors[expense.category] ?? AppTheme.textSecondary;
    final l10n = AppLocalizations.of(context);

    return Dismissible(
      key: Key(expense.id),
      direction:
          onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.errorColor,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        if (onDelete == null) return false;
        return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.deleteExpense),
            content: Text(l10n.deleteExpenseConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
                child: Text(l10n.delete),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete?.call(),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: categoryColor.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getCategoryIcon(),
            color: categoryColor,
            size: 20,
          ),
        ),
        title: Text(
          expense.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              _getLocalizedCategory(expense.category, l10n),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: categoryColor,
                  ),
            ),
            if (expense.expenseDate != null) ...[
              const Text(' \u2022 '),
              Text(
                _formatDate(expense.expenseDate!, l10n),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textHint,
                    ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              convertedAmount != null && displayCurrency != null
                  ? _formatAmount(convertedAmount!, displayCurrency!)
                  : expense.formattedAmount,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (convertedAmount != null &&
                displayCurrency != expense.currency) ...[
              Text(
                expense.formattedAmount,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textHint,
                      fontSize: 11,
                    ),
              ),
            ],
          ],
        ),
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

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return l10n.today;
    } else if (dateOnly == yesterday) {
      return l10n.yesterday;
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  String _getLocalizedCategory(String category, AppLocalizations l10n) {
    switch (category) {
      case 'transport':
        return l10n.categoryTransport;
      case 'accommodation':
        return l10n.categoryAccommodation;
      case 'food':
        return l10n.categoryFood;
      case 'activities':
        return l10n.categoryActivities;
      case 'shopping':
        return l10n.categoryShopping;
      case 'other':
        return l10n.categoryOther;
      default:
        return category;
    }
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

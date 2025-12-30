import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/expense_stats.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/currency_provider.dart';
import '../../providers/expenses_provider.dart';
import 'expense_list_tile.dart';

class CategoryDetailSheet extends ConsumerWidget {
  final String category;
  final CategoryTotal categoryTotal;
  final List<ExpenseModel> expenses;
  final String displayCurrency;

  const CategoryDetailSheet({
    super.key,
    required this.category,
    required this.categoryTotal,
    required this.expenses,
    required this.displayCurrency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showInHome = ref.watch(showInHomeCurrencyProvider);
    final ratesNotifier = ref.watch(exchangeRatesProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final localizedCategoryName = _getLocalizedCategory(category, l10n);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textHint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: categoryTotal.color.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        categoryTotal.icon,
                        color: categoryTotal.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizedCategoryName,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            expenses.length == 1
                                ? l10n.expenseCountSingular
                                : l10n.expenseCountPlural(expenses.length),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          categoryTotal.formattedAmount(displayCurrency),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: categoryTotal.color,
                                  ),
                        ),
                        Text(
                          l10n.percentOfTotal(
                              categoryTotal.percentage.toStringAsFixed(1)),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textHint,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Expense list
              Expanded(
                child: expenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              categoryTotal.icon,
                              size: 48,
                              color: AppTheme.textHint,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noCategoryExpenses(localizedCategoryName),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: expenses.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, indent: 72),
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          double? convertedAmount;
                          if (showInHome &&
                              expense.currency != displayCurrency) {
                            convertedAmount = ratesNotifier.convert(
                              expense.amount,
                              expense.currency,
                              displayCurrency,
                            );
                          }
                          return ExpenseListTile(
                            expense: expense,
                            displayCurrency: displayCurrency,
                            convertedAmount: convertedAmount,
                            onTap: () {
                              // TODO: Navigate to expense detail
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
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
}

/// Helper to show the category detail sheet
void showCategoryDetailSheet(
  BuildContext context, {
  required String category,
  required CategoryTotal categoryTotal,
  required List<ExpenseModel> expenses,
  required String displayCurrency,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CategoryDetailSheet(
      category: category,
      categoryTotal: categoryTotal,
      expenses: expenses,
      displayCurrency: displayCurrency,
    ),
  );
}

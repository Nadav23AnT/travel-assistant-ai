import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/expense_stats.dart';
import '../../../data/models/trip_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/country_currency_helper.dart';
import '../../providers/currency_provider.dart';
import '../../providers/expenses_provider.dart';

/// Enhanced trip card with expense summary, insights, and expandable details
class EnhancedTripCard extends ConsumerStatefulWidget {
  final TripModel trip;
  final bool showExpanded;

  const EnhancedTripCard({
    super.key,
    required this.trip,
    this.showExpanded = false,
  });

  @override
  ConsumerState<EnhancedTripCard> createState() => _EnhancedTripCardState();
}

class _EnhancedTripCardState extends ConsumerState<EnhancedTripCard> {
  bool _isExpanded = false;
  bool _showInLocalCurrency = true;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.showExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final expensesAsync = ref.watch(tripExpensesProvider(trip.id));
    final homeCurrency = ref.watch(userHomeCurrencyProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push('/trips/${trip.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with flag background and status indicators
            _buildHeader(context, trip),

            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row with shared badge
                  _buildTitleRow(context, trip),
                  const SizedBox(height: 8),

                  // Location and dates
                  _buildLocationRow(context, trip),
                  if (trip.startDate != null && trip.endDate != null) ...[
                    const SizedBox(height: 4),
                    _buildDatesRow(context, trip),
                  ],
                  const SizedBox(height: 16),

                  // Trip Insights Section (progress bar, trip length)
                  _buildTripInsights(context, trip),
                  const SizedBox(height: 16),

                  // Expenses Summary Section
                  expensesAsync.when(
                    loading: () => _buildExpensesSummaryLoading(),
                    error: (error, stack) => const SizedBox.shrink(),
                    data: (expenses) => _buildExpensesSummary(
                      context,
                      trip,
                      expenses,
                      homeCurrency,
                    ),
                  ),

                  // Expandable Details Section
                  if (_isExpanded)
                    expensesAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (error, stack) => const SizedBox.shrink(),
                      data: (expenses) => _buildExpandedDetails(
                        context,
                        trip,
                        expenses,
                      ),
                    ),

                  // Expand/Collapse toggle
                  _buildExpandToggle(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TripModel trip) {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withAlpha(200),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // Country flag
            Text(
              trip.flagEmoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            // Status pill
            _buildStatusPill(context, trip),
            const Spacer(),
            // Currency badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                trip.budgetCurrency,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(BuildContext context, TripModel trip) {
    final l10n = AppLocalizations.of(context);
    String label;
    Color color;
    IconData icon;

    if (trip.isActive) {
      label = l10n.ongoing;
      color = AppTheme.successColor;
      icon = Icons.flight_takeoff;
    } else if (trip.isUpcoming) {
      label = l10n.planning;
      color = AppTheme.primaryColor;
      icon = Icons.schedule;
    } else if (trip.isCompleted) {
      label = l10n.completed;
      color = AppTheme.textSecondary;
      icon = Icons.check_circle_outline;
    } else {
      label = trip.status.toUpperCase();
      color = AppTheme.textSecondary;
      icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context, TripModel trip) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            trip.displayTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Shared badge
        if (trip.isShared) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.group, size: 12, color: AppTheme.accentColor),
                const SizedBox(width: 4),
                Text(
                  l10n.sharedTrip,
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationRow(BuildContext context, TripModel trip) {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            trip.displayDestination,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDatesRow(BuildContext context, TripModel trip) {
    final dateFormat = DateFormat('MMM d, y');
    return Row(
      children: [
        Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          '${dateFormat.format(trip.startDate!)} - ${dateFormat.format(trip.endDate!)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildTripInsights(BuildContext context, TripModel trip) {
    final l10n = AppLocalizations.of(context);

    // Calculate trip progress
    double progress = 0;
    String progressText = '';
    int? currentDay;
    int? totalDays = trip.durationDays;

    if (trip.startDate != null && trip.endDate != null) {
      final now = DateTime.now();
      final start = trip.startDate!;
      final end = trip.endDate!;

      if (now.isBefore(start)) {
        // Upcoming trip
        final daysUntil = start.difference(now).inDays;
        progressText = '${l10n.startsIn} $daysUntil ${daysUntil == 1 ? l10n.day : l10n.days}';
        progress = 0;
      } else if (now.isAfter(end)) {
        // Completed trip
        progressText = l10n.completed;
        progress = 1;
        currentDay = totalDays;
      } else {
        // Active trip
        currentDay = now.difference(start).inDays + 1;
        progress = totalDays != null && totalDays > 0 ? currentDay / totalDays : 0;
        progressText = l10n.dayOfTotal(currentDay, totalDays ?? 0);
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Trip length
              Row(
                children: [
                  Icon(Icons.date_range, size: 16, color: AppTheme.primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    totalDays != null
                        ? '$totalDays ${totalDays == 1 ? l10n.day : l10n.days}'
                        : l10n.notSet,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              // Local currency
              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: AppTheme.accentColor),
                  const SizedBox(width: 4),
                  Text(
                    trip.budgetCurrency,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (trip.isActive || trip.isCompleted || trip.isUpcoming) ...[
            const SizedBox(height: 12),
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      progressText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    if (currentDay != null && totalDays != null)
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppTheme.textSecondary.withAlpha(51),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      trip.isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpensesSummaryLoading() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildExpensesSummary(
    BuildContext context,
    TripModel trip,
    List<ExpenseModel> expenses,
    String homeCurrency,
  ) {
    final l10n = AppLocalizations.of(context);

    // Calculate totals
    final displayCurrency = _showInLocalCurrency ? trip.budgetCurrency : homeCurrency;

    double convertAmount(double amount, String fromCurrency) {
      if (fromCurrency == displayCurrency) return amount;
      return ref.read(exchangeRatesProvider.notifier).convert(
            amount,
            fromCurrency,
            displayCurrency,
          );
    }

    final stats = ExpenseStats.compute(
      expenses: expenses,
      displayCurrency: displayCurrency,
      convertAmount: convertAmount,
      tripStartDate: trip.startDate,
      tripEndDate: trip.endDate,
    );

    final categoryTotals = expenses.computeCategoryTotals(displayCurrency, convertAmount);
    final topCategory = categoryTotals.isNotEmpty ? categoryTotals.first : null;

    // Calculate remaining budget
    double? remainingBudget;
    if (trip.budget != null) {
      final budgetInDisplay = convertAmount(trip.budget!, trip.budgetCurrency);
      remainingBudget = budgetInDisplay - stats.totalSpent;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with currency toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet, size: 18, color: AppTheme.primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    l10n.expensesSummary,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              // Currency flip button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showInLocalCurrency = !_showInLocalCurrency;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_horiz, size: 14, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        displayCurrency,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stats grid
          Row(
            children: [
              // Total Spent
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.payments,
                  label: l10n.totalSpent,
                  value: stats.formattedTotal,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              // Daily Average
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.trending_up,
                  label: l10n.dailyAverage,
                  value: stats.formattedDailyAverage,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Remaining Budget
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: Icons.savings,
                  label: l10n.remainingBudget,
                  value: remainingBudget != null
                      ? CountryCurrencyHelper.formatAmount(remainingBudget, displayCurrency)
                      : l10n.notSet,
                  color: remainingBudget != null && remainingBudget < 0
                      ? AppTheme.errorColor
                      : AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 12),
              // Top Category
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: topCategory?.icon ?? Icons.category,
                  label: l10n.topCategory,
                  value: topCategory?.displayName ?? l10n.none,
                  color: topCategory?.color ?? AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(51), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedDetails(
    BuildContext context,
    TripModel trip,
    List<ExpenseModel> expenses,
  ) {
    final l10n = AppLocalizations.of(context);

    // Get last 3 expenses
    final recentExpenses = expenses.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),

        // Recent Expenses
        if (recentExpenses.isNotEmpty) ...[
          Text(
            l10n.recentExpenses,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...recentExpenses.map((expense) => _buildExpenseItem(context, expense)),
          const SizedBox(height: 12),
        ],

        // Journal reminder for completed trips
        if (trip.isCompleted)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.accentColor.withAlpha(51)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_stories, color: AppTheme.accentColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.journalReminder,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                      Text(
                        l10n.journalReminderDescription,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildExpenseItem(BuildContext context, ExpenseModel expense) {
    final dateFormat = DateFormat('MMM d');
    final categoryColor = AppTheme.categoryColors[expense.category] ?? AppTheme.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: categoryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(expense.category),
              color: categoryColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (expense.expenseDate != null)
                  Text(
                    dateFormat.format(expense.expenseDate!),
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            CountryCurrencyHelper.formatAmount(expense.amount, expense.currency),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: categoryColor,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandToggle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: TextButton.icon(
        onPressed: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        icon: Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          size: 20,
        ),
        label: Text(
          _isExpanded ? l10n.showLess : l10n.showMore,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
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
      default:
        return Icons.receipt_long;
    }
  }
}

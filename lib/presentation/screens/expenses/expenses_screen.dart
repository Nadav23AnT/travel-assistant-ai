import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../data/models/expense_stats.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/currency_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../widgets/charts/expense_pie_chart.dart';
import '../../widgets/charts/spending_line_chart.dart';
import '../../widgets/expenses/category_card.dart';
import '../../widgets/expenses/category_detail_sheet.dart';
import '../../widgets/expenses/expenses_history_section.dart';
import '../../widgets/expenses/summary_stat_card.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure exchange rates are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeCurrency = ref.read(userHomeCurrencyProvider);
      ref.read(exchangeRatesProvider.notifier).fetchRates(homeCurrency);
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(expensesDashboardRefreshProvider)();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(expensesDashboardProvider);
    final displayMode = ref.watch(currencyDisplayModeProvider);
    final homeCurrency = ref.watch(userHomeCurrencyProvider);
    final localCurrency = ref.watch(tripLocalCurrencyProvider);

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.expenses),
        actions: [
          // Currency toggle with 3 options: Home, USD, Local
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SegmentedButton<CurrencyDisplayMode>(
              style: SegmentedButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              segments: [
                ButtonSegment(
                  value: CurrencyDisplayMode.home,
                  label: Text(
                    homeCurrency,
                    style: const TextStyle(fontSize: 11),
                  ),
                  tooltip: l10n.homeCurrency,
                ),
                ButtonSegment(
                  value: CurrencyDisplayMode.usd,
                  label: const Text(
                    'USD',
                    style: TextStyle(fontSize: 11),
                  ),
                  tooltip: l10n.usDollar,
                ),
                ButtonSegment(
                  value: CurrencyDisplayMode.local,
                  label: Text(
                    localCurrency ?? 'Local',
                    style: const TextStyle(fontSize: 11),
                  ),
                  tooltip: localCurrency != null
                      ? DestinationCurrencyMapper.getCurrencyDisplayName(localCurrency)
                      : l10n.localCurrency,
                ),
              ],
              selected: {displayMode},
              onSelectionChanged: (selected) async {
                final newMode = selected.first;
                ref.read(currencyDisplayModeProvider.notifier).state = newMode;

                // Fetch exchange rates for the target currency
                String targetCurrency;
                switch (newMode) {
                  case CurrencyDisplayMode.home:
                    targetCurrency = homeCurrency;
                    break;
                  case CurrencyDisplayMode.usd:
                    targetCurrency = 'USD';
                    break;
                  case CurrencyDisplayMode.local:
                    targetCurrency = localCurrency ?? homeCurrency;
                    break;
                }
                await ref.read(exchangeRatesProvider.notifier).fetchRates(targetCurrency);
              },
            ),
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (data) {
          if (data.expenses.isEmpty) {
            return _buildEmptyState(context);
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              slivers: [
                // Summary Stats Section
                SliverToBoxAdapter(
                  child: _buildSummarySection(data),
                ),

                // Trip Info (if available)
                if (data.trip != null)
                  SliverToBoxAdapter(
                    child: _buildTripInfoBanner(data),
                  ),

                // Category Breakdown Section
                SliverToBoxAdapter(
                  child: _buildCategorySection(data),
                ),

                // Spending Over Time Section
                SliverToBoxAdapter(
                  child: _buildSpendingOverTimeSection(data),
                ),

                // Expense History Section
                SliverToBoxAdapter(
                  child: ExpensesHistorySection(
                    expenses: data.expenses,
                    displayCurrency: data.displayCurrency,
                    convertedAmounts: _buildConvertedAmountsMap(data),
                  ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          );
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(context, error),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addExpense),
        icon: const Icon(Icons.add),
        label: Text(l10n.addExpense),
      ),
    );
  }

  Widget _buildSummarySection(ExpensesDashboardData data) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.overview,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SummaryStatCard(
                  type: StatType.totalSpent,
                  value: data.stats.formattedTotal,
                  subtitle: l10n.expensesCount(data.stats.totalExpenseCount),
                ),
                const SizedBox(width: 12),
                SummaryStatCard(
                  type: StatType.dailyAverage,
                  value: data.stats.formattedDailyAverage,
                  subtitle: data.stats.elapsedDays > 0
                      ? l10n.daysTracked(data.stats.elapsedDays)
                      : null,
                ),
                const SizedBox(width: 12),
                SummaryStatCard(
                  type: StatType.estimatedTotal,
                  value: data.stats.formattedEstimatedTotal,
                  subtitle: data.stats.tripDays > 0
                      ? l10n.dayTrip(data.stats.tripDays)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfoBanner(ExpensesDashboardData data) {
    final l10n = AppLocalizations.of(context);
    final trip = data.trip!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.flight_takeoff,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              trip.displayTitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (data.stats.remainingDays > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.daysLeft(data.stats.remainingDays),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(ExpensesDashboardData data) {
    final l10n = AppLocalizations.of(context);
    // Define all categories for empty state
    final allCategories = [
      ('transport', l10n.categoryTransport, Icons.directions_car),
      ('accommodation', l10n.categoryAccommodation, Icons.hotel),
      ('food', l10n.foodAndDrinks, Icons.restaurant),
      ('activities', l10n.categoryActivities, Icons.attractions),
      ('shopping', l10n.categoryShopping, Icons.shopping_bag),
      ('other', l10n.categoryOther, Icons.receipt_long),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.byCategory,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Pie Chart
          if (data.categoryTotals.isNotEmpty)
            ExpensePieChart(
              categoryTotals: data.categoryTotals,
              displayCurrency: data.displayCurrency,
              onCategoryTap: (category) =>
                  _showCategoryDetail(data, category),
            ),

          const SizedBox(height: 16),

          // Category Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: allCategories.length,
            itemBuilder: (context, index) {
              final (categoryKey, categoryName, icon) = allCategories[index];
              final categoryTotal = data.categoryTotals.firstWhere(
                (c) => c.category == categoryKey,
                orElse: () => CategoryTotal(
                  category: categoryKey,
                  amount: 0,
                  percentage: 0,
                  count: 0,
                  color: AppTheme.categoryColors[categoryKey] ??
                      AppTheme.textSecondary,
                ),
              );

              if (categoryTotal.count == 0) {
                return EmptyCategoryCard(
                  categoryName: categoryName,
                  icon: icon,
                  color: AppTheme.categoryColors[categoryKey] ??
                      AppTheme.textSecondary,
                );
              }

              return CategoryCard(
                category: categoryTotal,
                displayCurrency: data.displayCurrency,
                onTap: () => _showCategoryDetail(data, categoryKey),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingOverTimeSection(ExpensesDashboardData data) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.spendingOverTime,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SpendingLineChart(
                dailySpending: data.dailySpending,
                displayCurrency: data.displayCurrency,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryDetail(ExpensesDashboardData data, String category) {
    final categoryTotal = data.categoryTotals.firstWhere(
      (c) => c.category == category,
      orElse: () => CategoryTotal(
        category: category,
        amount: 0,
        percentage: 0,
        count: 0,
        color: AppTheme.categoryColors[category] ?? AppTheme.textSecondary,
      ),
    );

    final expenses =
        data.expenses.where((e) => e.category == category).toList();

    showCategoryDetailSheet(
      context,
      category: category,
      categoryTotal: categoryTotal,
      expenses: expenses,
      displayCurrency: data.displayCurrency,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withAlpha(77),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noExpensesYet,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.startTrackingExpenses,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.addExpense),
              icon: const Icon(Icons.add),
              label: Text(l10n.addExpense),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.overview,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SummaryStatCard(
                  type: StatType.totalSpent,
                  value: '',
                  isLoading: true,
                ),
                const SizedBox(width: 12),
                SummaryStatCard(
                  type: StatType.dailyAverage,
                  value: '',
                  isLoading: true,
                ),
                const SizedBox(width: 12),
                SummaryStatCard(
                  type: StatType.estimatedTotal,
                  value: '',
                  isLoading: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.somethingWentWrong,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a map of expense ID to converted amount for currency display
  Map<String, double>? _buildConvertedAmountsMap(ExpensesDashboardData data) {
    final displayCurrency = data.displayCurrency;
    final rates = ref.read(exchangeRatesProvider);

    // If no rates or all expenses are in display currency, return null
    if (rates.rates.isEmpty) return null;

    final convertedAmounts = <String, double>{};
    for (final expense in data.expenses) {
      if (expense.currency != displayCurrency) {
        final converted = ref.read(exchangeRatesProvider.notifier).convert(
              expense.amount,
              expense.currency,
              displayCurrency,
            );
        convertedAmounts[expense.id] = converted;
      }
    }

    return convertedAmounts.isNotEmpty ? convertedAmounts : null;
  }
}

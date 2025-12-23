import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../../core/design/design_system.dart';
import '../../../data/models/expense_stats.dart';
import '../../../data/models/trip_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/country_currency_helper.dart';
import '../../providers/currency_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/charts/mini_pie_chart.dart';
import '../../widgets/charts/spending_line_chart.dart';
import '../../widgets/expenses/budget_progress_bar.dart';
import '../../widgets/expenses/category_detail_sheet.dart';
import '../../widgets/expenses/category_progress_bar.dart';
import '../../widgets/expenses/compact_stat_tile.dart';
import '../../widgets/expenses/expenses_history_section.dart';
import '../../widgets/expenses/settlement_summary_card.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.expenses,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          // Currency toggle with glass styling
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _GlassCurrencySelector(
              displayMode: displayMode,
              homeCurrency: homeCurrency,
              localCurrency: localCurrency,
              isDark: isDark,
              l10n: l10n,
              onModeChanged: (newMode) async {
                ref.read(currencyDisplayModeProvider.notifier).state = newMode;

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
            return _buildEmptyState(context, isDark, l10n);
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: LiquidGlassColors.auroraIndigo,
            child: CustomScrollView(
              slivers: [
                // Spacer for app bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),

                // Budget Overview Section (includes trip badge)
                SliverToBoxAdapter(
                  child: _buildBudgetOverviewSection(data, isDark, l10n),
                ),

                // Settlement Summary (card handles visibility - only shows for trips with members)
                if (data.trip != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                      child: SettlementSummaryCard(
                        tripId: data.trip!.id,
                        displayCurrency: data.displayCurrency,
                      ),
                    ),
                  ),

                // Category Breakdown Section
                SliverToBoxAdapter(
                  child: _buildCategorySection(data, isDark, l10n),
                ),

                // Spending Over Time Section
                SliverToBoxAdapter(
                  child: _buildSpendingOverTimeSection(data, isDark, l10n),
                ),

                // Expense History Section
                SliverToBoxAdapter(
                  child: ExpensesHistorySection(
                    expenses: data.expenses,
                    displayCurrency: data.displayCurrency,
                    convertedAmounts: _buildConvertedAmountsMap(data),
                  ),
                ),

                // Bottom padding for floating nav
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
          );
        },
        loading: () => _buildLoadingState(isDark, l10n),
        error: (error, stack) => _buildErrorState(context, error, isDark, l10n),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: PremiumButton.gradient(
          label: l10n.addExpense,
          icon: Icons.add,
          onPressed: () => context.push(AppRoutes.addExpense),
          width: 160,
          height: 52,
        ),
      ),
    );
  }

  Widget _buildBudgetOverviewSection(ExpensesDashboardData data, bool isDark, AppLocalizations l10n) {
    final trip = data.trip;
    final originalBudget = trip?.budget ?? 0;
    final budgetCurrency = trip?.budgetCurrency ?? data.displayCurrency;
    final displayCurrency = data.displayCurrency;

    // Convert budget to display currency if needed
    // Watch the exchange rates to trigger rebuild when currency changes
    final exchangeRates = ref.watch(exchangeRatesProvider);
    double convertedBudget = originalBudget;
    if (originalBudget > 0 && budgetCurrency != displayCurrency && exchangeRates.rates.isNotEmpty) {
      convertedBudget = ref.read(exchangeRatesProvider.notifier).convert(
            originalBudget,
            budgetCurrency,
            displayCurrency,
          );
    }

    // Format budget value for display in the display currency
    final budgetFormatted = convertedBudget > 0
        ? CountryCurrencyHelper.formatAmount(convertedBudget, displayCurrency)
        : '';
    final spentFormatted = data.stats.formattedTotal;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with title and trip selector
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.overview,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              // Trip selector badge with popup menu
              if (trip != null)
                PopupMenuButton<String>(
                  onSelected: (tripId) {
                    ref.read(selectedExpensesTripIdProvider.notifier).state = tripId;
                  },
                  offset: const Offset(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  itemBuilder: (context) {
                    final tripsAsync = ref.read(userTripsProvider);
                    final currentTripId = ref.read(effectiveTripIdProvider);
                    final trips = tripsAsync.valueOrNull ?? [];

                    return trips.map((t) => PopupMenuItem<String>(
                      value: t.id,
                      child: Row(
                        children: [
                          Text(
                            t.flagEmoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  t.displayDestination,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                if (t.isShared)
                                  Text(
                                    'Shared',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: LiquidGlassColors.oceanTeal,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (t.id == currentTripId)
                            Icon(
                              Icons.check_circle,
                              color: LiquidGlassColors.auroraIndigo,
                              size: 20,
                            ),
                        ],
                      ),
                    )).toList();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LiquidGlassColors.auroraGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isDark
                          ? LiquidGlassColors.neonGlow(
                              LiquidGlassColors.auroraIndigo,
                              intensity: 0.3,
                              blur: 8,
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          trip.flagEmoji,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trip.displayDestination.length > 12
                              ? '${trip.displayDestination.substring(0, 12)}...'
                              : trip.displayDestination,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Budget Progress Card
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BudgetProgressBar(
                spent: data.stats.totalSpent,
                budget: convertedBudget,
                spentFormatted: spentFormatted,
                budgetFormatted: budgetFormatted,
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Compact Stats Row
          Row(
            children: [
              Expanded(
                child: CompactStatTile(
                  icon: Icons.calendar_today,
                  value: data.stats.formattedDailyAverage,
                  label: 'Daily Avg',
                  color: LiquidGlassColors.oceanTeal,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CompactStatTile(
                  icon: Icons.trending_up,
                  value: data.stats.formattedEstimatedTotal,
                  label: 'Est. Total',
                  color: LiquidGlassColors.auroraPurple,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CompactStatTile(
                  icon: Icons.receipt_long,
                  value: data.stats.totalExpenseCount.toString(),
                  label: 'Expenses',
                  color: LiquidGlassColors.sunsetOrange,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(ExpensesDashboardData data, bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.byCategory,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Compact layout: Mini Pie Chart + Category Progress Bars
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mini Pie Chart (140px)
                  MiniPieChart(
                    categoryTotals: data.categoryTotals,
                    onCategoryTap: (category) => _showCategoryDetail(data, category),
                    size: 140,
                  ),
                  const SizedBox(width: 12),

                  // Category Progress Bars
                  Expanded(
                    child: CategoryProgressBarList(
                      categories: data.categoryTotals,
                      displayCurrency: data.displayCurrency,
                      onCategoryTap: (category) => _showCategoryDetail(data, category),
                      isDark: isDark,
                      maxCategories: 6,
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

  Widget _buildSpendingOverTimeSection(ExpensesDashboardData data, bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.spendingOverTime,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 180,
                child: SpendingLineChart(
                  dailySpending: data.dailySpending,
                  displayCurrency: data.displayCurrency,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryDetail(ExpensesDashboardData data, String category) {
    final categoryColors = {
      'transport': LiquidGlassColors.auroraIndigo,
      'accommodation': LiquidGlassColors.auroraPurple,
      'food': LiquidGlassColors.sunsetOrange,
      'activities': LiquidGlassColors.oceanTeal,
      'shopping': LiquidGlassColors.sunsetRose,
      'other': LiquidGlassColors.mintEmerald,
    };

    final categoryTotal = data.categoryTotals.firstWhere(
      (c) => c.category == category,
      orElse: () => CategoryTotal(
        category: category,
        amount: 0,
        percentage: 0,
        count: 0,
        color: categoryColors[category] ?? LiquidGlassColors.auroraIndigo,
      ),
    );

    final expenses = data.expenses.where((e) => e.category == category).toList();

    showCategoryDetailSheet(
      context,
      category: category,
      categoryTotal: categoryTotal,
      expenses: expenses,
      displayCurrency: data.displayCurrency,
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LiquidGlassColors.auroraGradient,
                boxShadow: isDark
                    ? LiquidGlassColors.neonGlow(
                        LiquidGlassColors.auroraIndigo,
                        intensity: 0.5,
                        blur: 32,
                      )
                    : [
                        BoxShadow(
                          color: LiquidGlassColors.auroraIndigo.withAlpha(77),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 56,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.noExpensesYet,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.startTrackingExpenses,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PremiumButton.gradient(
              label: l10n.addExpense,
              icon: Icons.add,
              onPressed: () => context.push(AppRoutes.addExpense),
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.overview,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Loading skeleton for budget progress
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLoadingSkeleton(isDark, width: 80, height: 14),
                      _buildLoadingSkeleton(isDark, width: 80, height: 14),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLoadingSkeleton(isDark, width: 100, height: 24),
                      _buildLoadingSkeleton(isDark, width: 100, height: 24),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildLoadingSkeleton(isDark, width: double.infinity, height: 12),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Loading skeleton for stat tiles
          Row(
            children: [
              Expanded(child: _buildLoadingStatTile(isDark)),
              const SizedBox(width: 8),
              Expanded(child: _buildLoadingStatTile(isDark)),
              const SizedBox(width: 8),
              Expanded(child: _buildLoadingStatTile(isDark)),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                LiquidGlassColors.auroraIndigo,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(bool isDark, {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildLoadingStatTile(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLoadingSkeleton(isDark, width: 16, height: 16),
          const SizedBox(height: 6),
          _buildLoadingSkeleton(isDark, width: 60, height: 14),
          const SizedBox(height: 4),
          _buildLoadingSkeleton(isDark, width: 40, height: 10),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error, bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LiquidGlassColors.sunsetRose.withAlpha(51),
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: LiquidGlassColors.sunsetRose,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.somethingWentWrong,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PremiumButton.solid(
              label: l10n.tryAgain,
              icon: Icons.refresh,
              onPressed: _onRefresh,
              color: LiquidGlassColors.sunsetRose,
              width: 160,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double>? _buildConvertedAmountsMap(ExpensesDashboardData data) {
    final displayCurrency = data.displayCurrency;
    final rates = ref.read(exchangeRatesProvider);

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

/// Glass-styled currency selector
class _GlassCurrencySelector extends StatelessWidget {
  final CurrencyDisplayMode displayMode;
  final String homeCurrency;
  final String? localCurrency;
  final bool isDark;
  final AppLocalizations l10n;
  final ValueChanged<CurrencyDisplayMode> onModeChanged;

  const _GlassCurrencySelector({
    required this.displayMode,
    required this.homeCurrency,
    required this.localCurrency,
    required this.isDark,
    required this.l10n,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark
                ? Colors.white.withAlpha(15)
                : Colors.white.withAlpha(128),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(26)
                  : Colors.white.withAlpha(179),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CurrencyOption(
                label: homeCurrency,
                isSelected: displayMode == CurrencyDisplayMode.home,
                isDark: isDark,
                onTap: () => onModeChanged(CurrencyDisplayMode.home),
              ),
              _CurrencyOption(
                label: 'USD',
                isSelected: displayMode == CurrencyDisplayMode.usd,
                isDark: isDark,
                onTap: () => onModeChanged(CurrencyDisplayMode.usd),
              ),
              _CurrencyOption(
                label: localCurrency ?? 'Local',
                isSelected: displayMode == CurrencyDisplayMode.local,
                isDark: isDark,
                onTap: () => onModeChanged(CurrencyDisplayMode.local),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencyOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CurrencyOption({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: isSelected ? LiquidGlassColors.auroraGradient : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }
}

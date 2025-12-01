import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../../core/design/design_system.dart';
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

                // Summary Stats Section
                SliverToBoxAdapter(
                  child: _buildSummarySection(data, isDark, l10n),
                ),

                // Trip Info (if available)
                if (data.trip != null)
                  SliverToBoxAdapter(
                    child: _buildTripInfoBanner(data, isDark, l10n),
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

  Widget _buildSummarySection(ExpensesDashboardData data, bool isDark, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
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

  Widget _buildTripInfoBanner(ExpensesDashboardData data, bool isDark, AppLocalizations l10n) {
    final trip = data.trip!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: LiquidGlassColors.auroraIndigo.withAlpha(isDark ? 30 : 20),
              border: Border.all(
                color: LiquidGlassColors.auroraIndigo.withAlpha(51),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: LiquidGlassColors.auroraIndigo.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flight_takeoff,
                    color: LiquidGlassColors.auroraIndigo,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    trip.displayTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (data.stats.remainingDays > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LiquidGlassColors.auroraGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.daysLeft(data.stats.remainingDays),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(ExpensesDashboardData data, bool isDark, AppLocalizations l10n) {
    final categoryColors = {
      'transport': LiquidGlassColors.auroraIndigo,
      'accommodation': LiquidGlassColors.auroraPurple,
      'food': LiquidGlassColors.sunsetOrange,
      'activities': LiquidGlassColors.oceanTeal,
      'shopping': LiquidGlassColors.sunsetRose,
      'other': LiquidGlassColors.mintEmerald,
    };

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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Pie Chart
          if (data.categoryTotals.isNotEmpty)
            ExpensePieChart(
              categoryTotals: data.categoryTotals,
              displayCurrency: data.displayCurrency,
              onCategoryTap: (category) => _showCategoryDetail(data, category),
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
                  color: categoryColors[categoryKey] ?? LiquidGlassColors.auroraIndigo,
                ),
              );

              if (categoryTotal.count == 0) {
                return EmptyCategoryCard(
                  categoryName: categoryName,
                  icon: icon,
                  color: categoryColors[categoryKey] ?? LiquidGlassColors.auroraIndigo,
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
          const SizedBox(height: 16),
          GlassCard(
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

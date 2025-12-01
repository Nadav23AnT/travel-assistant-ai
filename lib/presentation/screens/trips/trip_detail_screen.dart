import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/routes.dart';
import '../../../core/design/design_system.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/journal_model.dart';
import '../../../data/models/trip_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/currency_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/trips/trip_members_card.dart';
import '../../widgets/trips/share_trip_sheet.dart';

class TripDetailScreen extends ConsumerWidget {
  final String tripId;

  const TripDetailScreen({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripByIdProvider(tripId));
    final expensesAsync = ref.watch(tripExpensesProvider(tripId));
    final journalAsync = ref.watch(tripJournalEntriesProvider(tripId));
    final homeCurrency = ref.watch(userHomeCurrencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  LiquidGlassColors.canvasBaseDark,
                  const Color(0xFF0D1321),
                  LiquidGlassColors.canvasSubtleDark,
                ]
              : [
                  LiquidGlassColors.canvasBaseLight,
                  const Color(0xFFF0F4FF),
                  const Color(0xFFFAF5FF),
                ],
        ),
      ),
      child: tripAsync.when(
        loading: () => Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(l10n.trips),
          ),
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                LiquidGlassColors.auroraIndigo,
              ),
            ),
          ),
        ),
        error: (error, stack) => Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(l10n.trips),
          ),
          body: _buildErrorState(context, ref, error, isDark),
        ),
        data: (trip) {
          if (trip == null) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(l10n.trips),
              ),
              body: Center(
                child: Text(
                  'Trip not found',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }
          return _buildTripDetail(
            context,
            ref,
            trip,
            expensesAsync,
            journalAsync,
            homeCurrency,
            isDark,
            l10n,
          );
        },
      ),
    );
  }

  Widget _buildTripDetail(
    BuildContext context,
    WidgetRef ref,
    TripModel trip,
    AsyncValue<List<ExpenseModel>> expensesAsync,
    AsyncValue<List<JournalModel>> journalAsync,
    String homeCurrency,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(tripByIdProvider(tripId));
          ref.invalidate(tripExpensesProvider(tripId));
          ref.invalidate(tripJournalEntriesProvider(tripId));
        },
        color: LiquidGlassColors.auroraIndigo,
        child: CustomScrollView(
          slivers: [
            // Collapsible App Bar with Cover Image
            _buildSliverAppBar(context, trip, isDark),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trip Status Banner
                    _buildStatusBanner(context, trip, isDark, l10n),
                    const SizedBox(height: 20),

                    // Quick Stats Row
                    _buildQuickStats(context, trip, expensesAsync, homeCurrency, isDark),
                    const SizedBox(height: 20),

                    // Expense Summary Card
                    _buildExpenseSummary(context, ref, trip, expensesAsync, homeCurrency, isDark, l10n),
                    const SizedBox(height: 20),

                    // Trip Journal Section
                    _buildJournalSection(context, trip, journalAsync, isDark),
                    const SizedBox(height: 20),

                    // Trip Info Card
                    _buildTripInfoCard(context, trip, isDark),
                    const SizedBox(height: 20),

                    // Trip Members Section
                    _buildTripMembersSection(context, ref, trip),
                    const SizedBox(height: 20),

                    // AI Tips Section
                    _buildAITipsSection(context, trip, isDark, l10n),
                    const SizedBox(height: 20),

                    // Recent Expenses
                    _buildRecentExpenses(context, expensesAsync, isDark, l10n),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: PremiumButton.gradient(
          label: l10n.addExpense,
          icon: Icons.add,
          onPressed: () => context.push('${AppRoutes.addExpense}?tripId=$tripId'),
          width: 160,
          height: 52,
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, TripModel trip, bool isDark) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GlowingIconButton(
          icon: Icons.arrow_back,
          onPressed: () => context.pop(),
          size: 40,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              trip.flagEmoji,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                trip.displayDestination,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover image or gradient background
            trip.coverImageUrl != null
                ? Image.network(
                    trip.coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildFlagCover(trip, isDark),
                  )
                : _buildFlagCover(trip, isDark),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(200),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: GlowingIconButton(
            icon: Icons.more_vert,
            onPressed: () => _showMenuBottomSheet(context, trip),
            size: 40,
          ),
        ),
      ],
    );
  }

  void _showMenuBottomSheet(BuildContext context, TripModel trip) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              color: isDark
                  ? Colors.white.withAlpha(20)
                  : Colors.white.withAlpha(200),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(31)
                    : Colors.white.withAlpha(128),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                _MenuOption(
                  icon: Icons.edit_outlined,
                  label: 'Edit Trip',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit trip coming soon')),
                    );
                  },
                  isDark: isDark,
                ),
                _MenuOption(
                  icon: Icons.share_outlined,
                  label: 'Share Trip',
                  onTap: () {
                    Navigator.pop(context);
                    ShareTripSheet.show(
                      context,
                      tripId: tripId,
                      tripTitle: trip.displayTitle,
                    );
                  },
                  isDark: isDark,
                ),
                _MenuOption(
                  icon: Icons.delete_outline,
                  label: 'Delete Trip',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Delete coming soon')),
                    );
                  },
                  isDark: isDark,
                  isDestructive: true,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlagCover(TripModel trip, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LiquidGlassColors.auroraGradient,
      ),
      child: Stack(
        children: [
          // Large flag emoji as background
          Positioned(
            right: -30,
            top: -20,
            child: Text(
              trip.flagEmoji,
              style: TextStyle(
                fontSize: 180,
                color: Colors.white.withAlpha(51),
              ),
            ),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  LiquidGlassColors.auroraIndigo.withAlpha(220),
                  LiquidGlassColors.auroraPurple.withAlpha(80),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, TripModel trip, bool isDark, AppLocalizations l10n) {
    final statusInfo = _getStatusInfo(trip, l10n);
    final daysInfo = _getDaysInfo(trip, l10n);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: statusInfo.color.withAlpha(isDark ? 26 : 20),
            border: Border.all(
              color: statusInfo.color.withAlpha(77),
            ),
          ),
          child: Row(
            children: [
              // Status icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusInfo.color.withAlpha(51),
                  shape: BoxShape.circle,
                  boxShadow: isDark
                      ? LiquidGlassColors.neonGlow(
                          statusInfo.color,
                          intensity: 0.3,
                          blur: 12,
                        )
                      : null,
                ),
                child: Icon(
                  statusInfo.icon,
                  color: statusInfo.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Status info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusInfo.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: statusInfo.color,
                      ),
                    ),
                    if (daysInfo != null)
                      Text(
                        daysInfo,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),

              // Budget progress
              if (trip.budget != null && trip.budget! > 0)
                _buildBudgetIndicator(context, trip, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetIndicator(BuildContext context, TripModel trip, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          l10n(context).budget,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        Text(
          '${trip.budgetCurrency} ${trip.budget!.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  AppLocalizations l10n(BuildContext context) => AppLocalizations.of(context);

  Widget _buildQuickStats(
    BuildContext context,
    TripModel trip,
    AsyncValue<List<ExpenseModel>> expensesAsync,
    String homeCurrency,
    bool isDark,
  ) {
    final expenses = expensesAsync.valueOrNull ?? [];
    final totalSpent = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final tripDays = trip.durationDays;

    return Row(
      children: [
        Expanded(
          child: _GlassStatCard(
            icon: Icons.account_balance_wallet_outlined,
            label: l10n(context).totalSpent,
            value: '\$${totalSpent.toStringAsFixed(0)}',
            color: LiquidGlassColors.auroraIndigo,
            isDark: isDark,
            onTap: () => context.go(AppRoutes.expenses),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GlassStatCard(
            icon: Icons.calendar_today_outlined,
            label: l10n(context).duration,
            value: '$tripDays ${l10n(context).days}',
            color: LiquidGlassColors.oceanTeal,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GlassStatCard(
            icon: Icons.receipt_long_outlined,
            label: l10n(context).expenses,
            value: '${expenses.length}',
            color: LiquidGlassColors.mintEmerald,
            isDark: isDark,
            onTap: () => context.go(AppRoutes.expenses),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseSummary(
    BuildContext context,
    WidgetRef ref,
    TripModel trip,
    AsyncValue<List<ExpenseModel>> expensesAsync,
    String homeCurrency,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return GlassCard(
      child: InkWell(
        onTap: () => context.go(AppRoutes.expenses),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.expensesSummary,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              expensesAsync.when(
                loading: () => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        LiquidGlassColors.auroraIndigo,
                      ),
                    ),
                  ),
                ),
                error: (_, __) => Text(
                  l10n.errorOccurred,
                  style: TextStyle(color: LiquidGlassColors.sunsetRose),
                ),
                data: (expenses) {
                  if (expenses.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 40,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.noExpensesYet,
                              style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return _buildCategoryBreakdown(context, expenses, isDark);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    BuildContext context,
    List<ExpenseModel> expenses,
    bool isDark,
  ) {
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final categoryColors = {
      'transport': LiquidGlassColors.auroraIndigo,
      'accommodation': LiquidGlassColors.auroraPurple,
      'food': LiquidGlassColors.sunsetOrange,
      'activities': LiquidGlassColors.oceanTeal,
      'shopping': LiquidGlassColors.sunsetRose,
      'other': LiquidGlassColors.mintEmerald,
    };

    return Column(
      children: [
        ...sortedCategories.take(4).map((entry) {
          final percentage = total > 0 ? (entry.value / total) : 0.0;
          final color = categoryColors[entry.key] ?? LiquidGlassColors.auroraIndigo;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getCategoryLabel(entry.key),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '\$${entry.value.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: color.withAlpha(40),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }),
        Divider(color: isDark ? Colors.white24 : Colors.black12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: LiquidGlassColors.auroraIndigo,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTripInfoCard(BuildContext context, TripModel trip, bool isDark) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            _GlassInfoRow(
              icon: Icons.location_on_outlined,
              label: l10n(context).destination,
              value: trip.displayDestination,
              isDark: isDark,
            ),
            const SizedBox(height: 12),

            if (trip.startDate != null && trip.endDate != null) ...[
              _GlassInfoRow(
                icon: Icons.calendar_today_outlined,
                label: l10n(context).dates,
                value: '${dateFormat.format(trip.startDate!)} - ${dateFormat.format(trip.endDate!)}',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
            ],

            if (trip.description != null && trip.description!.isNotEmpty)
              _GlassInfoRow(
                icon: Icons.notes_outlined,
                label: l10n(context).notes,
                value: trip.description!,
                isDark: isDark,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripMembersSection(BuildContext context, WidgetRef ref, TripModel trip) {
    return TripMembersCard(
      tripId: tripId,
      isOwner: trip.isOwner,
      onShareTap: () => ShareTripSheet.show(
        context,
        tripId: tripId,
        tripTitle: trip.displayTitle,
      ),
    );
  }

  Widget _buildJournalSection(
    BuildContext context,
    TripModel trip,
    AsyncValue<List<JournalModel>> journalAsync,
    bool isDark,
  ) {
    return GlassCard(
      child: InkWell(
        onTap: () => context.push('/trips/$tripId/journal'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_stories,
                        color: LiquidGlassColors.oceanTeal,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Trip Journal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              journalAsync.when(
                loading: () => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        LiquidGlassColors.oceanTeal,
                      ),
                    ),
                  ),
                ),
                error: (_, __) => Text(
                  'Error loading journal',
                  style: TextStyle(color: LiquidGlassColors.sunsetRose),
                ),
                data: (entries) {
                  if (entries.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: LiquidGlassColors.oceanTeal.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: LiquidGlassColors.oceanTeal.withAlpha(51),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_note,
                            color: LiquidGlassColors.oceanTeal,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start Your Travel Journal',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Document your ${trip.displayDestination} adventure!',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Row(
                        children: [
                          _JournalStatBadge(
                            icon: Icons.edit_note,
                            value: '${entries.length}',
                            label: 'entries',
                            isDark: isDark,
                          ),
                          const SizedBox(width: 16),
                          if (entries.any((e) => e.aiGenerated))
                            _JournalStatBadge(
                              icon: Icons.auto_awesome,
                              value: '${entries.where((e) => e.aiGenerated).length}',
                              label: 'AI generated',
                              isDark: isDark,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _JournalEntryPreview(
                        entry: entries.last,
                        dayNumber: entries.last.getDayNumber(
                          trip.startDate ?? entries.last.entryDate,
                        ),
                        isDark: isDark,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAITipsSection(BuildContext context, TripModel trip, bool isDark, AppLocalizations l10n) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LiquidGlassColors.auroraGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Travel Tips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: LiquidGlassColors.auroraIndigo.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: LiquidGlassColors.auroraIndigo.withAlpha(51),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: LiquidGlassColors.auroraIndigo,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chat with Waylo to get personalized recommendations for ${trip.displayDestination}!',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GhostButton(
              label: 'Ask Waylo',
              icon: Icons.chat_outlined,
              onPressed: () => context.push('/chat/new'),
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentExpenses(
    BuildContext context,
    AsyncValue<List<ExpenseModel>> expensesAsync,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentExpenses,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.expenses),
              child: Text(
                l10n.viewAll,
                style: TextStyle(
                  color: LiquidGlassColors.auroraIndigo,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        expensesAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                LiquidGlassColors.auroraIndigo,
              ),
            ),
          ),
          error: (_, __) => Text(
            l10n.errorOccurred,
            style: TextStyle(color: LiquidGlassColors.sunsetRose),
          ),
          data: (expenses) {
            if (expenses.isEmpty) {
              return GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 40,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.noExpensesRecorded,
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final recentExpenses = expenses.take(5).toList();
            return GlassCard(
              child: Column(
                children: recentExpenses.asMap().entries.map((entry) {
                  final index = entry.key;
                  final expense = entry.value;
                  return Column(
                    children: [
                      _ExpenseListItem(expense: expense, isDark: isDark),
                      if (index < recentExpenses.length - 1)
                        Divider(
                          height: 1,
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error, bool isDark) {
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
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            PremiumButton.solid(
              label: 'Try Again',
              icon: Icons.refresh,
              onPressed: () => ref.invalidate(tripByIdProvider(tripId)),
              color: LiquidGlassColors.sunsetRose,
              width: 160,
            ),
          ],
        ),
      ),
    );
  }

  ({String label, IconData icon, Color color}) _getStatusInfo(TripModel trip, AppLocalizations l10n) {
    if (trip.isActive) {
      return (
        label: l10n.ongoing,
        icon: Icons.flight_takeoff,
        color: LiquidGlassColors.mintEmerald,
      );
    } else if (trip.isUpcoming) {
      return (
        label: l10n.planning,
        icon: Icons.schedule,
        color: LiquidGlassColors.auroraIndigo,
      );
    } else if (trip.isCompleted) {
      return (
        label: l10n.completed,
        icon: Icons.check_circle_outline,
        color: LiquidGlassColors.oceanTeal,
      );
    } else {
      return (
        label: l10n.planning,
        icon: Icons.edit_calendar,
        color: LiquidGlassColors.sunsetOrange,
      );
    }
  }

  String? _getDaysInfo(TripModel trip, AppLocalizations l10n) {
    if (trip.startDate == null || trip.endDate == null) return null;

    final now = DateTime.now();
    if (trip.isActive) {
      final daysLeft = trip.endDate!.difference(now).inDays;
      return daysLeft == 0
          ? 'Last day of your trip!'
          : '${l10n.daysLeft(daysLeft)}';
    } else if (trip.isUpcoming) {
      final daysUntil = trip.startDate!.difference(now).inDays;
      return daysUntil == 0
          ? 'Trip starts today!'
          : 'Starts in $daysUntil days';
    }
    return null;
  }

  String _getCategoryLabel(String category) {
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
}

// Helper Widgets

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool isDestructive;

  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? LiquidGlassColors.sunsetRose
        : (isDark ? Colors.white : Colors.black87);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;

  const _GlassStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? Colors.white.withAlpha(15)
                  : Colors.white.withAlpha(128),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(26)
                    : Colors.white.withAlpha(179),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _GlassInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white60 : Colors.black54,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpenseListItem extends StatelessWidget {
  final ExpenseModel expense;
  final bool isDark;

  const _ExpenseListItem({
    required this.expense,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');

    final categoryColors = {
      'transport': LiquidGlassColors.auroraIndigo,
      'accommodation': LiquidGlassColors.auroraPurple,
      'food': LiquidGlassColors.sunsetOrange,
      'activities': LiquidGlassColors.oceanTeal,
      'shopping': LiquidGlassColors.sunsetRose,
      'other': LiquidGlassColors.mintEmerald,
    };

    final categoryColor = categoryColors[expense.category] ?? LiquidGlassColors.auroraIndigo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: categoryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(expense.category),
              color: categoryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  expense.expenseDate != null
                      ? dateFormat.format(expense.expenseDate!)
                      : 'No date',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${expense.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
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
      default:
        return Icons.receipt_long;
    }
  }
}

class _JournalStatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  const _JournalStatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: LiquidGlassColors.oceanTeal),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _JournalEntryPreview extends StatelessWidget {
  final JournalModel entry;
  final int dayNumber;
  final bool isDark;

  const _JournalEntryPreview({
    required this.entry,
    required this.dayNumber,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(10) : Colors.white.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LiquidGlassColors.auroraGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Day $dayNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                dateFormat.format(entry.entryDate),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const Spacer(),
              if (entry.mood != null)
                Text(entry.mood!.emoji, style: const TextStyle(fontSize: 16)),
              if (entry.aiGenerated) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.auto_awesome,
                  size: 12,
                  color: LiquidGlassColors.oceanTeal,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (entry.title != null && entry.title!.isNotEmpty) ...[
            Text(
              entry.title!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
          ],
          Text(
            entry.content,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

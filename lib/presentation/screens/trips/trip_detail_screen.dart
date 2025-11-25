import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/trip_model.dart';
import '../../providers/currency_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/trips_provider.dart';

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
    final homeCurrency = ref.watch(userHomeCurrencyProvider);

    return tripAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Trip Details')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Trip Details')),
        body: _buildErrorState(context, ref, error),
      ),
      data: (trip) {
        if (trip == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Trip Details')),
            body: const Center(child: Text('Trip not found')),
          );
        }
        return _buildTripDetail(context, ref, trip, expensesAsync, homeCurrency);
      },
    );
  }

  Widget _buildTripDetail(
    BuildContext context,
    WidgetRef ref,
    TripModel trip,
    AsyncValue<List<ExpenseModel>> expensesAsync,
    String homeCurrency,
  ) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(tripByIdProvider(tripId));
          ref.invalidate(tripExpensesProvider(tripId));
        },
        child: CustomScrollView(
          slivers: [
            // Collapsible App Bar with Cover Image
            _buildSliverAppBar(context, trip),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trip Status Banner
                    _buildStatusBanner(context, trip),
                    const SizedBox(height: 20),

                    // Quick Stats Row
                    _buildQuickStats(context, trip, expensesAsync, homeCurrency),
                    const SizedBox(height: 20),

                    // Expense Summary Card
                    _buildExpenseSummary(context, ref, trip, expensesAsync, homeCurrency),
                    const SizedBox(height: 20),

                    // Trip Info Card
                    _buildTripInfoCard(context, trip),
                    const SizedBox(height: 20),

                    // AI Tips Section (placeholder for now)
                    _buildAITipsSection(context, trip),
                    const SizedBox(height: 20),

                    // Recent Expenses
                    _buildRecentExpenses(context, expensesAsync),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addExpense),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, TripModel trip) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          trip.destination,
          style: const TextStyle(
            shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover image or gradient
            trip.coverImageUrl != null
                ? Image.network(
                    trip.coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildDefaultCover(),
                  )
                : _buildDefaultCover(),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(179),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuAction(context, value, trip),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined),
                  SizedBox(width: 8),
                  Text('Edit Trip'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share_outlined),
                  SizedBox(width: 8),
                  Text('Share'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withAlpha(179),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.flight_takeoff,
          size: 64,
          color: Colors.white54,
        ),
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, TripModel trip) {
    final statusInfo = _getStatusInfo(trip);
    final daysInfo = _getDaysInfo(trip);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusInfo.color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusInfo.color.withAlpha(77)),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusInfo.color.withAlpha(51),
              shape: BoxShape.circle,
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusInfo.color,
                      ),
                ),
                if (daysInfo != null)
                  Text(
                    daysInfo,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
              ],
            ),
          ),

          // Budget progress (if set)
          if (trip.budget != null && trip.budget! > 0)
            _buildBudgetIndicator(context, trip),
        ],
      ),
    );
  }

  Widget _buildBudgetIndicator(BuildContext context, TripModel trip) {
    // This would need actual expense data to calculate progress
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Budget',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        Text(
          '${trip.budgetCurrency} ${trip.budget!.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    TripModel trip,
    AsyncValue<List<ExpenseModel>> expensesAsync,
    String homeCurrency,
  ) {
    final expenses = expensesAsync.valueOrNull ?? [];
    final totalSpent = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final tripDays = trip.durationDays;

    return Row(
      children: [
        // Total Spent
        Expanded(
          child: _StatCard(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Total Spent',
            value: '\$${totalSpent.toStringAsFixed(0)}',
            color: AppTheme.primaryColor,
            onTap: () => context.push(AppRoutes.expenses),
          ),
        ),
        const SizedBox(width: 12),

        // Trip Duration
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_today_outlined,
            label: 'Duration',
            value: '$tripDays days',
            color: AppTheme.accentColor,
            onTap: null,
          ),
        ),
        const SizedBox(width: 12),

        // Expenses Count
        Expanded(
          child: _StatCard(
            icon: Icons.receipt_long_outlined,
            label: 'Expenses',
            value: '${expenses.length}',
            color: AppTheme.successColor,
            onTap: () => context.push(AppRoutes.expenses),
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
  ) {
    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.expenses),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expense Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              expensesAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => const Text('Error loading expenses'),
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
                              color: AppTheme.textHint,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No expenses yet',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return _buildCategoryBreakdown(context, expenses);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(BuildContext context, List<ExpenseModel> expenses) {
    // Group by category
    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        // Category bars
        ...sortedCategories.take(4).map((entry) {
          final percentage = total > 0 ? (entry.value / total) : 0.0;
          final color = AppTheme.categoryColors[entry.key] ?? AppTheme.textSecondary;

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
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '\$${entry.value.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: color.withAlpha(26),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }),

        // Total
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTripInfoCard(BuildContext context, TripModel trip) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Destination
            _InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Destination',
              value: trip.destination,
            ),
            const SizedBox(height: 12),

            // Dates
            if (trip.startDate != null && trip.endDate != null) ...[
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Dates',
                value:
                    '${dateFormat.format(trip.startDate!)} - ${dateFormat.format(trip.endDate!)}',
              ),
              const SizedBox(height: 12),
            ],

            // Description
            if (trip.description != null && trip.description!.isNotEmpty) ...[
              _InfoRow(
                icon: Icons.notes_outlined,
                label: 'Notes',
                value: trip.description!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAITipsSection(BuildContext context, TripModel trip) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Travel Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chat with TripBuddy to get personalized recommendations for ${trip.destination}!',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/chat/new'),
                icon: const Icon(Icons.chat_outlined),
                label: const Text('Ask TripBuddy'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentExpenses(
    BuildContext context,
    AsyncValue<List<ExpenseModel>> expensesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Expenses',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.expenses),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        expensesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Error loading expenses'),
          data: (expenses) {
            if (expenses.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 40,
                          color: AppTheme.textHint,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No expenses recorded yet',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final recentExpenses = expenses.take(5).toList();
            return Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentExpenses.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final expense = recentExpenses[index];
                  return _ExpenseListItem(expense: expense);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text('Something went wrong', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(tripByIdProvider(tripId)),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action, TripModel trip) {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit trip
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit trip coming soon')),
        );
        break;
      case 'share':
        // TODO: Implement share
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share coming soon')),
        );
        break;
      case 'delete':
        // TODO: Show delete confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delete coming soon')),
        );
        break;
    }
  }

  ({String label, IconData icon, Color color}) _getStatusInfo(TripModel trip) {
    if (trip.isActive) {
      return (
        label: 'Trip in Progress',
        icon: Icons.flight_takeoff,
        color: AppTheme.successColor,
      );
    } else if (trip.isUpcoming) {
      return (
        label: 'Upcoming Trip',
        icon: Icons.schedule,
        color: AppTheme.primaryColor,
      );
    } else if (trip.isCompleted) {
      return (
        label: 'Completed',
        icon: Icons.check_circle_outline,
        color: AppTheme.textSecondary,
      );
    } else {
      return (
        label: 'Planning',
        icon: Icons.edit_calendar,
        color: AppTheme.accentColor,
      );
    }
  }

  String? _getDaysInfo(TripModel trip) {
    if (trip.startDate == null || trip.endDate == null) return null;

    final now = DateTime.now();
    if (trip.isActive) {
      final daysLeft = trip.endDate!.difference(now).inDays;
      return daysLeft == 0
          ? 'Last day of your trip!'
          : '$daysLeft days remaining';
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
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

  const _ExpenseListItem({required this.expense});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d');
    final categoryColor =
        AppTheme.categoryColors[expense.category] ?? AppTheme.textSecondary;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: categoryColor.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getCategoryIcon(expense.category),
          color: categoryColor,
          size: 20,
        ),
      ),
      title: Text(
        expense.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        expense.expenseDate != null
            ? dateFormat.format(expense.expenseDate!)
            : 'No date',
        style: TextStyle(color: AppTheme.textSecondary),
      ),
      trailing: Text(
        '\$${expense.amount.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
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

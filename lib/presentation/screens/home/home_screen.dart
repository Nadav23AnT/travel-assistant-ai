import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../data/models/chat_models.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/trip_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/home/day_tip_card.dart';
import '../../widgets/home/journal_ready_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Load user's home currency from profile on first build
    ref.watch(loadUserHomeCurrencyProvider);

    // Load exchange rates for the user's home currency
    final homeCurrency = ref.watch(userHomeCurrencyProvider);
    final exchangeRatesState = ref.watch(exchangeRatesProvider);
    if (exchangeRatesState.rates.isEmpty && !exchangeRatesState.isLoading) {
      // Schedule the fetch after the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(exchangeRatesProvider.notifier).fetchRates(homeCurrency);
      });
    }

    final activeTripAsync = ref.watch(activeTripProvider);

    // Watch journal auto-generation (triggers on app open)
    final showJournalReady = ref.watch(shouldShowJournalReadyProvider);
    final journalReadyData = ref.watch(journalReadyDataProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              _buildWelcomeHeader(context, ref),
              const SizedBox(height: 24),

              // Journal Ready notification (shows when trip ended)
              if (showJournalReady && journalReadyData != null)
                JournalReadyCard(
                  result: journalReadyData,
                  onDismiss: ref.read(dismissJournalNotificationProvider),
                ),
              if (showJournalReady && journalReadyData != null)
                const SizedBox(height: 16),

              // Active trip card
              activeTripAsync.when(
                loading: () => const _TripCardLoading(),
                error: (error, stack) => _buildNoActiveTripCard(context),
                data: (trip) => trip != null
                    ? _buildActiveTripCard(context, trip)
                    : _buildNoActiveTripCard(context),
              ),
              const SizedBox(height: 24),

              // Quick actions
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // Day Tip (AI-powered destination tips)
              const DayTipCard(),
              const SizedBox(height: 24),

              // Recent Chats
              _buildRecentChats(context, ref),
              const SizedBox(height: 24),

              // Recent expenses
              _buildRecentExpenses(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final userName = user?.userMetadata?['full_name'] as String? ??
                     user?.email?.split('@').first ??
                     'Traveler';

    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = l10n.welcomeGreetingMorning;
    } else if (hour < 17) {
      greeting = l10n.welcomeGreetingAfternoon;
    } else {
      greeting = l10n.welcomeGreetingEvening;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              Text(
                '$userName!',
                style: Theme.of(context).textTheme.displaySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Row(
          children: [
            // Reset button for testing
            IconButton(
              onPressed: () => _showResetDialog(context, ref),
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset data (for testing)',
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryLight,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'T',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.resetDataTitle),
        content: Text(l10n.resetDataMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _resetUserData(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }

  Future<void> _resetUserData(BuildContext context, WidgetRef ref) async {
    // Store navigator and router before async gap
    final navigator = Navigator.of(context, rootNavigator: true);
    final router = GoRouter.of(context);

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Reset user data
      final authService = ref.read(authServiceProvider);
      await authService.resetUserData();

      // Close loading dialog using stored navigator
      navigator.pop();

      // Navigate to onboarding using stored router
      router.go(AppRoutes.onboardingLanguages);
    } on AuthException catch (e) {
      // Close loading dialog
      navigator.pop();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset: ${e.message}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      // Handle any other errors
      navigator.pop();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Widget _buildActiveTripCard(BuildContext context, TripModel trip) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('MMM d');
    final dateRange = trip.startDate != null && trip.endDate != null
        ? '${dateFormat.format(trip.startDate!)} - ${dateFormat.format(trip.endDate!)}'
        : l10n.datesNotSet;

    final daysInfo = _getTripDaysInfo(context, trip);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/trips/${trip.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip header with flag background
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withAlpha(230),
                    AppTheme.primaryColor.withAlpha(180),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Large flag emoji as background
                  Positioned(
                    right: -20,
                    top: -10,
                    child: Text(
                      trip.flagEmoji,
                      style: const TextStyle(fontSize: 120),
                    ),
                  ),
                  // Gradient overlay for readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withAlpha(240),
                          AppTheme.primaryColor.withAlpha(100),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(51),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                trip.status.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              trip.flagEmoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          trip.displayTitle,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              trip.displayDestination,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Trip details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Dates
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dates,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateRange,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Days info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          daysInfo.label,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          daysInfo.value,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: daysInfo.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoActiveTripCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.createTrip),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.add_location_alt_outlined,
                size: 48,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noActiveTrip,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.startPlanningAdventure,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.createTrip),
                icon: const Icon(Icons.add),
                label: Text(l10n.createNewTrip),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _TripDaysInfo _getTripDaysInfo(BuildContext context, TripModel trip) {
    final l10n = AppLocalizations.of(context);

    if (trip.startDate == null || trip.endDate == null) {
      return _TripDaysInfo(
        label: l10n.duration,
        value: l10n.notSet,
        color: AppTheme.textSecondary,
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(
      trip.startDate!.year,
      trip.startDate!.month,
      trip.startDate!.day,
    );
    final endDate = DateTime(
      trip.endDate!.year,
      trip.endDate!.month,
      trip.endDate!.day,
    );

    if (today.isBefore(startDate)) {
      final daysUntil = startDate.difference(today).inDays;
      return _TripDaysInfo(
        label: l10n.startsIn,
        value: '$daysUntil ${daysUntil == 1 ? l10n.day : l10n.days}',
        color: AppTheme.primaryColor,
      );
    } else if (today.isAfter(endDate)) {
      return _TripDaysInfo(
        label: l10n.status,
        value: l10n.completed,
        color: AppTheme.successColor,
      );
    } else {
      final dayNumber = today.difference(startDate).inDays + 1;
      final totalDays = endDate.difference(startDate).inDays + 1;
      return _TripDaysInfo(
        label: l10n.current,
        value: l10n.dayOfTotal(dayNumber, totalDays),
        color: AppTheme.accentColor,
      );
    }
  }

  Widget _buildQuickActions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add,
                label: l10n.newTrip,
                color: AppTheme.primaryColor,
                onTap: () => context.push(AppRoutes.createTrip),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.receipt_long,
                label: l10n.addExpense,
                color: AppTheme.accentColor,
                onTap: () => context.push(AppRoutes.addExpense),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.chat_bubble,
                label: l10n.aiChat,
                color: AppTheme.successColor,
                onTap: () => context.go(AppRoutes.chat),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentChats(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recentChatsAsync = ref.watch(recentChatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentChats,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.chat),
              child: Text(l10n.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        recentChatsAsync.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 32,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.failedToLoadChats,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          data: (chats) {
            if (chats.isEmpty) {
              return Card(
                child: InkWell(
                  onTap: () => context.go(AppRoutes.chat),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 32,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.startConversation,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => context.go(AppRoutes.chat),
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(l10n.newChat),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: chats.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return _buildChatItem(context, chats[index]);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChatItem(BuildContext context, ChatSession chat) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('MMM d');
    final timeFormat = DateFormat('h:mm a');
    final now = DateTime.now();
    final chatDate = chat.updatedAt;

    // Format time: "Today 2:30 PM" or "Dec 15"
    String timeText;
    if (chatDate.year == now.year &&
        chatDate.month == now.month &&
        chatDate.day == now.day) {
      timeText = '${l10n.today} ${timeFormat.format(chatDate)}';
    } else if (chatDate.year == now.year &&
               chatDate.month == now.month &&
               chatDate.day == now.day - 1) {
      timeText = l10n.yesterday;
    } else {
      timeText = dateFormat.format(chatDate);
    }

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.chat_bubble,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        chat.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        timeText,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.textSecondary,
      ),
      onTap: () => context.push('/chat/${chat.id}'),
    );
  }

  Widget _buildRecentExpenses(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recentExpensesAsync = ref.watch(defaultRecentExpensesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.recentExpenses,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.expenses),
              child: Text(l10n.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        recentExpensesAsync.when(
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 32,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.failedToLoadExpenses,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          data: (expenses) {
            if (expenses.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_outlined,
                          size: 32,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.noExpensesRecorded,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expenses.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return _buildExpenseItem(context, expenses[index]);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildExpenseItem(BuildContext context, ExpenseModel expense) {
    final dateFormat = DateFormat('MMM d');
    final categoryIcon = _getCategoryIcon(expense.category);
    final categoryColor = AppTheme.categoryColors[expense.category] ?? AppTheme.textSecondary;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: categoryColor.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          categoryIcon,
          color: categoryColor,
          size: 20,
        ),
      ),
      title: Text(
        expense.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        expense.expenseDate != null
            ? dateFormat.format(expense.expenseDate!)
            : 'No date',
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Text(
        '${expense.amount.toStringAsFixed(2)} ${expense.currency}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: categoryColor,
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

class _TripDaysInfo {
  final String label;
  final String value;
  final Color color;

  _TripDaysInfo({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _TripCardLoading extends StatelessWidget {
  const _TripCardLoading();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

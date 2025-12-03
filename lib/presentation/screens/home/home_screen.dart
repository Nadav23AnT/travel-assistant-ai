import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/routes.dart';
import '../../../core/design/design_system.dart';
import '../../../data/models/chat_models.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/trip_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/auth_service.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/trips_provider.dart';
import '../../providers/welcome_banner_provider.dart';
import '../../widgets/home/daily_welcome_dialog.dart';
import '../../widgets/home/day_tip_card.dart';
import '../../widgets/home/journal_ready_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Load user's home currency from profile on first build
    ref.watch(loadUserHomeCurrencyProvider);

    // Load exchange rates for the user's home currency
    final homeCurrency = ref.watch(userHomeCurrencyProvider);
    final exchangeRatesState = ref.watch(exchangeRatesProvider);
    if (exchangeRatesState.rates.isEmpty && !exchangeRatesState.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(exchangeRatesProvider.notifier).fetchRates(homeCurrency);
      });
    }

    final activeTripAsync = ref.watch(activeTripProvider);

    // Watch journal auto-generation (triggers on app open)
    final showJournalReady = ref.watch(shouldShowJournalReadyProvider);
    final journalReadyData = ref.watch(journalReadyDataProvider);

    // Show daily welcome banner on first login of the day
    ref.listen<AsyncValue<bool>>(shouldShowWelcomeBannerProvider, (_, next) {
      next.whenData((shouldShow) {
        if (shouldShow) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDailyWelcomeDialog(context, ref);
          });
        }
      });
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
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
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildWelcomeHeader(context, ref, isDark),
                ),
              ),

              // Journal Ready notification
              if (showJournalReady && journalReadyData != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: JournalReadyCard(
                      result: journalReadyData,
                      onDismiss: ref.read(dismissJournalNotificationProvider),
                    ),
                  ),
                ),

              // Active trip card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                  child: activeTripAsync.when(
                    loading: () => const _TripCardLoading(),
                    error: (error, stack) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildNoActiveTripCard(context, isDark),
                    ),
                    data: (trip) => trip != null
                        ? Consumer(
                            builder: (context, ref, _) {
                              final totalSpentAsync = ref.watch(
                                tripTotalSpentProvider(trip.id),
                              );
                              return PremiumTripCard(
                                trip: trip,
                                totalSpent: totalSpentAsync.valueOrNull,
                                onTap: () => context.push('/trips/${trip.id}'),
                              );
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildNoActiveTripCard(context, isDark),
                          ),
                  ),
                ),
              ),

              // Quick actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: _buildQuickActions(context, isDark),
                ),
              ),

              // Day Tip
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: DayTipCard(),
                ),
              ),

              // Recent Chats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: _buildRecentChats(context, ref, isDark),
                ),
              ),

              // Recent Expenses
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 100),
                  child: _buildRecentExpenses(context, ref, isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, WidgetRef ref, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final userName = user?.userMetadata?['full_name'] as String? ??
        user?.email?.split('@').first ??
        'Traveler';
    final isAdmin = ref.watch(isAdminProvider).valueOrNull ?? false;

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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$userName!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: -0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Row(
          children: [
            // Reset button (admin only - for testing)
            if (isAdmin) ...[
              GlowingIconButton(
                icon: Icons.refresh_rounded,
                onPressed: () => _showResetDialog(context, ref),
                size: 44,
              ),
              const SizedBox(width: 12),
            ],
            // Avatar - tap to go to profile
            GestureDetector(
              onTap: () => context.go(AppRoutes.profile),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LiquidGlassColors.auroraGradient,
                  boxShadow: isDark
                      ? LiquidGlassColors.neonGlow(
                          LiquidGlassColors.auroraIndigo,
                          intensity: 0.4,
                          blur: 16,
                        )
                      : [
                          BoxShadow(
                            color: LiquidGlassColors.auroraIndigo.withAlpha(77),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'T',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: isDark
              ? const Color(0xFF1A1F2E)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            l10n.resetDataTitle,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Text(
            l10n.resetDataMessage,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          actions: [
            GhostButton(
              label: l10n.cancel,
              onPressed: () => Navigator.of(dialogContext).pop(),
              width: 100,
              height: 44,
            ),
            const SizedBox(width: 8),
            PremiumButton.solid(
              label: l10n.reset,
              color: LiquidGlassColors.sunsetRose,
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _resetUserData(context, ref);
              },
              width: 100,
              height: 44,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetUserData(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final router = GoRouter.of(context);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1A1F2E)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                LiquidGlassColors.auroraIndigo,
              ),
            ),
          ),
        ),
      );

      final authService = ref.read(authServiceProvider);
      await authService.resetUserData();

      navigator.pop();
      router.go(AppRoutes.onboardingLanguages);
    } on AuthException catch (e) {
      navigator.pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset: ${e.message}'),
            backgroundColor: LiquidGlassColors.sunsetRose,
          ),
        );
      }
    } catch (e) {
      navigator.pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: LiquidGlassColors.sunsetRose,
          ),
        );
      }
    }
  }

  Widget _buildNoActiveTripCard(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return GlassCard(
      padding: const EdgeInsets.all(32),
      onTap: () => context.push(AppRoutes.createTrip),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LiquidGlassColors.auroraGradient,
              boxShadow: isDark
                  ? LiquidGlassColors.neonGlow(
                      LiquidGlassColors.auroraIndigo,
                      intensity: 0.4,
                      blur: 24,
                    )
                  : [
                      BoxShadow(
                        color: LiquidGlassColors.auroraIndigo.withAlpha(77),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: const Icon(
              Icons.add_location_alt_outlined,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noActiveTrip,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.startPlanningAdventure,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PremiumButton.gradient(
            label: l10n.createNewTrip,
            icon: Icons.add,
            onPressed: () => context.push(AppRoutes.createTrip),
            width: 200,
            height: 52,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_rounded,
                label: l10n.newTrip,
                gradient: LiquidGlassColors.auroraGradient,
                onTap: () => context.push(AppRoutes.createTrip),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.receipt_long_rounded,
                label: l10n.addExpense,
                gradient: LiquidGlassColors.oceanGradient,
                onTap: () => context.push(AppRoutes.addExpense),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.chat_bubble_rounded,
                label: l10n.aiChat,
                gradient: LiquidGlassColors.mintGradient,
                onTap: () => context.go(AppRoutes.chat),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.account_balance_wallet_rounded,
                label: l10n.expenses,
                gradient: LiquidGlassColors.sunsetGradient,
                onTap: () => context.go(AppRoutes.expenses),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentChats(BuildContext context, WidgetRef ref, bool isDark) {
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () => context.go(AppRoutes.chat),
              child: Text(
                l10n.viewAll,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: LiquidGlassColors.auroraIndigo,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        recentChatsAsync.when(
          loading: () => GlassCard(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  LiquidGlassColors.auroraIndigo,
                ),
              ),
            ),
          ),
          error: (error, stack) => GlassCard(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 32,
                    color: LiquidGlassColors.sunsetRose,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.failedToLoadChats,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          data: (chats) {
            if (chats.isEmpty) {
              return GlassCard(
                padding: const EdgeInsets.all(24),
                onTap: () => context.go(AppRoutes.chat),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: LiquidGlassColors.mintEmerald.withAlpha(30),
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          size: 28,
                          color: LiquidGlassColors.mintEmerald,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.startConversation,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      PremiumButton.solid(
                        label: l10n.newChat,
                        icon: Icons.add,
                        color: LiquidGlassColors.mintEmerald,
                        onPressed: () => context.go(AppRoutes.chat),
                        width: 140,
                        height: 44,
                      ),
                    ],
                  ),
                ),
              );
            }

            return GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: chats.asMap().entries.map((entry) {
                  final index = entry.key;
                  final chat = entry.value;
                  return Column(
                    children: [
                      _buildChatItem(context, chat, isDark),
                      if (index < chats.length - 1)
                        Divider(
                          height: 1,
                          color: isDark
                              ? Colors.white.withAlpha(20)
                              : Colors.black.withAlpha(10),
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

  Widget _buildChatItem(BuildContext context, ChatSession chat, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('MMM d');
    final timeFormat = DateFormat('h:mm a');
    final now = DateTime.now();
    final chatDate = chat.updatedAt;

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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/chat/${chat.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: LiquidGlassColors.mintEmerald.withAlpha(isDark ? 40 : 25),
                ),
                child: Icon(
                  Icons.chat_bubble_rounded,
                  size: 20,
                  color: LiquidGlassColors.mintEmerald,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeText,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white.withAlpha(128) : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white30 : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentExpenses(BuildContext context, WidgetRef ref, bool isDark) {
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () => context.go(AppRoutes.expenses),
              child: Text(
                l10n.viewAll,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: LiquidGlassColors.auroraIndigo,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        recentExpensesAsync.when(
          loading: () => GlassCard(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  LiquidGlassColors.auroraIndigo,
                ),
              ),
            ),
          ),
          error: (error, stack) => GlassCard(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 32,
                    color: LiquidGlassColors.sunsetRose,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.failedToLoadExpenses,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          data: (expenses) {
            if (expenses.isEmpty) {
              return GlassCard(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: LiquidGlassColors.oceanSky.withAlpha(30),
                        ),
                        child: Icon(
                          Icons.receipt_outlined,
                          size: 28,
                          color: LiquidGlassColors.oceanSky,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noExpensesRecorded,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: expenses.asMap().entries.map((entry) {
                  final index = entry.key;
                  final expense = entry.value;
                  return Column(
                    children: [
                      _buildExpenseItem(context, expense, isDark),
                      if (index < expenses.length - 1)
                        Divider(
                          height: 1,
                          color: isDark
                              ? Colors.white.withAlpha(20)
                              : Colors.black.withAlpha(10),
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

  Widget _buildExpenseItem(BuildContext context, ExpenseModel expense, bool isDark) {
    final dateFormat = DateFormat('MMM d');
    final categoryColor = _getCategoryColor(expense.category);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: categoryColor.withAlpha(isDark ? 40 : 25),
            ),
            child: Icon(
              _getCategoryIcon(expense.category),
              size: 20,
              color: categoryColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expense.expenseDate != null
                      ? dateFormat.format(expense.expenseDate!)
                      : 'No date',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white.withAlpha(128) : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${expense.amount.toStringAsFixed(2)} ${expense.currency}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: categoryColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
        return LiquidGlassColors.categoryTransport;
      case 'accommodation':
        return LiquidGlassColors.categoryAccommodation;
      case 'food':
        return LiquidGlassColors.categoryFood;
      case 'activities':
        return LiquidGlassColors.categoryActivities;
      case 'shopping':
        return LiquidGlassColors.categoryShopping;
      default:
        return LiquidGlassColors.categoryOther;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
        return Icons.directions_car_rounded;
      case 'accommodation':
        return Icons.hotel_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      case 'activities':
        return Icons.attractions_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }
}

class _TripCardLoading extends StatelessWidget {
  const _TripCardLoading();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  LiquidGlassColors.auroraIndigo,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading trip...',
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
}

class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final bool isDark;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: widget.isDark
                    ? Colors.white.withAlpha(20)
                    : Colors.white.withAlpha(179),
                border: Border.all(
                  width: 1.5,
                  color: widget.isDark
                      ? Colors.white.withAlpha(31)
                      : Colors.white.withAlpha(128),
                ),
                boxShadow: widget.isDark
                    ? LiquidGlassColors.neonGlow(
                        widget.gradient.colors.first,
                        intensity: _isPressed ? 0.5 : 0.25,
                        blur: 20,
                      )
                    : [
                        BoxShadow(
                          color: widget.gradient.colors.first.withAlpha(51),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.gradient,
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

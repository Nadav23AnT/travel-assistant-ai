import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/design/design_system.dart';
import '../../../data/models/expense_split_model.dart';
import '../../../data/models/trip_member_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/currency_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/trip_sharing_provider.dart';

/// Internal model for balance calculation
class _UserBalance {
  final String userId;
  String userName;
  String? avatarUrl;
  double totalPaid = 0;
  double totalOwed = 0;
  double balance = 0;

  _UserBalance({
    required this.userId,
    required this.userName,
    this.avatarUrl,
  });
}

class SettlementsScreen extends ConsumerWidget {
  final String tripId;
  final String? displayCurrency;

  const SettlementsScreen({
    super.key,
    required this.tripId,
    this.displayCurrency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use client-side balance calculation with currency conversion
    final expensesAsync = ref.watch(tripExpensesProvider(tripId));
    final splitsAsync = ref.watch(tripUnsettledSplitsProvider(tripId));
    final membersAsync = ref.watch(tripMembersProvider(tripId));
    final exchangeRates = ref.watch(exchangeRatesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final targetCurrency = displayCurrency ?? 'USD';

    // Build user info map from trip members
    final members = membersAsync.value ?? [];
    final userInfoMap = <String, TripMemberModel>{};
    for (final member in members) {
      userInfoMap[member.userId] = member;
    }

    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            l10n.settlements,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(tripExpensesProvider(tripId));
            ref.invalidate(tripUnsettledSplitsProvider(tripId));
            ref.invalidate(tripMembersProvider(tripId));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary section - now uses client-side calculation
                _buildSummarySection(
                  context,
                  ref,
                  expensesAsync,
                  splitsAsync,
                  exchangeRates,
                  targetCurrency,
                  userInfoMap,
                  isDark,
                  l10n,
                  currentUserId,
                ),
                const SizedBox(height: 24),

                // Unsettled splits section
                _buildUnsettledSplitsSection(
                    context, ref, splitsAsync, exchangeRates, targetCurrency, userInfoMap, isDark, l10n, currentUserId),
              ],
            ),
          ),
        ),
    );
  }

  /// Calculate balances from expenses and splits with currency conversion
  Map<String, _UserBalance> _calculateBalances({
    required List expenses,
    required List<ExpenseSplitModel> splits,
    required String targetCurrency,
    required ExchangeRatesState exchangeRates,
    required Map<String, TripMemberModel> userInfoMap,
    required WidgetRef ref,
  }) {
    final balances = <String, _UserBalance>{};

    // Helper to get user name from userInfoMap
    String getUserName(String userId) {
      final member = userInfoMap[userId];
      return member?.displayName ?? 'Unknown';
    }

    // Helper to get avatar from userInfoMap
    String? getAvatarUrl(String userId) {
      return userInfoMap[userId]?.avatarUrl;
    }

    // Helper to convert amount
    double convert(double amount, String fromCurrency) {
      if (fromCurrency == targetCurrency) return amount;
      if (exchangeRates.rates.isEmpty) return amount;
      return ref.read(exchangeRatesProvider.notifier).convert(
        amount,
        fromCurrency,
        targetCurrency,
      );
    }

    // Process each split
    for (final split in splits) {
      final currency = split.expenseCurrency ?? 'USD';
      final paidBy = split.expensePaidBy;

      // Convert split amount to target currency
      final convertedSplitAmount = convert(split.amount, currency);

      // User who has this split owes money - use userInfoMap for name
      balances.putIfAbsent(split.userId, () => _UserBalance(
        userId: split.userId,
        userName: getUserName(split.userId),
        avatarUrl: getAvatarUrl(split.userId),
      ));
      balances[split.userId]!.totalOwed += convertedSplitAmount;

      // User who paid gets credit (if we know who paid)
      if (paidBy != null) {
        final paidPortion = convert(split.amount, currency);

        // Use userInfoMap for payer info
        balances.putIfAbsent(paidBy, () => _UserBalance(
          userId: paidBy,
          userName: getUserName(paidBy),
          avatarUrl: getAvatarUrl(paidBy),
        ));
        balances[paidBy]!.totalPaid += paidPortion;
      }
    }

    // Calculate net balance for each user
    for (final balance in balances.values) {
      balance.balance = balance.totalPaid - balance.totalOwed;
    }

    return balances;
  }

  Widget _buildSummarySection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<dynamic> expensesAsync,
    AsyncValue<List<ExpenseSplitModel>> splitsAsync,
    ExchangeRatesState exchangeRates,
    String targetCurrency,
    Map<String, TripMemberModel> userInfoMap,
    bool isDark,
    AppLocalizations l10n,
    String? currentUserId,
  ) {
    // Wait for both to load
    if (expensesAsync.isLoading || splitsAsync.isLoading) {
      return _buildLoadingCard(isDark);
    }

    if (expensesAsync.hasError) {
      return _buildErrorCard(expensesAsync.error.toString(), isDark);
    }

    if (splitsAsync.hasError) {
      return _buildErrorCard(splitsAsync.error.toString(), isDark);
    }

    final expenses = expensesAsync.value ?? [];
    final splits = splitsAsync.value ?? [];

    // Calculate balances with currency conversion
    final balances = _calculateBalances(
      expenses: expenses,
      splits: splits,
      targetCurrency: targetCurrency,
      exchangeRates: exchangeRates,
      userInfoMap: userInfoMap,
      ref: ref,
    );

    // Get current user's balance
    final myBalance = balances[currentUserId];

    if (myBalance == null || myBalance.balance.abs() < 0.01) {
      return _buildAllSettledCard(isDark, l10n);
    }

    return _buildMyBalanceCard(myBalance, targetCurrency, isDark, l10n);
  }

  Widget _buildAllSettledCard(bool isDark, AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LiquidGlassColors.mintGradient,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(30),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'All Settled Up!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No outstanding balances for this trip',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(200),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyBalanceCard(
    _UserBalance balance,
    String currency,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final isOwed = balance.balance > 0;
    final absBalance = balance.balance.abs();
    final currencySymbol = _getCurrencySymbol(currency);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isOwed
                ? LiquidGlassColors.mintGradient
                : LinearGradient(
                    colors: [
                      LiquidGlassColors.sunsetRose,
                      LiquidGlassColors.sunsetRose.withAlpha(180),
                    ],
                  ),
          ),
          child: Column(
            children: [
              Text(
                isOwed ? 'You are owed' : 'You owe',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withAlpha(200),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$currencySymbol${absBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withAlpha(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOwed ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Total paid: $currencySymbol${balance.totalPaid.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    const symbols = {
      'USD': '\$',
      'EUR': '\u20AC',
      'GBP': '\u00A3',
      'ILS': '\u20AA',
      'JPY': '\u00A5',
      'THB': '\u0E3F',
    };
    return symbols[currency] ?? currency;
  }

  Widget _buildUnsettledSplitsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<ExpenseSplitModel>> splitsAsync,
    ExchangeRatesState exchangeRates,
    String targetCurrency,
    Map<String, TripMemberModel> userInfoMap,
    bool isDark,
    AppLocalizations l10n,
    String? currentUserId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pending Settlements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        splitsAsync.when(
          data: (splits) {
            if (splits.isEmpty) {
              return _buildEmptyState(isDark, l10n);
            }

            return Column(
              children: splits.map((split) {
                final isMyDebt = split.userId == currentUserId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildSplitCard(
                    context,
                    ref,
                    split,
                    isMyDebt,
                    exchangeRates,
                    targetCurrency,
                    userInfoMap,
                    isDark,
                    l10n,
                  ),
                );
              }).toList(),
            );
          },
          loading: () => _buildLoadingCard(isDark),
          error: (e, _) => _buildErrorCard(e.toString(), isDark),
        ),
      ],
    );
  }

  Widget _buildSplitCard(
    BuildContext context,
    WidgetRef ref,
    ExpenseSplitModel split,
    bool isMyDebt,
    ExchangeRatesState exchangeRates,
    String targetCurrency,
    Map<String, TripMemberModel> userInfoMap,
    bool isDark,
    AppLocalizations l10n,
  ) {
    // Convert amount to target currency
    final splitCurrency = split.expenseCurrency ?? 'USD';
    double convertedAmount = split.amount;
    if (splitCurrency != targetCurrency && exchangeRates.rates.isNotEmpty) {
      convertedAmount = ref.read(exchangeRatesProvider.notifier).convert(
        split.amount,
        splitCurrency,
        targetCurrency,
      );
    }
    final currencySymbol = _getCurrencySymbol(targetCurrency);

    // Determine which user to display based on debt direction
    // If I owe: show the payer (who I owe money to)
    // If someone owes me: show the debtor (who owes me)
    final displayUserId = isMyDebt ? split.expensePaidBy : split.userId;
    final displayMember = displayUserId != null ? userInfoMap[displayUserId] : null;

    // Get display name, avatar, and initials from trip member
    final displayName = displayMember?.displayName ?? 'Unknown';
    final avatarUrl = displayMember?.avatarUrl;
    final initials = displayMember?.initials ?? '?';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? Colors.white.withAlpha(10)
                : Colors.white.withAlpha(180),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(15)
                  : Colors.white.withAlpha(100),
            ),
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: isMyDebt
                    ? LiquidGlassColors.sunsetRose.withAlpha(30)
                    : LiquidGlassColors.mintEmerald.withAlpha(30),
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? Text(
                        initials,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isMyDebt
                              ? LiquidGlassColors.sunsetRose
                              : LiquidGlassColors.mintEmerald,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isMyDebt ? 'You owe' : 'Owes you',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              // Amount and settle button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$currencySymbol${convertedAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isMyDebt
                          ? LiquidGlassColors.sunsetRose
                          : LiquidGlassColors.mintEmerald,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _handleSettle(context, ref, split, targetCurrency),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LiquidGlassColors.mintGradient,
                      ),
                      child: const Text(
                        'Settle',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSettle(
    BuildContext context,
    WidgetRef ref,
    ExpenseSplitModel split,
    String currency,
  ) async {
    final currencySymbol = _getCurrencySymbol(currency);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Settlement'),
        content: Text(
          'Mark this $currencySymbol${split.amount.toStringAsFixed(2)} debt as settled?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: LiquidGlassColors.mintEmerald,
            ),
            child: const Text('Settle'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(splitOperationProvider.notifier)
          .settleSplit(split.id, tripId);
    }
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? Colors.white.withAlpha(10)
                : Colors.white.withAlpha(180),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: LiquidGlassColors.mintEmerald,
              ),
              const SizedBox(height: 16),
              Text(
                'No pending settlements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? Colors.white.withAlpha(10)
                : Colors.white.withAlpha(180),
          ),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                LiquidGlassColors.auroraIndigo,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: LiquidGlassColors.sunsetRose.withAlpha(30),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: LiquidGlassColors.sunsetRose),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error,
                  style: TextStyle(color: LiquidGlassColors.sunsetRose),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

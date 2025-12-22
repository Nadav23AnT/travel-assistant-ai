import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/design/design_system.dart';
import '../../../data/models/expense_split_model.dart';
import '../../../data/models/trip_member_model.dart';
import '../../providers/currency_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/trip_sharing_provider.dart';
import '../../screens/expenses/settlements_screen.dart';

/// Compact settlement summary card for expenses screen
/// Only visible for shared trips with non-zero balances
class SettlementSummaryCard extends ConsumerWidget {
  final String tripId;
  final String? displayCurrency;

  const SettlementSummaryCard({
    super.key,
    required this.tripId,
    this.displayCurrency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch expenses and splits for client-side balance calculation
    final expensesAsync = ref.watch(tripExpensesProvider(tripId));
    final splitsAsync = ref.watch(tripUnsettledSplitsProvider(tripId));
    final membersAsync = ref.watch(tripMembersProvider(tripId));
    final exchangeRates = ref.watch(exchangeRatesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final targetCurrency = displayCurrency ?? 'USD';

    // Wait for data to load
    if (expensesAsync.isLoading || splitsAsync.isLoading || membersAsync.isLoading) {
      return _buildLoadingCard(isDark);
    }

    if (expensesAsync.hasError) {
      return _buildErrorCard(expensesAsync.error.toString(), isDark, ref);
    }

    final expenses = expensesAsync.value ?? [];
    final splits = splitsAsync.value ?? [];
    final members = membersAsync.value ?? [];

    // Build user info map from trip members
    final userInfoMap = <String, TripMemberModel>{};
    for (final member in members) {
      userInfoMap[member.userId] = member;
    }

    // If no split expenses, hide the card
    if (splits.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate balances with currency conversion
    final balances = _calculateBalances(
      expenses: expenses,
      splits: splits,
      targetCurrency: targetCurrency,
      exchangeRates: exchangeRates,
      userInfoMap: userInfoMap,
      ref: ref,
    );

    // Only show if there are multiple members
    if (balances.length <= 1) {
      return const SizedBox.shrink();
    }

    // Filter to only show members with non-zero balances
    final activeBalances = balances.values.where((b) => b.balance.abs() > 0.01).toList();

    // If all balances are zero, show "All Settled" state
    if (activeBalances.isEmpty) {
      return _buildAllSettledCard(isDark);
    }

    // Get current user's balance
    final myBalance = balances[currentUserId];
    final currentUserOwes = myBalance != null && myBalance.balance < 0;

    // Get other members' balances
    final otherBalances = activeBalances.where((b) => b.userId != currentUserId).toList();

    return _buildSummaryCard(
      context,
      ref,
      myBalance,
      otherBalances,
      currentUserOwes,
      isDark,
      currentUserId,
      targetCurrency,
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

    // Helper to get user info from trip members
    String getUserName(String userId) {
      final member = userInfoMap[userId];
      return member?.displayName ?? 'Unknown';
    }

    String? getUserAvatar(String userId) {
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

      // User who has this split owes money - use trip members for name
      balances.putIfAbsent(split.userId, () => _UserBalance(
        userId: split.userId,
        userName: getUserName(split.userId),
        avatarUrl: getUserAvatar(split.userId),
      ));
      balances[split.userId]!.totalOwed += convertedSplitAmount;

      // User who paid gets credit (if we know who paid)
      if (paidBy != null) {
        final paidPortion = convert(split.amount, currency);

        // Use trip members for payer info
        balances.putIfAbsent(paidBy, () => _UserBalance(
          userId: paidBy,
          userName: getUserName(paidBy),
          avatarUrl: getUserAvatar(paidBy),
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

  Widget _buildSummaryCard(
    BuildContext context,
    WidgetRef ref,
    _UserBalance? myBalance,
    List<_UserBalance> otherBalances,
    bool currentUserOwes,
    bool isDark,
    String? currentUserId,
    String targetCurrency,
  ) {
    // Build settlement items from other members' balances
    final settlements = <_SettlementItem>[];

    for (final member in otherBalances) {
      final isOwed = member.balance < 0; // They have negative balance = they owe
      settlements.add(_SettlementItem(
        userId: member.userId,
        userName: member.userName.isNotEmpty ? member.userName : 'Unknown',
        avatarUrl: member.avatarUrl,
        initials: _getInitials(member.userName),
        amount: member.balance.abs(),
        // Current user can settle with members who are owed money (positive balance)
        // if current user owes money (negative balance)
        canSettle: currentUserOwes && member.balance > 0,
        isOwed: isOwed,
      ));
    }

    // Sort: show who you can settle with first
    settlements.sort((a, b) {
      if (a.canSettle && !b.canSettle) return -1;
      if (!a.canSettle && b.canSettle) return 1;
      return b.amount.compareTo(a.amount);
    });

    // Limit to max 3 visible
    final visibleSettlements = settlements.take(3).toList();
    final hasMore = settlements.length > 3;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withAlpha(15),
                      Colors.white.withAlpha(8),
                    ]
                  : [
                      Colors.white.withAlpha(200),
                      Colors.white.withAlpha(150),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(20)
                  : Colors.white.withAlpha(150),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LiquidGlassColors.auroraGradient,
                      ),
                      child: const Icon(
                        Icons.balance_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Settlement Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    // View All link
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettlementsScreen(tripId: tripId),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: LiquidGlassColors.auroraIndigo,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: LiquidGlassColors.auroraIndigo,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Container(
                height: 1,
                color: isDark
                    ? Colors.white.withAlpha(10)
                    : Colors.black.withAlpha(8),
              ),
              // Settlement items
              ...visibleSettlements.map((item) => _buildSettlementRow(
                    context,
                    ref,
                    item,
                    isDark,
                    targetCurrency,
                  )),
              // Show more indicator
              if (hasMore)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    '+${settlements.length - 3} more',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettlementRow(
    BuildContext context,
    WidgetRef ref,
    _SettlementItem item,
    bool isDark,
    String currency,
  ) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withAlpha(8)
                : Colors.black.withAlpha(5),
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar - green if they owe, red if they are owed
          CircleAvatar(
            radius: 22,
            backgroundColor: item.isOwed
                ? LiquidGlassColors.sunsetRose.withAlpha(30)  // They owe money
                : LiquidGlassColors.mintEmerald.withAlpha(30), // They are owed money
            backgroundImage: item.avatarUrl != null
                ? NetworkImage(item.avatarUrl!)
                : null,
            child: item.avatarUrl == null
                ? Text(
                    item.initials,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: item.isOwed
                          ? LiquidGlassColors.sunsetRose
                          : LiquidGlassColors.mintEmerald,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.isOwed
                      ? '${item.userName} owes'  // They have negative balance
                      : '${item.userName} is owed', // They have positive balance
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Amount - red if they owe, green if they are owed
          Text(
            _formatAmount(item.amount, currency),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: item.isOwed
                  ? LiquidGlassColors.sunsetRose  // They owe (red)
                  : LiquidGlassColors.mintEmerald, // They are owed (green)
            ),
          ),
          // Settle button (only when current user can settle)
          if (item.canSettle) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _showSettleDialog(context, ref, item, currency),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LiquidGlassColors.mintGradient,
                ),
                child: const Text(
                  'Settle',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showSettleDialog(
    BuildContext context,
    WidgetRef ref,
    _SettlementItem item,
    String currency,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Settlement'),
        content: Text(
          'Mark ${_formatAmount(item.amount, currency)} debt to ${item.userName} as settled?',
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

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(splitOperationProvider.notifier)
          .recordSettlement(
            tripId: tripId,
            toUserId: item.userId,
            amount: item.amount,
            currency: currency,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Settlement recorded successfully'
                  : 'Failed to record settlement',
            ),
            backgroundColor: success
                ? LiquidGlassColors.mintEmerald
                : LiquidGlassColors.sunsetRose,
          ),
        );
      }
    }
  }

  Widget _buildAllSettledCard(bool isDark) {
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(30),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'All Settled Up!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'No outstanding balances',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withAlpha(200),
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
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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

  Widget _buildErrorCard(String error, bool isDark, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: LiquidGlassColors.sunsetRose.withAlpha(30),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: LiquidGlassColors.sunsetRose),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Unable to load settlements',
                  style: TextStyle(color: LiquidGlassColors.sunsetRose),
                ),
              ),
              TextButton(
                onPressed: () => ref.invalidate(tripBalancesProvider(tripId)),
                child: Text(
                  'Retry',
                  style: TextStyle(color: LiquidGlassColors.auroraIndigo),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount, String currency) {
    final symbol = _getCurrencySymbol(currency);
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  String _getCurrencySymbol(String currency) {
    const symbols = {
      'USD': '\$',
      'EUR': '\u20AC',
      'GBP': '\u00A3',
      'ILS': '\u20AA',
      'JPY': '\u00A5',
    };
    return symbols[currency] ?? currency;
  }
}

/// Internal model for user balance calculation
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

/// Internal model for settlement items
class _SettlementItem {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final String initials;
  final double amount;
  final bool isOwed; // true = they owe (negative balance), false = they are owed (positive balance)
  final bool canSettle; // true if current user can settle with this person

  _SettlementItem({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.initials,
    required this.amount,
    required this.isOwed,
    this.canSettle = false,
  });
}

/// Helper to get initials from a name
String _getInitials(String name) {
  if (name.isEmpty) return '?';
  final parts = name.split(' ');
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return name[0].toUpperCase();
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/design_system.dart';
import '../../../data/models/expense_split_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/expenses_provider.dart';

class TripBalancesCard extends ConsumerWidget {
  final String tripId;
  final String? displayCurrency;

  const TripBalancesCard({
    super.key,
    required this.tripId,
    this.displayCurrency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balancesAsync = ref.watch(tripBalancesProvider(tripId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return balancesAsync.when(
      data: (balances) {
        // Filter to only show members with non-zero balances
        final activeBalances = balances.where((b) => b.balance != 0).toList();

        if (activeBalances.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildBalancesCard(context, activeBalances, isDark, l10n);
      },
      loading: () => _buildLoadingCard(isDark),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBalancesCard(
    BuildContext context,
    List<MemberBalanceModel> balances,
    bool isDark,
    AppLocalizations l10n,
  ) {
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.balances,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            '${balances.length} ${balances.length == 1 ? 'member' : 'members'} with balances',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
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
              // Balance items
              ...balances.map((balance) => _buildBalanceItem(
                    context,
                    balance,
                    isDark,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceItem(
    BuildContext context,
    MemberBalanceModel balance,
    bool isDark,
  ) {
    final isPositive = balance.balance > 0;
    final absBalance = balance.balance.abs();
    final currency = displayCurrency ?? 'USD';

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
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: isPositive
                ? LiquidGlassColors.mintEmerald.withAlpha(30)
                : LiquidGlassColors.sunsetRose.withAlpha(30),
            backgroundImage: balance.avatarUrl != null
                ? NetworkImage(balance.avatarUrl!)
                : null,
            child: balance.avatarUrl == null
                ? Text(
                    balance.initials,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isPositive
                          ? LiquidGlassColors.mintEmerald
                          : LiquidGlassColors.sunsetRose,
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
                  balance.displayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPositive ? 'is owed' : 'owes',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isPositive
                  ? LiquidGlassColors.mintEmerald.withAlpha(20)
                  : LiquidGlassColors.sunsetRose.withAlpha(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: isPositive
                      ? LiquidGlassColors.mintEmerald
                      : LiquidGlassColors.sunsetRose,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatAmount(absBalance, currency),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isPositive
                        ? LiquidGlassColors.mintEmerald
                        : LiquidGlassColors.sunsetRose,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 100,
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

  String _formatAmount(double amount, String currency) {
    final symbols = {
      'USD': '\$',
      'EUR': '\u20AC',
      'GBP': '\u00A3',
      'ILS': '\u20AA',
      'JPY': '\u00A5',
    };
    final symbol = symbols[currency] ?? currency;
    return '$symbol${amount.toStringAsFixed(2)}';
  }
}

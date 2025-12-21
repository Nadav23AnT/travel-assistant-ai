import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/design/design_system.dart';
import '../../../data/models/expense_split_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/expenses_provider.dart';

class SettlementsScreen extends ConsumerWidget {
  final String tripId;

  const SettlementsScreen({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balancesAsync = ref.watch(tripBalancesProvider(tripId));
    final splitsAsync = ref.watch(tripUnsettledSplitsProvider(tripId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? LiquidGlassColors.darkGradient
            : LiquidGlassColors.lightGradient,
      ),
      child: Scaffold(
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
            ref.invalidate(tripBalancesProvider(tripId));
            ref.invalidate(tripUnsettledSplitsProvider(tripId));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary section
                _buildSummarySection(
                    context, ref, balancesAsync, isDark, l10n, currentUserId),
                const SizedBox(height: 24),

                // Unsettled splits section
                _buildUnsettledSplitsSection(
                    context, ref, splitsAsync, isDark, l10n, currentUserId),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<MemberBalanceModel>> balancesAsync,
    bool isDark,
    AppLocalizations l10n,
    String? currentUserId,
  ) {
    return balancesAsync.when(
      data: (balances) {
        final myBalance = balances
            .where((b) => b.userId == currentUserId)
            .firstOrNull;

        if (myBalance == null || myBalance.balance == 0) {
          return _buildAllSettledCard(isDark, l10n);
        }

        return _buildMyBalanceCard(myBalance, isDark, l10n);
      },
      loading: () => _buildLoadingCard(isDark),
      error: (e, _) => _buildErrorCard(e.toString(), isDark),
    );
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
    MemberBalanceModel balance,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final isOwed = balance.balance > 0;
    final absBalance = balance.balance.abs();

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
                '\$${absBalance.toStringAsFixed(2)}',
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
                      'Total paid: \$${balance.totalPaid.toStringAsFixed(2)}',
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

  Widget _buildUnsettledSplitsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<ExpenseSplitModel>> splitsAsync,
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
    bool isDark,
    AppLocalizations l10n,
  ) {
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
                backgroundImage: split.userAvatarUrl != null
                    ? NetworkImage(split.userAvatarUrl!)
                    : null,
                child: split.userAvatarUrl == null
                    ? Text(
                        split.initials,
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
                      split.displayName,
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
                    '\$${split.amount.toStringAsFixed(2)}',
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
                    onTap: () => _handleSettle(context, ref, split),
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
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Settlement'),
        content: Text(
          'Mark this \$${split.amount.toStringAsFixed(2)} debt as settled?',
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

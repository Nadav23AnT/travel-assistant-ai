import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme.dart';
import '../../../data/models/day_tip_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/day_tip_provider.dart';

class DayTipCard extends ConsumerWidget {
  const DayTipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipsAsync = ref.watch(dayTipProvider);
    final hasActiveTrip = ref.watch(hasDayTipProvider);

    if (!hasActiveTrip) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.dayTip,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: () => ref.read(dayTipProvider.notifier).refresh(),
              tooltip: l10n.refreshTip,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        tipsAsync.when(
          loading: () => _buildLoadingCard(context),
          error: (error, _) => _buildErrorCard(context, ref, error.toString()),
          data: (tips) => tips.isNotEmpty
              ? _buildTipsList(context, ref, tips)
              : _buildNoTripCard(context),
        ),
      ],
    );
  }

  Widget _buildTipsList(BuildContext context, WidgetRef ref, List<DayTip> tips) {
    return Column(
      children: tips.map((tip) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildSingleTipCard(context, tip),
      )).toList(),
    );
  }

  Widget _buildSingleTipCard(BuildContext context, DayTip tip) {
    final icon = _getCategoryIcon(tip.category);
    final categoryName = DayTip.getCategoryDisplayName(tip.category);
    final categoryColor = _getCategoryColor(tip.category);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: categoryColor, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: categoryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    categoryName.toUpperCase(),
                    style: TextStyle(
                      color: categoryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                tip.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                tip.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                      fontSize: 13,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.loading,
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

  Widget _buildErrorCard(BuildContext context, WidgetRef ref, String error) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 32,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.errorOccurred,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => ref.read(dayTipProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTripCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 32,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.createTripForTips,
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'money':
        return Icons.account_balance;
      case 'medical':
        return Icons.local_hospital;
      case 'connectivity':
        return Icons.sim_card;
      case 'customs':
        return Icons.people;
      case 'safety':
        return Icons.security;
      case 'transport':
        return Icons.directions_transit;
      case 'food':
        return Icons.restaurant;
      case 'scams':
        return Icons.warning_amber;
      case 'language':
        return Icons.translate;
      case 'weather':
        return Icons.wb_sunny;
      case 'shopping':
        return Icons.shopping_bag;
      case 'nightlife':
        return Icons.nightlife;
      case 'emergency':
        return Icons.emergency;
      case 'water':
        return Icons.water_drop;
      case 'photography':
        return Icons.camera_alt;
      case 'bargaining':
        return Icons.handshake;
      case 'general':
      default:
        return Icons.lightbulb;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'money':
        return Colors.green;
      case 'medical':
        return Colors.red;
      case 'connectivity':
        return Colors.blue;
      case 'customs':
        return Colors.purple;
      case 'safety':
        return Colors.orange;
      case 'transport':
        return Colors.teal;
      case 'food':
        return Colors.amber;
      case 'scams':
        return Colors.red.shade700;
      case 'language':
        return Colors.indigo;
      case 'weather':
        return Colors.cyan;
      case 'shopping':
        return Colors.pink;
      case 'nightlife':
        return Colors.deepPurple;
      case 'emergency':
        return Colors.red.shade900;
      case 'water':
        return Colors.lightBlue;
      case 'photography':
        return Colors.brown;
      case 'bargaining':
        return Colors.lime.shade700;
      case 'general':
      default:
        return AppTheme.primaryColor;
    }
  }
}

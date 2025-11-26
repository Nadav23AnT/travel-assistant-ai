import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme.dart';
import '../../../data/models/day_tip_model.dart';
import '../../providers/day_tip_provider.dart';

class DayTipCard extends ConsumerWidget {
  const DayTipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipAsync = ref.watch(dayTipProvider);
    final hasActiveTrip = ref.watch(hasDayTipProvider);

    if (!hasActiveTrip) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Tip',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: () => ref.read(dayTipProvider.notifier).refresh(),
              tooltip: 'Get new tip',
              color: AppTheme.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 8),
        tipAsync.when(
          loading: () => _buildLoadingCard(context),
          error: (error, _) => _buildErrorCard(context, ref, error.toString()),
          data: (tip) => tip != null
              ? _buildTipCard(context, ref, tip)
              : _buildNoTripCard(context),
        ),
      ],
    );
  }

  Widget _buildTipCard(BuildContext context, WidgetRef ref, DayTip tip) {
    final icon = _getCategoryIcon(tip.category);
    final categoryName = DayTip.getCategoryDisplayName(tip.category);
    final categoryColor = _getCategoryColor(tip.category);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              categoryColor.withAlpha(30),
              categoryColor.withAlpha(10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with category
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: categoryColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
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
                          categoryName,
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          tip.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Tip content
              Text(
                tip.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 12),
              // Category chips for quick access
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: DayTip.categories
                      .where((c) => c != tip.category)
                      .take(4)
                      .map((category) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              avatar: Icon(
                                _getCategoryIcon(category),
                                size: 16,
                                color: _getCategoryColor(category),
                              ),
                              label: Text(
                                DayTip.getCategoryDisplayName(category),
                                style: const TextStyle(fontSize: 11),
                              ),
                              onPressed: () => ref
                                  .read(dayTipProvider.notifier)
                                  .refresh(category: category),
                              visualDensity: VisualDensity.compact,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(height: 12),
            Text(
              'Getting local tip...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, WidgetRef ref, String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 32,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              'Could not load tip',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => ref.read(dayTipProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTripCard(BuildContext context) {
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
                'Create a trip to get daily tips!',
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

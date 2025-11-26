import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme.dart';
import '../../../data/models/trip_model.dart';
import '../../providers/journal_provider.dart';
import '../../screens/journal/journal_entry_screen.dart';

/// A card that reminds users to generate their daily journal entry
/// Shows when user has an active trip and hasn't logged today
class JournalReminderCard extends ConsumerWidget {
  final TripModel trip;
  final VoidCallback? onDismiss;

  const JournalReminderCard({
    super.key,
    required this.trip,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayContextAsync = ref.watch(
      journalDayContextProvider((tripId: trip.id, date: DateTime.now())),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.accentColor.withAlpha(26),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.accentColor.withAlpha(77),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.auto_stories,
                    color: AppTheme.accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Journal Reminder',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Capture today\'s ${trip.displayDestination} memories',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: Icon(Icons.close, color: AppTheme.textHint, size: 20),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Show context info
            dayContextAsync.when(
              loading: () => const SizedBox(
                height: 20,
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (dayContext) {
                final hasMessages = dayContext.chatMessages.isNotEmpty;
                final hasExpenses = dayContext.expenses.isNotEmpty;

                if (!hasMessages && !hasExpenses) {
                  return Text(
                    'Tell me about your day and I\'ll help create a beautiful journal entry!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to generate from today\'s activity:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (hasMessages) ...[
                          _buildContextBadge(
                            context,
                            Icons.chat_bubble_outline,
                            '${dayContext.chatMessages.length} messages',
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (hasExpenses)
                          _buildContextBadge(
                            context,
                            Icons.receipt_outlined,
                            '${dayContext.expenses.length} expenses',
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToJournal(context),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Generate Today\'s Journal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextBadge(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToJournal(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JournalEntryScreen(
          tripId: trip.id,
          entryDate: DateTime.now(),
        ),
      ),
    );
  }
}

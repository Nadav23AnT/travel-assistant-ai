import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../data/models/journal_model.dart';
import '../../../data/models/trip_model.dart';
import '../../providers/journal_provider.dart';
import '../../providers/trips_provider.dart';
import 'journal_entry_screen.dart';

class JournalScreen extends ConsumerWidget {
  final String tripId;

  const JournalScreen({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripByIdProvider(tripId));
    final journalAsync = ref.watch(tripJournalEntriesProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Journal'),
      ),
      body: tripAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(context, ref, error),
        data: (trip) {
          if (trip == null) {
            return const Center(child: Text('Trip not found'));
          }
          return journalAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _buildErrorState(context, ref, error),
            data: (entries) => _buildJournalList(context, ref, trip, entries),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToNewEntry(context, tripId),
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
      ),
    );
  }

  Widget _buildJournalList(
    BuildContext context,
    WidgetRef ref,
    TripModel trip,
    List<JournalModel> entries,
  ) {
    if (entries.isEmpty) {
      return _buildEmptyState(context, trip);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(tripJournalEntriesProvider(tripId));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          final dayNumber = entry.getDayNumber(trip.startDate ?? entry.entryDate);
          return JournalEntryCard(
            entry: entry,
            dayNumber: dayNumber,
            onTap: () => _navigateToEntry(context, entry),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, TripModel trip) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 80,
              color: AppTheme.textHint,
            ),
            const SizedBox(height: 24),
            Text(
              'No Journal Entries Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Start documenting your ${trip.displayDestination} adventure! Create entries manually or let AI generate them from your conversations.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToNewEntry(context, tripId),
              icon: const Icon(Icons.add),
              label: const Text('Create First Entry'),
            ),
          ],
        ),
      ),
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
            Text('Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(tripJournalEntriesProvider(tripId));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToNewEntry(BuildContext context, String tripId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JournalEntryScreen(
          tripId: tripId,
          entryDate: DateTime.now(),
        ),
      ),
    );
  }

  void _navigateToEntry(BuildContext context, JournalModel entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JournalEntryScreen(
          tripId: entry.tripId,
          entryId: entry.id,
          entryDate: entry.entryDate,
        ),
      ),
    );
  }
}

/// Card widget for displaying a journal entry in a list
class JournalEntryCard extends StatelessWidget {
  final JournalModel entry;
  final int dayNumber;
  final VoidCallback? onTap;

  const JournalEntryCard({
    super.key,
    required this.entry,
    required this.dayNumber,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMM d');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with day number and date
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withAlpha(51),
              ),
              child: Row(
                children: [
                  // Day badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Day $dayNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dateFormat.format(entry.entryDate),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ),
                  // Mood indicator
                  if (entry.mood != null)
                    Text(
                      entry.mood!.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  // AI badge
                  if (entry.aiGenerated) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: AppTheme.accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'AI',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  if (entry.title != null && entry.title!.isNotEmpty) ...[
                    Text(
                      entry.title!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Content preview
                  Text(
                    entry.content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Highlights
                  if (entry.highlights.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: entry.highlights.take(3).map((highlight) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            highlight,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.successColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Locations
                  if (entry.locations.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppTheme.textHint,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            entry.locations.join(' - '),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textHint,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Photos indicator
                  if (entry.photos.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 14,
                          color: AppTheme.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.photos.length} photo${entry.photos.length == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textHint,
                              ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
        actions: [
          // Export button - only show if there are entries
          journalAsync.when(
            data: (entries) => entries.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.share),
                    tooltip: 'Export Journal',
                    onPressed: () => _exportJournal(
                      context,
                      ref,
                      tripAsync.value,
                      entries,
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
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
              'Your ${trip.displayDestination} journal entries will appear here automatically as you chat and log expenses during your trip.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: AppTheme.accentColor),
                  const SizedBox(width: 8),
                  Text(
                    'AI generates entries daily',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.accentColor,
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

  Future<void> _exportJournal(
    BuildContext context,
    WidgetRef ref,
    TripModel? trip,
    List<JournalModel> entries,
  ) async {
    if (trip == null || entries.isEmpty) return;

    // Show format selection dialog
    final format = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Journal'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'txt'),
            child: const Text('Text (.txt)'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'md'),
            child: const Text('Markdown (.md)'),
          ),
        ],
      ),
    );

    if (format == null) return;

    try {
      // Generate journal content
      final buffer = StringBuffer();
      final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

      // Header
      final journalTitle = trip.title.isNotEmpty ? trip.title : trip.displayDestination;
      buffer.writeln('# $journalTitle Travel Journal');
      buffer.writeln();
      if (trip.startDate != null && trip.endDate != null) {
        buffer.writeln(
          '${DateFormat('MMM d').format(trip.startDate!)} - ${DateFormat('MMM d, yyyy').format(trip.endDate!)}',
        );
      }
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();

      // Sort entries by date
      final sortedEntries = List<JournalModel>.from(entries)
        ..sort((a, b) => a.entryDate.compareTo(b.entryDate));

      // Each entry
      for (final entry in sortedEntries) {
        final dayNumber = entry.getDayNumber(trip.startDate ?? entry.entryDate);

        buffer.writeln('## Day $dayNumber - ${dateFormat.format(entry.entryDate)}');
        buffer.writeln();

        if (entry.title != null && entry.title!.isNotEmpty) {
          buffer.writeln('### ${entry.title}');
          buffer.writeln();
        }

        if (entry.mood != null) {
          buffer.writeln('*Mood: ${entry.mood!.emoji} ${entry.mood!.displayName}*');
          buffer.writeln();
        }

        buffer.writeln(entry.content);
        buffer.writeln();

        if (entry.highlights.isNotEmpty) {
          buffer.writeln('**Highlights:**');
          for (final highlight in entry.highlights) {
            buffer.writeln('- $highlight');
          }
          buffer.writeln();
        }

        if (entry.locations.isNotEmpty) {
          buffer.writeln('**Places visited:** ${entry.locations.join(', ')}');
          buffer.writeln();
        }

        buffer.writeln('---');
        buffer.writeln();
      }

      // Footer
      buffer.writeln();
      buffer.writeln('*Generated by Travel AI Companion*');

      // Save to file
      final directory = await getTemporaryDirectory();
      final fileName = '${journalTitle}_journal'.replaceAll(' ', '_').toLowerCase();
      final file = File('${directory.path}/$fileName.$format');
      await file.writeAsString(buffer.toString());

      // Share
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '$journalTitle Travel Journal',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
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

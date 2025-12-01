import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../../data/models/trip_model.dart';
import '../../../data/repositories/expenses_repository.dart';
import '../../../data/repositories/journal_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/trips_provider.dart';

class DeleteTripDialog extends ConsumerStatefulWidget {
  final TripModel trip;

  const DeleteTripDialog({
    super.key,
    required this.trip,
  });

  @override
  ConsumerState<DeleteTripDialog> createState() => _DeleteTripDialogState();
}

class _DeleteTripDialogState extends ConsumerState<DeleteTripDialog> {
  bool _isLoading = false;

  Future<void> _handleDelete() async {
    setState(() => _isLoading = true);

    try {
      final l10n = AppLocalizations.of(context);

      // Delete all related data first
      final expensesRepository = ExpensesRepository();
      final journalRepository = JournalRepository();

      // Delete all expenses for this trip
      await expensesRepository.deleteAllTripExpenses(widget.trip.id);

      // Delete all journal entries for this trip
      await journalRepository.deleteAllTripJournalEntries(widget.trip.id);

      // Delete the trip itself
      final success = await ref.read(tripOperationProvider.notifier).deleteTrip(
        widget.trip.id,
      );

      if (!mounted) return;

      if (success) {
        // Close dialog first
        Navigator.pop(context, true);

        // Navigate back to trips list
        context.go('/trips');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.tripDeletedSuccess),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        final error = ref.read(tripOperationProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? l10n.failedToDeleteTrip),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_forever,
              color: AppTheme.errorColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.deleteTrip,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip info card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Row(
              children: [
                Text(
                  widget.trip.flagEmoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.trip.displayTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        widget.trip.displayDestination,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Warning message
          Text(
            l10n.deleteTripConfirmation,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),

          // What will be deleted
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withAlpha(13),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.errorColor.withAlpha(51)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.deleteTripWarningTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _buildDeleteItem(Icons.receipt_long_outlined, l10n.deleteTripExpenses),
                const SizedBox(height: 4),
                _buildDeleteItem(Icons.auto_stories, l10n.deleteTripJournal),
                const SizedBox(height: 4),
                _buildDeleteItem(Icons.group_outlined, l10n.deleteTripMembers),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.delete),
              ),
            ),
          ],
        ),
      ],
      actionsPadding: const EdgeInsets.all(16),
    );
  }

  Widget _buildDeleteItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.errorColor.withAlpha(179),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.errorColor.withAlpha(179),
                ),
          ),
        ),
      ],
    );
  }
}

/// Shows the delete trip confirmation dialog and returns true if the trip was deleted
Future<bool?> showDeleteTripDialog(
  BuildContext context,
  TripModel trip,
) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => DeleteTripDialog(trip: trip),
  );
}

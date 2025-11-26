import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../data/models/journal_model.dart';
import '../../../data/models/trip_model.dart';
import '../../providers/journal_provider.dart';
import '../../providers/trips_provider.dart';

class JournalEntryScreen extends ConsumerStatefulWidget {
  final String tripId;
  final String? entryId;
  final DateTime entryDate;

  const JournalEntryScreen({
    super.key,
    required this.tripId,
    this.entryId,
    required this.entryDate,
  });

  @override
  ConsumerState<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends ConsumerState<JournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  JournalMood? _selectedMood;
  List<String> _highlights = [];
  List<String> _locations = [];
  bool _isEditing = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    if (widget.entryId != null) {
      _loadExistingEntry();
    }
  }

  Future<void> _loadExistingEntry() async {
    final entry = await ref.read(journalEntryByIdProvider(widget.entryId!).future);
    if (entry != null && mounted) {
      setState(() {
        _titleController.text = entry.title ?? '';
        _contentController.text = entry.content;
        _selectedMood = entry.mood;
        _highlights = List.from(entry.highlights);
        _locations = List.from(entry.locations);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripByIdProvider(widget.tripId));
    final operationState = ref.watch(journalOperationProvider);
    final existingEntryAsync = widget.entryId != null
        ? ref.watch(journalEntryByIdProvider(widget.entryId!))
        : null;

    final isLoading = operationState.isLoading || _isGenerating;
    final isNewEntry = widget.entryId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNewEntry ? 'New Entry' : 'Journal Entry'),
        actions: [
          if (!isNewEntry && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing || isNewEntry)
            TextButton(
              onPressed: isLoading ? null : _saveEntry,
              child: Text(isLoading ? 'Saving...' : 'Save'),
            ),
        ],
      ),
      body: tripAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (trip) {
          if (trip == null) {
            return const Center(child: Text('Trip not found'));
          }

          // If viewing existing entry
          if (!isNewEntry && !_isEditing) {
            return existingEntryAsync?.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
              data: (entry) {
                if (entry == null) {
                  return const Center(child: Text('Entry not found'));
                }
                return _buildViewMode(context, trip, entry);
              },
            ) ?? const Center(child: CircularProgressIndicator());
          }

          // If editing or creating new entry
          return _buildEditMode(context, trip, isLoading);
        },
      ),
    );
  }

  Widget _buildViewMode(BuildContext context, TripModel trip, JournalModel entry) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final dayNumber = entry.getDayNumber(trip.startDate ?? entry.entryDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Day $dayNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  dateFormat.format(entry.entryDate),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ),
              if (entry.mood != null)
                Text(entry.mood!.emoji, style: const TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 24),

          // Title
          if (entry.title != null && entry.title!.isNotEmpty) ...[
            Text(
              entry.title!,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
          ],

          // AI badge
          if (entry.aiGenerated) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    'AI Generated',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Content
          Text(
            entry.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 24),

          // Mood
          if (entry.mood != null) ...[
            _buildSection(
              context,
              icon: Icons.emoji_emotions_outlined,
              title: 'Mood',
              child: Chip(
                avatar: Text(entry.mood!.emoji),
                label: Text(entry.mood!.displayName),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Highlights
          if (entry.highlights.isNotEmpty) ...[
            _buildSection(
              context,
              icon: Icons.star_outline,
              title: 'Highlights',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.highlights.map((h) {
                  return Chip(
                    label: Text(h),
                    backgroundColor: AppTheme.successColor.withAlpha(26),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Locations
          if (entry.locations.isNotEmpty) ...[
            _buildSection(
              context,
              icon: Icons.location_on_outlined,
              title: 'Places Visited',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.locations.map((l) {
                  return Chip(
                    avatar: const Icon(Icons.place, size: 16),
                    label: Text(l),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Delete button
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              onPressed: () => _confirmDelete(context, entry),
              icon: Icon(Icons.delete_outline, color: AppTheme.errorColor),
              label: Text(
                'Delete Entry',
                style: TextStyle(color: AppTheme.errorColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildEditMode(BuildContext context, TripModel trip, bool isLoading) {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date display
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        dateFormat.format(widget.entryDate),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // AI Generate button
                if (_contentController.text.isEmpty) ...[
                  Card(
                    color: AppTheme.accentColor.withAlpha(26),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome, color: AppTheme.accentColor),
                              const SizedBox(width: 8),
                              Text(
                                'AI Journal Generation',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Let AI create a journal entry based on your chats and activities today.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isLoading ? null : () => _generateEntry(trip),
                              icon: _isGenerating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.auto_awesome),
                              label: Text(_isGenerating ? 'Generating...' : 'Generate with AI'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'OR write manually',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title (optional)',
                    hintText: 'e.g., "A Day in Paradise"',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) {},
                ),
                const SizedBox(height: 16),

                // Content field
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Journal Entry',
                    hintText: 'Write about your day...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 10,
                  minLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please write something about your day';
                    }
                    return null;
                  },
                  onChanged: (_) {},
                ),
                const SizedBox(height: 20),

                // Mood selector
                Text(
                  'How are you feeling?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: JournalMood.values.map((mood) {
                    final isSelected = _selectedMood == mood;
                    return FilterChip(
                      selected: isSelected,
                      label: Text('${mood.emoji} ${mood.displayName}'),
                      onSelected: (selected) {
                        setState(() {
                          _selectedMood = selected ? mood : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        ),

        // Loading overlay
        if (isLoading)
          Container(
            color: Colors.black26,
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Please wait...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _generateEntry(TripModel trip) async {
    setState(() => _isGenerating = true);

    try {
      // Fetch day context (chat messages and expenses for this date)
      final dayContext = await ref.read(
        journalDayContextProvider((tripId: widget.tripId, date: widget.entryDate)).future,
      );

      // Check if there's any data to generate from
      if (!dayContext.hasData) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No chat messages or expenses found for this day. Start a conversation or log some expenses first!'),
              backgroundColor: AppTheme.warningColor,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // Generate journal entry using day context
      final aiService = ref.read(aiServiceForJournalProvider);
      final generatedContent = await aiService.generateJournalEntry(
        chatMessages: dayContext.chatMessagesForAI,
        date: widget.entryDate,
        tripDestination: dayContext.tripDestination ?? trip.destination,
        expenses: dayContext.expensesForAI,
      );

      if (mounted) {
        setState(() {
          _titleController.text = generatedContent.title;
          _contentController.text = generatedContent.content;
          _selectedMood = generatedContent.mood;
          _highlights = List.from(generatedContent.highlights);
          _locations = List.from(generatedContent.locations);
        });

        // Show success message with context info
        final msgCount = dayContext.chatMessages.length;
        final expCount = dayContext.expenses.length;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generated from $msgCount messages and $expCount expenses'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(journalOperationProvider.notifier);

    JournalModel? result;
    if (widget.entryId != null) {
      // Update existing entry
      result = await notifier.updateEntry(
        widget.entryId!,
        widget.tripId,
        content: _contentController.text.trim(),
        title: _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : null,
        mood: _selectedMood,
        highlights: _highlights,
        locations: _locations,
      );
    } else {
      // Create new entry
      result = await notifier.saveEntry(
        tripId: widget.tripId,
        entryDate: widget.entryDate,
        content: _contentController.text.trim(),
        title: _titleController.text.trim().isNotEmpty
            ? _titleController.text.trim()
            : null,
        mood: _selectedMood,
        highlights: _highlights,
        locations: _locations,
        aiGenerated: false,
      );
    }

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry saved!')),
      );
      Navigator.of(context).pop();
    } else {
      final error = ref.read(journalOperationProvider).error;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to save entry'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, JournalModel entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text(
          'This will permanently delete this journal entry. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final notifier = ref.read(journalOperationProvider.notifier);
      final success = await notifier.deleteEntry(entry.id, entry.tripId);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted')),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../data/models/admin_models.dart';
import '../../providers/support_provider.dart';
import '../../widgets/admin/support_ticket_card.dart';

/// User-facing support screen for viewing and creating support tickets
class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(userSupportSessionsProvider);
    final unreadCount = ref.watch(userUnreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        actions: [
          if (unreadCount.valueOrNull != null && unreadCount.value! > 0)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${unreadCount.value} unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: sessions.when(
        data: (list) {
          if (list.isEmpty) {
            return _buildEmptyState(context);
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userSupportSessionsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final session = list[index];
                return _buildSessionCard(context, session);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildErrorState(context, e.toString()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTicketDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, SupportSessionModel session) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go('/support/${session.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.subject,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SupportStatusBadge(status: session.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Created ${_formatDate(session.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (session.unreadUserCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${session.unreadUserCount} new',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Need Help?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Our support team is here to help you with any questions or issues.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateTicketDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Create Support Ticket'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load tickets',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: AppTheme.errorColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(userSupportSessionsProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showCreateTicketDialog(BuildContext context, WidgetRef ref) {
    final subjectController = TextEditingController();
    SupportPriority selectedPriority = SupportPriority.normal;
    FeedbackType selectedFeedbackType = FeedbackType.generalSupport;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final createState = ref.watch(createSessionProvider);

          return AlertDialog(
            title: const Text('Create Support Ticket'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Feedback Type Selector
                  const Text('What type of feedback is this?'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: FeedbackType.values.map((type) {
                      final isSelected = type == selectedFeedbackType;
                      return ChoiceChip(
                        avatar: Icon(
                          _getFeedbackTypeIcon(type),
                          size: 18,
                          color: isSelected ? Colors.white : null,
                        ),
                        label: Text(type.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setDialogState(() => selectedFeedbackType = type);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      hintText: _getSubjectHint(selectedFeedbackType),
                    ),
                    maxLength: 100,
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  const Text('Priority:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: SupportPriority.values.map((priority) {
                      final isSelected = priority == selectedPriority;
                      return ChoiceChip(
                        label: Text(priority.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setDialogState(() => selectedPriority = priority);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  if (createState.error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      createState.error!,
                      style: const TextStyle(color: AppTheme.errorColor),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: createState.isCreating
                    ? null
                    : () async {
                        if (subjectController.text.trim().isEmpty) {
                          return;
                        }
                        final session = await ref
                            .read(createSessionProvider.notifier)
                            .createSession(
                              subject: subjectController.text.trim(),
                              priority: selectedPriority,
                              feedbackType: selectedFeedbackType,
                            );
                        if (session != null && context.mounted) {
                          Navigator.pop(context);
                          context.go('/support/${session.id}');
                        }
                      },
                child: createState.isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create'),
              ),
            ],
          );
        },
      ),
    ).then((_) {
      ref.read(createSessionProvider.notifier).reset();
    });
  }

  IconData _getFeedbackTypeIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.bugReport:
        return Icons.bug_report;
      case FeedbackType.featureRequest:
        return Icons.lightbulb;
      case FeedbackType.uxFeedback:
        return Icons.touch_app;
      case FeedbackType.generalSupport:
        return Icons.help;
    }
  }

  String _getSubjectHint(FeedbackType type) {
    switch (type) {
      case FeedbackType.bugReport:
        return 'Describe the bug or error you encountered';
      case FeedbackType.featureRequest:
        return 'Describe the feature you\'d like to see';
      case FeedbackType.uxFeedback:
        return 'What could be improved in the experience?';
      case FeedbackType.generalSupport:
        return 'Briefly describe your issue';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'today';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}

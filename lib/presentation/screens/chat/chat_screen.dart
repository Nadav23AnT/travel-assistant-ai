import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../../data/models/chat_models.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/token_usage_service.dart';
import '../../providers/chat_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/chat/expense_confirmation_card.dart';
import '../../widgets/chat/journal_reminder_card.dart';
import '../../widgets/chat/place_recommendation_card.dart';

/// Provider for credit usage in chat (auto-refresh)
final chatCreditUsageProvider = FutureProvider.autoDispose<TokenCheckResult>((ref) async {
  final service = TokenUsageService();
  return service.checkBeforeRequest();
});

class ChatScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const ChatScreen({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _journalReminderDismissed = false;

  @override
  void initState() {
    super.initState();
    // Defer initialization to avoid modifying providers during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  Future<void> _initializeChat() async {
    final chatNotifier = ref.read(chatNotifierProvider.notifier);
    final l10n = AppLocalizations.of(context);

    if (widget.sessionId == 'new') {
      // Create a new session
      try {
        await chatNotifier.createNewSession();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.errorCreatingChat}: $e')),
          );
        }
      }
    } else {
      // Load existing session
      try {
        await chatNotifier.loadSession(widget.sessionId);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${l10n.errorLoadingChat}: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _scrollToBottom();

    try {
      await ref.read(chatNotifierProvider.notifier).sendMessage(text);
      _scrollToBottom();
      // Refresh credit usage indicator after message sent
      ref.invalidate(chatCreditUsageProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showDeleteDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteChat),
        content: Text(l10n.deleteChatConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final router = GoRouter.of(context);
              navigator.pop();
              await ref.read(chatNotifierProvider.notifier).deleteCurrentSession();
              if (mounted) {
                router.pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmExpense() async {
    final l10n = AppLocalizations.of(context);
    final success = await ref.read(chatNotifierProvider.notifier).confirmPendingExpense();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? l10n.expenseAdded : l10n.failedToAddExpense),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final chatState = ref.watch(chatNotifierProvider);
    final messages = chatState.messages;
    final isSending = chatState.isSending;
    final isLoading = chatState.isLoading;
    final session = chatState.session;
    final pendingExpense = chatState.pendingExpense;
    final isCreatingExpense = chatState.isCreatingExpense;
    final pendingPlaces = chatState.pendingPlaces;

    // Watch for active trip and journal status for reminder
    final activeTripAsync = ref.watch(activeTripProvider);
    final shouldShowJournalReminder = !_journalReminderDismissed &&
        ref.watch(shouldShowJournalPromptProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(chatNotifierProvider.notifier).reset();
            context.pop();
          },
        ),
        title: Text(session?.title ?? l10n.aiChat),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog();
              }
            },
            itemBuilder: (menuContext) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.deleteChat, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Credit usage indicator at top
                _buildCreditIndicator(context, ref),

                // Journal reminder banner (if applicable)
                if (shouldShowJournalReminder)
                  activeTripAsync.when(
                    data: (trip) => trip != null
                        ? JournalReminderCard(
                            trip: trip,
                            onDismiss: () => setState(() {
                              _journalReminderDismissed = true;
                            }),
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                // Chat messages
                Expanded(
                  child: messages.isEmpty && !isSending
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length +
                              (isSending ? 1 : 0) +
                              (pendingExpense != null ? 1 : 0) +
                              (pendingPlaces.isNotEmpty ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Show typing indicator while sending
                            if (isSending && index == messages.length) {
                              return _buildTypingIndicator();
                            }

                            // Calculate card indices
                            final typingOffset = isSending ? 1 : 0;
                            final expenseCardIndex = messages.length + typingOffset;
                            final placesCardIndex = expenseCardIndex + (pendingExpense != null ? 1 : 0);

                            // Show expense confirmation card
                            if (pendingExpense != null && index == expenseCardIndex) {
                              return ExpenseConfirmationCard(
                                expense: pendingExpense,
                                onConfirm: isCreatingExpense ? () {} : _confirmExpense,
                                onDismiss: () {
                                  ref.read(chatNotifierProvider.notifier).dismissPendingExpense();
                                },
                                onEdit: (editedExpense) {
                                  ref.read(chatNotifierProvider.notifier).updatePendingExpense(editedExpense);
                                },
                              );
                            }

                            // Show place recommendations card
                            if (pendingPlaces.isNotEmpty && index == placesCardIndex) {
                              return PlaceRecommendationsCard(
                                places: pendingPlaces,
                                onDismiss: () {
                                  ref.read(chatNotifierProvider.notifier).dismissPendingPlaces();
                                },
                              );
                            }

                            return _buildMessageBubble(messages[index]);
                          },
                        ),
                ),

                // Input area
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            enabled: !isSending,
                            decoration: InputDecoration(
                              hintText: l10n.chatHint,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                            textInputAction: TextInputAction.send,
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: isSending
                              ? Colors.grey
                              : AppTheme.primaryColor,
                          child: IconButton(
                            icon: isSending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.send, color: Colors.white),
                            onPressed: isSending ? null : _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// Small credit usage indicator at the top of chat
  Widget _buildCreditIndicator(BuildContext context, WidgetRef ref) {
    final creditUsageAsync = ref.watch(chatCreditUsageProvider);
    final l10n = AppLocalizations.of(context);

    return creditUsageAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (usage) {
        final percentage = usage.dailyLimit > 0
            ? (usage.tokensUsed / usage.dailyLimit).clamp(0.0, 1.0)
            : 0.0;
        final creditsUsed = (usage.tokensUsed / 100).round();
        final creditsLimit = (usage.dailyLimit / 100).round();

        // Determine color based on usage
        Color progressColor;
        if (percentage < 0.5) {
          progressColor = AppTheme.successColor;
        } else if (percentage < 0.8) {
          progressColor = AppTheme.warningColor;
        } else {
          progressColor = AppTheme.errorColor;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.dividerColor.withAlpha(128),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 16,
                color: progressColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$creditsUsed/$creditsLimit',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.credits,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textHint,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.travel_explore,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.chatWelcomeTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.chatWelcomeDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.chatWhatToDo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),

            // Quick action buttons
            _buildQuickActionButton(
              icon: Icons.calendar_today,
              label: l10n.tellAboutDay,
              description: l10n.tellAboutDayDescription,
              color: AppTheme.primaryColor,
              onTap: () {
                _messageController.text = l10n.tellAboutDayPrompt;
                _sendMessage();
              },
            ),
            const SizedBox(height: 12),
            _buildQuickActionButton(
              icon: Icons.explore,
              label: l10n.planActivity,
              description: l10n.planActivityDescription,
              color: AppTheme.successColor,
              onTap: () {
                _messageController.text = l10n.planActivityPrompt;
                _sendMessage();
              },
            ),
            const SizedBox(height: 12),
            _buildQuickActionButton(
              icon: Icons.receipt_long,
              label: l10n.logExpenseAction,
              description: l10n.logExpenseDescription,
              color: AppTheme.accentColor,
              onTap: () {
                _messageController.text = l10n.logExpensePrompt;
                _sendMessage();
              },
            ),
            const SizedBox(height: 12),
            _buildQuickActionButton(
              icon: Icons.auto_stories,
              label: l10n.generateJournal,
              description: l10n.generateJournalDescription,
              color: Colors.purple,
              onTap: () {
                _messageController.text = l10n.generateJournalPrompt;
                _sendMessage();
              },
            ),
            const SizedBox(height: 12),
            _buildQuickActionButton(
              icon: Icons.help_outline,
              label: l10n.askAnything,
              description: l10n.askAnythingDescription,
              color: AppTheme.textSecondary,
              onTap: () {
                // Just focus the text field
                FocusScope.of(context).requestFocus(FocusNode());
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(
                Icons.auto_awesome,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryColor : AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SelectableText(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(
              Icons.auto_awesome,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.textSecondary.withAlpha((value * 255).toInt()),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}


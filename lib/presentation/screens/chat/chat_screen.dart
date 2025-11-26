import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../../data/models/chat_models.dart';
import '../../providers/chat_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/chat/expense_confirmation_card.dart';
import '../../widgets/chat/journal_reminder_card.dart';

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

    if (widget.sessionId == 'new') {
      // Create a new session
      try {
        await chatNotifier.createNewSession();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating chat: $e')),
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
            SnackBar(content: Text('Error loading chat: $e')),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text('Are you sure you want to delete this chat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final router = GoRouter.of(context);
              navigator.pop();
              await ref.read(chatNotifierProvider.notifier).deleteCurrentSession();
              if (mounted) {
                router.pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmExpense() async {
    final success = await ref.read(chatNotifierProvider.notifier).confirmPendingExpense();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Expense added!' : 'Failed to add expense'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final messages = chatState.messages;
    final isSending = chatState.isSending;
    final isLoading = chatState.isLoading;
    final session = chatState.session;
    final pendingExpense = chatState.pendingExpense;
    final isCreatingExpense = chatState.isCreatingExpense;

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
        title: Text(session?.title ?? 'AI Chat'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Chat', style: TextStyle(color: Colors.red)),
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
                              (pendingExpense != null ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Show typing indicator while sending
                            if (isSending && index == messages.length) {
                              return _buildTypingIndicator();
                            }

                            // Calculate expense card index
                            final expenseCardIndex = messages.length + (isSending ? 1 : 0);

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

                            return _buildMessageBubble(messages[index]);
                          },
                        ),
                ),

                // Suggestion chips (only for new chats)
                if (messages.isEmpty && !isSending)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SuggestionChip(
                          label: 'Plan a trip to Paris',
                          onTap: () {
                            _messageController.text =
                                'Help me plan a trip to Paris';
                            _sendMessage();
                          },
                        ),
                        _SuggestionChip(
                          label: 'Log an expense',
                          onTap: () {
                            _messageController.text =
                                'I spent \$25 on lunch at a cafe';
                            _sendMessage();
                          },
                        ),
                        _SuggestionChip(
                          label: 'Weekend getaway ideas',
                          onTap: () {
                            _messageController.text =
                                'Suggest some weekend getaway ideas';
                            _sendMessage();
                          },
                        ),
                      ],
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
                              hintText: 'Ask me anything about travel...',
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Hi! I\'m TripBuddy',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'I can help you plan trips, find recommendations, create itineraries, and more. What would you like to explore today?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
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

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppTheme.primaryLight.withAlpha(77),
    );
  }
}

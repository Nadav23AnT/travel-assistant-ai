import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/design_system.dart';
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
final chatCreditUsageProvider =
    FutureProvider.autoDispose<TokenCheckResult>((ref) async {
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
          _showGlassSnackBar('${l10n.errorCreatingChat}: $e', isError: true);
        }
      }
    } else {
      // Load existing session
      try {
        await chatNotifier.loadSession(widget.sessionId);
      } catch (e) {
        if (mounted) {
          _showGlassSnackBar('${l10n.errorLoadingChat}: $e', isError: true);
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

  void _showGlassSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? LiquidGlassColors.sunsetRose.withAlpha(200)
            : LiquidGlassColors.mintEmerald.withAlpha(200),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
        _showGlassSnackBar('Error: $e', isError: true);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.deleteChat,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l10n.deleteChatConfirmation,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final router = GoRouter.of(context);
              navigator.pop();
              await ref
                  .read(chatNotifierProvider.notifier)
                  .deleteCurrentSession();
              if (mounted) {
                router.pop();
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: LiquidGlassColors.sunsetRose,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmExpense() async {
    final l10n = AppLocalizations.of(context);
    final success =
        await ref.read(chatNotifierProvider.notifier).confirmPendingExpense();
    if (mounted) {
      _showGlassSnackBar(
        success ? l10n.expenseAdded : l10n.failedToAddExpense,
        isError: !success,
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
    final pendingSearchUrl = chatState.pendingSearchUrl;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Watch for active trip and journal status for reminder
    final activeTripAsync = ref.watch(activeTripProvider);
    final shouldShowJournalReminder =
        !_journalReminderDismissed && ref.watch(shouldShowJournalPromptProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  LiquidGlassColors.canvasBaseDark,
                  const Color(0xFF0D1321),
                  LiquidGlassColors.canvasSubtleDark,
                ]
              : [
                  LiquidGlassColors.canvasBaseLight,
                  const Color(0xFFF0F4FF),
                  const Color(0xFFFAF5FF),
                ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: GlowingIconButton(
            icon: Icons.arrow_back,
            onPressed: () {
              ref.read(chatNotifierProvider.notifier).reset();
              context.pop();
            },
            size: 40,
          ),
          title: Text(
            session?.title ?? l10n.aiChat,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                      Icon(
                        Icons.delete_outline,
                        color: LiquidGlassColors.sunsetRose,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.deleteChat,
                        style: TextStyle(color: LiquidGlassColors.sunsetRose),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    LiquidGlassColors.auroraIndigo,
                  ),
                ),
              )
            : Column(
                children: [
                  // Credit usage indicator at top
                  _GlassCreditIndicator(ref: ref),

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
                        ? _buildEmptyState(isDark, l10n)
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
                                return _GlassTypingIndicator(isDark: isDark);
                              }

                              // Calculate card indices
                              final typingOffset = isSending ? 1 : 0;
                              final expenseCardIndex =
                                  messages.length + typingOffset;
                              final placesCardIndex = expenseCardIndex +
                                  (pendingExpense != null ? 1 : 0);

                              // Show expense confirmation card
                              if (pendingExpense != null &&
                                  index == expenseCardIndex) {
                                return ExpenseConfirmationCard(
                                  expense: pendingExpense,
                                  onConfirm:
                                      isCreatingExpense ? () {} : _confirmExpense,
                                  onDismiss: () {
                                    ref
                                        .read(chatNotifierProvider.notifier)
                                        .dismissPendingExpense();
                                  },
                                  onEdit: (editedExpense) {
                                    ref
                                        .read(chatNotifierProvider.notifier)
                                        .updatePendingExpense(editedExpense);
                                  },
                                );
                              }

                              // Show place recommendations card
                              if (pendingPlaces.isNotEmpty &&
                                  index == placesCardIndex) {
                                return PlaceRecommendationsCard(
                                  places: pendingPlaces,
                                  searchUrl: pendingSearchUrl,
                                  onDismiss: () {
                                    ref
                                        .read(chatNotifierProvider.notifier)
                                        .dismissPendingPlaces();
                                  },
                                );
                              }

                              return _GlassMessageBubble(
                                message: messages[index],
                                isDark: isDark,
                              );
                            },
                          ),
                  ),

                  // Input area
                  _GlassInputArea(
                    controller: _messageController,
                    isSending: isSending,
                    onSend: _sendMessage,
                    isDark: isDark,
                    l10n: l10n,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),

            // Glass icon container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LiquidGlassColors.auroraGradient,
                boxShadow: isDark
                    ? LiquidGlassColors.neonGlow(
                        LiquidGlassColors.auroraIndigo,
                        intensity: 0.5,
                        blur: 30,
                      )
                    : [
                        BoxShadow(
                          color: LiquidGlassColors.auroraIndigo.withAlpha(60),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: const Icon(
                Icons.travel_explore,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.chatWelcomeTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.chatWelcomeDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              l10n.chatWhatToDo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Quick action buttons with glass styling
            _GlassQuickActionButton(
              icon: Icons.calendar_today,
              label: l10n.tellAboutDay,
              description: l10n.tellAboutDayDescription,
              gradient: LiquidGlassColors.oceanGradient,
              isDark: isDark,
              onTap: () {
                _messageController.text = l10n.tellAboutDayPrompt;
                _sendMessage();
              },
            ),
            const SizedBox(height: 12),
            ComingSoonOverlay(
              child: _GlassQuickActionButton(
                icon: Icons.explore,
                label: l10n.planActivity,
                description: l10n.planActivityDescription,
                gradient: LiquidGlassColors.mintGradient,
                isDark: isDark,
                onTap: () {
                  // Navigate to Activity Discovery screen
                  context.push('/discover');
                },
              ),
            ),
            const SizedBox(height: 12),
            _GlassQuickActionButton(
              icon: Icons.receipt_long,
              label: l10n.logExpenseAction,
              description: l10n.logExpenseDescription,
              gradient: LiquidGlassColors.sunsetGradient,
              isDark: isDark,
              onTap: () {
                _messageController.text = l10n.logExpensePrompt;
                _sendMessage();
              },
            ),
            const SizedBox(height: 12),
            _GlassQuickActionButton(
              icon: Icons.auto_stories,
              label: l10n.generateJournal,
              description: l10n.generateJournalDescription,
              gradient: LiquidGlassColors.auroraGradient,
              isDark: isDark,
              onTap: () {
                _messageController.text = l10n.generateJournalPrompt;
                _sendMessage();
              },
            ),
            const SizedBox(height: 12),
            _GlassQuickActionButton(
              icon: Icons.help_outline,
              label: l10n.askAnything,
              description: l10n.askAnythingDescription,
              gradient: LinearGradient(
                colors: [
                  isDark ? Colors.white24 : Colors.black26,
                  isDark ? Colors.white12 : Colors.black12,
                ],
              ),
              isDark: isDark,
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
}

// ============================================
// GLASS COMPONENTS
// ============================================

class _GlassCreditIndicator extends StatelessWidget {
  final WidgetRef ref;

  const _GlassCreditIndicator({required this.ref});

  @override
  Widget build(BuildContext context) {
    final creditUsageAsync = ref.watch(chatCreditUsageProvider);
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          progressColor = LiquidGlassColors.mintEmerald;
        } else if (percentage < 0.8) {
          progressColor = LiquidGlassColors.sunsetOrange;
        } else {
          progressColor = LiquidGlassColors.sunsetRose;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark
                      ? Colors.white.withAlpha(10)
                      : Colors.white.withAlpha(180),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withAlpha(15)
                        : Colors.white.withAlpha(100),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [progressColor, progressColor.withAlpha(180)],
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: isDark
                                  ? Colors.white.withAlpha(20)
                                  : Colors.black.withAlpha(15),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(progressColor),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$creditsUsed/$creditsLimit',
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.credits,
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlassQuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Gradient gradient;
  final bool isDark;
  final VoidCallback onTap;

  const _GlassQuickActionButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.gradient,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? Colors.white.withAlpha(10)
                  : Colors.white.withAlpha(180),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(15)
                    : Colors.white.withAlpha(100),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: gradient,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassMessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isDark;

  const _GlassMessageBubble({
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LiquidGlassColors.auroraGradient,
                boxShadow: isDark
                    ? LiquidGlassColors.neonGlow(
                        LiquidGlassColors.auroraIndigo,
                        intensity: 0.3,
                        blur: 12,
                      )
                    : null,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: isUser ? 0 : 15,
                  sigmaY: isUser ? 0 : 15,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: isUser ? LiquidGlassColors.auroraGradient : null,
                    color: isUser
                        ? null
                        : (isDark
                            ? Colors.white.withAlpha(15)
                            : Colors.white.withAlpha(200)),
                    border: isUser
                        ? null
                        : Border.all(
                            color: isDark
                                ? Colors.white.withAlpha(20)
                                : Colors.white.withAlpha(100),
                          ),
                    boxShadow: isUser && isDark
                        ? LiquidGlassColors.neonGlow(
                            LiquidGlassColors.auroraIndigo,
                            intensity: 0.2,
                            blur: 16,
                          )
                        : LiquidGlassColors.glassShadow(isDark),
                  ),
                  child: SelectableText(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: isUser
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _GlassTypingIndicator extends StatelessWidget {
  final bool isDark;

  const _GlassTypingIndicator({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LiquidGlassColors.auroraGradient,
              boxShadow: isDark
                  ? LiquidGlassColors.neonGlow(
                      LiquidGlassColors.auroraIndigo,
                      intensity: 0.3,
                      blur: 12,
                    )
                  : null,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: isDark
                      ? Colors.white.withAlpha(15)
                      : Colors.white.withAlpha(200),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withAlpha(20)
                        : Colors.white.withAlpha(100),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _AnimatedDot(index: 0, isDark: isDark),
                    const SizedBox(width: 6),
                    _AnimatedDot(index: 1, isDark: isDark),
                    const SizedBox(width: 6),
                    _AnimatedDot(index: 2, isDark: isDark),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  final int index;
  final bool isDark;

  const _AnimatedDot({required this.index, required this.isDark});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          widget.index * 0.15,
          0.5 + widget.index * 0.15,
          curve: Curves.easeInOut,
        ),
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: LiquidGlassColors.auroraIndigo
                .withAlpha((_animation.value * 255).toInt()),
          ),
        );
      },
    );
  }
}

class _GlassInputArea extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final bool isDark;
  final AppLocalizations l10n;

  const _GlassInputArea({
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withAlpha(8)
                : Colors.white.withAlpha(200),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withAlpha(15)
                    : Colors.black.withAlpha(10),
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: isDark
                              ? Colors.white.withAlpha(10)
                              : Colors.white.withAlpha(180),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withAlpha(20)
                                : Colors.black.withAlpha(10),
                          ),
                        ),
                        child: TextField(
                          controller: controller,
                          enabled: !isSending,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.chatHint,
                            hintStyle: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          onSubmitted: (_) => onSend(),
                          textInputAction: TextInputAction.send,
                          maxLines: null,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSending ? null : LiquidGlassColors.auroraGradient,
                    color: isSending
                        ? (isDark ? Colors.white.withAlpha(15) : Colors.black12)
                        : null,
                    boxShadow: isSending
                        ? null
                        : (isDark
                            ? LiquidGlassColors.neonGlow(
                                LiquidGlassColors.auroraIndigo,
                                intensity: 0.4,
                                blur: 16,
                              )
                            : [
                                BoxShadow(
                                  color: LiquidGlassColors.auroraIndigo
                                      .withAlpha(80),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isSending ? null : onSend,
                      borderRadius: BorderRadius.circular(24),
                      child: Center(
                        child: isSending
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    LiquidGlassColors.auroraIndigo,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 22,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

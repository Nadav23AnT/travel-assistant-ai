import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design/components/premium_button.dart';
import '../../../core/design/tokens/liquid_glass_colors.dart';
import '../../../data/models/admin_models.dart';
import '../../providers/support_provider.dart';

/// User-facing support chat screen with Liquid Glass design
class SupportChatScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const SupportChatScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chatState = ref.watch(
      supportChatProvider((widget.sessionId, SenderRole.user)),
    );

    // Scroll to bottom when messages change
    ref.listen(
      supportChatProvider((widget.sessionId, SenderRole.user)),
      (prev, next) {
        if (prev?.messages.length != next.messages.length) {
          _scrollToBottom();
        }
      },
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(context, chatState, isDark),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    LiquidGlassColors.canvasBaseDark,
                    LiquidGlassColors.canvasSubtleDark,
                    const Color(0xFF1E1B4B),
                  ]
                : [
                    LiquidGlassColors.canvasBaseLight,
                    LiquidGlassColors.canvasSubtleLight,
                    const Color(0xFFEEF2FF),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Info banner for closed tickets
              if (chatState.session?.status == SupportStatus.closed ||
                  chatState.session?.status == SupportStatus.resolved)
                _buildClosedBanner(context, chatState.session!, isDark),

              // Messages list
              Expanded(
                child: chatState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : chatState.error != null
                        ? _buildErrorState(context, chatState.error!)
                        : _buildMessagesList(context, chatState, isDark),
              ),

              // Input area (disabled for closed tickets)
              if (chatState.session?.isOpen ?? true)
                _buildGlassInputArea(context, ref, chatState, isDark),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildGlassAppBar(
    BuildContext context,
    SupportChatState chatState,
    bool isDark,
  ) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 20),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withAlpha(40)
                  : Colors.white.withAlpha(180),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withAlpha(20)
                      : Colors.black.withAlpha(10),
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    // Back button
                    GlowingIconButton(
                      icon: Icons.arrow_back,
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/support');
                        }
                      },
                      size: 44,
                    ),
                    const SizedBox(width: 12),
                    // Title and status
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chatState.session?.subject ?? 'Support Chat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (chatState.session != null) ...[
                            const SizedBox(height: 4),
                            _buildGlassStatusBadge(
                                chatState.session!.status, isDark),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassStatusBadge(SupportStatus status, bool isDark) {
    final (color, label) = _getStatusColorAndLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withAlpha(isDark ? 40 : 30),
        border: Border.all(
          color: color.withAlpha(isDark ? 80 : 60),
        ),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: color.withAlpha(40),
                  blurRadius: 8,
                  offset: Offset.zero,
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  (Color, String) _getStatusColorAndLabel(SupportStatus status) {
    switch (status) {
      case SupportStatus.open:
        return (LiquidGlassColors.sunsetOrange, 'Open');
      case SupportStatus.inProgress:
        return (LiquidGlassColors.auroraIndigo, 'In Progress');
      case SupportStatus.resolved:
        return (LiquidGlassColors.mintEmerald, 'Resolved');
      case SupportStatus.closed:
        return (Colors.grey, 'Closed');
    }
  }

  Widget _buildClosedBanner(
      BuildContext context, SupportSessionModel session, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: LiquidGlassColors.mintEmerald.withAlpha(isDark ? 30 : 20),
              border: Border.all(
                color: LiquidGlassColors.mintEmerald.withAlpha(isDark ? 60 : 40),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: LiquidGlassColors.mintEmerald.withAlpha(30),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: LiquidGlassColors.mintEmerald,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    session.status == SupportStatus.resolved
                        ? 'This ticket has been resolved.'
                        : 'This ticket has been closed.',
                    style: TextStyle(
                      color: isDark
                          ? LiquidGlassColors.mintLight
                          : LiquidGlassColors.mintEmerald,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GhostButton(
                  label: 'Reopen?',
                  onPressed: () => _showReopenDialog(context),
                  color: LiquidGlassColors.mintEmerald,
                  height: 36,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(
      BuildContext context, SupportChatState chatState, bool isDark) {
    if (chatState.messages.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[index];
        final isUser = message.isFromUser;
        final showDateHeader = index == 0 ||
            !_isSameDay(
              chatState.messages[index - 1].createdAt,
              message.createdAt,
            );

        return Column(
          children: [
            if (showDateHeader)
              _buildGlassDateHeader(context, message.createdAt, isDark),
            _buildGlassMessageBubble(context, message, isUser, isDark),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LiquidGlassColors.auroraGradient,
                boxShadow: isDark
                    ? LiquidGlassColors.neonGlow(
                        LiquidGlassColors.auroraViolet,
                        intensity: 0.3,
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
                Icons.chat_bubble_outline,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Start the conversation',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Send a message to describe your issue and our support team will respond as soon as possible.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark
                    ? Colors.white.withAlpha(180)
                    : Colors.black.withAlpha(150),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassDateHeader(
      BuildContext context, DateTime date, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isDark
                    ? Colors.white.withAlpha(15)
                    : Colors.black.withAlpha(8),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withAlpha(20)
                      : Colors.black.withAlpha(10),
                ),
              ),
              child: Text(
                _formatDateHeader(date),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? Colors.white.withAlpha(150)
                      : Colors.black.withAlpha(120),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassMessageBubble(
    BuildContext context,
    SupportMessageModel message,
    bool isUser,
    bool isDark,
  ) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Support agent label
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LiquidGlassColors.auroraGradient,
                      ),
                      child: const Icon(
                        Icons.support_agent,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      message.senderDisplayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: LiquidGlassColors.auroraIndigo,
                      ),
                    ),
                  ],
                ),
              ),

            // Message bubble with glass effect
            ClipRRect(
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomRight: isUser ? const Radius.circular(6) : null,
                bottomLeft: !isUser ? const Radius.circular(6) : null,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: isUser ? 0 : 10,
                  sigmaY: isUser ? 0 : 10,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomRight: isUser ? const Radius.circular(6) : null,
                      bottomLeft: !isUser ? const Radius.circular(6) : null,
                    ),
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
                                : Colors.black.withAlpha(8),
                          ),
                    boxShadow: isUser && isDark
                        ? LiquidGlassColors.neonGlow(
                            LiquidGlassColors.auroraViolet,
                            intensity: 0.25,
                            blur: 16,
                          )
                        : [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDark ? 40 : 15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: isUser
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),

            // Timestamp
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
              child: Text(
                DateFormat('HH:mm').format(message.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: isDark
                      ? Colors.white.withAlpha(100)
                      : Colors.black.withAlpha(80),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassInputArea(
    BuildContext context,
    WidgetRef ref,
    SupportChatState chatState,
    bool isDark,
  ) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withAlpha(40)
                : Colors.white.withAlpha(180),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : Colors.black.withAlpha(10),
              ),
            ),
          ),
          child: Row(
            children: [
              // Text input with glass effect
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: isDark
                        ? Colors.white.withAlpha(10)
                        : Colors.black.withAlpha(5),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withAlpha(15)
                          : Colors.black.withAlpha(8),
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.white.withAlpha(100)
                            : Colors.black.withAlpha(80),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(ref),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Send button with glow
              GestureDetector(
                onTap: chatState.isSending ? null : () => _sendMessage(ref),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: chatState.isSending
                        ? null
                        : LiquidGlassColors.auroraGradient,
                    color: chatState.isSending
                        ? (isDark
                            ? Colors.white.withAlpha(20)
                            : Colors.black.withAlpha(10))
                        : null,
                    boxShadow: chatState.isSending
                        ? []
                        : (isDark
                            ? LiquidGlassColors.neonGlow(
                                LiquidGlassColors.auroraViolet,
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
                  child: Center(
                    child: chatState.isSending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? Colors.white : Colors.black54,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LiquidGlassColors.sunsetRose.withAlpha(20),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: LiquidGlassColors.sunsetRose,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(WidgetRef ref) async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // Store notifier reference before clearing and awaiting
    final notifier = ref.read(
      supportChatProvider((widget.sessionId, SenderRole.user)).notifier,
    );

    _messageController.clear();

    if (!mounted) return;
    await notifier.sendMessage(content);
  }

  void _showReopenDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? LiquidGlassColors.canvasSubtleDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Reopen Ticket',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Would you like to reopen this support ticket? '
          'This will notify our support team.',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          GhostButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context),
            height: 40,
          ),
          const SizedBox(width: 8),
          PremiumButton.gradient(
            label: 'Create New Ticket',
            onPressed: () {
              Navigator.pop(context);
              context.go('/support');
            },
            height: 40,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == DateTime(now.year, now.month, now.day)) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }
}

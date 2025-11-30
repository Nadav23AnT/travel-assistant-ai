import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../data/models/admin_models.dart';
import '../../providers/support_provider.dart';
import '../../widgets/admin/support_ticket_card.dart';

/// Admin support chat screen for messaging with users
class AdminSupportChatScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const AdminSupportChatScreen({super.key, required this.sessionId});

  @override
  ConsumerState<AdminSupportChatScreen> createState() =>
      _AdminSupportChatScreenState();
}

class _AdminSupportChatScreenState
    extends ConsumerState<AdminSupportChatScreen> {
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
    final chatState = ref.watch(
      supportChatProvider((widget.sessionId, SenderRole.admin)),
    );

    // Scroll to bottom when messages change
    ref.listen(
      supportChatProvider((widget.sessionId, SenderRole.admin)),
      (prev, next) {
        if (prev?.messages.length != next.messages.length) {
          _scrollToBottom();
        }
      },
    );

    return Scaffold(
      appBar: _buildAppBar(context, chatState),
      body: Column(
        children: [
          // Session info header
          if (chatState.session != null)
            _buildSessionHeader(context, chatState.session!),

          // Messages list
          Expanded(
            child: chatState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : chatState.error != null
                    ? _buildErrorState(context, chatState.error!)
                    : _buildMessagesList(context, chatState),
          ),

          // Input area
          _buildInputArea(context, ref, chatState),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    SupportChatState chatState,
  ) {
    final session = chatState.session;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/admin/support'),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session?.subject ?? 'Loading...',
            style: const TextStyle(fontSize: 16),
          ),
          if (session != null)
            Text(
              session.userDisplayName,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
              ),
            ),
        ],
      ),
      actions: [
        if (session != null) ...[
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(context, ref, value, session),
            itemBuilder: (context) => [
              if (!session.isAssigned)
                const PopupMenuItem(
                  value: 'assign',
                  child: ListTile(
                    leading: Icon(Icons.person_add),
                    title: Text('Assign to me'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              if (session.isAssigned)
                const PopupMenuItem(
                  value: 'unassign',
                  child: ListTile(
                    leading: Icon(Icons.person_remove),
                    title: Text('Unassign'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'status',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Change status'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'priority',
                child: ListTile(
                  leading: Icon(Icons.flag),
                  title: Text('Change priority'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSessionHeader(BuildContext context, SupportSessionModel session) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.darkDivider : AppTheme.dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          SupportStatusBadge(status: session.status),
          const SizedBox(width: 8),
          SupportPriorityBadge(priority: session.priority),
          const Spacer(),
          if (session.isAssigned)
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  session.adminDisplayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, SupportChatState chatState) {
    if (chatState.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[index];
        final isAdmin = message.isFromAdmin;
        final showDateHeader = index == 0 ||
            !_isSameDay(
              chatState.messages[index - 1].createdAt,
              message.createdAt,
            );

        return Column(
          children: [
            if (showDateHeader) _buildDateHeader(context, message.createdAt),
            _buildMessageBubble(context, message, isAdmin),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDateHeader(date),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    SupportMessageModel message,
    bool isAdmin,
  ) {
    final theme = Theme.of(context);

    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isAdmin)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Text(
                  message.senderDisplayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isAdmin
                    ? AppTheme.primaryColor
                    : (theme.brightness == Brightness.dark
                        ? AppTheme.darkCard
                        : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isAdmin ? const Radius.circular(4) : null,
                  bottomLeft: !isAdmin ? const Radius.circular(4) : null,
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isAdmin ? Colors.white : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
              child: Text(
                DateFormat('HH:mm').format(message.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(
    BuildContext context,
    WidgetRef ref,
    SupportChatState chatState,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.darkDivider : AppTheme.dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(ref),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: chatState.isSending ? null : () => _sendMessage(ref),
            icon: chatState.isSending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
          const SizedBox(height: 16),
          Text('Error: $error'),
        ],
      ),
    );
  }

  Future<void> _sendMessage(WidgetRef ref) async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    await ref
        .read(supportChatProvider((widget.sessionId, SenderRole.admin)).notifier)
        .sendMessage(content);
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    SupportSessionModel session,
  ) {
    final notifier =
        ref.read(supportChatProvider((widget.sessionId, SenderRole.admin)).notifier);

    switch (action) {
      case 'assign':
        notifier.assignToMe();
        break;
      case 'unassign':
        notifier.unassign();
        break;
      case 'status':
        _showStatusDialog(context, notifier, session.status);
        break;
      case 'priority':
        _showPriorityDialog(context, notifier, session.priority);
        break;
    }
  }

  void _showStatusDialog(
    BuildContext context,
    SupportChatNotifier notifier,
    SupportStatus currentStatus,
  ) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Change Status'),
        children: SupportStatus.values.map((status) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              notifier.updateStatus(status);
            },
            child: Row(
              children: [
                if (status == currentStatus)
                  const Icon(Icons.check, size: 20, color: AppTheme.primaryColor)
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 12),
                Text(status.displayName),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showPriorityDialog(
    BuildContext context,
    SupportChatNotifier notifier,
    SupportPriority currentPriority,
  ) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Change Priority'),
        children: SupportPriority.values.map((priority) {
          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              notifier.updatePriority(priority);
            },
            child: Row(
              children: [
                if (priority == currentPriority)
                  const Icon(Icons.check, size: 20, color: AppTheme.primaryColor)
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 12),
                Text(priority.displayName),
              ],
            ),
          );
        }).toList(),
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

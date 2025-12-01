import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design/design_system.dart';
import '../../../data/models/chat_models.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/chat_provider.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final Set<String> _pinnedChats = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessionsAsync = ref.watch(chatSessionsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              backgroundColor: isDark
                  ? Colors.black.withAlpha(77)
                  : Colors.white.withAlpha(179),
              elevation: 0,
              centerTitle: true,
              title: Text(
                l10n.aiChats,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GlowingIconButton(
                    icon: Icons.search_rounded,
                    onPressed: () {
                      // TODO: Implement search
                    },
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          sessionsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  LiquidGlassColors.auroraIndigo,
                ),
              ),
            ),
            error: (error, stack) => _buildErrorState(context, ref, error, isDark),
            data: (sessions) {
              if (sessions.isEmpty) {
                return _buildEmptyState(context, isDark);
              }
              return _buildSessionsList(context, ref, sessions, isDark);
            },
          ),
          // Floating New Chat Button - positioned above the nav bar
          Positioned(
            bottom: 100, // Above the floating nav bar
            right: 20,
            child: _GlassFAB(
              label: l10n.newChat,
              icon: Icons.add_rounded,
              onPressed: () => context.push('/chat/new'),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(
    BuildContext context,
    WidgetRef ref,
    List<ChatSession> sessions,
    bool isDark,
  ) {
    // Sort: pinned first, then by date
    final sortedSessions = [...sessions];
    sortedSessions.sort((a, b) {
      final aIsPinned = _pinnedChats.contains(a.id);
      final bIsPinned = _pinnedChats.contains(b.id);
      if (aIsPinned && !bIsPinned) return -1;
      if (!aIsPinned && bIsPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(chatSessionsProvider);
      },
      color: LiquidGlassColors.auroraIndigo,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 180),
        itemCount: sortedSessions.length,
        itemBuilder: (context, index) {
          final session = sortedSessions[index];
          final isPinned = _pinnedChats.contains(session.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SwipeableChatCard(
              session: session,
              isPinned: isPinned,
              isDark: isDark,
              onTap: () => context.push('/chat/${session.id}'),
              onDelete: () => _showDeleteDialog(context, ref, session),
              onPin: () {
                setState(() {
                  if (isPinned) {
                    _pinnedChats.remove(session.id);
                  } else {
                    _pinnedChats.add(session.id);
                  }
                });
                HapticFeedback.mediumImpact();
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, ChatSession session) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: isDark
              ? const Color(0xFF1A1F2E)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: LiquidGlassColors.sunsetRose.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: LiquidGlassColors.sunsetRose,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.deleteChat,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            l10n.deleteChatTitle(session.title),
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          actions: [
            GhostButton(
              label: l10n.cancel,
              onPressed: () => Navigator.pop(dialogContext),
              width: 100,
              height: 44,
            ),
            const SizedBox(width: 8),
            PremiumButton.solid(
              label: l10n.delete,
              color: LiquidGlassColors.sunsetRose,
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _deleteChat(context, ref, session);
              },
              width: 100,
              height: 44,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteChat(BuildContext context, WidgetRef ref, ChatSession session) async {
    final l10n = AppLocalizations.of(context);
    try {
      final repository = ref.read(chatRepositoryProvider);
      await repository.deleteSession(session.id);
      ref.invalidate(chatSessionsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(l10n.chatDeleted),
              ],
            ),
            backgroundColor: LiquidGlassColors.mintEmerald,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorDeletingChat}: $e'),
            backgroundColor: LiquidGlassColors.sunsetRose,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          ),
        );
      }
    }
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error, bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LiquidGlassColors.sunsetRose.withAlpha(26),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: LiquidGlassColors.sunsetRose,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.failedToLoadChats,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              PremiumButton.gradient(
                label: l10n.retry,
                icon: Icons.refresh_rounded,
                onPressed: () => ref.invalidate(chatSessionsProvider),
                width: 140,
                height: 48,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassCard(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LiquidGlassColors.mintGradient,
                  boxShadow: isDark
                      ? LiquidGlassColors.neonGlow(
                          LiquidGlassColors.mintEmerald,
                          intensity: 0.4,
                          blur: 24,
                        )
                      : [
                          BoxShadow(
                            color: LiquidGlassColors.mintEmerald.withAlpha(77),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.aiTravelAssistant,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.aiTravelAssistantDescription,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white60 : Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              PremiumButton.gradient(
                label: l10n.startNewChat,
                icon: Icons.chat_bubble_outline_rounded,
                onPressed: () => context.push('/chat/new'),
                width: 180,
                height: 52,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Swipeable chat card with delete and pin actions
class _SwipeableChatCard extends StatefulWidget {
  final ChatSession session;
  final bool isPinned;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onPin;

  const _SwipeableChatCard({
    required this.session,
    required this.isPinned,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
    required this.onPin,
  });

  @override
  State<_SwipeableChatCard> createState() => _SwipeableChatCardState();
}

class _SwipeableChatCardState extends State<_SwipeableChatCard> {
  double _dragExtent = 0;

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.delta.dx;
      _dragExtent = _dragExtent.clamp(-100.0, 100.0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragExtent < -60) {
      // Swipe left - Delete
      HapticFeedback.mediumImpact();
      widget.onDelete();
    } else if (_dragExtent > 60) {
      // Swipe right - Pin/Unpin
      HapticFeedback.lightImpact();
      widget.onPin();
    }
    setState(() {
      _dragExtent = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = (_dragExtent.abs() / 100).clamp(0.0, 1.0);

    return Stack(
      children: [
        // Background actions
        Positioned.fill(
          child: Row(
            children: [
              // Left side - Pin action
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: widget.isPinned
                        ? LiquidGlassColors.categoryOther.withAlpha((progress * 255).toInt())
                        : LiquidGlassColors.oceanSky.withAlpha((progress * 255).toInt()),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 24),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _dragExtent > 30 ? 1 : 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.isPinned ? l10n.unpin : l10n.pin,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Right side - Delete action
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: LiquidGlassColors.sunsetRose.withAlpha((progress * 255).toInt()),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _dragExtent < -30 ? 1 : 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.delete,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Foreground card
        GestureDetector(
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: _handleDragEnd,
          child: Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: _ChatCard(
              session: widget.session,
              isPinned: widget.isPinned,
              isDark: widget.isDark,
              onTap: widget.onTap,
              onMorePressed: () => _showOptionsSheet(context),
            ),
          ),
        ),
      ],
    );
  }

  void _showOptionsSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A1F2E).withAlpha(230)
                : Colors.white.withAlpha(230),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(20)
                  : Colors.black.withAlpha(10),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white30 : Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // Options
                _OptionTile(
                  icon: widget.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                  label: widget.isPinned ? l10n.unpin : l10n.pin,
                  color: LiquidGlassColors.oceanSky,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    widget.onPin();
                  },
                ),
                _OptionTile(
                  icon: Icons.delete_outline_rounded,
                  label: l10n.deleteChat,
                  color: LiquidGlassColors.sunsetRose,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    widget.onDelete();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Modern chat card with country flag avatar
class _ChatCard extends StatefulWidget {
  final ChatSession session;
  final bool isPinned;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onMorePressed;

  const _ChatCard({
    required this.session,
    required this.isPinned,
    required this.isDark,
    required this.onTap,
    required this.onMorePressed,
  });

  @override
  State<_ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<_ChatCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final hasFlag = widget.session.tripFlagEmoji != null &&
        widget.session.tripFlagEmoji!.isNotEmpty;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Transform.scale(
        scale: _isPressed ? 0.98 : 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.isDark ? 24 : 20,
              sigmaY: widget.isDark ? 24 : 20,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: widget.isDark
                    ? Colors.white.withAlpha(20)
                    : Colors.white.withAlpha(179),
                border: Border.all(
                  width: widget.isPinned ? 2 : 1.5,
                  color: widget.isPinned
                      ? LiquidGlassColors.oceanSky.withAlpha(128)
                      : (widget.isDark
                          ? Colors.white.withAlpha(31)
                          : Colors.white.withAlpha(128)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isDark
                        ? const Color(0x40000000)
                        : const Color(0x14000000),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  if (widget.isPinned && widget.isDark)
                    BoxShadow(
                      color: LiquidGlassColors.oceanSky.withAlpha(51),
                      blurRadius: 16,
                      offset: Offset.zero,
                    ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar - Flag or Icon
                  _ChatAvatar(
                    flagEmoji: hasFlag ? widget.session.tripFlagEmoji : null,
                    isDark: widget.isDark,
                  ),
                  const SizedBox(width: 14),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row with pin indicator
                        Row(
                          children: [
                            if (widget.isPinned) ...[
                              Icon(
                                Icons.push_pin_rounded,
                                size: 14,
                                color: LiquidGlassColors.oceanSky,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Expanded(
                              child: Text(
                                widget.session.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: widget.isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Destination badge
                        if (widget.session.tripDestination != null &&
                            widget.session.tripDestination!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: LiquidGlassColors.auroraIndigo.withAlpha(26),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.session.tripDestination!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: LiquidGlassColors.auroraIndigo,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        // Timestamp
                        Text(
                          _formatDate(context, widget.session.updatedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // More button
                  GestureDetector(
                    onTap: widget.onMorePressed,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isDark
                            ? Colors.white.withAlpha(10)
                            : Colors.black.withAlpha(10),
                      ),
                      child: Icon(
                        Icons.more_vert_rounded,
                        size: 18,
                        color: widget.isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return l10n.todayAt(DateFormat.jm().format(date));
    } else if (dateToCheck == yesterday) {
      return l10n.yesterdayAt(DateFormat.jm().format(date));
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }
}

/// Chat avatar showing country flag or default icon
class _ChatAvatar extends StatelessWidget {
  final String? flagEmoji;
  final bool isDark;

  const _ChatAvatar({
    this.flagEmoji,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (flagEmoji != null && flagEmoji!.isNotEmpty) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isDark
              ? Colors.white.withAlpha(15)
              : Colors.white.withAlpha(200),
          border: Border.all(
            width: 1.5,
            color: isDark
                ? Colors.white.withAlpha(20)
                : Colors.black.withAlpha(10),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0x30000000)
                  : const Color(0x10000000),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            flagEmoji!,
            style: const TextStyle(fontSize: 28),
          ),
        ),
      );
    }

    // Default modern placeholder icon
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LiquidGlassColors.mintGradient,
        boxShadow: isDark
            ? LiquidGlassColors.neonGlow(
                LiquidGlassColors.mintEmerald,
                intensity: 0.25,
                blur: 12,
              )
            : [
                BoxShadow(
                  color: LiquidGlassColors.mintEmerald.withAlpha(51),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: const Icon(
        Icons.auto_awesome_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

/// Option tile for bottom sheet
class _OptionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: _isPressed
              ? widget.color.withAlpha(26)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: widget.color.withAlpha(26),
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Glass-styled floating action button
class _GlassFAB extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDark;

  const _GlassFAB({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.isDark,
  });

  @override
  State<_GlassFAB> createState() => _GlassFABState();
}

class _GlassFABState extends State<_GlassFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LiquidGlassColors.auroraGradient,
                boxShadow: widget.isDark
                    ? [
                        BoxShadow(
                          color: LiquidGlassColors.auroraIndigo
                              .withAlpha(_isPressed ? 153 : 102),
                          blurRadius: _isPressed ? 30 : 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: LiquidGlassColors.auroraViolet.withAlpha(51),
                          blurRadius: 40,
                          offset: Offset.zero,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: LiquidGlassColors.auroraIndigo.withAlpha(102),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

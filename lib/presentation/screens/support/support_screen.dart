import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/design/components/premium_button.dart';
import '../../../core/design/tokens/liquid_glass_colors.dart';
import '../../../data/models/admin_models.dart';
import '../../providers/support_provider.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(context, unreadCount, isDark),
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
          child: sessions.when(
            data: (list) {
              if (list.isEmpty) {
                return _buildEmptyState(context, isDark);
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
                    return _buildSessionCard(context, session, isDark);
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _buildErrorState(context, e.toString(), isDark),
          ),
        ),
      ),
      floatingActionButton: _buildGradientFAB(context, isDark),
    );
  }

  PreferredSizeWidget _buildGlassAppBar(
    BuildContext context,
    AsyncValue<int> unreadCount,
    bool isDark,
  ) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    GlowingIconButton(
                      icon: Icons.arrow_back,
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/profile');
                        }
                      },
                      size: 44,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Support & Feedback',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    if (unreadCount.valueOrNull != null &&
                        unreadCount.value! > 0)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LiquidGlassColors.auroraGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isDark
                              ? LiquidGlassColors.neonGlow(
                                  LiquidGlassColors.auroraViolet,
                                  intensity: 0.3,
                                  blur: 8,
                                )
                              : [],
                        ),
                        child: Text(
                          '${unreadCount.value} new',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildGradientFAB(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LiquidGlassColors.auroraGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: isDark
            ? LiquidGlassColors.neonGlow(
                LiquidGlassColors.auroraViolet,
                intensity: 0.4,
                blur: 16,
              )
            : [
                BoxShadow(
                  color: LiquidGlassColors.auroraIndigo.withAlpha(80),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCreateTicketSheet(context, ref),
          borderRadius: BorderRadius.circular(28),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'New Ticket',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    SupportSessionModel session,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? Colors.white.withAlpha(15)
                  : Colors.white.withAlpha(200),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : Colors.black.withAlpha(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 40 : 15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.go('/support/${session.id}'),
                borderRadius: BorderRadius.circular(16),
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildGlassStatusBadge(session.status, isDark),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Feedback type badge
                          _buildFeedbackTypeBadge(session.feedbackType, isDark),
                          const SizedBox(width: 8),
                          // Priority badge
                          _buildPriorityBadge(session.priority, isDark),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: isDark
                                ? Colors.white.withAlpha(150)
                                : Colors.black.withAlpha(120),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Created ${_formatDate(session.createdAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white.withAlpha(150)
                                  : Colors.black.withAlpha(120),
                            ),
                          ),
                          const Spacer(),
                          if (session.unreadUserCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LiquidGlassColors.auroraGradient,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isDark
                                    ? LiquidGlassColors.neonGlow(
                                        LiquidGlassColors.auroraViolet,
                                        intensity: 0.3,
                                        blur: 6,
                                      )
                                    : [],
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

  Widget _buildFeedbackTypeBadge(FeedbackType type, bool isDark) {
    final (icon, label, color) = _getFeedbackTypeInfo(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withAlpha(isDark ? 30 : 20),
        border: Border.all(
          color: color.withAlpha(isDark ? 60 : 40),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(SupportPriority priority, bool isDark) {
    final (icon, label, color) = _getPriorityInfo(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withAlpha(isDark ? 30 : 20),
        border: Border.all(
          color: color.withAlpha(isDark ? 60 : 40),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
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

  (IconData, String, Color) _getFeedbackTypeInfo(FeedbackType type) {
    switch (type) {
      case FeedbackType.bugReport:
        return (Icons.bug_report, 'Bug', LiquidGlassColors.sunsetRose);
      case FeedbackType.featureRequest:
        return (Icons.lightbulb, 'Feature', LiquidGlassColors.auroraViolet);
      case FeedbackType.uxFeedback:
        return (Icons.touch_app, 'UX', LiquidGlassColors.oceanCyan);
      case FeedbackType.generalSupport:
        return (Icons.help, 'Support', LiquidGlassColors.auroraIndigo);
    }
  }

  (IconData, String, Color) _getPriorityInfo(SupportPriority priority) {
    switch (priority) {
      case SupportPriority.low:
        return (Icons.arrow_downward, 'Low', Colors.grey);
      case SupportPriority.normal:
        return (Icons.remove, 'Normal', LiquidGlassColors.auroraIndigo);
      case SupportPriority.high:
        return (Icons.arrow_upward, 'High', LiquidGlassColors.sunsetOrange);
      case SupportPriority.urgent:
        return (Icons.priority_high, 'Urgent', LiquidGlassColors.sunsetRose);
    }
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
                Icons.support_agent,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Need Help?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Our support team is here to help you with any questions, feedback, or issues.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark
                    ? Colors.white.withAlpha(180)
                    : Colors.black.withAlpha(150),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            PremiumButton.gradient(
              label: 'Create Support Ticket',
              onPressed: () => _showCreateTicketSheet(context, ref),
              icon: Icons.add,
              height: 52,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, bool isDark) {
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
            'Failed to load tickets',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          GhostButton(
            label: 'Retry',
            onPressed: () => ref.invalidate(userSupportSessionsProvider),
            color: LiquidGlassColors.auroraIndigo,
          ),
        ],
      ),
    );
  }

  void _showCreateTicketSheet(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateTicketSheet(
        ref: ref,
        isDark: isDark,
        onCreated: (session) {
          Navigator.pop(context);
          context.go('/support/${session.id}');
        },
      ),
    ).then((_) {
      ref.read(createSessionProvider.notifier).reset();
    });
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

/// Bottom sheet widget for creating a new support ticket
class _CreateTicketSheet extends StatefulWidget {
  final WidgetRef ref;
  final bool isDark;
  final void Function(SupportSessionModel session) onCreated;

  const _CreateTicketSheet({
    required this.ref,
    required this.isDark,
    required this.onCreated,
  });

  @override
  State<_CreateTicketSheet> createState() => _CreateTicketSheetState();
}

class _CreateTicketSheetState extends State<_CreateTicketSheet> {
  final _subjectController = TextEditingController();
  FeedbackType _selectedFeedbackType = FeedbackType.generalSupport;
  SupportPriority _selectedPriority = SupportPriority.normal;

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final createState = widget.ref.watch(createSessionProvider);
    final isDark = widget.isDark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E1B4B).withAlpha(240)
                : Colors.white.withAlpha(245),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : Colors.black.withAlpha(10),
              ),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withAlpha(60)
                            : Colors.black.withAlpha(40),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Create Support Ticket',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tell us how we can help you',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? Colors.white.withAlpha(150)
                          : Colors.black.withAlpha(120),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Feedback Type Grid
                  Text(
                    'What type of feedback is this?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: FeedbackType.values.map((type) {
                      return _buildFeedbackTypeCard(type, isDark);
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Subject Input
                  Text(
                    'Subject',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isDark
                          ? Colors.white.withAlpha(10)
                          : Colors.black.withAlpha(5),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withAlpha(15)
                            : Colors.black.withAlpha(10),
                      ),
                    ),
                    child: TextField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        hintText: _getSubjectHint(_selectedFeedbackType),
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.white.withAlpha(100)
                              : Colors.black.withAlpha(80),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        counterText: '',
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLength: 100,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Priority Selector
                  Text(
                    'Priority',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPrioritySelector(isDark),
                  const SizedBox(height: 24),

                  // Error message
                  if (createState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: LiquidGlassColors.sunsetRose.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: LiquidGlassColors.sunsetRose.withAlpha(40),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 18,
                              color: LiquidGlassColors.sunsetRose,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                createState.error!,
                                style: const TextStyle(
                                  color: LiquidGlassColors.sunsetRose,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Create Button
                  SizedBox(
                    width: double.infinity,
                    child: PremiumButton.gradient(
                      label: 'Create Ticket',
                      onPressed: createState.isCreating
                          ? null
                          : () async {
                              if (_subjectController.text.trim().isEmpty) {
                                return;
                              }
                              final session = await widget.ref
                                  .read(createSessionProvider.notifier)
                                  .createSession(
                                    subject: _subjectController.text.trim(),
                                    priority: _selectedPriority,
                                    feedbackType: _selectedFeedbackType,
                                  );
                              if (session != null && context.mounted) {
                                widget.onCreated(session);
                              }
                            },
                      icon: createState.isCreating ? null : Icons.send,
                      isLoading: createState.isCreating,
                      height: 52,
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

  Widget _buildFeedbackTypeCard(FeedbackType type, bool isDark) {
    final isSelected = type == _selectedFeedbackType;
    final (icon, label, description, color) = _getFeedbackTypeCardInfo(type);

    return GestureDetector(
      onTap: () => setState(() => _selectedFeedbackType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? color.withAlpha(isDark ? 30 : 20)
              : (isDark
                  ? Colors.white.withAlpha(8)
                  : Colors.black.withAlpha(5)),
          border: Border.all(
            color: isSelected
                ? color.withAlpha(isDark ? 100 : 80)
                : (isDark
                    ? Colors.white.withAlpha(15)
                    : Colors.black.withAlpha(10)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected && isDark
              ? [
                  BoxShadow(
                    color: color.withAlpha(30),
                    blurRadius: 12,
                    offset: Offset.zero,
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withAlpha(isDark ? 40 : 30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: color,
                    ),
                  ),
                  if (isSelected) ...[
                    const Spacer(),
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: color,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(5),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
        ),
      ),
      child: Row(
        children: SupportPriority.values.map((priority) {
          final isSelected = priority == _selectedPriority;
          final color = _getPriorityColor(priority);

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPriority = priority),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isSelected ? color.withAlpha(isDark ? 40 : 30) : null,
                  border: isSelected
                      ? Border.all(color: color.withAlpha(isDark ? 80 : 60))
                      : null,
                ),
                child: Center(
                  child: Text(
                    priority.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? color
                          : (isDark
                              ? Colors.white.withAlpha(150)
                              : Colors.black.withAlpha(120)),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  (IconData, String, String, Color) _getFeedbackTypeCardInfo(FeedbackType type) {
    switch (type) {
      case FeedbackType.bugReport:
        return (
          Icons.bug_report,
          'Bug Report',
          'Report an issue',
          LiquidGlassColors.sunsetRose
        );
      case FeedbackType.featureRequest:
        return (
          Icons.lightbulb,
          'Feature Request',
          'Suggest a feature',
          LiquidGlassColors.auroraViolet
        );
      case FeedbackType.uxFeedback:
        return (
          Icons.touch_app,
          'UX Feedback',
          'Improve experience',
          LiquidGlassColors.oceanCyan
        );
      case FeedbackType.generalSupport:
        return (
          Icons.help,
          'General Support',
          'Get help',
          LiquidGlassColors.auroraIndigo
        );
    }
  }

  Color _getPriorityColor(SupportPriority priority) {
    switch (priority) {
      case SupportPriority.low:
        return Colors.grey;
      case SupportPriority.normal:
        return LiquidGlassColors.auroraIndigo;
      case SupportPriority.high:
        return LiquidGlassColors.sunsetOrange;
      case SupportPriority.urgent:
        return LiquidGlassColors.sunsetRose;
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
}

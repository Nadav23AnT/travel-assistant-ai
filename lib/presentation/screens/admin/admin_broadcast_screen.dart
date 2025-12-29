import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme.dart';
import '../../../core/design/tokens/liquid_glass_colors.dart';
import '../../../data/models/broadcast_notification_model.dart';
import '../../providers/broadcast_notification_provider.dart';
import 'admin_scaffold.dart';

/// Admin screen for sending broadcast notifications
class AdminBroadcastScreen extends ConsumerStatefulWidget {
  const AdminBroadcastScreen({super.key});

  @override
  ConsumerState<AdminBroadcastScreen> createState() =>
      _AdminBroadcastScreenState();
}

class _AdminBroadcastScreenState extends ConsumerState<AdminBroadcastScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentItem: AdminNavItem.broadcasts,
      title: 'Broadcasts',
      child: Column(
        children: [
          // Tab bar
          Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Compose', icon: Icon(Icons.edit_outlined)),
                Tab(text: 'History', icon: Icon(Icons.history)),
              ],
              indicatorColor: AppTheme.primaryColor,
              labelColor: AppTheme.primaryColor,
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ComposeTab(
                  onSent: () {
                    // Switch to history tab after sending
                    _tabController.animateTo(1);
                  },
                ),
                const _HistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compose notification tab
class _ComposeTab extends ConsumerStatefulWidget {
  final VoidCallback? onSent;

  const _ComposeTab({this.onSent});

  @override
  ConsumerState<_ComposeTab> createState() => _ComposeTabState();
}

class _ComposeTabState extends ConsumerState<_ComposeTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  NotificationPriority _priority = NotificationPriority.normal;
  String? _selectedDeepLink;

  final _deepLinkOptions = [
    ('None', null),
    ('Home', '/home'),
    ('Trips', '/trips'),
    ('Expenses', '/expenses'),
    ('Chat', '/chat'),
    ('Settings', '/settings'),
    ('Profile', '/profile'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Broadcast?'),
        content: Text(
          'This will send a ${_priority.displayName.toLowerCase()} priority '
          'notification to all users. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: _priority.color,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Send notification
    final success = await ref.read(sendBroadcastProvider.notifier).send(
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          priority: _priority,
          deepLink: _selectedDeepLink,
        );

    if (success && mounted) {
      // Show success snackbar
      final result = ref.read(sendBroadcastProvider).result;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Notification sent to ${result?.sentCount ?? 0} users!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      _titleController.clear();
      _messageController.clear();
      setState(() {
        _priority = NotificationPriority.normal;
        _selectedDeepLink = null;
      });

      // Reset send state
      ref.read(sendBroadcastProvider.notifier).reset();

      // Callback
      widget.onSent?.call();
    } else if (mounted) {
      final error = ref.read(sendBroadcastProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to send notification'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sendState = ref.watch(sendBroadcastProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form card
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title field
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Notification Title *',
                      hintText: 'Keep it short and clear',
                      prefixIcon: const Icon(Icons.title),
                      counterText: '${_titleController.text.length}/60',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLength: 60,
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      if (value.trim().length < 3) {
                        return 'Title must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Message field
                  TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Message *',
                      hintText: 'What do you want to tell users?',
                      prefixIcon: const Icon(Icons.message),
                      counterText: '${_messageController.text.length}/500',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignLabelWithHint: true,
                    ),
                    maxLength: 500,
                    maxLines: 4,
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Message is required';
                      }
                      if (value.trim().length < 10) {
                        return 'Message must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Priority selector
                  Text(
                    'Priority',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<NotificationPriority>(
                    segments: NotificationPriority.values.map((p) {
                      return ButtonSegment(
                        value: p,
                        label: Text(p.displayName),
                        icon: Icon(p.icon),
                      );
                    }).toList(),
                    selected: {_priority},
                    onSelectionChanged: (selected) {
                      setState(() => _priority = selected.first);
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return _priority.color.withOpacity(0.2);
                        }
                        return null;
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Deep link selector
                  DropdownButtonFormField<String?>(
                    value: _selectedDeepLink,
                    decoration: InputDecoration(
                      labelText: 'Action Link (Optional)',
                      hintText: 'Select screen to navigate to',
                      prefixIcon: const Icon(Icons.link),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _deepLinkOptions.map((option) {
                      return DropdownMenuItem(
                        value: option.$2,
                        child: Text(option.$1),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedDeepLink = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Preview section
            Text(
              'Preview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            _NotificationPreview(
              title: _titleController.text.isEmpty
                  ? 'Preview Title'
                  : _titleController.text,
              message: _messageController.text.isEmpty
                  ? 'Preview message'
                  : _messageController.text,
              priority: _priority,
            ),
            const SizedBox(height: 24),

            // Send button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: sendState.isLoading ? null : _sendNotification,
                icon: sendState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(sendState.isLoading ? 'Sending...' : 'Send to All Users'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: _priority.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// History tab showing sent notifications
class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final broadcastsAsync = ref.watch(adminBroadcastsProvider);
    final totalSent = ref.watch(totalBroadcastsSentProvider);
    final avgReadRate = ref.watch(averageReadRateProvider);

    return broadcastsAsync.when(
      data: (broadcasts) {
        if (broadcasts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.campaign_outlined,
                  size: 80,
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No broadcasts yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Send your first broadcast notification',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(adminBroadcastsProvider.notifier).refresh();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats summary
              _GlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatChip(
                      label: 'Total Sent',
                      value: '$totalSent',
                      icon: Icons.send,
                      color: LiquidGlassColors.oceanCyan,
                    ),
                    _StatChip(
                      label: 'Avg Read Rate',
                      value: '${avgReadRate.toStringAsFixed(1)}%',
                      icon: Icons.visibility,
                      color: LiquidGlassColors.mintEmerald,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Broadcast list
              ...broadcasts.map((broadcast) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _BroadcastHistoryCard(broadcast: broadcast),
                  )),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Failed to load broadcasts'),
            TextButton(
              onPressed: () => ref.read(adminBroadcastsProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Glass card wrapper
class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? LiquidGlassColors.canvasSubtleDark
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: LiquidGlassColors.glassShadow(isDark),
      ),
      child: child,
    );
  }
}

/// Stat chip for summary
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.grey[900],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

/// Notification preview widget
class _NotificationPreview extends StatelessWidget {
  final String title;
  final String message;
  final NotificationPriority priority;

  const _NotificationPreview({
    required this.title,
    required this.message,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = priority.color;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                priorityColor.withOpacity(isDark ? 0.15 : 0.12),
                priorityColor.withOpacity(isDark ? 0.08 : 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(priority.icon, size: 20, color: priorityColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.grey[900],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.close,
                    size: 20,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Just now',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.grey[500],
                    ),
                  ),
                  Text(
                    'Tap to read',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: priorityColor.withOpacity(0.8),
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
}

/// Broadcast history card
class _BroadcastHistoryCard extends StatelessWidget {
  final AdminBroadcastModel broadcast;

  const _BroadcastHistoryCard({required this.broadcast});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = broadcast.priority.color;

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Priority indicator
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: priorityColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      broadcast.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.grey[900],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      broadcast.relativeTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              // Read rate badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: LiquidGlassColors.mintEmerald.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  broadcast.readPercentageFormatted,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: LiquidGlassColors.mintEmerald,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            broadcast.message,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetricChip(
                icon: Icons.people,
                value: '${broadcast.sentCount}',
                label: 'Sent',
                color: LiquidGlassColors.oceanCyan,
              ),
              const SizedBox(width: 12),
              _MetricChip(
                icon: Icons.visibility,
                value: '${broadcast.readCount}',
                label: 'Read',
                color: LiquidGlassColors.mintEmerald,
              ),
              const SizedBox(width: 12),
              _MetricChip(
                icon: Icons.close,
                value: '${broadcast.dismissedCount}',
                label: 'Dismissed',
                color: LiquidGlassColors.sunsetOrange,
              ),
              if (broadcast.hasDeepLink) ...[
                const SizedBox(width: 12),
                _MetricChip(
                  icon: Icons.touch_app,
                  value: '${broadcast.clickCount}',
                  label: 'Clicks',
                  color: LiquidGlassColors.auroraViolet,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Metric chip for broadcast stats
class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MetricChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

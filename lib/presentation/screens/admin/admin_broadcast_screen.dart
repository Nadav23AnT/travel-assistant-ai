import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme.dart';
import '../../../core/design/tokens/liquid_glass_colors.dart';
import '../../../core/utils/notification_text_utils.dart';
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
      // Use LayoutBuilder to ensure Column has bounded constraints
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Tab bar - fixed height
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
              // Tab content - takes remaining space
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
          );
        },
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

/// Link type for action links
enum LinkType { none, internal, external }

class _ComposeTabState extends ConsumerState<_ComposeTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _externalUrlController = TextEditingController();
  final _actionButtonTextController = TextEditingController(text: 'View Details');
  NotificationPriority _priority = NotificationPriority.normal;
  LinkType _linkType = LinkType.none;
  String? _selectedDeepLink;
  int _autoDismissHours = 48; // Default: 2 days
  bool _isRTL = false; // Right-to-left text direction

  final _deepLinkOptions = [
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
    _externalUrlController.dispose();
    _actionButtonTextController.dispose();
    super.dispose();
  }

  String? get _effectiveDeepLink {
    switch (_linkType) {
      case LinkType.none:
        return null;
      case LinkType.internal:
        return _selectedDeepLink;
      case LinkType.external:
        final url = _externalUrlController.text.trim();
        return url.isNotEmpty ? url : null;
    }
  }

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return true;
    final uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
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
    final actionButtonText = _actionButtonTextController.text.trim().isNotEmpty
        ? _actionButtonTextController.text.trim()
        : 'View Details';
    final success = await ref.read(sendBroadcastProvider.notifier).send(
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          priority: _priority,
          deepLink: _effectiveDeepLink,
          actionButtonText: actionButtonText,
          autoDismissHours: _autoDismissHours,
          isRTL: _isRTL,
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
      _externalUrlController.clear();
      _actionButtonTextController.text = 'View Details';
      setState(() {
        _priority = NotificationPriority.normal;
        _linkType = LinkType.none;
        _selectedDeepLink = null;
        _autoDismissHours = 48;
        _isRTL = false;
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

    // Wrap in Scaffold with resizeToAvoidBottomInset for proper keyboard handling
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 80,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // CRITICAL: prevents unbounded height
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
                      helperText: 'Tip: Use **text** for bold formatting',
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
                  const SizedBox(height: 12),

                  // RTL toggle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.format_textdirection_r_to_l,
                          size: 20,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Right-to-Left (RTL)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.grey[800],
                                ),
                              ),
                              Text(
                                'For Hebrew or Arabic text',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isRTL,
                          onChanged: (value) => setState(() => _isRTL = value),
                          activeColor: LiquidGlassColors.auroraIndigo,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Priority selector - Visual cards
                  Text(
                    'Priority Level',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: NotificationPriority.values.map((p) {
                      final isSelected = _priority == p;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _priority = p),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.only(
                              right: p != NotificationPriority.urgent ? 8 : 0,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? p.color.withOpacity(0.2)
                                  : (isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.grey.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? p.color
                                    : (isDark
                                        ? Colors.white12
                                        : Colors.grey[300]!),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: p.color.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: -2,
                                      )
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: p.color.withOpacity(
                                        isSelected ? 0.3 : 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    p.icon,
                                    color: p.color,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  p.displayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? p.color
                                        : (isDark
                                            ? Colors.white70
                                            : Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Link type selector - using DropdownButtonFormField for flexibility
                  DropdownButtonFormField<LinkType>(
                    value: _linkType,
                    decoration: InputDecoration(
                      labelText: 'Action Link (Optional)',
                      prefixIcon: Icon(
                        _linkType == LinkType.none
                            ? Icons.link_off
                            : (_linkType == LinkType.internal
                                ? Icons.pages
                                : Icons.open_in_new),
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: LinkType.none,
                        child: Text('None'),
                      ),
                      DropdownMenuItem(
                        value: LinkType.internal,
                        child: Text('In-App Page'),
                      ),
                      DropdownMenuItem(
                        value: LinkType.external,
                        child: Text('External URL'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _linkType = value);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Internal page dropdown
                  if (_linkType == LinkType.internal)
                    DropdownButtonFormField<String?>(
                      value: _selectedDeepLink,
                      decoration: InputDecoration(
                        labelText: 'Navigate to Page',
                        hintText: 'Select screen',
                        prefixIcon: const Icon(Icons.pages),
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
                      validator: (value) {
                        if (_linkType == LinkType.internal && value == null) {
                          return 'Please select a page';
                        }
                        return null;
                      },
                    ),

                  // External URL text field
                  if (_linkType == LinkType.external)
                    TextFormField(
                      controller: _externalUrlController,
                      decoration: InputDecoration(
                        labelText: 'External URL',
                        hintText: 'https://example.com',
                        prefixIcon: const Icon(Icons.link),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        helperText: 'Enter a valid https:// URL',
                      ),
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (_linkType == LinkType.external) {
                          if (value == null || value.trim().isEmpty) {
                            return 'URL is required';
                          }
                          if (!_isValidUrl(value.trim())) {
                            return 'Please enter a valid URL (https://...)';
                          }
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 20),

                  // Action button text (only if link is set)
                  if (_linkType != LinkType.none) ...[
                    TextFormField(
                      controller: _actionButtonTextController,
                      decoration: InputDecoration(
                        labelText: 'Action Button Text',
                        hintText: 'View Details',
                        prefixIcon: const Icon(Icons.touch_app),
                        helperText: 'Customize the button text users will see',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: _actionButtonTextController.text != 'View Details'
                            ? IconButton(
                                icon: Icon(Icons.restore,
                                    color: isDark ? Colors.white54 : Colors.grey[600]),
                                onPressed: () {
                                  setState(() {
                                    _actionButtonTextController.text = 'View Details';
                                  });
                                },
                                tooltip: 'Reset to default',
                              )
                            : null,
                      ),
                      maxLength: 30,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Lifetime selector
                  _LifetimeSelector(
                    hours: _autoDismissHours,
                    onChanged: (hours) =>
                        setState(() => _autoDismissHours = hours),
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
              hasLink: _linkType != LinkType.none,
              actionButtonText: _actionButtonTextController.text.isEmpty
                  ? 'View Details'
                  : _actionButtonTextController.text,
              isRTL: _isRTL,
            ),
            const SizedBox(height: 24),

            // Send button - enhanced visibility
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _priority.color.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: _priority.color.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: sendState.isLoading ? null : _sendNotification,
                icon: sendState.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, size: 22),
                label: Text(
                  sendState.isLoading ? 'Sending...' : 'Send to All Users',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: _priority.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),

          ],
          ),
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
    final totalNotifs = ref.watch(totalBroadcastsSentProvider);
    final totalSent = ref.watch(totalUsersReachedProvider);
    final totalReads = ref.watch(totalReadsProvider);
    final totalClicks = ref.watch(totalClicksProvider);
    final readRate = ref.watch(overallReadRateProvider);
    final ctr = ref.watch(overallClickThroughRateProvider);
    final byPriority = ref.watch(notificationsByPriorityProvider);

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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 56),
            children: [
              // Header with refresh button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    onPressed: () {
                      ref.read(adminBroadcastsProvider.notifier).refresh();
                    },
                    tooltip: 'Refresh stats',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Comprehensive stats dashboard
              _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Engagement metrics row
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        _DashboardStat(
                          label: 'Sent',
                          value: _formatNumber(totalSent),
                          icon: Icons.send,
                          color: LiquidGlassColors.oceanCyan,
                        ),
                        _DashboardStat(
                          label: 'Reads',
                          value: _formatNumber(totalReads),
                          icon: Icons.visibility,
                          color: LiquidGlassColors.mintEmerald,
                        ),
                        _DashboardStat(
                          label: 'Clicks',
                          value: _formatNumber(totalClicks),
                          icon: Icons.touch_app,
                          color: LiquidGlassColors.auroraViolet,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      color: isDark ? Colors.white12 : Colors.grey[200],
                    ),
                    const SizedBox(height: 12),
                    // Rates row
                    Wrap(
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        _DashboardStat(
                          label: 'Read Rate',
                          value: '${readRate.toStringAsFixed(1)}%',
                          icon: Icons.trending_up,
                          color: LiquidGlassColors.mintEmerald,
                        ),
                        _DashboardStat(
                          label: 'CTR',
                          value: '${ctr.toStringAsFixed(1)}%',
                          icon: Icons.ads_click,
                          color: LiquidGlassColors.auroraViolet,
                        ),
                        _DashboardStat(
                          label: 'Notifications',
                          value: '$totalNotifs',
                          icon: Icons.notifications,
                          color: LiquidGlassColors.sunsetOrange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      color: isDark ? Colors.white12 : Colors.grey[200],
                    ),
                    const SizedBox(height: 12),
                    // Priority breakdown
                    Text(
                      'By Priority',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PriorityBadge(
                          priority: NotificationPriority.normal,
                          count: byPriority[NotificationPriority.normal] ?? 0,
                        ),
                        _PriorityBadge(
                          priority: NotificationPriority.important,
                          count: byPriority[NotificationPriority.important] ?? 0,
                        ),
                        _PriorityBadge(
                          priority: NotificationPriority.urgent,
                          count: byPriority[NotificationPriority.urgent] ?? 0,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // History header
              Text(
                'History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),

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

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return '$number';
  }
}

/// Dashboard stat widget
class _DashboardStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use intrinsic width with FittedBox for bulletproof overflow protection
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey[900],
            ),
          ),
        ),
      ],
    );
  }
}

/// Priority badge widget
class _PriorityBadge extends StatelessWidget {
  final NotificationPriority priority;
  final int count;

  const _PriorityBadge({
    required this.priority,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: priority.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: priority.color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: priority.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count ${priority.displayName}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: priority.color,
            ),
          ),
        ],
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
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive padding: smaller on narrow screens to prevent overflow
    final horizontalPadding = screenWidth < 400 ? 12.0 : 16.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
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

/// Notification preview widget - matches inline card design
class _NotificationPreview extends StatelessWidget {
  final String title;
  final String message;
  final NotificationPriority priority;
  final String? actionButtonText;
  final bool hasLink;
  final bool isRTL;

  const _NotificationPreview({
    required this.title,
    required this.message,
    required this.priority,
    this.actionButtonText,
    this.hasLink = false,
    this.isRTL = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = priority.color;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? const Color(0xFF1E2432) : Colors.white,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.12)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: priorityColor.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Row(
            children: [
              // Priority bar
              Container(
                width: 4,
                height: 120,
                decoration: BoxDecoration(
                  color: priorityColor,
                  boxShadow: [
                    BoxShadow(
                      color: priorityColor.withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isRTL ? 10 : 12,
                    10,
                    isRTL ? 12 : 10,
                    10,
                  ),
                  child: Column(
                    crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                    // Header row
                    Row(
                      children: [
                        // Priority icon
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            priority.icon,
                            size: 14,
                            color: priorityColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Title with RTL/bold support
                        Expanded(
                          child: NotificationText(
                            text: title.isEmpty ? 'Notification Title' : title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.grey[900],
                            ),
                            isRTL: isRTL,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Timestamp
                        Text(
                          'Just now',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Dismiss X
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white60 : Colors.grey[600]!)
                                .withOpacity(isDark ? 0.15 : 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: isDark ? Colors.white60 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Message preview with RTL/bold support
                    Padding(
                      padding: EdgeInsets.only(
                        left: isRTL ? 0 : 36,
                        right: isRTL ? 36 : 0,
                      ),
                      child: NotificationText(
                        text: message.isEmpty ? 'Your message preview...' : message,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey[600],
                          height: 1.3,
                        ),
                        isRTL: isRTL,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Footer row with tap hint and mark-read button
                    Padding(
                      padding: EdgeInsets.only(
                        left: isRTL ? 0 : 36,
                        right: isRTL ? 36 : 0,
                        top: 4,
                      ),
                      child: Row(
                        children: [
                          // Tap anywhere hint
                          Icon(
                            Icons.touch_app_outlined,
                            size: 12,
                            color: isDark ? Colors.white38 : Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tap for details',
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  isDark ? Colors.white38 : Colors.grey[400],
                            ),
                          ),
                          if (hasLink && actionButtonText != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '• ${actionButtonText!}',
                              style: TextStyle(
                                fontSize: 10,
                                color: priorityColor.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const Spacer(),
                          // Mark as Read icon button
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: priorityColor
                                  .withOpacity(isDark ? 0.15 : 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: priorityColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Broadcast history card
class _BroadcastHistoryCard extends ConsumerWidget {
  final AdminBroadcastModel broadcast;

  const _BroadcastHistoryCard({required this.broadcast});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 12),
            Flexible(child: Text('Delete Notification?')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete this notification for ALL users.',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"${broadcast.title}"',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(adminBroadcastsProvider.notifier)
          .deleteNotification(broadcast.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Notification deleted successfully'
                  : 'Failed to delete notification',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              // Expiration status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: broadcast.isExpired
                      ? Colors.grey.withOpacity(0.15)
                      : LiquidGlassColors.sunsetOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      broadcast.isExpired
                          ? Icons.timer_off_outlined
                          : Icons.timer_outlined,
                      size: 12,
                      color: broadcast.isExpired
                          ? Colors.grey
                          : LiquidGlassColors.sunsetOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      broadcast.timeRemainingFormatted,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: broadcast.isExpired
                            ? Colors.grey
                            : LiquidGlassColors.sunsetOrange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
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
              const SizedBox(width: 8),
              // Delete button
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: isDark ? Colors.white54 : Colors.grey[500],
                ),
                tooltip: 'Delete notification',
                onPressed: () => _confirmDelete(context, ref),
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
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _MetricChip(
                icon: Icons.people,
                value: '${broadcast.sentCount}',
                label: 'Sent',
                color: LiquidGlassColors.oceanCyan,
              ),
              _MetricChip(
                icon: Icons.visibility,
                value: '${broadcast.readCount}',
                label: 'Read',
                color: LiquidGlassColors.mintEmerald,
              ),
              _MetricChip(
                icon: Icons.close,
                value: '${broadcast.dismissedCount}',
                label: 'Dismissed',
                color: LiquidGlassColors.sunsetOrange,
              ),
              if (broadcast.hasDeepLink)
                _MetricChip(
                  icon: Icons.touch_app,
                  value: '${broadcast.clickCount}',
                  label: 'Clicks',
                  color: LiquidGlassColors.auroraViolet,
                ),
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

    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for selecting notification lifetime/auto-dismiss duration
class _LifetimeSelector extends StatelessWidget {
  final int hours;
  final ValueChanged<int> onChanged;

  const _LifetimeSelector({
    required this.hours,
    required this.onChanged,
  });

  static const presets = [
    (1, '1 hour'),
    (6, '6 hours'),
    (24, '1 day'),
    (48, '2 days'),
    (168, '1 week'),
    (720, '30 days'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCustom = !presets.any((p) => p.$1 == hours);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Auto-dismiss after',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...presets.map((preset) => ChoiceChip(
                  label: Text(preset.$2),
                  selected: hours == preset.$1,
                  onSelected: (_) => onChanged(preset.$1),
                )),
            ChoiceChip(
              label: Text(isCustom ? '${hours}h' : 'Custom'),
              selected: isCustom,
              onSelected: (_) => _showCustomDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Notification will be automatically removed after this time',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white38 : Colors.grey[500],
          ),
        ),
      ],
    );
  }

  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CustomLifetimeDialog(
        initialHours: hours,
        onConfirm: onChanged,
      ),
    );
  }
}

/// Dialog for entering custom lifetime value
class _CustomLifetimeDialog extends StatefulWidget {
  final int initialHours;
  final ValueChanged<int> onConfirm;

  const _CustomLifetimeDialog({
    required this.initialHours,
    required this.onConfirm,
  });

  @override
  State<_CustomLifetimeDialog> createState() => _CustomLifetimeDialogState();
}

class _CustomLifetimeDialogState extends State<_CustomLifetimeDialog> {
  late TextEditingController _controller;
  String _unit = 'hours';
  String? _error;

  @override
  void initState() {
    super.initState();
    // Convert initial hours to appropriate unit
    if (widget.initialHours >= 168 && widget.initialHours % 168 == 0) {
      _controller =
          TextEditingController(text: '${widget.initialHours ~/ 168}');
      _unit = 'weeks';
    } else if (widget.initialHours >= 24 && widget.initialHours % 24 == 0) {
      _controller = TextEditingController(text: '${widget.initialHours ~/ 24}');
      _unit = 'days';
    } else {
      _controller = TextEditingController(text: '${widget.initialHours}');
      _unit = 'hours';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? _calculateHours() {
    final value = int.tryParse(_controller.text);
    if (value == null || value <= 0) return null;

    switch (_unit) {
      case 'hours':
        return value;
      case 'days':
        return value * 24;
      case 'weeks':
        return value * 168;
      default:
        return value;
    }
  }

  void _validate() {
    final hours = _calculateHours();
    if (hours == null) {
      setState(() => _error = 'Enter a valid number');
    } else if (hours < 1) {
      setState(() => _error = 'Minimum is 1 hour');
    } else if (hours > 720) {
      setState(() => _error = 'Maximum is 30 days (720 hours)');
    } else {
      setState(() => _error = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom Lifetime'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Duration',
                    errorText: _error,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (_) => _validate(),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _unit,
                items: const [
                  DropdownMenuItem(value: 'hours', child: Text('Hours')),
                  DropdownMenuItem(value: 'days', child: Text('Days')),
                  DropdownMenuItem(value: 'weeks', child: Text('Weeks')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _unit = value);
                    _validate();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Range: 1 hour to 30 days',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _error == null
              ? () {
                  final hours = _calculateHours();
                  if (hours != null && hours >= 1 && hours <= 720) {
                    widget.onConfirm(hours);
                    Navigator.pop(context);
                  }
                }
              : null,
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

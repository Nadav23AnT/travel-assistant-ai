import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../../data/models/admin_models.dart';
import '../../providers/support_provider.dart';
import '../../widgets/admin/support_ticket_card.dart';
import 'admin_scaffold.dart';

/// Admin screen for managing support tickets
class AdminSupportScreen extends ConsumerStatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  ConsumerState<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends ConsumerState<AdminSupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AdminScaffold(
      currentItem: AdminNavItem.support,
      title: 'Support Tickets',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: () {
            ref.invalidate(allSupportSessionsProvider);
            ref.invalidate(unassignedSessionsProvider);
            ref.invalidate(myAssignedSessionsProvider);
          },
        ),
      ],
      child: Column(
        children: [
          // Tab bar
          Container(
            color: isDark ? AppTheme.darkSurface : AppTheme.surfaceColor,
            child: TabBar(
              controller: _tabController,
              tabs: [
                _buildTab('All', ref.watch(allSupportSessionsProvider)),
                _buildTab('Unassigned', ref.watch(unassignedSessionsProvider)),
                _buildTab('My Tickets', ref.watch(myAssignedSessionsProvider)),
              ],
            ),
          ),

          // Filter bar
          _buildFilterBar(context, ref),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllTicketsTab(context, ref),
                _buildUnassignedTab(context, ref),
                _buildMyTicketsTab(context, ref),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, AsyncValue<List<SupportSessionModel>> sessions) {
    final count = sessions.valueOrNull?.length ?? 0;

    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(supportSessionFiltersProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.darkDivider : AppTheme.dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          // Status filter
          PopupMenuButton<SupportStatus?>(
            child: Chip(
              label: Text(
                filters.status?.displayName ?? 'Status',
                style: TextStyle(
                  color: filters.status != null
                      ? AppTheme.primaryColor
                      : null,
                ),
              ),
              deleteIcon: filters.status != null
                  ? const Icon(Icons.close, size: 16)
                  : null,
              onDeleted: filters.status != null
                  ? () {
                      ref.read(supportSessionFiltersProvider.notifier).state =
                          filters.copyWith(clearStatus: true);
                    }
                  : null,
            ),
            onSelected: (status) {
              ref.read(supportSessionFiltersProvider.notifier).state =
                  filters.copyWith(status: status, clearStatus: status == null);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Statuses'),
              ),
              ...SupportStatus.values.map(
                (s) => PopupMenuItem(value: s, child: Text(s.displayName)),
              ),
            ],
          ),
          const SizedBox(width: 8),

          // Priority filter
          PopupMenuButton<SupportPriority?>(
            child: Chip(
              label: Text(
                filters.priority?.displayName ?? 'Priority',
                style: TextStyle(
                  color: filters.priority != null
                      ? AppTheme.primaryColor
                      : null,
                ),
              ),
              deleteIcon: filters.priority != null
                  ? const Icon(Icons.close, size: 16)
                  : null,
              onDeleted: filters.priority != null
                  ? () {
                      ref.read(supportSessionFiltersProvider.notifier).state =
                          filters.copyWith(clearPriority: true);
                    }
                  : null,
            ),
            onSelected: (priority) {
              ref.read(supportSessionFiltersProvider.notifier).state =
                  filters.copyWith(
                      priority: priority, clearPriority: priority == null);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Priorities'),
              ),
              ...SupportPriority.values.map(
                (p) => PopupMenuItem(value: p, child: Text(p.displayName)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllTicketsTab(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(allSupportSessionsProvider);

    return sessions.when(
      data: (list) {
        if (list.isEmpty) {
          return _buildEmptyState('No support tickets yet');
        }
        return _buildTicketList(context, list);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _buildErrorState(context, ref, e.toString()),
    );
  }

  Widget _buildUnassignedTab(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(unassignedSessionsProvider);

    return sessions.when(
      data: (list) {
        if (list.isEmpty) {
          return _buildEmptyState('No unassigned tickets');
        }
        return _buildTicketList(context, list);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _buildErrorState(context, ref, e.toString()),
    );
  }

  Widget _buildMyTicketsTab(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(myAssignedSessionsProvider);

    return sessions.when(
      data: (list) {
        if (list.isEmpty) {
          return _buildEmptyState('No tickets assigned to you');
        }
        return _buildTicketList(context, list);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _buildErrorState(context, ref, e.toString()),
    );
  }

  Widget _buildTicketList(
    BuildContext context,
    List<SupportSessionModel> sessions,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allSupportSessionsProvider);
        ref.invalidate(unassignedSessionsProvider);
        ref.invalidate(myAssignedSessionsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return SupportTicketCard(
            session: session,
            onTap: () => context.go('/admin/support/${session.id}'),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.support_agent,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
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
            onPressed: () {
              ref.invalidate(allSupportSessionsProvider);
              ref.invalidate(unassignedSessionsProvider);
              ref.invalidate(myAssignedSessionsProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

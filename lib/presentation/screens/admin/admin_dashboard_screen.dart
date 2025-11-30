import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../providers/admin_provider.dart';
import '../../providers/support_provider.dart';
import '../../widgets/admin/admin_charts.dart';
import 'admin_scaffold.dart';

/// Main admin dashboard screen with comprehensive system statistics
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  void _refreshAll(WidgetRef ref) {
    ref.invalidate(systemStatsProvider);
    ref.invalidate(userCountByPlanProvider);
    ref.invalidate(openTicketsCountProvider);
    ref.invalidate(userGrowthTrendProvider);
    ref.invalidate(tokenUsageTrendProvider);
    ref.invalidate(peakUsageHoursProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(systemStatsProvider);
    final userCounts = ref.watch(userCountByPlanProvider);
    final openTickets = ref.watch(openTicketsCountProvider);

    return AdminScaffold(
      currentItem: AdminNavItem.dashboard,
      title: 'Dashboard',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: () => _refreshAll(ref),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () async => _refreshAll(ref),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: stats.when(
            data: (data) => _buildDashboardContent(context, ref, data, userCounts, openTickets),
            loading: () => _buildLoadingState(),
            error: (e, _) => _buildErrorCard(context, e.toString()),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    WidgetRef ref,
    dynamic stats,
    AsyncValue<Map<String, int>> userCounts,
    AsyncValue<int> openTickets,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Real-time section
        _buildSectionHeader(context, 'Real-time', Icons.bolt, Colors.amber),
        const SizedBox(height: 8),
        _buildRealTimeSection(context, stats),
        const SizedBox(height: 20),

        // Overview section (compact cards)
        _buildSectionHeader(context, 'Overview', Icons.dashboard, AppTheme.primaryColor),
        const SizedBox(height: 8),
        _buildOverviewGrid(context, stats),
        const SizedBox(height: 20),

        // Usage Stats section
        _buildSectionHeader(context, 'Token Usage', Icons.token, Colors.purple),
        const SizedBox(height: 8),
        _buildUsageSection(context, stats),
        const SizedBox(height: 20),

        // Growth section
        _buildSectionHeader(context, 'Growth', Icons.trending_up, AppTheme.successColor),
        const SizedBox(height: 8),
        _buildGrowthSection(context, stats),
        const SizedBox(height: 20),

        // Engagement section
        _buildSectionHeader(context, 'Engagement', Icons.groups, Colors.teal),
        const SizedBox(height: 8),
        _buildEngagementSection(context, stats),
        const SizedBox(height: 20),

        // Charts section
        _buildChartsSection(context, ref),
        const SizedBox(height: 20),

        // Users section
        _buildSectionHeader(context, 'Users', Icons.people, AppTheme.primaryColor),
        const SizedBox(height: 8),
        userCounts.when(
          data: (data) => _buildUserBreakdown(context, ref, data),
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (e, _) => _buildErrorCard(context, e.toString()),
        ),
        const SizedBox(height: 20),

        // Quick actions
        _buildSectionHeader(context, 'Quick Actions', Icons.flash_on, AppTheme.warningColor),
        const SizedBox(height: 8),
        _buildQuickActions(context, ref, openTickets),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildRealTimeSection(BuildContext context, dynamic stats) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Live users indicator
            Expanded(
              child: _buildLiveIndicator(
                context,
                'Live Now',
                stats.liveUsers,
                Colors.green,
                isDark,
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: theme.dividerColor,
            ),
            // Active today
            Expanded(
              child: _buildLiveIndicator(
                context,
                'Active Today',
                stats.activeUsersToday,
                Colors.blue,
                isDark,
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: theme.dividerColor,
            ),
            // Open tickets
            Expanded(
              child: _buildLiveIndicator(
                context,
                'Open Tickets',
                stats.openSupportTickets,
                stats.openSupportTickets > 0 ? Colors.orange : Colors.grey,
                isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveIndicator(
    BuildContext context,
    String label,
    int value,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (label == 'Live Now')
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(128),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            Text(
              '$value',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewGrid(BuildContext context, dynamic stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final crossAxisCount = isWide ? 6 : 3;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.0,
          children: [
            _MiniStatCard(
              label: 'Users',
              value: '${stats.totalUsers}',
              icon: Icons.people,
              color: AppTheme.primaryColor,
            ),
            _MiniStatCard(
              label: 'Trips',
              value: '${stats.totalTrips}',
              icon: Icons.flight_takeoff,
              color: AppTheme.successColor,
            ),
            _MiniStatCard(
              label: 'Active',
              value: '${stats.activeTrips}',
              icon: Icons.explore,
              color: Colors.teal,
            ),
            _MiniStatCard(
              label: 'Expenses',
              value: '${stats.totalExpenses}',
              icon: Icons.receipt,
              color: AppTheme.warningColor,
            ),
            _MiniStatCard(
              label: 'Chats',
              value: '${stats.totalChatSessions}',
              icon: Icons.chat,
              color: Colors.purple,
            ),
            _MiniStatCard(
              label: 'Premium',
              value: '${stats.premiumUsers}',
              icon: Icons.star,
              color: Colors.amber,
            ),
          ],
        );
      },
    );
  }

  Widget _buildUsageSection(BuildContext context, dynamic stats) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Tokens Today',
                    value: _formatNumber(stats.totalTokensToday),
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Tokens This Week',
                    value: _formatNumber(stats.totalTokensWeek),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Avg/User Today',
                    value: _formatNumber(stats.avgTokensPerUser),
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Requests Today',
                    value: _formatNumber(stats.totalRequestsToday),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthSection(BuildContext context, dynamic stats) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'New Today',
                    value: '+${stats.usersToday}',
                    isDark: isDark,
                    valueColor: AppTheme.successColor,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'This Week',
                    value: '+${stats.usersThisWeek}',
                    isDark: isDark,
                    valueColor: AppTheme.successColor,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'This Month',
                    value: '+${stats.usersThisMonth}',
                    isDark: isDark,
                    valueColor: AppTheme.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Trips Today',
                    value: '${stats.tripsCreatedToday}',
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Trips This Week',
                    value: '${stats.tripsCreatedWeek}',
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Expenses Today',
                    value: '${stats.expensesLoggedToday}',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementSection(BuildContext context, dynamic stats) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Active Today',
                    value: '${stats.activeUsersToday}',
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Active This Week',
                    value: '${stats.activeUsersWeek}',
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Active This Month',
                    value: '${stats.activeUsersMonth}',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Messages Today',
                    value: '${stats.chatMessagesToday}',
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Avg Msgs/Session',
                    value: '${stats.avgMessagesPerSession}',
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Expense Amount',
                    value: '\$${stats.totalExpenseAmountToday.toStringAsFixed(0)}',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, WidgetRef ref) {
    final userGrowth = ref.watch(userGrowthTrendProvider);
    final tokenUsage = ref.watch(tokenUsageTrendProvider);
    final peakHours = ref.watch(peakUsageHoursProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Trends', Icons.show_chart, Colors.indigo),
        const SizedBox(height: 8),
        // User growth chart
        ChartCard(
          title: 'User Growth (14 days)',
          icon: Icons.trending_up,
          iconColor: AppTheme.primaryColor,
          isLoading: userGrowth.isLoading,
          error: userGrowth.hasError ? userGrowth.error.toString() : null,
          child: userGrowth.when(
            data: (data) => UserGrowthChart(data: data),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ),
        const SizedBox(height: 12),
        // Token usage chart
        ChartCard(
          title: 'Token Usage (14 days)',
          icon: Icons.token,
          iconColor: Colors.purple,
          isLoading: tokenUsage.isLoading,
          error: tokenUsage.hasError ? tokenUsage.error.toString() : null,
          child: tokenUsage.when(
            data: (data) => TokenUsageChart(data: data),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ),
        const SizedBox(height: 12),
        // Peak hours chart
        ChartCard(
          title: 'Activity by Hour (7 days)',
          icon: Icons.schedule,
          iconColor: Colors.orange,
          isLoading: peakHours.isLoading,
          error: peakHours.hasError ? peakHours.error.toString() : null,
          child: peakHours.when(
            data: (data) => PeakHoursChart(data: data),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ),
      ],
    );
  }

  Widget _buildUserBreakdown(
    BuildContext context,
    WidgetRef ref,
    Map<String, int> counts,
  ) {
    final free = counts['free'] ?? 0;
    final premium = counts['subscription'] ?? 0;
    final total = free + premium;
    final premiumPercent = total > 0 ? (premium / total * 100) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildUserTypeColumn(
                    context,
                    'Free',
                    free,
                    Icons.person_outline,
                    AppTheme.textSecondary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 50,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  child: _buildUserTypeColumn(
                    context,
                    'Premium',
                    premium,
                    Icons.star,
                    AppTheme.warningColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: premiumPercent / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.warningColor,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${premiumPercent.toStringAsFixed(1)}% conversion rate',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeColumn(
    BuildContext context,
    String label,
    int count,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<int> openTickets,
  ) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.people,
            label: 'Manage Users',
            onTap: () => context.go('/admin/users'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.support_agent,
            label: 'Support',
            badge: openTickets.valueOrNull ?? 0,
            onTap: () => context.go('/admin/support'),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Card(
      color: AppTheme.errorColor.withAlpha(26),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.errorColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Failed to load: $error',
                style: const TextStyle(color: AppTheme.errorColor),
              ),
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

/// Compact mini stat card for overview grid
class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppTheme.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat item for section cards
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Quick action card
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int badge;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    this.badge = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Badge(
                isLabelVisible: badge > 0,
                label: Text('$badge'),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

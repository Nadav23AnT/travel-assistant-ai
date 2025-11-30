import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../providers/admin_provider.dart';
import '../../providers/support_provider.dart';
import '../../widgets/admin/admin_stat_card.dart';
import 'admin_scaffold.dart';

/// Main admin dashboard screen with system statistics
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

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
          onPressed: () {
            ref.invalidate(systemStatsProvider);
            ref.invalidate(userCountByPlanProvider);
            ref.invalidate(openTicketsCountProvider);
          },
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(systemStatsProvider);
          ref.invalidate(userCountByPlanProvider);
          ref.invalidate(openTicketsCountProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _buildWelcomeSection(context),
              const SizedBox(height: 24),

              // Main stats grid
              Text(
                'Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              stats.when(
                data: (data) => _buildStatsGrid(context, ref, data),
                loading: () => _buildLoadingGrid(),
                error: (e, _) => _buildErrorCard(context, e.toString()),
              ),
              const SizedBox(height: 24),

              // User breakdown
              Text(
                'Users',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              userCounts.when(
                data: (data) => _buildUserBreakdown(context, ref, data),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (e, _) => _buildErrorCard(context, e.toString()),
              ),
              const SizedBox(height: 24),

              // Quick actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              _buildQuickActions(context, ref, openTickets),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                color: AppTheme.primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Admin Dashboard',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Monitor your app, manage users, and handle support requests.',
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, WidgetRef ref, dynamic stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
        // Lower ratio = taller cards to prevent overflow
        final childAspectRatio = constraints.maxWidth > 800 ? 1.1 : 1.2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
          children: [
            AdminStatCard(
              title: 'Total Users',
              value: '${stats.totalUsers}',
              icon: Icons.people,
              color: AppTheme.primaryColor,
              subtitle: '${stats.usersToday} today',
              onTap: () => context.go('/admin/users'),
            ),
            AdminStatCard(
              title: 'Total Trips',
              value: '${stats.totalTrips}',
              icon: Icons.flight_takeoff,
              color: AppTheme.successColor,
              subtitle: '${stats.activeTrips} active',
            ),
            AdminStatCard(
              title: 'Total Expenses',
              value: '${stats.totalExpenses}',
              icon: Icons.receipt_long,
              color: AppTheme.warningColor,
            ),
            AdminStatCard(
              title: 'Chat Sessions',
              value: '${stats.totalChatSessions}',
              icon: Icons.chat,
              color: Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: List.generate(
        4,
        (_) => const AdminStatCard(
          title: 'Loading...',
          value: '-',
          icon: Icons.hourglass_empty,
          isLoading: true,
        ),
      ),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildUserTypeColumn(
                    context,
                    'Free Users',
                    free,
                    Icons.person_outline,
                    AppTheme.textSecondary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  child: _buildUserTypeColumn(
                    context,
                    'Premium Users',
                    premium,
                    Icons.star,
                    AppTheme.warningColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: premiumPercent / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.warningColor,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${premiumPercent.toStringAsFixed(1)}% premium conversion rate',
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
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.support_agent,
            label: 'Support Tickets',
            badge: openTickets.valueOrNull ?? 0,
            onTap: () => context.go('/admin/support'),
          ),
        ),
      ],
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
}

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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Badge(
                isLabelVisible: badge > 0,
                label: Text('$badge'),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
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

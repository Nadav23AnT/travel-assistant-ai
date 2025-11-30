import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../data/models/admin_models.dart';
import '../../providers/admin_provider.dart';

/// Screen for viewing and managing a single user's details
class AdminUserDetailScreen extends ConsumerWidget {
  final String userId;

  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(adminUserDetailProvider(userId));
    final operations = ref.watch(adminOperationsProvider);

    // Show snackbar on success/error
    ref.listen<AdminOperationsState>(adminOperationsProvider, (prev, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppTheme.successColor,
          ),
        );
        ref.read(adminOperationsProvider.notifier).clearMessages();
      }
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        ref.read(adminOperationsProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/users'),
        ),
        title: const Text('User Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminUserDetailProvider(userId)),
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found'));
          }
          return _buildUserDetails(context, ref, user, operations);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
              const SizedBox(height: 16),
              Text('Error: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(adminUserDetailProvider(userId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetails(
    BuildContext context,
    WidgetRef ref,
    AdminUserModel user,
    AdminOperationsState operations,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header card
          _buildUserHeader(context, user),
          const SizedBox(height: 16),

          // Stats section
          Text('Statistics', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          _buildStatsGrid(context, user),
          const SizedBox(height: 24),

          // Token usage
          Text('Token Usage', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          _buildTokenUsage(context, ref, user, operations),
          const SizedBox(height: 24),

          // Plan management
          Text('Plan Management', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          _buildPlanManagement(context, ref, user, operations),
          const SizedBox(height: 24),

          // Admin actions
          Text('Admin Actions', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          _buildAdminActions(context, ref, user, operations),
          const SizedBox(height: 24),

          // Danger zone
          Text(
            'Danger Zone',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildDangerZone(context, ref, user, operations),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, AdminUserModel user) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.primaryColor.withAlpha(26),
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? Text(
                      _getInitials(user.displayName),
                      style: const TextStyle(
                        fontSize: 24,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.displayName,
                          style: theme.textTheme.headlineSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user.isAdmin) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Joined ${dateFormat.format(user.createdAt)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, AdminUserModel user) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _StatTile(
          icon: Icons.flight_takeoff,
          label: 'Trips',
          value: '${user.tripsCount}',
          color: AppTheme.successColor,
        ),
        _StatTile(
          icon: Icons.receipt_long,
          label: 'Expenses',
          value: '${user.expensesCount}',
          color: AppTheme.warningColor,
        ),
        _StatTile(
          icon: Icons.chat,
          label: 'Chat Sessions',
          value: '${user.chatSessionsCount}',
          color: Colors.purple,
        ),
        _StatTile(
          icon: Icons.attach_money,
          label: 'Total Spent',
          value: '\$${user.totalExpenses.toStringAsFixed(0)}',
          color: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildTokenUsage(
    BuildContext context,
    WidgetRef ref,
    AdminUserModel user,
    AdminOperationsState operations,
  ) {
    final percent = user.tokenUsagePercent;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${user.todayTokensUsed} / ${user.dailyTokenLimit}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${percent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: percent > 80 ? AppTheme.errorColor : AppTheme.successColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percent > 80 ? AppTheme.errorColor : AppTheme.primaryColor,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${user.tokensRemaining} tokens remaining today',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: operations.isLoading
                      ? null
                      : () => _confirmResetTokens(context, ref, user),
                  icon: operations.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 18),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanManagement(
    BuildContext context,
    WidgetRef ref,
    AdminUserModel user,
    AdminOperationsState operations,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  user.isPremium ? Icons.star : Icons.person_outline,
                  color: user.isPremium ? AppTheme.warningColor : Colors.grey,
                ),
                const SizedBox(width: 12),
                Text(
                  'Current Plan: ${user.isPremium ? 'Premium' : 'Free'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            if (user.subscriptionExpiresAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Expires: ${DateFormat('MMM d, yyyy').format(user.subscriptionExpiresAt!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: operations.isLoading || !user.isPremium
                        ? null
                        : () => _confirmPlanChange(context, ref, user, 'free'),
                    child: const Text('Downgrade to Free'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: operations.isLoading || user.isPremium
                        ? null
                        : () => _confirmPlanChange(context, ref, user, 'subscription'),
                    child: const Text('Upgrade to Premium'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActions(
    BuildContext context,
    WidgetRef ref,
    AdminUserModel user,
    AdminOperationsState operations,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                user.isAdmin ? Icons.remove_moderator : Icons.add_moderator,
                color: user.isAdmin ? AppTheme.errorColor : AppTheme.successColor,
              ),
              title: Text(user.isAdmin ? 'Remove Admin Access' : 'Grant Admin Access'),
              subtitle: Text(
                user.isAdmin
                    ? 'Remove administrative privileges from this user'
                    : 'Give this user administrative privileges',
              ),
              trailing: operations.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: operations.isLoading
                  ? null
                  : () => _confirmAdminToggle(context, ref, user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone(
    BuildContext context,
    WidgetRef ref,
    AdminUserModel user,
    AdminOperationsState operations,
  ) {
    return Card(
      color: AppTheme.errorColor.withAlpha(13),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'These actions are destructive and cannot be undone.',
              style: TextStyle(color: AppTheme.errorColor),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DangerButton(
                  label: 'Delete Trips',
                  onPressed: operations.isLoading
                      ? null
                      : () => _confirmDeleteData(
                            context,
                            ref,
                            user,
                            UserDataType.trips,
                          ),
                ),
                _DangerButton(
                  label: 'Delete Expenses',
                  onPressed: operations.isLoading
                      ? null
                      : () => _confirmDeleteData(
                            context,
                            ref,
                            user,
                            UserDataType.expenses,
                          ),
                ),
                _DangerButton(
                  label: 'Delete Chat History',
                  onPressed: operations.isLoading
                      ? null
                      : () => _confirmDeleteData(
                            context,
                            ref,
                            user,
                            UserDataType.chatHistory,
                          ),
                ),
                _DangerButton(
                  label: 'Delete All Data',
                  onPressed: operations.isLoading
                      ? null
                      : () => _confirmDeleteData(
                            context,
                            ref,
                            user,
                            UserDataType.all,
                          ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmResetTokens(
    BuildContext context,
    WidgetRef ref,
    AdminUserModel user,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Token Usage'),
        content: Text(
          'Are you sure you want to reset token usage for ${user.displayName}? '
          'This will allow them to use AI features again today.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminOperationsProvider.notifier).resetUserTokens(user.id);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _confirmPlanChange(
    BuildContext context,
    WidgetRef ref,
    AdminUserModel user,
    String newPlan,
  ) {
    final isUpgrade = newPlan == 'subscription';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isUpgrade ? 'Upgrade to Premium' : 'Downgrade to Free'),
        content: Text(
          'Are you sure you want to ${isUpgrade ? 'upgrade' : 'downgrade'} '
          '${user.displayName} to the ${isUpgrade ? 'Premium' : 'Free'} plan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminOperationsProvider.notifier).updateUserPlan(user.id, newPlan);
            },
            child: Text(isUpgrade ? 'Upgrade' : 'Downgrade'),
          ),
        ],
      ),
    );
  }

  void _confirmAdminToggle(
    BuildContext context,
    WidgetRef ref,
    AdminUserModel user,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.isAdmin ? 'Remove Admin Access' : 'Grant Admin Access'),
        content: Text(
          user.isAdmin
              ? 'Are you sure you want to remove admin access from ${user.displayName}?'
              : 'Are you sure you want to grant admin access to ${user.displayName}? '
                  'They will have full access to all admin features.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isAdmin ? AppTheme.errorColor : AppTheme.successColor,
            ),
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminOperationsProvider.notifier).setAdminStatus(
                    user.id,
                    !user.isAdmin,
                  );
            },
            child: Text(user.isAdmin ? 'Remove Access' : 'Grant Access'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteData(
    BuildContext context,
    WidgetRef ref,
    AdminUserModel user,
    UserDataType dataType,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${dataType.displayName}'),
        content: Text(
          'Are you sure you want to delete ${dataType.displayName.toLowerCase()} '
          'for ${user.displayName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            onPressed: () {
              Navigator.pop(context);
              ref.read(adminOperationsProvider.notifier).deleteUserData(
                    user.id,
                    dataType,
                  );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '?';
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _DangerButton({
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.errorColor,
        side: const BorderSide(color: AppTheme.errorColor),
      ),
      child: Text(label),
    );
  }
}

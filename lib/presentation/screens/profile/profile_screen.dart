import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../utils/country_currency_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/trips_provider.dart';

/// Provider for profile statistics
final profileStatsProvider = FutureProvider<ProfileStats>((ref) async {
  final trips = await ref.watch(userTripsProvider.future);
  final expenses = await ref.watch(userExpensesProvider.future);

  // Calculate unique countries visited
  final visitedCountries = <String>{};
  for (final trip in trips) {
    final country = CountryCurrencyHelper.extractCountryFromDestination(trip.destination);
    if (country.isNotEmpty) {
      visitedCountries.add(country);
    }
  }

  // Calculate total spent across all expenses
  final totalSpent = expenses.fold<double>(0, (sum, e) => sum + e.amount);

  return ProfileStats(
    tripCount: trips.length,
    expenseCount: expenses.length,
    countriesCount: visitedCountries.length,
    totalSpent: totalSpent,
  );
});

class ProfileStats {
  final int tripCount;
  final int expenseCount;
  final int countriesCount;
  final double totalSpent;

  const ProfileStats({
    required this.tripCount,
    required this.expenseCount,
    required this.countriesCount,
    required this.totalSpent,
  });
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userEmail = user?.email ?? 'Not signed in';
    final userName = user?.userMetadata?['full_name'] as String? ??
                     user?.email?.split('@').first ??
                     'Traveler';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Navigate to edit profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile header
            _buildProfileHeader(context, userName, userEmail),
            const SizedBox(height: 24),

            // Stats
            _buildStats(context, ref),
            const SizedBox(height: 24),

            // Subscription card
            _buildSubscriptionCard(context),
            const SizedBox(height: 16),

            // Menu items
            _buildMenuItem(
              context,
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => context.push(AppRoutes.settings),
            ),
            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                // TODO: Navigate to help
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {
                // TODO: Show privacy policy
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () {
                // TODO: Show terms
              },
            ),
            const SizedBox(height: 24),

            // Sign out
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () {
                  _showSignOutDialog(context, ref);
                },
                icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.errorColor),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // App version
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String userName, String userEmail) {
    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: AppTheme.primaryLight,
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : 'T',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          userEmail,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildStats(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(profileStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: statsAsync.when(
            loading: () => const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Trips',
                    value: '-',
                    icon: Icons.luggage_outlined,
                  ),
                ),
                Container(width: 1, height: 40, color: AppTheme.textHint),
                Expanded(
                  child: _StatItem(
                    label: 'Expenses',
                    value: '-',
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
                Container(width: 1, height: 40, color: AppTheme.textHint),
                Expanded(
                  child: _StatItem(
                    label: 'Countries',
                    value: '-',
                    icon: Icons.public_outlined,
                  ),
                ),
              ],
            ),
            data: (stats) => Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Trips',
                    value: '${stats.tripCount}',
                    icon: Icons.luggage_outlined,
                  ),
                ),
                Container(width: 1, height: 40, color: AppTheme.textHint),
                Expanded(
                  child: _StatItem(
                    label: 'Expenses',
                    value: '${stats.expenseCount}',
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
                Container(width: 1, height: 40, color: AppTheme.textHint),
                Expanded(
                  child: _StatItem(
                    label: 'Countries',
                    value: '${stats.countriesCount}',
                    icon: Icons.public_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: AppTheme.primaryLight.withAlpha(77),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Free Plan',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Upgrade to unlock unlimited trips and AI features',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to subscription screen
                },
                child: const Text('Upgrade'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(title),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                // Actually sign out using the auth notifier
                await ref.read(authNotifierProvider.notifier).signOut();

                if (context.mounted) {
                  Navigator.of(context).pop(); // Close loading
                  context.go(AppRoutes.login);
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to sign out: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              _buildWelcomeHeader(context),
              const SizedBox(height: 24),

              // Active trip card (placeholder)
              _buildActiveTripCard(context),
              const SizedBox(height: 24),

              // Quick actions
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // Today's itinerary
              _buildTodayItinerary(context),
              const SizedBox(height: 24),

              // Recent expenses
              _buildRecentExpenses(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning,',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            Text(
              'Traveler!', // TODO: Replace with actual user name
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.primaryLight,
          child: const Icon(
            Icons.person,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTripCard(BuildContext context) {
    // Placeholder for no active trip
    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.createTrip),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.add_location_alt_outlined,
                size: 48,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No Active Trip',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Start planning your next adventure!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.createTrip),
                icon: const Icon(Icons.add),
                label: const Text('Create New Trip'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add,
                label: 'New Trip',
                color: AppTheme.primaryColor,
                onTap: () => context.push(AppRoutes.createTrip),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.receipt_long,
                label: 'Add Expense',
                color: AppTheme.accentColor,
                onTap: () => context.push(AppRoutes.addExpense),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.chat_bubble,
                label: 'AI Chat',
                color: AppTheme.successColor,
                onTap: () => context.go(AppRoutes.chat),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayItinerary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Itinerary",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.trips),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 32,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No activities planned for today',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentExpenses(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Expenses',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.expenses),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_outlined,
                    size: 32,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No expenses recorded yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

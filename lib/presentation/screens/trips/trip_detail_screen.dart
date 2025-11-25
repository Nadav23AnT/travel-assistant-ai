import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';

class TripDetailScreen extends StatelessWidget {
  final String tripId;

  const TripDetailScreen({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Trip Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // TODO: Show trip options menu
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Itinerary'),
              Tab(text: 'Expenses'),
              Tab(text: 'Members'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(context),
            _buildItineraryTab(context),
            _buildExpensesTab(context),
            _buildMembersTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.image,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Trip ID: $tripId',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading trip details...',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryTab(BuildContext context) {
    return const Center(
      child: Text('Itinerary Tab - Coming Soon'),
    );
  }

  Widget _buildExpensesTab(BuildContext context) {
    return const Center(
      child: Text('Expenses Tab - Coming Soon'),
    );
  }

  Widget _buildMembersTab(BuildContext context) {
    return const Center(
      child: Text('Members Tab - Coming Soon'),
    );
  }
}

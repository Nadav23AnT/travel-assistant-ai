import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/admin/admin_user_list_tile.dart';
import 'admin_scaffold.dart';

/// Admin screen for managing users
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchController = TextEditingController();
  String? _selectedPlanFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(adminUsersProvider);
    final filters = ref.watch(userFiltersProvider);

    return AdminScaffold(
      currentItem: AdminNavItem.users,
      title: 'User Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: () => ref.invalidate(adminUsersProvider),
        ),
      ],
      child: Column(
        children: [
          // Search and filters
          _buildSearchBar(context, ref),

          // Filter chips
          if (_selectedPlanFilter != null || filters.searchQuery != null)
            _buildActiveFilters(context, ref, filters),

          // User list
          Expanded(
            child: users.when(
              data: (userList) {
                if (userList.isEmpty) {
                  return _buildEmptyState(context);
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(adminUsersProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      final user = userList[index];
                      return AdminUserListTile(
                        user: user,
                        onTap: () => context.go('/admin/users/${user.id}'),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildErrorState(context, e.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
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
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(userFiltersProvider.notifier).state =
                              ref.read(userFiltersProvider).copyWith(
                                    searchQuery: null,
                                  );
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (value) {
                ref.read(userFiltersProvider.notifier).state =
                    ref.read(userFiltersProvider).copyWith(
                          searchQuery: value.isEmpty ? null : value,
                        );
              },
            ),
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            icon: Badge(
              isLabelVisible: _selectedPlanFilter != null,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Filter by plan',
            onSelected: (value) {
              setState(() {
                _selectedPlanFilter = value == 'all' ? null : value;
              });
              ref.read(userFiltersProvider.notifier).state =
                  ref.read(userFiltersProvider).copyWith(
                        planFilter: value == 'all' ? null : value,
                      );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Plans'),
              ),
              const PopupMenuItem(
                value: 'free',
                child: Text('Free Users'),
              ),
              const PopupMenuItem(
                value: 'subscription',
                child: Text('Premium Users'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(
    BuildContext context,
    WidgetRef ref,
    UserFilters filters,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (filters.searchQuery != null)
            Chip(
              label: Text('Search: ${filters.searchQuery}'),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                _searchController.clear();
                ref.read(userFiltersProvider.notifier).state =
                    filters.copyWith(searchQuery: null);
              },
            ),
          if (_selectedPlanFilter != null)
            Chip(
              label: Text(
                _selectedPlanFilter == 'subscription' ? 'Premium' : 'Free',
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () {
                setState(() => _selectedPlanFilter = null);
                ref.read(userFiltersProvider.notifier).state =
                    filters.copyWith(planFilter: null);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
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
            'Failed to load users',
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
            onPressed: () => ref.invalidate(adminUsersProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme.dart';
import '../../providers/support_provider.dart';

/// Navigation items for admin sidebar
enum AdminNavItem {
  dashboard('Dashboard', Icons.dashboard_outlined, Icons.dashboard, '/admin'),
  users('Users', Icons.people_outline, Icons.people, '/admin/users'),
  support('Support', Icons.support_agent_outlined, Icons.support_agent, '/admin/support');

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;

  const AdminNavItem(this.label, this.icon, this.selectedIcon, this.path);
}

/// Scaffold wrapper for admin screens with sidebar navigation
class AdminScaffold extends ConsumerWidget {
  final Widget child;
  final AdminNavItem currentItem;
  final String? title;
  final List<Widget>? actions;

  const AdminScaffold({
    super.key,
    required this.child,
    required this.currentItem,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWideScreen = MediaQuery.of(context).size.width >= 900;
    final openTickets = ref.watch(openTicketsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? currentItem.label),
        leading: isWideScreen
            ? null
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
        actions: [
          ...?actions,
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Exit Admin',
            onPressed: () => context.go('/home'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: isWideScreen ? null : _buildDrawer(context, ref, openTickets),
      body: Row(
        children: [
          if (isWideScreen)
            _AdminSidebar(
              currentItem: currentItem,
              openTicketsCount: openTickets.valueOrNull ?? 0,
            ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref, AsyncValue<int> openTickets) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(context),
            const Divider(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: AdminNavItem.values.map((item) {
                  final isSelected = item == currentItem;
                  final badgeCount = item == AdminNavItem.support
                      ? (openTickets.valueOrNull ?? 0)
                      : 0;

                  return ListTile(
                    leading: Badge(
                      isLabelVisible: badgeCount > 0,
                      label: Text('$badgeCount'),
                      child: Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected ? AppTheme.primaryColor : null,
                      ),
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppTheme.primaryColor : null,
                      ),
                    ),
                    selected: isSelected,
                    onTap: () {
                      Navigator.pop(context);
                      if (!isSelected) {
                        context.go(item.path);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text('Back to App'),
              onTap: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: AppTheme.primaryColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Manage your app',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sidebar navigation for wide screens
class _AdminSidebar extends StatelessWidget {
  final AdminNavItem currentItem;
  final int openTicketsCount;

  const _AdminSidebar({
    required this.currentItem,
    required this.openTicketsCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.surfaceColor,
        border: Border(
          right: BorderSide(
            color: isDark ? AppTheme.darkDivider : AppTheme.dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: AdminNavItem.values.map((item) {
                final isSelected = item == currentItem;
                final badgeCount = item == AdminNavItem.support
                    ? openTicketsCount
                    : 0;

                return _SidebarItem(
                  item: item,
                  isSelected: isSelected,
                  badgeCount: badgeCount,
                  onTap: () {
                    if (!isSelected) {
                      context.go(item.path);
                    }
                  },
                );
              }).toList(),
            ),
          ),

          // Footer
          const Divider(height: 1),
          _SidebarItem(
            icon: Icons.arrow_back,
            label: 'Back to App',
            onTap: () => context.go('/home'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Individual sidebar navigation item
class _SidebarItem extends StatelessWidget {
  final AdminNavItem? item;
  final IconData? icon;
  final String? label;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  const _SidebarItem({
    this.item,
    this.icon,
    this.label,
    this.isSelected = false,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final displayIcon = icon ?? (isSelected ? item!.selectedIcon : item!.icon);
    final displayLabel = label ?? item!.label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected
            ? AppTheme.primaryColor.withAlpha(26)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Badge(
                  isLabelVisible: badgeCount > 0,
                  label: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: const TextStyle(fontSize: 10),
                  ),
                  child: Icon(
                    displayIcon,
                    size: 22,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : (isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

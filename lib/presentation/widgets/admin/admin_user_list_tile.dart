import 'package:flutter/material.dart';

import '../../../config/theme.dart';
import '../../../data/models/admin_models.dart';

/// List tile for displaying a user in the admin user list
class AdminUserListTile extends StatelessWidget {
  final AdminUserModel user;
  final VoidCallback? onTap;

  const AdminUserListTile({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor.withAlpha(26),
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? Text(
                        _getInitials(user.displayName),
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.isAdmin) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withAlpha(26),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ADMIN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.errorColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Plan badge and stats
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildPlanBadge(user.planType),
                  const SizedBox(height: 4),
                  Text(
                    '${user.tripsCount} trips · ${user.expensesCount} expenses',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
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

  Widget _buildPlanBadge(String planType) {
    final isPremium = planType == 'subscription';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPremium
            ? AppTheme.warningColor.withAlpha(26)
            : Colors.grey.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPremium)
            const Icon(
              Icons.star,
              size: 12,
              color: AppTheme.warningColor,
            ),
          if (isPremium) const SizedBox(width: 4),
          Text(
            isPremium ? 'Premium' : 'Free',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isPremium ? AppTheme.warningColor : Colors.grey,
            ),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../data/models/admin_models.dart';

/// Card displaying a support ticket in the admin list
class SupportTicketCard extends StatelessWidget {
  final SupportSessionModel session;
  final VoidCallback? onTap;

  const SupportTicketCard({
    super.key,
    required this.session,
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      session.subject,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SupportStatusBadge(status: session.status),
                ],
              ),
              const SizedBox(height: 8),

              // User info row
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppTheme.primaryColor.withAlpha(26),
                    backgroundImage: session.userAvatarUrl != null
                        ? NetworkImage(session.userAvatarUrl!)
                        : null,
                    child: session.userAvatarUrl == null
                        ? Text(
                            _getInitials(session.userDisplayName),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      session.userDisplayName,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SupportPriorityBadge(priority: session.priority),
                ],
              ),
              const SizedBox(height: 12),

              // Footer row
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(session.lastMessageAt ?? session.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (session.isAssigned) ...[
                    Icon(
                      Icons.person,
                      size: 14,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      session.adminDisplayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  if (session.unreadAdminCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${session.unreadAdminCount}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}

/// Badge displaying support status
class SupportStatusBadge extends StatelessWidget {
  final SupportStatus status;

  const SupportStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bgColor) = _getColors();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  (Color, Color) _getColors() {
    switch (status) {
      case SupportStatus.open:
        return (AppTheme.warningColor, AppTheme.warningColor.withAlpha(26));
      case SupportStatus.inProgress:
        return (AppTheme.primaryColor, AppTheme.primaryColor.withAlpha(26));
      case SupportStatus.resolved:
        return (AppTheme.successColor, AppTheme.successColor.withAlpha(26));
      case SupportStatus.closed:
        return (Colors.grey, Colors.grey.withAlpha(26));
    }
  }
}

/// Badge displaying support priority
class SupportPriorityBadge extends StatelessWidget {
  final SupportPriority priority;

  const SupportPriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    if (priority == SupportPriority.normal) {
      return const SizedBox.shrink();
    }

    final (color, icon) = _getColorAndIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            priority.displayName,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData) _getColorAndIcon() {
    switch (priority) {
      case SupportPriority.low:
        return (Colors.grey, Icons.arrow_downward);
      case SupportPriority.normal:
        return (Colors.grey, Icons.remove);
      case SupportPriority.high:
        return (AppTheme.warningColor, Icons.arrow_upward);
      case SupportPriority.urgent:
        return (AppTheme.errorColor, Icons.priority_high);
    }
  }
}

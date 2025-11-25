import 'package:flutter/material.dart';

import '../../../config/theme.dart';

enum StatType {
  totalSpent,
  dailyAverage,
  estimatedTotal,
}

class SummaryStatCard extends StatelessWidget {
  final StatType type;
  final String value;
  final String? subtitle;
  final bool isLoading;

  const SummaryStatCard({
    super.key,
    required this.type,
    required this.value,
    this.subtitle,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getIconColor().withAlpha(51),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getIconColor().withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIcon(),
                  size: 18,
                  color: _getIconColor(),
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            Container(
              height: 24,
              width: 80,
              decoration: BoxDecoration(
                color: AppTheme.textHint.withAlpha(51),
                borderRadius: BorderRadius.circular(4),
              ),
            )
          else
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 4),
          Text(
            _getLabel(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textHint,
                    fontSize: 10,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  String _getLabel() {
    switch (type) {
      case StatType.totalSpent:
        return 'Total Spent';
      case StatType.dailyAverage:
        return 'Daily Average';
      case StatType.estimatedTotal:
        return 'Est. Trip Total';
    }
  }

  IconData _getIcon() {
    switch (type) {
      case StatType.totalSpent:
        return Icons.account_balance_wallet;
      case StatType.dailyAverage:
        return Icons.calendar_today;
      case StatType.estimatedTotal:
        return Icons.trending_up;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case StatType.totalSpent:
        return AppTheme.primaryColor;
      case StatType.dailyAverage:
        return AppTheme.accentColor;
      case StatType.estimatedTotal:
        return AppTheme.successColor;
    }
  }

  Color _getBackgroundColor() {
    return Colors.white;
  }
}

import 'package:flutter/material.dart';

import '../../../core/design/design_system.dart';
import '../../../l10n/app_localizations.dart';

/// A budget progress bar widget that shows spent vs budget with color-coded status
class BudgetProgressBar extends StatelessWidget {
  final double spent;
  final double budget;
  final String spentFormatted;
  final String budgetFormatted;
  final bool isDark;
  final AppLocalizations l10n;

  const BudgetProgressBar({
    super.key,
    required this.spent,
    required this.budget,
    required this.spentFormatted,
    required this.budgetFormatted,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final hasBudget = budget > 0;
    final progress = hasBudget ? (spent / budget).clamp(0.0, 1.5) : 0.0;
    final isOverBudget = progress > 1.0;
    final isWarning = progress > 0.8 && progress <= 1.0;

    // Determine color based on budget status
    final progressColor = isOverBudget
        ? LiquidGlassColors.sunsetRose
        : isWarning
            ? LiquidGlassColors.sunsetOrange
            : LiquidGlassColors.mintEmerald;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: Spent and Budget values
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Spent column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.spent,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  spentFormatted,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            // Budget column (only if budget is set)
            if (hasBudget)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.budget,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    budgetFormatted,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Progress bar
        if (hasBudget) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                // Background track
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withAlpha(15)
                        : Colors.black.withAlpha(10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                // Progress fill with gradient
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          progressColor,
                          progressColor.withAlpha(200),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: isDark
                          ? LiquidGlassColors.neonGlow(
                              progressColor,
                              intensity: 0.3,
                              blur: 8,
                            )
                          : null,
                    ),
                  ),
                ),
                // Over-budget overflow indicator
                if (isOverBudget)
                  Positioned(
                    right: 0,
                    child: Container(
                      width: 4,
                      height: 12,
                      decoration: BoxDecoration(
                        color: LiquidGlassColors.sunsetRose,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Status text
          Center(
            child: Text(
              _getStatusText(progress, isOverBudget),
              style: TextStyle(
                fontSize: 11,
                color: progressColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ] else ...[
          // No budget set message
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withAlpha(10)
                  : Colors.black.withAlpha(5),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              l10n.noBudgetSetTrip,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getStatusText(double progress, bool isOverBudget) {
    if (isOverBudget) {
      final overPercent = ((progress - 1) * 100).toInt();
      return l10n.percentOverBudget(overPercent);
    } else {
      final remainingPercent = ((1 - progress) * 100).toInt();
      return l10n.percentRemaining(remainingPercent);
    }
  }
}

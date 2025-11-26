import 'package:flutter/material.dart';

import '../../../config/theme.dart';
import '../../../services/budget_estimation_service.dart';
import '../../../utils/country_currency_helper.dart';

/// A card widget that displays smart budget suggestions based on destination and trip dates.
/// Shows an inactive state when required fields are not filled, and an active state
/// with estimated budget when destination and dates are provided.
class SmartBudgetSuggestionsCard extends StatelessWidget {
  /// The destination for the trip
  final String destination;

  /// Number of trip days
  final int tripDays;

  /// The currency to display the budget in
  final String currency;

  /// Callback when user wants to apply the suggested budget
  final VoidCallback? onApplyBudget;

  const SmartBudgetSuggestionsCard({
    super.key,
    required this.destination,
    required this.tripDays,
    required this.currency,
    this.onApplyBudget,
  });

  /// Whether the card should be in active state
  bool get _isActive => destination.isNotEmpty && tripDays > 0;

  @override
  Widget build(BuildContext context) {
    final estimate = _isActive
        ? BudgetEstimationService.getEstimate(
            destination: destination,
            tripDays: tripDays,
            currency: currency,
          )
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isActive ? AppTheme.primaryLight.withAlpha(50) : AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isActive ? AppTheme.primaryColor.withAlpha(100) : AppTheme.dividerColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isActive
                      ? AppTheme.primaryColor.withAlpha(30)
                      : AppTheme.textHint.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: _isActive ? AppTheme.primaryColor : AppTheme.textHint,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Smart Budget Suggestions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _isActive ? AppTheme.textPrimary : AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content based on state
          if (!_isActive) ...[
            // Inactive state - show instruction
            Text(
              'After choosing a destination and trip dates, the app will automatically suggest an average traveler budget for this trip.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ] else if (estimate != null) ...[
            // Active state - show estimate
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated daily budget:',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${CountryCurrencyHelper.getSymbolForCurrency(currency)}${estimate.formattedDailyBudget}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              currency,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onApplyBudget != null)
                    TextButton.icon(
                      onPressed: onApplyBudget,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Apply'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Based on average travelers in ${estimate.destination}.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (tripDays > 1) ...[
              const SizedBox(height: 4),
              Text(
                'Total for $tripDays days: ${CountryCurrencyHelper.getSymbolForCurrency(currency)}${estimate.formattedTotalBudget} $currency',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

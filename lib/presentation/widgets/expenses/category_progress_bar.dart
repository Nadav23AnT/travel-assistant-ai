import 'package:flutter/material.dart';

import '../../../data/models/expense_stats.dart';

/// A compact horizontal category progress bar showing icon, name, amount, and progress
class CategoryProgressBar extends StatelessWidget {
  final CategoryTotal category;
  final String displayCurrency;
  final VoidCallback? onTap;
  final bool isDark;

  const CategoryProgressBar({
    super.key,
    required this.category,
    required this.displayCurrency,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row: Icon + Name + Amount
            Row(
              children: [
                // Category icon
                Icon(
                  category.icon,
                  size: 14,
                  color: category.color,
                ),
                const SizedBox(width: 6),
                // Category name
                Expanded(
                  child: Text(
                    category.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Amount
                Text(
                  category.formattedAmount(displayCurrency),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: category.color,
                  ),
                ),
                const SizedBox(width: 6),
                // Percentage badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: category.color.withAlpha(isDark ? 30 : 20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${category.percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: category.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: category.percentage / 100,
                backgroundColor: category.color.withAlpha(isDark ? 25 : 20),
                valueColor: AlwaysStoppedAnimation<Color>(category.color),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A list of category progress bars
class CategoryProgressBarList extends StatelessWidget {
  final List<CategoryTotal> categories;
  final String displayCurrency;
  final void Function(String category)? onCategoryTap;
  final bool isDark;
  final int maxCategories;

  const CategoryProgressBarList({
    super.key,
    required this.categories,
    required this.displayCurrency,
    this.onCategoryTap,
    required this.isDark,
    this.maxCategories = 6,
  });

  @override
  Widget build(BuildContext context) {
    final displayCategories = categories.take(maxCategories).toList();

    if (displayCategories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No categories yet',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: displayCategories.map((category) {
        return CategoryProgressBar(
          category: category,
          displayCurrency: displayCurrency,
          onTap: onCategoryTap != null
              ? () => onCategoryTap!(category.category)
              : null,
          isDark: isDark,
        );
      }).toList(),
    );
  }
}

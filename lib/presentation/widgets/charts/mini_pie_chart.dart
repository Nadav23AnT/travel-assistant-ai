import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../data/models/expense_stats.dart';

/// A compact pie chart for category breakdown - 140px version without legend
class MiniPieChart extends StatefulWidget {
  final List<CategoryTotal> categoryTotals;
  final void Function(String category)? onCategoryTap;
  final double size;

  const MiniPieChart({
    super.key,
    required this.categoryTotals,
    this.onCategoryTap,
    this.size = 140,
  });

  @override
  State<MiniPieChart> createState() => _MiniPieChartState();
}

class _MiniPieChartState extends State<MiniPieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.categoryTotals.isEmpty) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 32,
                color: isDark ? Colors.white24 : Colors.black12,
              ),
              const SizedBox(height: 8),
              Text(
                'No data',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    response == null ||
                    response.touchedSection == null) {
                  _touchedIndex = null;
                  return;
                }
                _touchedIndex = response.touchedSection!.touchedSectionIndex;
              });

              if (event is FlTapUpEvent && response?.touchedSection != null) {
                final index = response!.touchedSection!.touchedSectionIndex;
                if (index >= 0 && index < widget.categoryTotals.length) {
                  widget.onCategoryTap?.call(widget.categoryTotals[index].category);
                }
              }
            },
          ),
          sections: _buildSections(),
          centerSpaceRadius: 25, // Smaller center
          sectionsSpace: 2,
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return widget.categoryTotals.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 55.0 : 50.0; // Smaller radius
      final fontSize = isTouched ? 11.0 : 10.0; // Smaller font

      return PieChartSectionData(
        value: category.amount,
        title: '${category.percentage.toStringAsFixed(0)}%',
        color: category.color,
        radius: radius,
        titleStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
          shadows: const [
            Shadow(color: Colors.black26, blurRadius: 2),
          ],
        ),
        badgePositionPercentageOffset: 0.98,
      );
    }).toList();
  }
}

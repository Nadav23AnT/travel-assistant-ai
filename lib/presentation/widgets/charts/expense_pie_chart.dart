import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../data/models/expense_stats.dart';

class ExpensePieChart extends StatefulWidget {
  final List<CategoryTotal> categoryTotals;
  final String displayCurrency;
  final void Function(String category)? onCategoryTap;

  const ExpensePieChart({
    super.key,
    required this.categoryTotals,
    required this.displayCurrency,
    this.onCategoryTap,
  });

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.categoryTotals.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No expense data'),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            flex: 3,
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
                      _touchedIndex =
                          response.touchedSection!.touchedSectionIndex;
                    });

                    if (event is FlTapUpEvent &&
                        response?.touchedSection != null) {
                      final index =
                          response!.touchedSection!.touchedSectionIndex;
                      if (index >= 0 &&
                          index < widget.categoryTotals.length) {
                        widget.onCategoryTap
                            ?.call(widget.categoryTotals[index].category);
                      }
                    }
                  },
                ),
                sections: _buildSections(),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: _buildLegend(),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return widget.categoryTotals.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 65.0 : 55.0;
      final fontSize = isTouched ? 14.0 : 12.0;

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

  Widget _buildLegend() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.categoryTotals.take(5).map((category) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.displayName,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

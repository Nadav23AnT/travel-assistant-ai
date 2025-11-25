import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../data/models/expense_stats.dart';

class SpendingLineChart extends StatefulWidget {
  final List<DailySpending> dailySpending;
  final String displayCurrency;

  const SpendingLineChart({
    super.key,
    required this.dailySpending,
    required this.displayCurrency,
  });

  @override
  State<SpendingLineChart> createState() => _SpendingLineChartState();
}

class _SpendingLineChartState extends State<SpendingLineChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.dailySpending.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No spending data'),
        ),
      );
    }

    // Need at least 2 points for a line chart
    if (widget.dailySpending.length < 2) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.show_chart, size: 48, color: AppTheme.textHint),
              const SizedBox(height: 8),
              Text(
                'Add more expenses to see trends',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 16),
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              touchCallback: (event, response) {
                setState(() {
                  if (response?.lineBarSpots != null &&
                      response!.lineBarSpots!.isNotEmpty) {
                    _touchedIndex = response.lineBarSpots!.first.spotIndex;
                  } else {
                    _touchedIndex = null;
                  }
                });
              },
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (spot) => AppTheme.primaryColor.withAlpha(230),
                tooltipRoundedRadius: 8,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final index = spot.spotIndex;
                    if (index < 0 || index >= widget.dailySpending.length) {
                      return null;
                    }
                    final data = widget.dailySpending[index];
                    return LineTooltipItem(
                      '${DateFormat('MMM d').format(data.date)}\n${data.formattedAmount}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _calculateInterval(),
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppTheme.textHint.withAlpha(51),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45,
                  interval: _calculateInterval(),
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        _formatAxisValue(value),
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: _calculateBottomInterval(),
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= widget.dailySpending.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('M/d')
                            .format(widget.dailySpending[index].date),
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: widget.dailySpending.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    entry.value.amount,
                  );
                }).toList(),
                isCurved: true,
                curveSmoothness: 0.3,
                color: AppTheme.primaryColor,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, index) {
                    final isTouched = index == _touchedIndex;
                    return FlDotCirclePainter(
                      radius: isTouched ? 6 : 4,
                      color: AppTheme.primaryColor,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withAlpha(77),
                      AppTheme.primaryColor.withAlpha(0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
            minY: 0,
          ),
        ),
      ),
    );
  }

  double _calculateInterval() {
    if (widget.dailySpending.isEmpty) return 100;
    final maxAmount = widget.dailySpending
        .map((e) => e.amount)
        .reduce((a, b) => a > b ? a : b);
    if (maxAmount <= 100) return 25;
    if (maxAmount <= 500) return 100;
    if (maxAmount <= 1000) return 200;
    return (maxAmount / 5).ceilToDouble();
  }

  double _calculateBottomInterval() {
    final count = widget.dailySpending.length;
    if (count <= 7) return 1;
    if (count <= 14) return 2;
    if (count <= 30) return 5;
    return (count / 6).ceilToDouble();
  }

  String _formatAxisValue(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }
}

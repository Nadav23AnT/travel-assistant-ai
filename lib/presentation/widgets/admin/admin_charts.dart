import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../data/models/admin_models.dart';

/// User growth line chart showing new users and cumulative users over time
class UserGrowthChart extends StatelessWidget {
  final List<UserGrowthPoint> data;

  const UserGrowthChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;

    // Get the last 14 days for better visibility
    final displayData = data.length > 14 ? data.sublist(data.length - 14) : data;

    final maxNew = displayData.map((p) => p.newUsers).reduce((a, b) => a > b ? a : b);
    final maxY = (maxNew * 1.2).ceilToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LegendItem(color: AppTheme.primaryColor, label: 'New Users'),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: isDark ? Colors.white12 : Colors.black12,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 10, color: textColor),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: (displayData.length / 5).ceilToDouble(),
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= displayData.length) return const SizedBox();
                      final date = displayData[index].date;
                      return Text(
                        DateFormat('M/d').format(date),
                        style: TextStyle(fontSize: 9, color: textColor),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: displayData.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.newUsers.toDouble());
                  }).toList(),
                  isCurved: true,
                  color: AppTheme.primaryColor,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.primaryColor.withAlpha(51),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final point = displayData[spot.x.toInt()];
                      return LineTooltipItem(
                        '${DateFormat('MMM d').format(point.date)}\n${point.newUsers} new users',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Token usage bar chart showing daily token consumption
class TokenUsageChart extends StatelessWidget {
  final List<TokenUsagePoint> data;

  const TokenUsageChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;

    final maxTokens = data.map((p) => p.totalTokens).reduce((a, b) => a > b ? a : b);
    final maxY = (maxTokens * 1.2).ceilToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LegendItem(color: Colors.purple, label: 'Tokens'),
            const SizedBox(width: 16),
            _LegendItem(color: Colors.teal, label: 'Users'),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY > 0 ? maxY : 100,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final point = data[group.x];
                    return BarTooltipItem(
                      '${DateFormat('MMM d').format(point.date)}\n${_formatNumber(point.totalTokens)} tokens\n${point.uniqueUsers} users',
                      const TextStyle(color: Colors.white, fontSize: 11),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        _formatNumber(value.toInt()),
                        style: TextStyle(fontSize: 9, color: textColor),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= data.length) return const SizedBox();
                      final date = data[index].date;
                      return Text(
                        DateFormat('M/d').format(date),
                        style: TextStyle(fontSize: 9, color: textColor),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY > 0 ? maxY / 4 : 25,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: isDark ? Colors.white12 : Colors.black12,
                  strokeWidth: 1,
                ),
              ),
              barGroups: data.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.totalTokens.toDouble(),
                      color: Colors.purple,
                      width: 12,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return '$number';
  }
}

/// Peak hours bar chart showing message activity by hour
class PeakHoursChart extends StatelessWidget {
  final List<PeakHoursPoint> data;

  const PeakHoursChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;

    // Create full 24 hours data
    final fullData = List.generate(24, (hour) {
      final existing = data.where((p) => p.hour == hour).toList();
      return existing.isNotEmpty ? existing.first : PeakHoursPoint(hour: hour, messageCount: 0);
    });

    final maxCount = fullData.map((p) => p.messageCount).reduce((a, b) => a > b ? a : b);
    final maxY = (maxCount * 1.2).ceilToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LegendItem(color: Colors.orange, label: 'Messages'),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY > 0 ? maxY : 10,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final point = fullData[group.x];
                    return BarTooltipItem(
                      '${point.hourLabel}\n${point.messageCount} messages',
                      const TextStyle(color: Colors.white, fontSize: 11),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(fontSize: 9, color: textColor),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) {
                      final hour = value.toInt();
                      // Show every 4 hours
                      if (hour % 4 != 0) return const SizedBox();
                      return Text(
                        hour == 0 ? '12a' : hour == 12 ? '12p' : hour < 12 ? '${hour}a' : '${hour - 12}p',
                        style: TextStyle(fontSize: 9, color: textColor),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY > 0 ? maxY / 4 : 2.5,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: isDark ? Colors.white12 : Colors.black12,
                  strokeWidth: 1,
                ),
              ),
              barGroups: fullData.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.messageCount.toDouble(),
                      color: Colors.orange,
                      width: 8,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(2),
                        topRight: Radius.circular(2),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Legend item widget
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkTextSecondary
                : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Chart card wrapper with title and loading/error states
class ChartCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final bool isLoading;
  final String? error;

  const ChartCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null)
              SizedBox(
                height: 180,
                child: Center(
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(color: AppTheme.errorColor),
                  ),
                ),
              )
            else
              child,
          ],
        ),
      ),
    );
  }
}

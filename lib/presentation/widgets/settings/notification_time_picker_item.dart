import 'package:flutter/material.dart';

import '../../../core/design/tokens/liquid_glass_colors.dart';

/// A notification item with time picker
class NotificationTimePickerItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? description;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final bool enabled;
  final bool showToggle;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;

  const NotificationTimePickerItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.description,
    required this.time,
    required this.onTimeChanged,
    this.enabled = true,
    this.showToggle = false,
    this.toggleValue,
    this.onToggleChanged,
  });

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = enabled && (toggleValue ?? true);

    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: isEnabled ? () => _showTimePicker(context) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              // Title and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description ?? _formatTime(time),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Toggle or time chip
              if (showToggle && toggleValue != null && onToggleChanged != null)
                Switch(
                  value: toggleValue!,
                  onChanged: enabled ? onToggleChanged : null,
                  activeColor: LiquidGlassColors.mintEmerald,
                )
              else
                GestureDetector(
                  onTap: isEnabled ? () => _showTimePicker(context) : null,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatTime(time),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: isDark
                  ? LiquidGlassColors.canvasSubtleDark
                  : LiquidGlassColors.canvasBaseLight,
              hourMinuteColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return iconColor.withOpacity(0.2);
                }
                return isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05);
              }),
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return iconColor;
                }
                return isDark ? Colors.white70 : Colors.black87;
              }),
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return iconColor.withOpacity(0.2);
                }
                return Colors.transparent;
              }),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return iconColor;
                }
                return isDark ? Colors.white70 : Colors.black87;
              }),
              dialHandColor: iconColor,
              dialBackgroundColor: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              dialTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return isDark ? Colors.white70 : Colors.black87;
              }),
              entryModeIconColor: isDark ? Colors.white70 : Colors.black54,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: iconColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      onTimeChanged(selectedTime);
    }
  }
}

/// A notification item with time picker and toggle combined
class NotificationScheduledItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool isEnabled;
  final TimeOfDay time;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final bool masterEnabled;

  const NotificationScheduledItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.isEnabled,
    required this.time,
    required this.onEnabledChanged,
    required this.onTimeChanged,
    this.masterEnabled = true,
  });

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedOpacity(
      opacity: masterEnabled ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            // Time picker button (only when enabled)
            if (isEnabled && masterEnabled)
              GestureDetector(
                onTap: () => _showTimePicker(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatTime(time),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            // Toggle switch
            Switch(
              value: isEnabled,
              onChanged: masterEnabled ? onEnabledChanged : null,
              activeColor: LiquidGlassColors.mintEmerald,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: isDark
                  ? LiquidGlassColors.canvasSubtleDark
                  : LiquidGlassColors.canvasBaseLight,
              dialHandColor: iconColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: iconColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      onTimeChanged(selectedTime);
    }
  }
}

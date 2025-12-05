import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/effects/glass_container.dart' show GlassCard;
import '../../../core/design/tokens/liquid_glass_colors.dart';
import '../../../data/models/notification_settings_model.dart';
import '../../providers/notification_settings_provider.dart';

class DndScheduleScreen extends ConsumerStatefulWidget {
  const DndScheduleScreen({super.key});

  @override
  ConsumerState<DndScheduleScreen> createState() => _DndScheduleScreenState();
}

class _DndScheduleScreenState extends ConsumerState<DndScheduleScreen> {
  late bool _enabled;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late List<int> _activeDays;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Initialize with current values from provider
    final settings = ref.read(notificationSettingsProvider).valueOrNull;
    final dnd = settings?.dndSchedule ?? const DoNotDisturbSchedule();
    _enabled = dnd.enabled;
    _startTime = dnd.startTime;
    _endTime = dnd.endTime;
    _activeDays = List.from(dnd.activeDays);
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _saveChanges() async {
    final newSchedule = DoNotDisturbSchedule(
      enabled: _enabled,
      startTime: _startTime,
      endTime: _endTime,
      activeDays: _activeDays,
    );

    await ref
        .read(notificationSettingsProvider.notifier)
        .updateDndSchedule(newSchedule);

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? LiquidGlassColors.canvasBaseDark
          : LiquidGlassColors.canvasBaseLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Do Not Disturb',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveChanges,
              child: Text(
                'Save',
                style: TextStyle(
                  color: LiquidGlassColors.mintEmerald,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Enable toggle
          GlassCard(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: LiquidGlassColors.auroraIndigo
                          .withOpacity(isDark ? 0.2 : 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.bedtime_rounded,
                      color: LiquidGlassColors.auroraIndigo,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enable Do Not Disturb',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Silence notifications during quiet hours',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _enabled,
                    onChanged: (value) {
                      setState(() => _enabled = value);
                      _markChanged();
                    },
                    activeColor: LiquidGlassColors.mintEmerald,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Schedule section
          AnimatedOpacity(
            opacity: _enabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !_enabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'SCHEDULE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.black54,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  GlassCard(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        // Start time
                        _buildTimeTile(
                          context,
                          icon: Icons.schedule_rounded,
                          title: 'Start Time',
                          time: _startTime,
                          isDark: isDark,
                          onTap: () => _pickTime(isStart: true),
                        ),
                        Divider(
                          height: 1,
                          indent: 56,
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.06),
                        ),
                        // End time
                        _buildTimeTile(
                          context,
                          icon: Icons.alarm_off_rounded,
                          title: 'End Time',
                          time: _endTime,
                          isDark: isDark,
                          onTap: () => _pickTime(isStart: false),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Days section
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'ACTIVE DAYS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.black54,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  GlassCard(
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildDaySelector(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Preview
          if (_enabled) _buildPreview(isDark),
        ],
      ),
    );
  }

  Widget _buildTimeTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required TimeOfDay time,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: LiquidGlassColors.auroraIndigo
                    .withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(icon, color: LiquidGlassColors.auroraIndigo, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: LiquidGlassColors.auroraIndigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatTime(time),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: LiquidGlassColors.auroraIndigo,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector(bool isDark) {
    const days = [
      (1, 'M'),
      (2, 'T'),
      (3, 'W'),
      (4, 'T'),
      (5, 'F'),
      (6, 'S'),
      (7, 'S'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) {
        final isSelected = _activeDays.contains(day.$1);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _activeDays.remove(day.$1);
              } else {
                _activeDays.add(day.$1);
                _activeDays.sort();
              }
            });
            _markChanged();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected
                  ? LiquidGlassColors.auroraIndigo
                  : (isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? LiquidGlassColors.auroraIndigo
                    : (isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.08)),
              ),
            ),
            child: Center(
              child: Text(
                day.$2,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreview(bool isDark) {
    final dayNames = _getDayNames();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview_rounded,
                size: 18,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              const SizedBox(width: 8),
              Text(
                'Preview',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Notifications will be silenced from ${_formatTime(_startTime)} to ${_formatTime(_endTime)}',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Active on: $dayNames',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getDayNames() {
    if (_activeDays.length == 7) return 'Every day';
    if (_activeDays.isEmpty) return 'No days selected';

    const names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return _activeDays.map((d) => names[d]).join(', ');
  }

  Future<void> _pickTime({required bool isStart}) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final time = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: isDark
                  ? LiquidGlassColors.canvasSubtleDark
                  : LiquidGlassColors.canvasBaseLight,
              dialHandColor: LiquidGlassColors.auroraIndigo,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: LiquidGlassColors.auroraIndigo,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        if (isStart) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
      _markChanged();
    }
  }
}

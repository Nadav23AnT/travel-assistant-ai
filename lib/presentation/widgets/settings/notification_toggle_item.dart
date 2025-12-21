import 'package:flutter/material.dart';

import '../../../core/design/tokens/liquid_glass_colors.dart';

/// A notification toggle item with icon, title, optional description
class NotificationToggleItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final Widget? trailing;
  final bool comingSoon;

  const NotificationToggleItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.description,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.trailing,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInteractive = enabled && !comingSoon;

    return AnimatedOpacity(
      opacity: isInteractive ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: isInteractive ? () => onChanged(!value) : null,
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
              // Title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (comingSoon) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: LiquidGlassColors.auroraIndigo
                                  .withOpacity(isDark ? 0.3 : 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Soon',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: LiquidGlassColors.auroraIndigo,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Trailing widget or switch
              if (trailing != null)
                trailing!
              else
                Switch(
                  value: comingSoon ? false : value,
                  onChanged: isInteractive ? onChanged : null,
                  activeColor: LiquidGlassColors.mintEmerald,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A notification item that navigates to another screen (with chevron)
class NotificationNavigationItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool enabled;
  final bool comingSoon;

  const NotificationNavigationItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.enabled = true,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInteractive = enabled && !comingSoon;

    return AnimatedOpacity(
      opacity: isInteractive ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: isInteractive ? onTap : null,
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
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (comingSoon) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: LiquidGlassColors.auroraIndigo
                                  .withOpacity(isDark ? 0.3 : 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Soon',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: LiquidGlassColors.auroraIndigo,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Chevron
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A notification item for selecting days before trip reminder
class NotificationDaysPickerItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final int value;
  final List<int> options;
  final ValueChanged<int> onChanged;
  final bool enabled;

  const NotificationDaysPickerItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.options = const [1, 3, 7, 14],
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: enabled ? () => _showPicker(context) : null,
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
              // Title
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
                      '$value ${value == 1 ? 'day' : 'days'} before',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Current value chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$value ${value == 1 ? 'day' : 'days'}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark
              ? LiquidGlassColors.canvasSubtleDark
              : LiquidGlassColors.canvasBaseLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Remind me',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              ...options.map((days) => ListTile(
                    title: Text(
                      '$days ${days == 1 ? 'day' : 'days'} before',
                      style: TextStyle(
                        fontWeight:
                            value == days ? FontWeight.w600 : FontWeight.normal,
                        color: value == days
                            ? iconColor
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    trailing: value == days
                        ? Icon(Icons.check_rounded, color: iconColor)
                        : null,
                    onTap: () {
                      onChanged(days);
                      Navigator.pop(context);
                    },
                  )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

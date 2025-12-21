import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens/liquid_glass_colors.dart';
import '../../../data/models/notification_settings_model.dart';
import '../../providers/notification_settings_provider.dart';
import '../../widgets/settings/notification_category_section.dart';
import '../../widgets/settings/notification_toggle_item.dart';
import '../../widgets/settings/notification_time_picker_item.dart';
import '../../../services/notification_service.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _permissionGranted = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final granted = await NotificationService().areNotificationsEnabled();
    if (mounted) {
      setState(() => _permissionGranted = granted);
    }
  }

  Future<void> _requestPermissions() async {
    final granted = await NotificationService().requestPermissions();
    if (mounted) {
      setState(() => _permissionGranted = granted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(notificationSettingsProvider);
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
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          // Master toggle in AppBar
          settingsAsync.when(
            data: (settings) {
              if (settings == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Transform.scale(
                  scale: 1.1,
                  child: Switch(
                    value: settings.masterEnabled,
                    onChanged: (value) {
                      ref
                          .read(notificationSettingsProvider.notifier)
                          .updateMasterEnabled(value);
                    },
                    activeColor: LiquidGlassColors.mintEmerald,
                  ),
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: settingsAsync.when(
        data: (settings) {
          if (settings == null) {
            return const Center(child: Text('Unable to load settings'));
          }
          return _buildContent(context, settings, isDark);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(notificationSettingsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    NotificationSettingsModel settings,
    bool isDark,
  ) {
    final notifier = ref.read(notificationSettingsProvider.notifier);
    final masterEnabled = settings.masterEnabled;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Permission warning banner
        if (!_permissionGranted) _buildPermissionBanner(isDark),

        // Master disabled info
        if (!masterEnabled) _buildDisabledBanner(isDark),

        const SizedBox(height: 8),

        // General Section
        NotificationCategorySection(
          title: NotificationCategory.general.title,
          icon: NotificationCategory.general.icon,
          accentColor: NotificationCategory.general.color,
          initiallyExpanded: true,
          enabled: masterEnabled,
          children: [
            NotificationToggleItem(
              icon: Icons.notifications_active_rounded,
              iconColor: LiquidGlassColors.sunsetOrange,
              title: 'Push Notifications',
              description: 'Get instant alerts on your device',
              value: settings.pushNotifications,
              onChanged: (value) => notifier.updatePushNotifications(value),
              enabled: masterEnabled,
            ),
            NotificationToggleItem(
              icon: Icons.email_rounded,
              iconColor: LiquidGlassColors.oceanTeal,
              title: 'Email Notifications',
              description: 'Receive updates via email',
              value: settings.emailNotifications,
              onChanged: (value) => notifier.updateEmailNotifications(value),
              enabled: masterEnabled,
            ),
            NotificationNavigationItem(
              icon: Icons.bedtime_rounded,
              iconColor: LiquidGlassColors.auroraIndigo,
              title: 'Do Not Disturb',
              subtitle: settings.dndSchedule.enabled
                  ? settings.dndSchedule.displayRange
                  : 'Not set',
              onTap: () => context.push('/settings/notifications/dnd'),
              enabled: masterEnabled,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Trip Section
        NotificationCategorySection(
          title: NotificationCategory.trips.title,
          icon: NotificationCategory.trips.icon,
          accentColor: NotificationCategory.trips.color,
          enabled: masterEnabled,
          children: [
            NotificationDaysPickerItem(
              icon: Icons.notification_important_rounded,
              iconColor: LiquidGlassColors.oceanTeal,
              title: 'Trip Reminders',
              value: settings.tripReminderDaysBefore,
              onChanged: (days) => notifier.updateTripReminderDays(days),
              enabled: masterEnabled && settings.tripReminders,
            ),
            NotificationToggleItem(
              icon: Icons.update_rounded,
              iconColor: LiquidGlassColors.oceanCyan,
              title: 'Trip Status Changes',
              description: 'Updates about your bookings',
              value: settings.tripStatusChanges,
              onChanged: (value) => notifier.updateTripStatusChanges(value),
              enabled: masterEnabled,
            ),
            NotificationToggleItem(
              icon: Icons.thunderstorm_rounded,
              iconColor: LiquidGlassColors.sunsetRose,
              title: 'Weather Warnings',
              description: 'Get notified of weather changes',
              value: settings.weatherWarnings,
              onChanged: (value) => notifier.updateWeatherWarnings(value),
              enabled: masterEnabled,
            ),
            NotificationScheduledItem(
              icon: Icons.today_rounded,
              iconColor: LiquidGlassColors.oceanTeal,
              title: 'Daily Trip Summary',
              description: 'Tell us about your day',
              isEnabled: settings.dailyTripSummary,
              time: settings.dailyTripSummaryTime,
              onEnabledChanged: (value) =>
                  notifier.updateDailyTripSummary(value),
              onTimeChanged: (time) =>
                  notifier.updateDailyTripSummaryTime(time),
              masterEnabled: masterEnabled,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Expense & Budget Section
        NotificationCategorySection(
          title: NotificationCategory.expenses.title,
          icon: NotificationCategory.expenses.icon,
          accentColor: NotificationCategory.expenses.color,
          enabled: masterEnabled,
          children: [
            NotificationScheduledItem(
              icon: Icons.alarm_rounded,
              iconColor: LiquidGlassColors.mintEmerald,
              title: 'Expense Reminder',
              description: 'Daily reminder to log expenses',
              isEnabled: settings.expenseReminder,
              time: settings.expenseReminderTime,
              onEnabledChanged: (value) =>
                  notifier.updateExpenseReminder(value),
              onTimeChanged: (time) => notifier.updateExpenseReminderTime(time),
              masterEnabled: masterEnabled,
            ),
            NotificationToggleItem(
              icon: Icons.warning_amber_rounded,
              iconColor: LiquidGlassColors.sunsetOrange,
              title: 'Budget Alerts',
              description:
                  'Alert at ${(settings.budgetAlertThreshold * 100).toInt()}% of budget',
              value: settings.budgetAlerts,
              onChanged: (value) => notifier.updateBudgetAlerts(value),
              enabled: masterEnabled,
            ),
            NotificationToggleItem(
              icon: Icons.insert_chart_rounded,
              iconColor: LiquidGlassColors.mintEmerald,
              title: 'Weekly Spending Summary',
              description: 'See your weekly spending breakdown',
              value: settings.weeklySpendingSummary,
              onChanged: (value) => notifier.updateWeeklySpendingSummary(value),
              enabled: masterEnabled,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Journal Section
        NotificationCategorySection(
          title: NotificationCategory.journal.title,
          icon: NotificationCategory.journal.icon,
          accentColor: NotificationCategory.journal.color,
          enabled: masterEnabled,
          children: [
            NotificationToggleItem(
              icon: Icons.check_circle_rounded,
              iconColor: LiquidGlassColors.auroraPurple,
              title: 'Journal Ready',
              description: 'Prompt when trip ends and journal is ready',
              value: settings.journalReady,
              onChanged: (value) => notifier.updateJournalReady(value),
              enabled: masterEnabled,
            ),
            NotificationScheduledItem(
              icon: Icons.edit_note_rounded,
              iconColor: LiquidGlassColors.auroraViolet,
              title: 'Daily Journal Prompt',
              description: 'Daily reminder to journal',
              isEnabled: settings.dailyJournalPrompt,
              time: settings.dailyJournalTime,
              onEnabledChanged: (value) =>
                  notifier.updateDailyJournalPrompt(value),
              onTimeChanged: (time) => notifier.updateDailyJournalTime(time),
              masterEnabled: masterEnabled,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // App & Engagement Section
        NotificationCategorySection(
          title: NotificationCategory.engagement.title,
          icon: NotificationCategory.engagement.icon,
          accentColor: NotificationCategory.engagement.color,
          enabled: masterEnabled,
          children: [
            NotificationToggleItem(
              icon: Icons.star_rounded,
              iconColor: LiquidGlassColors.sunsetOrange,
              title: 'Rate App Reminder',
              description: 'Help us improve with your feedback',
              value: settings.rateAppReminder,
              onChanged: (value) => notifier.updateRateAppReminder(value),
              enabled: masterEnabled,
            ),
            NotificationToggleItem(
              icon: Icons.new_releases_rounded,
              iconColor: LiquidGlassColors.auroraIndigo,
              title: 'New Feature Announcements',
              description: 'Be the first to know about new features',
              value: settings.newFeatureAnnouncements,
              onChanged: (value) =>
                  notifier.updateNewFeatureAnnouncements(value),
              enabled: masterEnabled,
            ),
            NotificationToggleItem(
              icon: Icons.lightbulb_rounded,
              iconColor: LiquidGlassColors.oceanCyan,
              title: 'Tips & Recommendations',
              description: 'Get travel tips based on your trips',
              value: settings.tipsAndRecommendations,
              onChanged: (value) =>
                  notifier.updateTipsAndRecommendations(value),
              enabled: masterEnabled,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Support Section
        NotificationCategorySection(
          title: NotificationCategory.support.title,
          icon: NotificationCategory.support.icon,
          accentColor: NotificationCategory.support.color,
          enabled: masterEnabled,
          children: [
            NotificationToggleItem(
              icon: Icons.chat_rounded,
              iconColor: LiquidGlassColors.oceanCyan,
              title: 'Support Reply Notifications',
              description: 'Get notified when we reply',
              value: settings.supportReplyNotifications,
              onChanged: (value) =>
                  notifier.updateSupportReplyNotifications(value),
              enabled: masterEnabled,
            ),
            NotificationToggleItem(
              icon: Icons.confirmation_number_rounded,
              iconColor: LiquidGlassColors.oceanTeal,
              title: 'Ticket Status Updates',
              description: 'Track your support requests',
              value: settings.ticketStatusUpdates,
              onChanged: (value) => notifier.updateTicketStatusUpdates(value),
              enabled: masterEnabled,
            ),
          ],
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPermissionBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LiquidGlassColors.sunsetOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LiquidGlassColors.sunsetOrange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: LiquidGlassColors.sunsetOrange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Notifications are disabled in system settings',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          TextButton(
            onPressed: _requestPermissions,
            child: Text(
              'Enable',
              style: TextStyle(
                color: LiquidGlassColors.sunsetOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_off_rounded,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'All notifications are disabled. Toggle the switch above to enable.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/user_settings_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/currency_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${info.version} (${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(userSettingsProvider);
    final homeCurrency = ref.watch(userHomeCurrencyProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.settings),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.error}: $e')),
        data: (settings) => ListView(
          children: [
            // General Settings
            _buildSectionHeader(context, l10n.generalSettings.toUpperCase()),
            _buildLanguageTile(context, l10n, currentLocale),
            _buildCurrencyTile(context, l10n, homeCurrency),
            _buildDateFormatTile(context, l10n, settings),
            _buildDistanceUnitTile(context, l10n, settings),
            _buildDarkModeTile(context, l10n, settings),

            // Notifications
            _buildSectionHeader(context, l10n.notifications.toUpperCase()),
            _buildPushNotificationsTile(context, l10n, settings),
            _buildEmailNotificationsTile(context, l10n, settings),
            _buildTripRemindersTile(context, l10n, settings),

            // Privacy
            _buildSectionHeader(context, l10n.privacy.toUpperCase()),
            _buildShareAnalyticsTile(context, l10n, settings),
            _buildLocationTrackingTile(context, l10n, settings),

            // Account
            _buildSectionHeader(context, l10n.account.toUpperCase()),
            _buildSettingTile(
              context,
              title: l10n.changePassword,
              icon: Icons.lock_outline,
              onTap: () => _showChangePasswordDialog(context, l10n),
            ),
            _buildSettingTile(
              context,
              title: l10n.exportData,
              icon: Icons.download_outlined,
              onTap: () => _showExportDataDialog(context, l10n),
            ),
            _buildSettingTile(
              context,
              title: l10n.resetAccount,
              icon: Icons.refresh_outlined,
              titleColor: AppTheme.warningColor,
              onTap: () => _showResetAccountDialog(context, l10n),
            ),
            _buildSettingTile(
              context,
              title: l10n.deleteAccount,
              icon: Icons.delete_outline,
              titleColor: AppTheme.errorColor,
              onTap: () => _showDeleteAccountDialog(context, l10n),
            ),

            // Help & Legal
            _buildSectionHeader(context, l10n.helpAndLegal.toUpperCase()),
            _buildSettingTile(
              context,
              title: l10n.helpAndSupport,
              icon: Icons.help_outline,
              onTap: () => context.push('/legal/help-support'),
            ),
            _buildSettingTile(
              context,
              title: l10n.termsOfService,
              icon: Icons.description_outlined,
              onTap: () => context.push('/legal/terms-of-service'),
            ),
            _buildSettingTile(
              context,
              title: l10n.privacyPolicy,
              icon: Icons.privacy_tip_outlined,
              onTap: () => context.push('/legal/privacy-policy'),
            ),

            // About
            _buildSectionHeader(context, l10n.about.toUpperCase()),
            _buildSettingTile(
              context,
              title: l10n.appVersion,
              subtitle: _appVersion.isNotEmpty ? _appVersion : '...',
              icon: Icons.info_outline,
              showChevron: false,
              onTap: () {},
            ),
            _buildSettingTile(
              context,
              title: l10n.rateApp,
              icon: Icons.star_outline,
              onTap: () => _showRateAppDialog(context, l10n),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    IconData? icon,
    Color? titleColor,
    bool showChevron = true,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: icon != null
          ? Icon(icon, color: titleColor ?? AppTheme.textSecondary)
          : null,
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: showChevron
          ? const Icon(Icons.chevron_right, color: AppTheme.textSecondary)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    AppLocalizations l10n,
    Locale currentLocale,
  ) {
    final languageName = _getLanguageName(currentLocale.languageCode);

    return ListTile(
      leading: const Icon(Icons.language, color: AppTheme.textSecondary),
      title: Text(l10n.appLanguage),
      subtitle: Text(languageName),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: () => _showLanguagePicker(context, l10n),
    );
  }

  Widget _buildCurrencyTile(
    BuildContext context,
    AppLocalizations l10n,
    String currentCurrency,
  ) {
    return ListTile(
      leading: const Icon(Icons.attach_money, color: AppTheme.textSecondary),
      title: Text(l10n.defaultCurrency),
      subtitle: Text(currentCurrency),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: () => _showCurrencyPicker(context, l10n, currentCurrency),
    );
  }

  Widget _buildDateFormatTile(
    BuildContext context,
    AppLocalizations l10n,
    UserSettingsModel? settings,
  ) {
    final dateFormat = settings?.dateFormat ?? DateFormatOption.ddMmYyyy;

    return ListTile(
      leading:
          const Icon(Icons.calendar_today_outlined, color: AppTheme.textSecondary),
      title: Text(l10n.dateFormat),
      subtitle: Text(dateFormat.displayName),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: () => _showDateFormatPicker(context, l10n, dateFormat),
    );
  }

  Widget _buildDistanceUnitTile(
    BuildContext context,
    AppLocalizations l10n,
    UserSettingsModel? settings,
  ) {
    final distanceUnit = settings?.distanceUnit ?? DistanceUnit.kilometers;
    final unitName = distanceUnit == DistanceUnit.kilometers
        ? l10n.kilometers
        : l10n.miles;

    return ListTile(
      leading: const Icon(Icons.straighten, color: AppTheme.textSecondary),
      title: Text(l10n.distanceUnits),
      subtitle: Text(unitName),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: () => _showDistanceUnitPicker(context, l10n, distanceUnit),
    );
  }

  Widget _buildDarkModeTile(
    BuildContext context,
    AppLocalizations l10n,
    UserSettingsModel? settings,
  ) {
    final isDarkMode = settings?.darkMode ?? false;

    return SwitchListTile(
      secondary: const Icon(Icons.dark_mode_outlined, color: AppTheme.textSecondary),
      title: Text(l10n.darkMode),
      value: isDarkMode,
      onChanged: (value) async {
        await ref.read(userSettingsProvider.notifier).updateDarkMode(value);
      },
    );
  }

  Widget _buildPushNotificationsTile(
    BuildContext context,
    AppLocalizations l10n,
    UserSettingsModel? settings,
  ) {
    return SwitchListTile(
      secondary:
          const Icon(Icons.notifications_outlined, color: AppTheme.textSecondary),
      title: Text(l10n.pushNotifications),
      value: settings?.pushNotifications ?? true,
      onChanged: (value) async {
        await ref
            .read(userSettingsProvider.notifier)
            .updatePushNotifications(value);
      },
    );
  }

  Widget _buildEmailNotificationsTile(
    BuildContext context,
    AppLocalizations l10n,
    UserSettingsModel? settings,
  ) {
    return SwitchListTile(
      secondary: const Icon(Icons.email_outlined, color: AppTheme.textSecondary),
      title: Text(l10n.emailNotifications),
      value: settings?.emailNotifications ?? true,
      onChanged: (value) async {
        await ref
            .read(userSettingsProvider.notifier)
            .updateEmailNotifications(value);
      },
    );
  }

  Widget _buildTripRemindersTile(
    BuildContext context,
    AppLocalizations l10n,
    UserSettingsModel? settings,
  ) {
    return SwitchListTile(
      secondary: const Icon(Icons.alarm, color: AppTheme.textSecondary),
      title: Text(l10n.tripReminders),
      value: settings?.tripReminders ?? true,
      onChanged: (value) async {
        await ref.read(userSettingsProvider.notifier).updateTripReminders(value);
      },
    );
  }

  Widget _buildShareAnalyticsTile(
    BuildContext context,
    AppLocalizations l10n,
    UserSettingsModel? settings,
  ) {
    return SwitchListTile(
      secondary: const Icon(Icons.analytics_outlined, color: AppTheme.textSecondary),
      title: Text(l10n.shareAnalytics),
      value: settings?.shareAnalytics ?? true,
      onChanged: (value) async {
        await ref.read(userSettingsProvider.notifier).updateShareAnalytics(value);
      },
    );
  }

  Widget _buildLocationTrackingTile(
    BuildContext context,
    AppLocalizations l10n,
    UserSettingsModel? settings,
  ) {
    return SwitchListTile(
      secondary:
          const Icon(Icons.location_on_outlined, color: AppTheme.textSecondary),
      title: Text(l10n.locationTracking),
      value: settings?.locationTracking ?? true,
      onChanged: (value) async {
        await ref
            .read(userSettingsProvider.notifier)
            .updateLocationTracking(value);
      },
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'he':
        return 'עברית';
      case 'ja':
        return '日本語';
      case 'zh':
        return '中文';
      case 'ko':
        return '한국어';
      case 'it':
        return 'Italiano';
      case 'pt':
        return 'Português';
      case 'ru':
        return 'Русский';
      case 'ar':
        return 'العربية';
      default:
        return code.toUpperCase();
    }
  }

  void _showLanguagePicker(BuildContext context, AppLocalizations l10n) {
    final currentLocale = ref.read(localeProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 16),
            Text(l10n.appLanguage, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: AppLocales.supportedLocales.map((locale) {
                  final isSelected =
                      currentLocale.languageCode == locale.languageCode;
                  return ListTile(
                    title: Text(_getLanguageName(locale.languageCode)),
                    trailing: isSelected ? const Icon(Icons.check) : null,
                    onTap: () {
                      ref.read(localeProvider.notifier).setLocale(locale);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(
    BuildContext context,
    AppLocalizations l10n,
    String currentCurrency,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 16),
            Text(l10n.defaultCurrency,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: AppConstants.supportedCurrencies.map((currency) {
                  return ListTile(
                    title: Text(currency),
                    trailing:
                        currentCurrency == currency ? const Icon(Icons.check) : null,
                    onTap: () async {
                      await _updateCurrency(currency);
                      if (mounted) Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateCurrency(String currency) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('profiles').update({
        'default_currency': currency,
      }).eq('id', user.id);

      ref.read(userHomeCurrencyProvider.notifier).state = currency;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).currency}: $currency'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).error}: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showDateFormatPicker(
    BuildContext context,
    AppLocalizations l10n,
    DateFormatOption currentFormat,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(l10n.dateFormat, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ...DateFormatOption.values.map((format) => ListTile(
                title: Text(format.value),
                subtitle: Text(format.displayName),
                trailing:
                    currentFormat == format ? const Icon(Icons.check) : null,
                onTap: () async {
                  await ref
                      .read(userSettingsProvider.notifier)
                      .updateDateFormat(format);
                  if (mounted) Navigator.pop(context);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showDistanceUnitPicker(
    BuildContext context,
    AppLocalizations l10n,
    DistanceUnit currentUnit,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(l10n.distanceUnits,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ListTile(
            title: Text(l10n.kilometers),
            subtitle: const Text('km'),
            trailing: currentUnit == DistanceUnit.kilometers
                ? const Icon(Icons.check)
                : null,
            onTap: () async {
              await ref
                  .read(userSettingsProvider.notifier)
                  .updateDistanceUnit(DistanceUnit.kilometers);
              if (mounted) Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text(l10n.miles),
            subtitle: const Text('mi'),
            trailing: currentUnit == DistanceUnit.miles
                ? const Icon(Icons.check)
                : null,
            onTap: () async {
              await ref
                  .read(userSettingsProvider.notifier)
                  .updateDistanceUnit(DistanceUnit.miles);
              if (mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AppLocalizations l10n) {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.password,
                hintText: 'Enter new password',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Confirm new password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }

              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password must be at least 6 characters'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }

              try {
                await Supabase.instance.client.auth.updateUser(
                  UserAttributes(password: newPasswordController.text),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update password: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showExportDataDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exportData),
        content: const Text(
          'Your data export will be prepared and sent to your email address. This may take a few minutes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data export requested. Check your email.'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showResetAccountDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetAccount),
        content: Text(l10n.resetAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetAccountData(context, l10n);
            },
            child: Text(
              l10n.reset,
              style: const TextStyle(color: AppTheme.warningColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAccountData(BuildContext context, AppLocalizations l10n) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Store navigator and scaffold messenger before async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Call the reset_user_data function
      await Supabase.instance.client.rpc('reset_user_data', params: {
        'p_user_id': user.id,
      });

      // Refresh settings to get the reset onboarding state
      await ref.read(userSettingsProvider.notifier).refresh();

      // Close loading dialog
      navigator.pop();

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(l10n.accountResetSuccess),
          backgroundColor: AppTheme.successColor,
        ),
      );

      // Navigate to onboarding flow since onboarding_completed is now false
      router.go('/onboarding/languages');
    } catch (e) {
      // Close loading dialog
      navigator.pop();

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showDeleteAccountDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Sign out first
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.pop(context);
                  context.go('/login');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.error}: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showRateAppDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rateApp),
        content: const Text(
          'If you enjoy using Waylo, please take a moment to rate us on the app store. Your feedback helps us improve!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Open app store link
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your support!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }

}

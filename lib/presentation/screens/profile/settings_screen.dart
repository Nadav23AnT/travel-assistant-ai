import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/constants.dart';
import '../../../config/external_links.dart';
import '../../../config/theme.dart';
import '../../../core/design/effects/glass_container.dart';
import '../../../core/design/tokens/liquid_glass_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.error}: $e')),
        data: (settings) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Header
              _buildProfileHeader(context, user, isDark),
              const SizedBox(height: 20),

              // Quick Actions
              _buildQuickActions(context, l10n, isDark),
              const SizedBox(height: 24),

              // Preferences Section
              _buildSectionTitle(context, l10n.generalSettings),
              const SizedBox(height: 8),
              _buildPreferencesCard(context, l10n, settings, homeCurrency, currentLocale, isDark),
              const SizedBox(height: 24),

              // Notifications Section
              _buildSectionTitle(context, l10n.notifications),
              const SizedBox(height: 8),
              _buildNotificationsCard(context, l10n, settings, isDark),
              const SizedBox(height: 24),

              // Privacy Section
              _buildSectionTitle(context, l10n.privacy),
              const SizedBox(height: 8),
              _buildPrivacyCard(context, l10n, settings, isDark),
              const SizedBox(height: 24),

              // Account Section
              _buildSectionTitle(context, l10n.account),
              const SizedBox(height: 8),
              _buildAccountCard(context, l10n, isDark),
              const SizedBox(height: 24),

              // Social & Community
              _buildSectionTitle(context, 'Connect With Us'),
              const SizedBox(height: 8),
              _buildSocialLinksRow(context, isDark),
              const SizedBox(height: 24),

              // Help & Legal Section
              _buildSectionTitle(context, l10n.helpAndLegal),
              const SizedBox(height: 8),
              _buildLegalCard(context, l10n, isDark),
              const SizedBox(height: 24),

              // About Section
              _buildSectionTitle(context, l10n.about),
              const SizedBox(height: 8),
              _buildAboutCard(context, l10n, isDark),
              const SizedBox(height: 24),

              // Danger Zone
              _buildDangerZone(context, l10n, isDark),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User? user, bool isDark) {
    final email = user?.email ?? '';
    final displayName = user?.userMetadata?['full_name'] as String? ??
                        user?.userMetadata?['name'] as String? ??
                        email.split('@').first;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  LiquidGlassColors.oceanTeal,
                  LiquidGlassColors.auroraPurple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: LiquidGlassColors.oceanTeal.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Plan Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        LiquidGlassColors.mintEmerald.withOpacity(0.2),
                        LiquidGlassColors.oceanTeal.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: LiquidGlassColors.mintEmerald.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: LiquidGlassColors.mintEmerald,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Free Plan',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: LiquidGlassColors.mintEmerald,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.star_rounded,
            label: l10n.rateApp,
            color: LiquidGlassColors.sunsetOrange,
            isDark: isDark,
            onTap: () => _launchUrl(ExternalLinks.appStoreUrl),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.share_rounded,
            label: 'Share',
            color: LiquidGlassColors.oceanTeal,
            isDark: isDark,
            onTap: () => _shareApp(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.person_add_rounded,
            label: 'Invite',
            color: LiquidGlassColors.auroraPurple,
            isDark: isDark,
            onTap: () => _inviteFriends(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPreferencesCard(
    BuildContext context,
    AppLocalizations l10n,
    UserSettingsModel? settings,
    String homeCurrency,
    Locale currentLocale,
    bool isDark,
  ) {
    final languageName = _getLanguageName(currentLocale.languageCode);
    final dateFormat = settings?.dateFormat ?? DateFormatOption.ddMmYyyy;
    final distanceUnit = settings?.distanceUnit ?? DistanceUnit.kilometers;
    final unitName = distanceUnit == DistanceUnit.kilometers ? l10n.kilometers : l10n.miles;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.language_rounded,
            iconColor: LiquidGlassColors.oceanTeal,
            title: l10n.appLanguage,
            subtitle: languageName,
            isDark: isDark,
            onTap: () => _showLanguagePicker(context, l10n),
          ),
          _buildDivider(isDark),
          _SettingsTile(
            icon: Icons.attach_money_rounded,
            iconColor: LiquidGlassColors.mintEmerald,
            title: l10n.defaultCurrency,
            subtitle: homeCurrency,
            isDark: isDark,
            onTap: () => _showCurrencyPicker(context, l10n, homeCurrency),
          ),
          _buildDivider(isDark),
          _SettingsTile(
            icon: Icons.calendar_today_rounded,
            iconColor: LiquidGlassColors.auroraPurple,
            title: l10n.dateFormat,
            subtitle: dateFormat.displayName,
            isDark: isDark,
            onTap: () => _showDateFormatPicker(context, l10n, dateFormat),
          ),
          _buildDivider(isDark),
          _SettingsTile(
            icon: Icons.straighten_rounded,
            iconColor: LiquidGlassColors.sunsetOrange,
            title: l10n.distanceUnits,
            subtitle: unitName,
            isDark: isDark,
            onTap: () => _showDistanceUnitPicker(context, l10n, distanceUnit),
          ),
          _buildDivider(isDark),
          _SettingsToggle(
            icon: Icons.dark_mode_rounded,
            iconColor: LiquidGlassColors.auroraIndigo,
            title: l10n.darkMode,
            value: settings?.darkMode ?? false,
            isDark: isDark,
            onChanged: (value) async {
              await ref.read(userSettingsProvider.notifier).updateDarkMode(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard(
    BuildContext context,
    AppLocalizations l10n,
    UserSettingsModel? settings,
    bool isDark,
  ) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: _SettingsTile(
        icon: Icons.notifications_rounded,
        iconColor: LiquidGlassColors.sunsetOrange,
        title: l10n.notifications,
        subtitle: 'Manage all notification preferences',
        isDark: isDark,
        onTap: () => context.push('/settings/notifications'),
      ),
    );
  }

  Widget _buildPrivacyCard(
    BuildContext context,
    AppLocalizations l10n,
    UserSettingsModel? settings,
    bool isDark,
  ) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _SettingsToggle(
            icon: Icons.analytics_rounded,
            iconColor: LiquidGlassColors.oceanTeal,
            title: l10n.shareAnalytics,
            subtitle: 'Help improve Waylo',
            value: settings?.shareAnalytics ?? true,
            isDark: isDark,
            onChanged: (value) async {
              await ref.read(userSettingsProvider.notifier).updateShareAnalytics(value);
            },
          ),
          _buildDivider(isDark),
          _SettingsToggle(
            icon: Icons.location_on_rounded,
            iconColor: LiquidGlassColors.mintEmerald,
            title: l10n.locationTracking,
            subtitle: 'For trip suggestions',
            value: settings?.locationTracking ?? true,
            isDark: isDark,
            onChanged: (value) async {
              await ref.read(userSettingsProvider.notifier).updateLocationTracking(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.lock_rounded,
            iconColor: LiquidGlassColors.auroraPurple,
            title: l10n.changePassword,
            isDark: isDark,
            onTap: () => _showChangePasswordDialog(context, l10n),
          ),
          _buildDivider(isDark),
          _SettingsTile(
            icon: Icons.download_rounded,
            iconColor: LiquidGlassColors.oceanTeal,
            title: l10n.exportData,
            subtitle: 'Get a copy of your data',
            isDark: isDark,
            onTap: () => _showExportDataDialog(context, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinksRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _SocialLinkCard(
            icon: Icons.camera_alt_rounded,
            label: 'Instagram',
            color: const Color(0xFFE4405F),
            isDark: isDark,
            onTap: () => _launchUrl(ExternalLinks.instagramUrl),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialLinkCard(
            icon: Icons.close, // X icon approximation
            label: 'X',
            color: isDark ? Colors.white : Colors.black,
            isDark: isDark,
            onTap: () => _launchUrl(ExternalLinks.twitterUrl),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialLinkCard(
            icon: Icons.language_rounded,
            label: 'Website',
            color: LiquidGlassColors.oceanTeal,
            isDark: isDark,
            onTap: () => _launchUrl(ExternalLinks.websiteUrl),
          ),
        ),
      ],
    );
  }

  Widget _buildLegalCard(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            iconColor: LiquidGlassColors.oceanTeal,
            title: l10n.helpAndSupport,
            isDark: isDark,
            onTap: () => context.push('/legal/help-support'),
          ),
          _buildDivider(isDark),
          _SettingsTile(
            icon: Icons.description_outlined,
            iconColor: LiquidGlassColors.auroraPurple,
            title: l10n.termsOfService,
            isDark: isDark,
            onTap: () => context.push('/legal/terms-of-service'),
          ),
          _buildDivider(isDark),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            iconColor: LiquidGlassColors.mintEmerald,
            title: l10n.privacyPolicy,
            isDark: isDark,
            onTap: () => context.push('/legal/privacy-policy'),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  LiquidGlassColors.oceanTeal,
                  LiquidGlassColors.auroraPurple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                'W',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Waylo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your AI Travel Companion',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _appVersion.isNotEmpty ? 'v$_appVersion' : '...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, AppLocalizations l10n, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DANGER ZONE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ),
            _SettingsTile(
              icon: Icons.refresh_rounded,
              iconColor: AppTheme.warningColor,
              title: l10n.resetAccount,
              subtitle: 'Clear all trips and data',
              isDark: isDark,
              onTap: () => _showResetAccountDialog(context, l10n),
            ),
            _buildDivider(isDark),
            _SettingsTile(
              icon: Icons.delete_forever_rounded,
              iconColor: AppTheme.errorColor,
              title: l10n.deleteAccount,
              subtitle: 'Permanently delete account',
              isDark: isDark,
              onTap: () => _showDeleteAccountDialog(context, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
    );
  }

  // --- Helper Methods ---

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareApp() async {
    final shareText = '${ExternalLinks.shareAppText}${ExternalLinks.appStoreUrl}';
    await Share.share(shareText);
  }

  Future<void> _inviteFriends() async {
    final inviteText = '${ExternalLinks.shareAppText}${ExternalLinks.inviteLinkBase}';
    await Share.share(inviteText);
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

  // --- Pickers and Dialogs ---

  void _showLanguagePicker(BuildContext context, AppLocalizations l10n) {
    final currentLocale = ref.read(localeProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.appLanguage, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: AppLocales.supportedLocales.map((locale) {
                    final isSelected = currentLocale.languageCode == locale.languageCode;
                    return ListTile(
                      title: Text(_getLanguageName(locale.languageCode)),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: LiquidGlassColors.mintEmerald)
                          : null,
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
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, AppLocalizations l10n, String currentCurrency) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.defaultCurrency, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: AppConstants.supportedCurrencies.map((currency) {
                    final isSelected = currentCurrency == currency;
                    return ListTile(
                      title: Text(currency),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: LiquidGlassColors.mintEmerald)
                          : null,
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

  void _showDateFormatPicker(BuildContext context, AppLocalizations l10n, DateFormatOption currentFormat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.dateFormat, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...DateFormatOption.values.map((format) => ListTile(
              title: Text(format.value),
              subtitle: Text(format.displayName),
              trailing: currentFormat == format
                  ? Icon(Icons.check_circle, color: LiquidGlassColors.mintEmerald)
                  : null,
              onTap: () async {
                await ref.read(userSettingsProvider.notifier).updateDateFormat(format);
                if (mounted) Navigator.pop(context);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDistanceUnitPicker(BuildContext context, AppLocalizations l10n, DistanceUnit currentUnit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.distanceUnits, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              title: Text(l10n.kilometers),
              subtitle: const Text('km'),
              trailing: currentUnit == DistanceUnit.kilometers
                  ? Icon(Icons.check_circle, color: LiquidGlassColors.mintEmerald)
                  : null,
              onTap: () async {
                await ref.read(userSettingsProvider.notifier).updateDistanceUnit(DistanceUnit.kilometers);
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.miles),
              subtitle: const Text('mi'),
              trailing: currentUnit == DistanceUnit.miles
                  ? Icon(Icons.check_circle, color: LiquidGlassColors.mintEmerald)
                  : null,
              onTap: () async {
                await ref.read(userSettingsProvider.notifier).updateDistanceUnit(DistanceUnit.miles);
                if (mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
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
                prefixIcon: const Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Confirm new password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
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
          FilledButton(
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
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor),
            const SizedBox(width: 8),
            Text(l10n.resetAccount),
          ],
        ),
        content: Text(l10n.resetAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.warningColor,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _resetAccountData(context, l10n);
            },
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAccountData(BuildContext context, AppLocalizations l10n) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await Supabase.instance.client.rpc('reset_user_data', params: {
        'p_user_id': user.id,
      });

      await ref.read(userSettingsProvider.notifier).refresh();
      navigator.pop();

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(l10n.accountResetSuccess),
          backgroundColor: AppTheme.successColor,
        ),
      );

      router.go('/onboarding/languages');
    } catch (e) {
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
        title: Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: AppTheme.errorColor),
            const SizedBox(width: 8),
            Text(l10n.deleteAccount),
          ],
        ),
        content: Text(l10n.deleteAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            onPressed: () async {
              try {
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
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

// --- Custom Widget Components ---

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(isDark ? 0.2 : 0.1),
              color.withOpacity(isDark ? 0.1 : 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool isDark;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
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
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : Colors.black38,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
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
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: LiquidGlassColors.mintEmerald,
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialLinkCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _SocialLinkCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

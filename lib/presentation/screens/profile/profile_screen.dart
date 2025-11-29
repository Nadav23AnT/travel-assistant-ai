import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/country_currency_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/trips_provider.dart';

/// Provider for app version info
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

/// Provider for profile statistics
final profileStatsProvider = FutureProvider<ProfileStats>((ref) async {
  final trips = await ref.watch(userTripsProvider.future);
  final expenses = await ref.watch(userExpensesProvider.future);

  // Calculate unique countries visited
  final visitedCountries = <String>{};
  for (final trip in trips) {
    final country = CountryCurrencyHelper.extractCountryFromDestination(trip.destination);
    if (country.isNotEmpty) {
      visitedCountries.add(country);
    }
  }

  // Calculate total spent across all expenses
  final totalSpent = expenses.fold<double>(0, (sum, e) => sum + e.amount);

  return ProfileStats(
    tripCount: trips.length,
    expenseCount: expenses.length,
    countriesCount: visitedCountries.length,
    totalSpent: totalSpent,
  );
});

class ProfileStats {
  final int tripCount;
  final int expenseCount;
  final int countriesCount;
  final double totalSpent;

  const ProfileStats({
    required this.tripCount,
    required this.expenseCount,
    required this.countriesCount,
    required this.totalSpent,
  });
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider);
    final userEmail = user?.email ?? l10n.notSignedIn;
    final userName = user?.userMetadata?['full_name'] as String? ??
                     user?.email?.split('@').first ??
                     l10n.traveler;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(AppRoutes.editProfile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Profile header
            _buildProfileHeader(context, ref, userName, userEmail, user),
            const SizedBox(height: 24),

            // Stats
            _buildStats(context, ref),
            const SizedBox(height: 24),

            // Language selector
            _buildLanguageSelector(context, ref, currentLocale),
            const SizedBox(height: 16),

            // Subscription card
            _buildSubscriptionCard(context),
            const SizedBox(height: 16),

            // Menu items
            _buildMenuItem(
              context,
              icon: Icons.settings_outlined,
              title: l10n.settings,
              onTap: () => context.push(AppRoutes.settings),
            ),
            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              title: l10n.helpAndSupport,
              onTap: () {
                // TODO: Navigate to help
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.privacy_tip_outlined,
              title: l10n.privacyPolicy,
              onTap: () {
                // TODO: Show privacy policy
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.description_outlined,
              title: l10n.termsOfService,
              onTap: () {
                // TODO: Show terms
              },
            ),
            const SizedBox(height: 24),

            // Sign out
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () {
                  _showSignOutDialog(context, ref);
                },
                icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                label: Text(
                  l10n.signOut,
                  style: const TextStyle(color: AppTheme.errorColor),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.errorColor),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // App version (dynamic)
            _buildAppVersion(context, ref),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    WidgetRef ref,
    String userName,
    String userEmail,
    dynamic user,
  ) {
    final l10n = AppLocalizations.of(context);

    // Format member since date
    String? memberSinceText;
    if (user?.createdAt != null) {
      try {
        final createdAt = DateTime.parse(user!.createdAt!);
        final formattedDate = DateFormat.yMMM().format(createdAt);
        memberSinceText = l10n.memberSince(formattedDate);
      } catch (_) {
        // Ignore parsing errors
      }
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: AppTheme.primaryLight,
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : 'T',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          userEmail,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        if (memberSinceText != null) ...[
          const SizedBox(height: 4),
          Text(
            memberSinceText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textHint,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildStats(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(profileStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: statsAsync.when(
            loading: () => const SizedBox(
              height: 80,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: l10n.trips,
                    value: '-',
                    icon: Icons.luggage_outlined,
                  ),
                ),
                Container(width: 1, height: 40, color: AppTheme.textHint),
                Expanded(
                  child: _StatItem(
                    label: l10n.expenses,
                    value: '-',
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
                Container(width: 1, height: 40, color: AppTheme.textHint),
                Expanded(
                  child: _StatItem(
                    label: l10n.countries,
                    value: '-',
                    icon: Icons.public_outlined,
                  ),
                ),
              ],
            ),
            data: (stats) => Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: l10n.trips,
                    value: '${stats.tripCount}',
                    icon: Icons.luggage_outlined,
                  ),
                ),
                Container(width: 1, height: 40, color: AppTheme.textHint),
                Expanded(
                  child: _StatItem(
                    label: l10n.expenses,
                    value: '${stats.expenseCount}',
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
                Container(width: 1, height: 40, color: AppTheme.textHint),
                Expanded(
                  child: _StatItem(
                    label: l10n.countries,
                    value: '${stats.countriesCount}',
                    icon: Icons.public_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, WidgetRef ref, Locale currentLocale) {
    final l10n = AppLocalizations.of(context);
    final currentLanguageName = _getLanguageName(currentLocale.languageCode, l10n);
    final flag = AppLocales.getFlag(currentLocale.languageCode);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(flag, style: const TextStyle(fontSize: 20)),
            ),
          ),
          title: Text(l10n.appLanguage),
          subtitle: Text(
            currentLanguageName,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          onTap: () => _showLanguageDialog(context, ref, currentLocale),
        ),
      ),
    );
  }

  String _getLanguageName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'en': return l10n.languageEnglish;
      case 'es': return l10n.languageSpanish;
      case 'fr': return l10n.languageFrench;
      case 'de': return l10n.languageGerman;
      case 'he': return l10n.languageHebrew;
      case 'ja': return l10n.languageJapanese;
      case 'zh': return l10n.languageChinese;
      case 'ko': return l10n.languageKorean;
      case 'it': return l10n.languageItalian;
      case 'pt': return l10n.languagePortuguese;
      case 'ru': return l10n.languageRussian;
      case 'ar': return l10n.languageArabic;
      default: return l10n.languageEnglish;
    }
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, Locale currentLocale) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.appLanguage),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AppLocales.supportedLocales.length,
            itemBuilder: (context, index) {
              final locale = AppLocales.supportedLocales[index];
              final flag = AppLocales.getFlag(locale.languageCode);
              final name = _getLanguageName(locale.languageCode, l10n);
              final isSelected = locale.languageCode == currentLocale.languageCode;

              return ListTile(
                leading: Text(flag, style: const TextStyle(fontSize: 24)),
                title: Text(name),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppTheme.primaryColor)
                    : null,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocaleByCode(locale.languageCode);
                  Navigator.pop(dialogContext);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: AppTheme.primaryLight.withAlpha(77),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.freePlan,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.upgradeUnlockFeatures,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to subscription screen
                },
                child: Text(l10n.upgrade),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(title),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.signOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                // Actually sign out using the auth notifier
                await ref.read(authNotifierProvider.notifier).signOut();

                if (context.mounted) {
                  Navigator.of(context).pop(); // Close loading
                  context.go(AppRoutes.login);
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.failedToSignOut}: $e'),
                      backgroundColor: AppTheme.errorColor,
                    ),
                  );
                }
              }
            },
            child: Text(
              l10n.signOut,
              style: const TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppVersion(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final versionAsync = ref.watch(appVersionProvider);

    return versionAsync.when(
      data: (version) => Text(
        '${l10n.appVersion} $version',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
      ),
      loading: () => Text(
        '${l10n.appVersion} ...',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
      ),
      error: (_, __) => Text(
        '${l10n.appVersion} 1.0.0',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }
}

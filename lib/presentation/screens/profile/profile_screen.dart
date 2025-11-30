import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/referral_service.dart';
import '../../../services/token_usage_service.dart';
import '../../../utils/country_currency_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/trips_provider.dart';

/// Provider for token usage status (auto-refresh)
final tokenUsageProvider = FutureProvider.autoDispose<TokenCheckResult>((ref) async {
  final service = TokenUsageService();
  return service.checkBeforeRequest();
});

/// Provider for app version info
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

/// Provider for referral stats
final referralStatsProvider = FutureProvider.autoDispose<ReferralStats?>((ref) async {
  final service = ReferralService();
  return service.getReferralStats();
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
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => context.push(AppRoutes.editProfile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Compact profile header
            _buildProfileHeader(context, ref, userName, userEmail, user),
            const SizedBox(height: 16),

            // Compact stats widget
            _buildStats(context, ref),
            const SizedBox(height: 12),

            // Premium section (redesigned)
            _buildPremiumCard(context),
            const SizedBox(height: 8),

            // Compact AI usage widget
            _buildTokenUsageWidget(context, ref),
            const SizedBox(height: 8),

            // Language selector (compact)
            _buildLanguageSelector(context, ref, currentLocale),
            const SizedBox(height: 8),

            // Invite Friends (compact)
            _buildInviteFriendsCard(context, ref),
            const SizedBox(height: 4),

            // Thin separator
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1),
            ),

            // Menu items (compact)
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
              onTap: () => context.push(AppRoutes.helpSupport),
            ),
            _buildMenuItem(
              context,
              icon: Icons.privacy_tip_outlined,
              title: l10n.privacyPolicy,
              onTap: () => context.push(AppRoutes.privacyPolicy),
            ),
            _buildMenuItem(
              context,
              icon: Icons.description_outlined,
              title: l10n.termsOfService,
              onTap: () => context.push(AppRoutes.termsOfService),
            ),
            const SizedBox(height: 16),

            // Sign out (compact)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: () => _showSignOutDialog(context, ref),
                  icon: const Icon(Icons.logout, color: AppTheme.errorColor, size: 18),
                  label: Text(
                    l10n.signOut,
                    style: const TextStyle(color: AppTheme.errorColor, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.errorColor, width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // App version
            _buildAppVersion(context, ref),
            const SizedBox(height: 16),
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
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Smaller, sharper avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryLight,
              border: Border.all(color: AppTheme.primaryColor.withAlpha(51), width: 2),
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'T',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and email on the right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  userEmail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                ),
                if (memberSinceText != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    memberSinceText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textHint,
                          fontSize: 11,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(profileStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: statsAsync.when(
          loading: () => const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (error, stack) => _buildStatsRow(context, l10n, '-', '-', '-'),
          data: (stats) => _buildStatsRow(
            context,
            l10n,
            '${stats.tripCount}',
            '${stats.expenseCount}',
            '${stats.countriesCount}',
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    AppLocalizations l10n,
    String trips,
    String expenses,
    String countries,
  ) {
    return Row(
      children: [
        Expanded(
          child: _CompactStatItem(
            icon: Icons.luggage_outlined,
            value: trips,
            label: l10n.trips,
          ),
        ),
        Container(width: 1, height: 32, color: AppTheme.dividerColor),
        Expanded(
          child: _CompactStatItem(
            icon: Icons.receipt_long_outlined,
            value: expenses,
            label: l10n.expenses,
          ),
        ),
        Container(width: 1, height: 32, color: AppTheme.dividerColor),
        Expanded(
          child: _CompactStatItem(
            icon: Icons.public_outlined,
            value: countries,
            label: l10n.countries,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withAlpha(13),
              AppTheme.accentColor.withAlpha(13),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.primaryColor.withAlpha(38),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Star icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.star_rounded,
                color: AppTheme.accentColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            // Free Plan badge + text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondary.withAlpha(26),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.freePlan,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.upgradeUnlockFeatures,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
            // Upgrade button
            SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to subscription screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.upgrade,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenUsageWidget(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokenUsageAsync = ref.watch(tokenUsageProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: tokenUsageAsync.when(
          loading: () => const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (error, stack) => _buildTokenUsageContent(
            context,
            l10n,
            tokensUsed: 0,
            dailyLimit: 10000,
            planType: 'free',
          ),
          data: (usage) => _buildTokenUsageContent(
            context,
            l10n,
            tokensUsed: usage.tokensUsed,
            dailyLimit: usage.dailyLimit,
            planType: usage.planType,
          ),
        ),
      ),
    );
  }

  Widget _buildTokenUsageContent(
    BuildContext context,
    AppLocalizations l10n, {
    required int tokensUsed,
    required int dailyLimit,
    required String planType,
  }) {
    final percentage = dailyLimit > 0 ? (tokensUsed / dailyLimit).clamp(0.0, 1.0) : 0.0;
    final remaining = (dailyLimit - tokensUsed).clamp(0, dailyLimit);

    // Convert tokens to credits
    final creditsUsed = (tokensUsed / 100).round();
    final creditsRemaining = (remaining / 100).round();

    // Subtle color gradient based on usage
    Color progressColor;
    if (percentage < 0.5) {
      progressColor = AppTheme.successColor;
    } else if (percentage < 0.8) {
      progressColor = AppTheme.warningColor;
    } else {
      progressColor = AppTheme.accentColor; // Use accent instead of aggressive red
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: AppTheme.primaryColor,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.aiUsageToday,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
            ),
            const Spacer(),
            Text(
              '$creditsUsed/${creditsRemaining + creditsUsed}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
            ),
            Text(
              ' ${l10n.used.toLowerCase()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textHint,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Sleek thin progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppTheme.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(BuildContext context, WidgetRef ref, Locale currentLocale) {
    final l10n = AppLocalizations.of(context);
    final currentLanguageName = _getLanguageName(currentLocale.languageCode, l10n);
    final flag = AppLocales.getFlag(currentLocale.languageCode);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          visualDensity: VisualDensity.compact,
          leading: Text(flag, style: const TextStyle(fontSize: 18)),
          title: Text(
            l10n.appLanguage,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            currentLanguageName,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppTheme.textHint, size: 20),
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
                dense: true,
                leading: Text(flag, style: const TextStyle(fontSize: 20)),
                title: Text(name, style: const TextStyle(fontSize: 14)),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppTheme.primaryColor, size: 20)
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

  Widget _buildInviteFriendsCard(BuildContext context, WidgetRef ref) {
    final referralAsync = ref.watch(referralStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: referralAsync.when(
          loading: () => const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (error, stack) => _buildInviteFriendsContent(context, ref, null),
          data: (stats) => _buildInviteFriendsContent(context, ref, stats),
        ),
      ),
    );
  }

  Widget _buildInviteFriendsContent(
    BuildContext context,
    WidgetRef ref,
    ReferralStats? stats,
  ) {
    final l10n = AppLocalizations.of(context);
    final referralCode = stats?.referralCode ?? '...';
    final referralCount = stats?.referralCount ?? 0;
    final creditsEarned = stats?.totalCreditsEarned ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withAlpha(26),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.card_giftcard,
                color: AppTheme.accentColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.inviteFriends,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    l10n.inviteFriendsSubtitle,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            // Share button (icon only)
            IconButton(
              onPressed: () => _shareReferralCode(context, referralCode),
              icon: const Icon(Icons.share, size: 18),
              color: AppTheme.accentColor,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Referral code row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withAlpha(51),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppTheme.primaryColor.withAlpha(38)),
          ),
          child: Row(
            children: [
              Text(
                l10n.yourReferralCode,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                referralCode,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AppTheme.primaryColor,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: referralCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.copiedToClipboard),
                      backgroundColor: AppTheme.successColor,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Icon(Icons.copy, color: AppTheme.primaryColor, size: 16),
              ),
            ],
          ),
        ),

        // Stats row (if any)
        if (referralCount > 0 || creditsEarned > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.people_outline, size: 12, color: AppTheme.textHint),
                const SizedBox(width: 4),
                Text(
                  l10n.friendsInvited(referralCount.toString()),
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                ),
                const SizedBox(width: 12),
                Icon(Icons.stars, size: 12, color: AppTheme.accentColor),
                const SizedBox(width: 4),
                Text(
                  l10n.creditsEarned(creditsEarned.toString()),
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _shareReferralCode(BuildContext context, String referralCode) {
    final service = ReferralService();
    final message = service.getShareMessage(referralCode);

    Share.share(
      message,
      subject: 'Join me on TripBuddy!',
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: AppTheme.textSecondary, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 13)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textHint, size: 18),
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
              color: AppTheme.textHint,
              fontSize: 10,
            ),
      ),
      loading: () => Text(
        '${l10n.appVersion} ...',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textHint,
              fontSize: 10,
            ),
      ),
      error: (error, stack) => Text(
        '${l10n.appVersion} 1.0.0',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textHint,
              fontSize: 10,
            ),
      ),
    );
  }
}

/// Compact stat item widget for the dashboard-style stats
class _CompactStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _CompactStatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 14),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

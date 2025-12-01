import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../../config/routes.dart';
import '../../../core/design/design_system.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/referral_service.dart';
import '../../../services/token_usage_service.dart';
import '../../../utils/country_currency_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/trips_provider.dart';

/// Provider for token usage status (auto-refresh)
final tokenUsageProvider =
    FutureProvider.autoDispose<TokenCheckResult>((ref) async {
  final service = TokenUsageService();
  return service.checkBeforeRequest();
});

/// Provider for app version info
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

/// Provider for referral stats
final referralStatsProvider =
    FutureProvider.autoDispose<ReferralStats?>((ref) async {
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
    final country =
        CountryCurrencyHelper.extractCountryFromDestination(trip.destination);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.profile,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          GlowingIconButton(
            icon: Icons.edit_outlined,
            onPressed: () => context.push(AppRoutes.editProfile),
            size: 40,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          children: [
            // Profile header with glass styling
            _GlassProfileHeader(
              userName: userName,
              userEmail: userEmail,
              user: user,
              isDark: isDark,
              l10n: l10n,
            ),
            const SizedBox(height: 20),

            // Stats widget
            _GlassStats(ref: ref, isDark: isDark, l10n: l10n),
            const SizedBox(height: 16),

            // Premium section
            _GlassPremiumCard(isDark: isDark, l10n: l10n),
            const SizedBox(height: 12),

            // AI usage widget
            _GlassTokenUsageWidget(ref: ref, isDark: isDark, l10n: l10n),
            const SizedBox(height: 12),

            // Language selector
            _GlassLanguageSelector(
              ref: ref,
              currentLocale: currentLocale,
              isDark: isDark,
              l10n: l10n,
            ),
            const SizedBox(height: 12),

            // Invite Friends
            _GlassInviteFriendsCard(ref: ref, isDark: isDark, l10n: l10n),
            const SizedBox(height: 16),

            // Menu items
            _GlassMenuItem(
              icon: Icons.settings_outlined,
              title: l10n.settings,
              onTap: () => context.push(AppRoutes.settings),
              isDark: isDark,
            ),
            _GlassMenuItem(
              icon: Icons.help_outline,
              title: l10n.helpAndSupport,
              onTap: () => context.push(AppRoutes.helpSupport),
              isDark: isDark,
            ),
            _GlassMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: l10n.privacyPolicy,
              onTap: () => context.push(AppRoutes.privacyPolicy),
              isDark: isDark,
            ),
            _GlassMenuItem(
              icon: Icons.description_outlined,
              title: l10n.termsOfService,
              onTap: () => context.push(AppRoutes.termsOfService),
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // Sign out button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GhostButton(
                label: l10n.signOut,
                icon: Icons.logout,
                onPressed: () => _showSignOutDialog(context, ref, l10n, isDark),
                width: double.infinity,
                color: LiquidGlassColors.sunsetRose,
              ),
            ),
            const SizedBox(height: 20),

            // App version
            _buildAppVersion(context, ref, l10n, isDark),
            const SizedBox(height: 120), // Padding for floating nav bar
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    bool isDark,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.signOut,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          l10n.signOutConfirmation,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      LiquidGlassColors.auroraIndigo,
                    ),
                  ),
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
                      backgroundColor:
                          LiquidGlassColors.sunsetRose.withAlpha(200),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: LiquidGlassColors.sunsetRose,
            ),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }

  Widget _buildAppVersion(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    bool isDark,
  ) {
    final versionAsync = ref.watch(appVersionProvider);

    return versionAsync.when(
      data: (version) => Text(
        '${l10n.appVersion} $version',
        style: TextStyle(
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: 11,
        ),
      ),
      loading: () => Text(
        '${l10n.appVersion} ...',
        style: TextStyle(
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: 11,
        ),
      ),
      error: (_, __) => Text(
        '${l10n.appVersion} 1.0.0',
        style: TextStyle(
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ============================================
// GLASS COMPONENTS
// ============================================

class _GlassProfileHeader extends StatelessWidget {
  final String userName;
  final String userEmail;
  final dynamic user;
  final bool isDark;
  final AppLocalizations l10n;

  const _GlassProfileHeader({
    required this.userName,
    required this.userEmail,
    required this.user,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Gradient avatar with glow
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LiquidGlassColors.auroraGradient,
              boxShadow: isDark
                  ? LiquidGlassColors.neonGlow(
                      LiquidGlassColors.auroraIndigo,
                      intensity: 0.4,
                      blur: 20,
                    )
                  : [
                      BoxShadow(
                        color: LiquidGlassColors.auroraIndigo.withAlpha(60),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'T',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Name and email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                if (memberSinceText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    memberSinceText,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
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
}

class _GlassStats extends StatelessWidget {
  final WidgetRef ref;
  final bool isDark;
  final AppLocalizations l10n;

  const _GlassStats({
    required this.ref,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(profileStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withAlpha(15),
                        Colors.white.withAlpha(8),
                      ]
                    : [
                        Colors.white.withAlpha(200),
                        Colors.white.withAlpha(150),
                      ],
              ),
              border: Border.all(
                width: 1.5,
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : Colors.white.withAlpha(100),
              ),
              boxShadow: LiquidGlassColors.glassShadow(isDark, elevated: true),
            ),
            child: statsAsync.when(
              loading: () => SizedBox(
                height: 60,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      LiquidGlassColors.auroraIndigo,
                    ),
                  ),
                ),
              ),
              error: (_, __) => _buildStatsRow('-', '-', '-'),
              data: (stats) => _buildStatsRow(
                '${stats.tripCount}',
                '${stats.expenseCount}',
                '${stats.countriesCount}',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(String trips, String expenses, String countries) {
    return Row(
      children: [
        Expanded(
          child: _GlassStatItem(
            icon: Icons.luggage_outlined,
            value: trips,
            label: l10n.trips,
            gradient: LiquidGlassColors.auroraGradient,
            isDark: isDark,
          ),
        ),
        Container(
          width: 1,
          height: 50,
          color:
              isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
        ),
        Expanded(
          child: _GlassStatItem(
            icon: Icons.receipt_long_outlined,
            value: expenses,
            label: l10n.expenses,
            gradient: LiquidGlassColors.oceanGradient,
            isDark: isDark,
          ),
        ),
        Container(
          width: 1,
          height: 50,
          color:
              isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(10),
        ),
        Expanded(
          child: _GlassStatItem(
            icon: Icons.public_outlined,
            value: countries,
            label: l10n.countries,
            gradient: LiquidGlassColors.sunsetGradient,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _GlassStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Gradient gradient;
  final bool isDark;

  const _GlassStatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => gradient.createShader(bounds),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _GlassPremiumCard extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;

  const _GlassPremiumCard({
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  LiquidGlassColors.auroraIndigo.withAlpha(isDark ? 30 : 20),
                  LiquidGlassColors.auroraPurple.withAlpha(isDark ? 20 : 15),
                ],
              ),
              border: Border.all(
                color: LiquidGlassColors.auroraIndigo.withAlpha(50),
              ),
            ),
            child: Row(
              children: [
                // Star icon with gradient
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LiquidGlassColors.auroraGradient,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Free Plan badge + text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withAlpha(20)
                              : Colors.black.withAlpha(10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          l10n.freePlan,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.upgradeUnlockFeatures,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                // Upgrade button
                PremiumButton.solid(
                  label: l10n.upgrade,
                  onPressed: () {
                    // TODO: Navigate to subscription screen
                  },
                  width: 90,
                  height: 38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassTokenUsageWidget extends StatelessWidget {
  final WidgetRef ref;
  final bool isDark;
  final AppLocalizations l10n;

  const _GlassTokenUsageWidget({
    required this.ref,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final tokenUsageAsync = ref.watch(tokenUsageProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? Colors.white.withAlpha(10)
                  : Colors.white.withAlpha(180),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(15)
                    : Colors.white.withAlpha(100),
              ),
            ),
            child: tokenUsageAsync.when(
              loading: () => SizedBox(
                height: 50,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      LiquidGlassColors.auroraIndigo,
                    ),
                  ),
                ),
              ),
              error: (_, __) => _buildContent(0, 10000, 'free'),
              data: (usage) => _buildContent(
                usage.tokensUsed,
                usage.dailyLimit,
                usage.planType,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(int tokensUsed, int dailyLimit, String planType) {
    final percentage =
        dailyLimit > 0 ? (tokensUsed / dailyLimit).clamp(0.0, 1.0) : 0.0;
    final creditsUsed = (tokensUsed / 100).round();
    final creditsLimit = (dailyLimit / 100).round();

    // Determine color based on usage
    Color progressColor;
    if (percentage < 0.5) {
      progressColor = LiquidGlassColors.mintEmerald;
    } else if (percentage < 0.8) {
      progressColor = LiquidGlassColors.sunsetOrange;
    } else {
      progressColor = LiquidGlassColors.sunsetRose;
    }

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
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [progressColor, progressColor.withAlpha(180)],
                ),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.aiUsageToday,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Text(
              '$creditsUsed/$creditsLimit',
              style: TextStyle(
                color: progressColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              ' ${l10n.credits}',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black45,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor:
                isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _GlassLanguageSelector extends StatelessWidget {
  final WidgetRef ref;
  final Locale currentLocale;
  final bool isDark;
  final AppLocalizations l10n;

  const _GlassLanguageSelector({
    required this.ref,
    required this.currentLocale,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final currentLanguageName =
        _getLanguageName(currentLocale.languageCode, l10n);
    final flag = AppLocales.getFlag(currentLocale.languageCode);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _showLanguageDialog(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isDark
                    ? Colors.white.withAlpha(10)
                    : Colors.white.withAlpha(180),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withAlpha(15)
                      : Colors.white.withAlpha(100),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isDark
                          ? Colors.white.withAlpha(15)
                          : Colors.black.withAlpha(10),
                    ),
                    child: Center(
                      child: Text(flag, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appLanguage,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentLanguageName,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getLanguageName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'en':
        return l10n.languageEnglish;
      case 'es':
        return l10n.languageSpanish;
      case 'fr':
        return l10n.languageFrench;
      case 'de':
        return l10n.languageGerman;
      case 'he':
        return l10n.languageHebrew;
      case 'ja':
        return l10n.languageJapanese;
      case 'zh':
        return l10n.languageChinese;
      case 'ko':
        return l10n.languageKorean;
      case 'it':
        return l10n.languageItalian;
      case 'pt':
        return l10n.languagePortuguese;
      case 'ru':
        return l10n.languageRussian;
      case 'ar':
        return l10n.languageArabic;
      default:
        return l10n.languageEnglish;
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.appLanguage,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: AppLocales.supportedLocales.length,
            itemBuilder: (context, index) {
              final locale = AppLocales.supportedLocales[index];
              final flag = AppLocales.getFlag(locale.languageCode);
              final name = _getLanguageName(locale.languageCode, l10n);
              final isSelected =
                  locale.languageCode == currentLocale.languageCode;

              return ListTile(
                dense: true,
                leading: Text(flag, style: const TextStyle(fontSize: 20)),
                title: Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check,
                        color: LiquidGlassColors.auroraIndigo,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  ref
                      .read(localeProvider.notifier)
                      .setLocaleByCode(locale.languageCode);
                  Navigator.pop(dialogContext);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassInviteFriendsCard extends StatelessWidget {
  final WidgetRef ref;
  final bool isDark;
  final AppLocalizations l10n;

  const _GlassInviteFriendsCard({
    required this.ref,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final referralAsync = ref.watch(referralStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? Colors.white.withAlpha(10)
                  : Colors.white.withAlpha(180),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(15)
                    : Colors.white.withAlpha(100),
              ),
            ),
            child: referralAsync.when(
              loading: () => SizedBox(
                height: 80,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      LiquidGlassColors.auroraIndigo,
                    ),
                  ),
                ),
              ),
              error: (_, __) => _buildContent(context, null),
              data: (stats) => _buildContent(context, stats),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReferralStats? stats) {
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LiquidGlassColors.sunsetGradient,
              ),
              child: const Icon(
                Icons.card_giftcard,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.inviteFriends,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    l10n.inviteFriendsSubtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            GlowingIconButton(
              icon: Icons.share,
              onPressed: () => _shareReferralCode(context, referralCode),
              size: 40,
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Referral code row
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    LiquidGlassColors.auroraIndigo.withAlpha(isDark ? 30 : 20),
                    LiquidGlassColors.auroraPurple.withAlpha(isDark ? 20 : 15),
                  ],
                ),
                border: Border.all(
                  color: LiquidGlassColors.auroraIndigo.withAlpha(40),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    l10n.yourReferralCode,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    referralCode,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: LiquidGlassColors.auroraIndigo,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: referralCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.copiedToClipboard),
                          backgroundColor:
                              LiquidGlassColors.mintEmerald.withAlpha(200),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.copy,
                      color: LiquidGlassColors.auroraIndigo,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Stats row (if any)
        if (referralCount > 0 || creditsEarned > 0)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 14,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.friendsInvited(referralCount.toString()),
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.stars,
                  size: 14,
                  color: LiquidGlassColors.sunsetOrange,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.creditsEarned(creditsEarned.toString()),
                  style: TextStyle(
                    color: LiquidGlassColors.sunsetOrange,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
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
      subject: 'Join me on Waylo!',
    );
  }
}

class _GlassMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDark;

  const _GlassMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isDark
                    ? Colors.white.withAlpha(8)
                    : Colors.white.withAlpha(150),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withAlpha(10)
                      : Colors.white.withAlpha(80),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isDark ? Colors.white60 : Colors.black54,
                    size: 22,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.white38 : Colors.black38,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

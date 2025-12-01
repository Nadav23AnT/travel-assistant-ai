import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../../core/design/design_system.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/trips_provider.dart';

class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(userTripsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.myTrips,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          // Join trip button
          GlowingIconButton(
            icon: Icons.group_add,
            onPressed: () => context.push(AppRoutes.joinTrip),
            size: 40,
          ),
          const SizedBox(width: 8),
          // Create trip button
          GlowingIconButton(
            icon: Icons.add,
            onPressed: () => context.push(AppRoutes.createTrip),
            size: 40,
          ),
          const SizedBox(width: 16),
        ],
      ),
      // MainScaffold provides the gradient background, so we use transparent here
      body: tripsAsync.when(
        loading: () => _buildLoadingState(context, isDark),
        error: (error, stack) => _buildErrorState(context, ref, error, isDark),
        data: (trips) {
          if (trips.isEmpty) {
            return _buildEmptyState(context, isDark, l10n);
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userTripsProvider);
            },
            color: LiquidGlassColors.auroraIndigo,
            child: CustomScrollView(
              slivers: [
                // Spacer for app bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),

                // Hero trip card (first/active trip)
                if (trips.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Consumer(
                        builder: (context, ref, _) {
                          final totalSpentAsync = ref.watch(
                            tripTotalSpentProvider(trips.first.id),
                          );
                          return PremiumTripCard(
                            trip: trips.first,
                            totalSpent: totalSpentAsync.valueOrNull,
                            onTap: () => context.push(
                              AppRoutes.tripDetail.replaceFirst(':id', trips.first.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Other trips as compact cards
                if (trips.length > 1)
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 16),
                    sliver: SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          l10n.otherTrips,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),

                if (trips.length > 1)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final trip = trips[index + 1];
                        return Consumer(
                          builder: (context, ref, _) {
                            final totalSpentAsync = ref.watch(
                              tripTotalSpentProvider(trip.id),
                            );
                            return CompactTripCard(
                              trip: trip,
                              totalSpent: totalSpentAsync.valueOrNull,
                              onTap: () => context.push(
                                AppRoutes.tripDetail.replaceFirst(':id', trip.id),
                              ),
                            );
                          },
                        );
                      },
                      childCount: trips.length - 1,
                    ),
                  ),

                // Bottom padding for floating nav bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
          );
        },
      ),
      // FAB positioned above the floating nav bar
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: PremiumButton.gradient(
          label: l10n.newTrip,
          icon: Icons.add,
          onPressed: () => context.push(AppRoutes.createTrip),
          width: 140,
          height: 52,
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isDark
                  ? LiquidGlassColors.neonGlow(
                      LiquidGlassColors.auroraIndigo,
                      intensity: 0.4,
                      blur: 24,
                    )
                  : [],
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                LiquidGlassColors.auroraIndigo,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your trips...',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon with glow
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LiquidGlassColors.auroraGradient,
                boxShadow: isDark
                    ? LiquidGlassColors.neonGlow(
                        LiquidGlassColors.auroraIndigo,
                        intensity: 0.5,
                        blur: 32,
                      )
                    : [
                        BoxShadow(
                          color: LiquidGlassColors.auroraIndigo.withAlpha(77),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: const Icon(
                Icons.luggage_outlined,
                size: 56,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.noTripsYet,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noTripsDescription,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PremiumButton.gradient(
              label: l10n.createNewTrip,
              icon: Icons.add,
              onPressed: () => context.push(AppRoutes.createTrip),
              width: 200,
            ),
            const SizedBox(height: 16),
            GhostButton(
              label: l10n.joinTrip,
              icon: Icons.group_add,
              onPressed: () => context.push(AppRoutes.joinTrip),
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : Colors.white.withAlpha(179),
                border: Border.all(
                  width: 1.5,
                  color: isDark
                      ? Colors.white.withAlpha(31)
                      : Colors.white.withAlpha(77),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: LiquidGlassColors.sunsetRose.withAlpha(51),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 40,
                      color: LiquidGlassColors.sunsetRose,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Something went wrong',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  PremiumButton.solid(
                    label: 'Try Again',
                    icon: Icons.refresh,
                    onPressed: () => ref.invalidate(userTripsProvider),
                    color: LiquidGlassColors.sunsetRose,
                    width: 160,
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

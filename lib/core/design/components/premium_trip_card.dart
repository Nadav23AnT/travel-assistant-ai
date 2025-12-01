import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../data/models/trip_model.dart';

/// Premium Trip Card - Figma-style Travel Card Design
/// Beautiful immersive hero with elegant typography and refined details
class PremiumTripCard extends StatefulWidget {
  final TripModel trip;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final double? totalSpent;

  const PremiumTripCard({
    super.key,
    required this.trip,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.totalSpent,
  });

  @override
  State<PremiumTripCard> createState() => _PremiumTripCardState();
}

class _PremiumTripCardState extends State<PremiumTripCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  double _dragOffset = 0;
  late AnimationController _shimmerController;

  static const double _cardRadius = 28.0;
  static const double _heroHeight = 180.0;
  static const double _actionButtonWidth = 70.0;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Stack(
        children: [
          // Action buttons (revealed on swipe)
          _buildActionButtons(),

          // Main card
          GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              if (_dragOffset == 0) {
                HapticFeedback.selectionClick();
                widget.onTap?.call();
              }
            },
            onTapCancel: () => setState(() => _isPressed = false),
            onHorizontalDragUpdate: _handleDragUpdate,
            onHorizontalDragEnd: _handleDragEnd,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              transform: Matrix4.identity()
                ..translate(_dragOffset)
                ..scale(_isPressed ? 0.98 : 1.0),
              child: _buildCard(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_cardRadius),
        color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
        boxShadow: [
          // Main shadow
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(100)
                : const Color(0xFF64748B).withAlpha(30),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -8,
          ),
          // Subtle inner glow
          if (!isDark)
            BoxShadow(
              color: Colors.white.withAlpha(180),
              blurRadius: 2,
              offset: const Offset(0, -1),
              spreadRadius: 0,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hero Image Section
            _buildHeroSection(isDark),

            // Info Section
            _buildInfoSection(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return SizedBox(
      height: _heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient (simulating destination image)
          _buildHeroBackground(),

          // Gradient overlay for text readability
          _buildGradientOverlay(),

          // Shimmer effect
          _buildShimmerEffect(),

          // Content on hero
          _buildHeroContent(isDark),
        ],
      ),
    );
  }

  Widget _buildHeroBackground() {
    // Create a beautiful gradient based on destination
    final gradients = _getDestinationGradient();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradients,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles/shapes
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(15),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(10),
              ),
            ),
          ),
          // Flag emoji as decorative element
          Positioned(
            right: 20,
            top: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.trip.flagEmoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getDestinationGradient() {
    // Return 3-color gradients for richer visuals
    final destination = widget.trip.destination?.toLowerCase() ?? '';

    if (destination.contains('italy') || destination.contains('rome')) {
      return [const Color(0xFF1E8449), const Color(0xFFE74C3C), const Color(0xFFE74C3C)];
    } else if (destination.contains('france') || destination.contains('paris')) {
      return [const Color(0xFF2980B9), const Color(0xFFF8F9FA), const Color(0xFFE91E63)];
    } else if (destination.contains('japan') || destination.contains('tokyo')) {
      return [const Color(0xFFEB4D4B), const Color(0xFFFEC8D8), const Color(0xFFFFB300)];
    } else if (destination.contains('spain') || destination.contains('barcelona')) {
      return [const Color(0xFFE67E22), const Color(0xFFE74C3C), const Color(0xFFC0392B)];
    } else if (destination.contains('greece') || destination.contains('athens')) {
      return [const Color(0xFF0EA5E9), const Color(0xFF38BDF8), const Color(0xFFF8FAFC)];
    } else if (destination.contains('usa') || destination.contains('america')) {
      return [const Color(0xFF3B82F6), const Color(0xFFF8FAFC), const Color(0xFFEF4444)];
    }

    // Default beautiful travel gradient (sunset/adventure)
    return [const Color(0xFF667EEA), const Color(0xFF764BA2), const Color(0xFFF093FB)];
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha(10),
            Colors.black.withAlpha(60),
            Colors.black.withAlpha(150),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2 * _shimmerController.value, -0.3),
              end: Alignment(0.0 + 2 * _shimmerController.value, 0.3),
              colors: [
                Colors.transparent,
                Colors.white.withAlpha(20),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroContent(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Status pill + Date
          Row(
            children: [
              _buildStatusPill(),
              const SizedBox(width: 10),
              if (widget.trip.startDate != null) _buildDateChip(),
              const Spacer(),
            ],
          ),

          const Spacer(),

          // Bottom: Title, location, and button
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Title and location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.trip.displayTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.1,
                        shadows: [
                          Shadow(
                            color: Color(0x80000000),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.place_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.trip.displayDestination,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withAlpha(220),
                              letterSpacing: 0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // View Trip button
              _buildViewButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill() {
    final status = _getStatusInfo();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: status.color.withAlpha(100),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip() {
    final dateFormat = DateFormat('MMM d');
    final startStr = dateFormat.format(widget.trip.startDate!);
    final endStr = widget.trip.endDate != null
        ? dateFormat.format(widget.trip.endDate!)
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(30),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withAlpha(50),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 12,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                endStr != null ? '$startStr - $endStr' : startStr,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'View',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _getDestinationGradient().first,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_forward_rounded,
            size: 16,
            color: _getDestinationGradient().first,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(bool isDark) {
    final spent = widget.totalSpent ?? 0;
    final budget = widget.trip.budget ?? 0;
    final days = widget.trip.durationDays ?? 0;
    final dailyAvg = days > 0 ? spent / days : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Duration
          _buildInfoItem(
            icon: Icons.schedule_rounded,
            value: days > 0 ? '$days' : '--',
            label: 'Days',
            color: const Color(0xFF3B82F6),
            isDark: isDark,
          ),

          _buildDivider(isDark),

          // Budget/Spent
          _buildInfoItem(
            icon: Icons.account_balance_wallet_rounded,
            value: '${widget.trip.currencySymbol}${spent.toStringAsFixed(0)}',
            label: budget > 0 ? 'of ${widget.trip.currencySymbol}${budget.toStringAsFixed(0)}' : 'Spent',
            color: const Color(0xFF10B981),
            isDark: isDark,
          ),

          _buildDivider(isDark),

          // Daily Average
          _buildInfoItem(
            icon: Icons.trending_up_rounded,
            value: '${widget.trip.currencySymbol}${dailyAvg.toStringAsFixed(0)}',
            label: 'Daily',
            color: const Color(0xFFF59E0B),
            isDark: isDark,
          ),

          _buildDivider(isDark),

          // Status/Days left
          _buildInfoItem(
            icon: Icons.flight_takeoff_rounded,
            value: _getDaysValue(),
            label: _getDaysLabel(),
            color: const Color(0xFFEC4899),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(isDark ? 40 : 25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? Colors.white.withAlpha(140)
                  : const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            isDark
                ? Colors.white.withAlpha(25)
                : const Color(0xFFE2E8F0),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: _actionButtonWidth * 2,
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onEdit?.call();
                  _resetDrag();
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.edit_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  widget.onDelete?.call();
                  _resetDrag();
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.delete_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
      _dragOffset = _dragOffset.clamp(-_actionButtonWidth * 2, 0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (velocity < -200 || _dragOffset < -_actionButtonWidth) {
      setState(() => _dragOffset = -_actionButtonWidth * 2);
      HapticFeedback.lightImpact();
    } else {
      _resetDrag();
    }
  }

  void _resetDrag() {
    setState(() => _dragOffset = 0);
  }

  String _getDaysValue() {
    final daysUntil = widget.trip.daysUntilStart;
    if (daysUntil != null && daysUntil > 0) return '$daysUntil';
    if (widget.trip.isActive) return 'Now';
    if (widget.trip.isCompleted) return '✓';
    return '--';
  }

  String _getDaysLabel() {
    final daysUntil = widget.trip.daysUntilStart;
    if (daysUntil != null && daysUntil > 0) return 'Left';
    if (widget.trip.isActive) return 'Active';
    if (widget.trip.isCompleted) return 'Done';
    return 'Plan';
  }

  ({String label, Color color}) _getStatusInfo() {
    if (widget.trip.isActive) {
      return (label: 'ACTIVE', color: const Color(0xFF10B981));
    } else if (widget.trip.isUpcoming) {
      return (label: 'UPCOMING', color: const Color(0xFF3B82F6));
    } else if (widget.trip.isCompleted) {
      return (label: 'COMPLETED', color: const Color(0xFF64748B));
    }
    return (label: 'PLANNING', color: const Color(0xFFF59E0B));
  }
}

/// Compact Trip Card for list views
class CompactTripCard extends StatefulWidget {
  final TripModel trip;
  final VoidCallback? onTap;
  final double? totalSpent;

  const CompactTripCard({
    super.key,
    required this.trip,
    this.onTap,
    this.totalSpent,
  });

  @override
  State<CompactTripCard> createState() => _CompactTripCardState();
}

class _CompactTripCardState extends State<CompactTripCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha(60)
                  : const Color(0xFF94A3B8).withAlpha(25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Colored side bar with flag
            Container(
              width: 60,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getGradient(),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(
                  widget.trip.flagEmoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.trip.displayTitle,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildChip(
                          Icons.schedule_rounded,
                          '${widget.trip.durationDays ?? 0}d',
                          isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildChip(
                          Icons.account_balance_wallet_rounded,
                          '${widget.trip.currencySymbol}${(widget.totalSpent ?? 0).toStringAsFixed(0)}',
                          isDark,
                        ),
                        const Spacer(),
                        if (widget.trip.startDate != null)
                          Text(
                            DateFormat('MMM d').format(widget.trip.startDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white.withAlpha(120)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? Colors.white.withAlpha(80)
                    : const Color(0xFFCBD5E1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withAlpha(10)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark
                ? Colors.white.withAlpha(150)
                : const Color(0xFF64748B),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withAlpha(180)
                  : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradient() {
    final destination = widget.trip.destination?.toLowerCase() ?? '';
    if (destination.contains('italy')) return [const Color(0xFF2E7D32), const Color(0xFFC62828)];
    if (destination.contains('france')) return [const Color(0xFF1565C0), const Color(0xFFE91E63)];
    if (destination.contains('japan')) return [const Color(0xFFE91E63), const Color(0xFFFFB300)];
    if (destination.contains('spain')) return [const Color(0xFFFF8F00), const Color(0xFFD32F2F)];
    return [const Color(0xFF3B82F6), const Color(0xFF8B5CF6)];
  }

  Color _getStatusColor() {
    if (widget.trip.isActive) return const Color(0xFF22C55E);
    if (widget.trip.isUpcoming) return const Color(0xFF3B82F6);
    if (widget.trip.isCompleted) return const Color(0xFF94A3B8);
    return const Color(0xFFF59E0B);
  }
}

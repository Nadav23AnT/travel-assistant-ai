import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/theme.dart';
import '../../../data/models/travel_context.dart';

/// A card displaying place recommendations with Google Maps links
class PlaceRecommendationsCard extends StatefulWidget {
  final List<PlaceRecommendation> places;
  final String? searchUrl; // "See more" link to Google Maps search
  final VoidCallback? onDismiss;

  const PlaceRecommendationsCard({
    super.key,
    required this.places,
    this.searchUrl,
    this.onDismiss,
  });

  @override
  State<PlaceRecommendationsCard> createState() => _PlaceRecommendationsCardState();
}

class _PlaceRecommendationsCardState extends State<PlaceRecommendationsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'cafe':
        return Icons.coffee;
      case 'bar':
        return Icons.local_bar;
      case 'attraction':
        return Icons.attractions;
      case 'museum':
        return Icons.museum;
      case 'temple':
        return Icons.temple_buddhist;
      case 'market':
        return Icons.store;
      case 'park':
        return Icons.park;
      case 'beach':
        return Icons.beach_access;
      case 'shopping':
        return Icons.shopping_bag;
      case 'nightlife':
        return Icons.nightlife;
      case 'activity':
        return Icons.sports;
      default:
        return Icons.place;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'restaurant':
        return Colors.orange;
      case 'cafe':
        return Colors.brown;
      case 'bar':
        return Colors.purple;
      case 'attraction':
        return AppTheme.primaryColor;
      case 'museum':
        return Colors.indigo;
      case 'temple':
        return Colors.amber;
      case 'market':
        return Colors.green;
      case 'park':
        return Colors.lightGreen;
      case 'beach':
        return Colors.cyan;
      case 'shopping':
        return Colors.pink;
      case 'nightlife':
        return Colors.deepPurple;
      case 'activity':
        return Colors.red;
      default:
        return AppTheme.textSecondary;
    }
  }

  Future<void> _openGoogleMaps(PlaceRecommendation place) async {
    final url = Uri.parse(place.mapsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openDirections(PlaceRecommendation place) async {
    final url = Uri.parse(place.directionsUrl());
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openSearchUrl() async {
    if (widget.searchUrl == null) return;
    final url = Uri.parse(widget.searchUrl!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.places.isEmpty) return const SizedBox.shrink();

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.successColor.withAlpha(77),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.successColor.withAlpha(26),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withAlpha(30),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.place,
                    color: AppTheme.successColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recommended Places',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.places.length} places',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),

            // Place List
            ...widget.places.asMap().entries.map((entry) {
              final index = entry.key;
              final place = entry.value;
              final isLast = index == widget.places.length - 1;

              return _buildPlaceItem(place, isLast);
            }),

            // "See more" button
            if (widget.searchUrl != null)
              InkWell(
                onTap: () => _openSearchUrl(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(15),
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.explore,
                        size: 18,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'See more on Google Maps',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppTheme.textHint,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap a place to view on Google Maps',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textHint,
                          ),
                    ),
                  ),
                  if (widget.onDismiss != null)
                    TextButton(
                      onPressed: widget.onDismiss,
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text('Dismiss'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceItem(PlaceRecommendation place, bool isLast) {
    final categoryColor = _getCategoryColor(place.category);

    return InkWell(
      onTap: () => _openGoogleMaps(place),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: categoryColor.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getCategoryIcon(place.category),
                color: categoryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Place Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      if (place.priceLevel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            place.priceLevel!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ),
                    ],
                  ),
                  if (place.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      place.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),

                  // Tags and Info Row
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (place.bestTimeToVisit != null)
                        _buildInfoChip(
                          Icons.schedule,
                          place.bestTimeToVisit!,
                        ),
                      if (place.estimatedDuration != null)
                        _buildInfoChip(
                          Icons.timer_outlined,
                          place.estimatedDuration!,
                        ),
                      if (place.address != null)
                        _buildInfoChip(
                          Icons.location_on_outlined,
                          place.address!,
                          maxWidth: 120,
                        ),
                    ],
                  ),

                  // Action Buttons
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.map_outlined,
                        label: 'View Map',
                        onTap: () => _openGoogleMaps(place),
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.directions,
                        label: 'Directions',
                        onTap: () => _openDirections(place),
                        color: AppTheme.successColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {double? maxWidth}) {
    return Container(
      constraints: maxWidth != null ? BoxConstraints(maxWidth: maxWidth) : null,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

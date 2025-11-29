import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/trip_member_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/trip_sharing_provider.dart';

/// Card showing trip members with avatars
class TripMembersCard extends ConsumerWidget {
  final String tripId;
  final bool isOwner;
  final VoidCallback? onShareTap;
  final Function(TripMemberModel)? onMemberTap;

  const TripMembersCard({
    super.key,
    required this.tripId,
    required this.isOwner,
    this.onShareTap,
    this.onMemberTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(tripMembersProvider(tripId));
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.tripMembers,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isOwner)
                  IconButton(
                    icon: const Icon(Icons.person_add_outlined),
                    onPressed: onShareTap,
                    tooltip: l10n.inviteFriends,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Members list
            membersAsync.when(
              data: (members) {
                if (members.isEmpty) {
                  return _buildEmptyState(context, l10n);
                }
                return _buildMembersList(context, members, theme);
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Error loading members',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),

            // Share button (always show for owner)
            if (isOwner) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onShareTap,
                  icon: const Icon(Icons.share),
                  label: Text(l10n.shareInviteCode),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        isOwner ? l10n.inviteFriendsToTrip : l10n.noOtherMembers,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildMembersList(BuildContext context, List<TripMemberModel> members, ThemeData theme) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return _buildMemberAvatar(context, member, theme);
        },
      ),
    );
  }

  Widget _buildMemberAvatar(BuildContext context, TripMemberModel member, ThemeData theme) {
    return GestureDetector(
      onTap: () => onMemberTap?.call(member),
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                      ? NetworkImage(member.avatarUrl!)
                      : null,
                  child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                      ? Text(
                          member.initials,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                // Owner badge
                if (member.isOwner)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star,
                        size: 12,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 56,
              child: Text(
                member.displayName.split(' ').first, // First name only
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (member.isOwner)
              Text(
                AppLocalizations.of(context)!.tripOwner,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

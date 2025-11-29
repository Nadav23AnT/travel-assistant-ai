import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/trip_sharing_service.dart';
import '../../providers/trip_sharing_provider.dart';

/// Bottom sheet for sharing trip invite code
class ShareTripSheet extends ConsumerWidget {
  final String tripId;
  final String tripTitle;

  const ShareTripSheet({
    super.key,
    required this.tripId,
    required this.tripTitle,
  });

  static Future<void> show(BuildContext context, {required String tripId, required String tripTitle}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ShareTripSheet(tripId: tripId, tripTitle: tripTitle),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inviteCodeAsync = ref.watch(tripInviteCodeProvider(tripId));
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Text(
            l10n.inviteFriends,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.shareCodeDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Invite code display
          inviteCodeAsync.when(
            data: (code) {
              if (code == null) {
                return Text(
                  'Error generating code',
                  style: TextStyle(color: theme.colorScheme.error),
                );
              }
              return _buildCodeDisplay(context, code, theme, l10n, ref);
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
            error: (e, _) => Text(
              'Error: $e',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCodeDisplay(
    BuildContext context,
    String code,
    ThemeData theme,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    return Column(
      children: [
        // Code box
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                code,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => _copyCode(context, code, l10n),
                tooltip: l10n.copyCode,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Share button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _shareCode(context, code, ref),
            icon: const Icon(Icons.share),
            label: Text(l10n.shareInviteCode),
          ),
        ),

        const SizedBox(height: 12),

        // Info text
        Text(
          l10n.shareCodeInfo,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _copyCode(BuildContext context, String code, AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.codeCopied),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareCode(BuildContext context, String code, WidgetRef ref) {
    final service = ref.read(tripSharingServiceProvider);
    final message = service.getShareMessage(code, tripTitle);
    Share.share(message);
  }
}

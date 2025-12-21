import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../providers/trip_sharing_provider.dart';
import '../../providers/trips_provider.dart';

/// Screen for joining a trip via invite code
class JoinTripScreen extends ConsumerStatefulWidget {
  const JoinTripScreen({super.key});

  @override
  ConsumerState<JoinTripScreen> createState() => _JoinTripScreenState();
}

class _JoinTripScreenState extends ConsumerState<JoinTripScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinTrip() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final code = _codeController.text.trim().toUpperCase();
    final result = await ref.read(joinTripNotifierProvider.notifier).joinTrip(code);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      // Refresh trips list
      ref.invalidate(userTripsProvider);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.joinTripSuccess),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to the trip - first go to trips, then push trip detail
      if (result.tripId != null) {
        // Go to trips first to restore proper navigation stack
        context.go('/trips');
        // Then push the trip detail on top
        context.push('/trips/${result.tripId}');
      } else {
        // Safe pop with fallback
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/trips');
        }
      }
    } else {
      setState(() {
        _errorMessage = _translateError(result.error ?? 'Unknown error');
      });
    }
  }

  String _translateError(String error) {
    final l10n = AppLocalizations.of(context)!;

    if (error.contains('Invalid invite code')) {
      return l10n.invalidInviteCode;
    } else if (error.contains('owner')) {
      return l10n.cannotJoinOwnTrip;
    } else if (error.contains('Already a member')) {
      return l10n.alreadyMember;
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.joinTrip),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Icon(
                  Icons.group_add,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  l10n.joinTripTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.joinTripDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Code input
                TextFormField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    letterSpacing: 4,
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.inviteCode,
                    hintText: 'XXXXXXXX',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.key),
                  ),
                  maxLength: 8,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.enterInviteCode;
                    }
                    if (value.length < 8) {
                      return l10n.invalidCodeLength;
                    }
                    return null;
                  },
                ),

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Join button
                FilledButton.icon(
                  onPressed: _isLoading ? null : _joinTrip,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login),
                  label: Text(_isLoading ? l10n.joining : l10n.joinTrip),
                ),

                const Spacer(),

                // Help text
                Text(
                  l10n.joinTripHelp,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

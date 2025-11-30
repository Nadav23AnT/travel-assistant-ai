import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'app_exception.dart';
import 'error_messages.dart';

/// UI utilities for displaying errors
class ErrorUI {
  /// Show an error snackbar with optional retry action
  static void showSnackBar(
    BuildContext context,
    AppException error, {
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    final l10n = AppLocalizations.of(context);
    final message = ErrorMessages.getMessage(error, l10n);
    final showRetry = onRetry != null && ErrorMessages.shouldShowRetry(error);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(error.type),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(error.type),
        duration: showRetry ? const Duration(seconds: 8) : duration,
        action: showRetry
            ? SnackBarAction(
                label: l10n?.tryAgain ?? 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show a simple error message snackbar (for non-AppException errors)
  static void showErrorMessage(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show an error dialog for critical errors
  static Future<void> showErrorDialog(
    BuildContext context,
    AppException error, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    final l10n = AppLocalizations.of(context);
    final message = ErrorMessages.getMessage(error, l10n);
    final title = ErrorMessages.getTitle(error);
    final showRetry = onRetry != null && ErrorMessages.shouldShowRetry(error);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          _getErrorIcon(error.type),
          color: _getErrorColor(error.type),
          size: 48,
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          if (showRetry)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: Text(l10n?.tryAgain ?? 'Try Again'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
            child: Text(l10n?.cancel ?? 'OK'),
          ),
        ],
      ),
    );
  }

  /// Get appropriate icon for error type
  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
      case ErrorType.timeout:
      case ErrorType.noConnection:
        return Icons.wifi_off;
      case ErrorType.serverError:
        return Icons.cloud_off;
      case ErrorType.authInvalidCredentials:
      case ErrorType.authSessionExpired:
      case ErrorType.authEmailNotVerified:
        return Icons.lock_outline;
      case ErrorType.tokenLimitExceeded:
      case ErrorType.quotaExceeded:
        return Icons.hourglass_empty;
      case ErrorType.forbidden:
      case ErrorType.unauthorized:
        return Icons.block;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.validation:
        return Icons.warning_amber;
      default:
        return Icons.error_outline;
    }
  }

  /// Get appropriate color for error type
  static Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
      case ErrorType.timeout:
      case ErrorType.noConnection:
        return Colors.orange.shade700;
      case ErrorType.tokenLimitExceeded:
      case ErrorType.quotaExceeded:
        return Colors.purple.shade700;
      case ErrorType.authSessionExpired:
        return Colors.blue.shade700;
      case ErrorType.validation:
        return Colors.amber.shade700;
      default:
        return Colors.red.shade700;
    }
  }
}

/// Widget to display error state with retry option
class ErrorStateWidget extends StatelessWidget {
  final AppException? error;
  final String? message;
  final VoidCallback? onRetry;
  final bool compact;

  const ErrorStateWidget({
    super.key,
    this.error,
    this.message,
    this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final displayMessage = error != null
        ? ErrorMessages.getMessage(error!, l10n)
        : message ?? 'Something went wrong';
    final showRetry = onRetry != null &&
        (error == null || ErrorMessages.shouldShowRetry(error!));

    if (compact) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              error != null ? ErrorUI._getErrorIcon(error!.type) : Icons.error_outline,
              color: theme.colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                displayMessage,
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
            if (showRetry) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onRetry,
                child: Text(l10n?.tryAgain ?? 'Retry'),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              error != null ? ErrorUI._getErrorIcon(error!.type) : Icons.error_outline,
              color: theme.colorScheme.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              error != null ? ErrorMessages.getTitle(error!) : 'Error',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              displayMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (showRetry) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n?.tryAgain ?? 'Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget wrapper that handles loading, error, and data states
class AsyncStateWidget<T> extends StatelessWidget {
  final T? data;
  final bool isLoading;
  final AppException? error;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;
  final Widget? loadingWidget;
  final Widget? emptyWidget;

  const AsyncStateWidget({
    super.key,
    required this.data,
    required this.isLoading,
    required this.error,
    required this.builder,
    this.onRetry,
    this.loadingWidget,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && data == null) {
      return loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    if (error != null && data == null) {
      return ErrorStateWidget(
        error: error,
        onRetry: onRetry,
      );
    }

    if (data == null) {
      return emptyWidget ?? const SizedBox.shrink();
    }

    return builder(data as T);
  }
}

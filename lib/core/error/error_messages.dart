import '../../l10n/app_localizations.dart';
import 'app_exception.dart';

/// Provides user-friendly error messages based on error type
/// Supports localization through AppLocalizations
class ErrorMessages {
  /// Get a user-friendly message for an error
  static String getMessage(AppException error, [AppLocalizations? l10n]) {
    // Use localized messages if available
    if (l10n != null) {
      return _getLocalizedMessage(error, l10n);
    }

    // Fallback to English messages
    return _getEnglishMessage(error);
  }

  /// Get localized error message
  static String _getLocalizedMessage(AppException error, AppLocalizations l10n) {
    switch (error.type) {
      // Network errors
      case ErrorType.network:
        return l10n.errorNetwork;
      case ErrorType.timeout:
        return l10n.errorTimeout;
      case ErrorType.noConnection:
        return l10n.errorNoConnection;

      // Server errors
      case ErrorType.serverError:
        return l10n.errorServer;
      case ErrorType.rateLimited:
        return l10n.errorRateLimited;

      // Auth errors
      case ErrorType.authInvalidCredentials:
        return l10n.errorInvalidCredentials;
      case ErrorType.authSessionExpired:
        return l10n.errorSessionExpired;
      case ErrorType.authEmailNotVerified:
        return l10n.errorEmailNotVerified;

      // Quota errors
      case ErrorType.tokenLimitExceeded:
        return l10n.errorTokenLimit;

      // Permission errors
      case ErrorType.forbidden:
        return l10n.errorForbidden;
      case ErrorType.unauthorized:
        return l10n.errorUnauthorized;

      // Not found
      case ErrorType.notFound:
        return l10n.errorNotFound;

      // Validation
      case ErrorType.validation:
        return error.message; // Use specific validation message

      // Default
      default:
        return l10n.errorGeneric;
    }
  }

  /// Get English fallback message
  static String _getEnglishMessage(AppException error) {
    switch (error.type) {
      // Network errors
      case ErrorType.network:
        return 'Network error. Please check your connection.';
      case ErrorType.timeout:
        return 'Request timed out. Please try again.';
      case ErrorType.noConnection:
        return 'No internet connection. Please check your network.';

      // Server errors
      case ErrorType.serverError:
        return 'Server error. Please try again later.';
      case ErrorType.rateLimited:
        return 'Too many requests. Please wait a moment.';

      // Auth errors
      case ErrorType.authInvalidCredentials:
        return 'Invalid email or password.';
      case ErrorType.authSessionExpired:
        return 'Your session has expired. Please sign in again.';
      case ErrorType.authEmailNotVerified:
        return 'Please verify your email address.';
      case ErrorType.authAccountDisabled:
        return 'Your account has been disabled.';

      // Quota errors
      case ErrorType.tokenLimitExceeded:
        return 'You have reached your daily AI usage limit.';
      case ErrorType.quotaExceeded:
        return 'Usage limit exceeded. Please try again later.';

      // Permission errors
      case ErrorType.forbidden:
        return 'You don\'t have permission to do this.';
      case ErrorType.unauthorized:
        return 'Please sign in to continue.';

      // Not found
      case ErrorType.notFound:
      case ErrorType.resourceNotFound:
        return 'The requested item was not found.';

      // Data errors
      case ErrorType.parseError:
        return 'Error processing data. Please try again.';
      case ErrorType.cacheError:
        return 'Error loading cached data.';
      case ErrorType.storageError:
        return 'Error saving data. Please try again.';

      // Validation - use the specific message
      case ErrorType.validation:
        return error.message;

      // Bad request
      case ErrorType.badRequest:
        return 'Invalid request. Please check your input.';

      // Default
      case ErrorType.unknown:
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Get a short title for the error (for dialogs/alerts)
  static String getTitle(AppException error) {
    switch (error.type) {
      case ErrorType.network:
      case ErrorType.timeout:
      case ErrorType.noConnection:
        return 'Connection Error';
      case ErrorType.serverError:
        return 'Server Error';
      case ErrorType.authInvalidCredentials:
      case ErrorType.authSessionExpired:
      case ErrorType.authEmailNotVerified:
        return 'Authentication Error';
      case ErrorType.tokenLimitExceeded:
      case ErrorType.quotaExceeded:
        return 'Limit Reached';
      case ErrorType.forbidden:
      case ErrorType.unauthorized:
        return 'Access Denied';
      case ErrorType.validation:
        return 'Validation Error';
      default:
        return 'Error';
    }
  }

  /// Check if error should show retry option
  static bool shouldShowRetry(AppException error) {
    return error.isRecoverable &&
           (error.type == ErrorType.network ||
            error.type == ErrorType.timeout ||
            error.type == ErrorType.noConnection ||
            error.type == ErrorType.serverError ||
            error.type == ErrorType.rateLimited);
  }
}

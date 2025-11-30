/// Base exception class for all app exceptions
/// Provides a unified structure for error handling across the app
class AppException implements Exception {
  final String message;
  final String? code;
  final ErrorType type;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final bool isRecoverable;

  const AppException({
    required this.message,
    this.code,
    this.type = ErrorType.unknown,
    this.originalError,
    this.stackTrace,
    this.isRecoverable = true,
  });

  @override
  String toString() => 'AppException($type): $message${code != null ? ' [$code]' : ''}';

  /// Create from any exception
  factory AppException.from(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppException) return error;

    return AppException(
      message: error.toString(),
      type: ErrorType.unknown,
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

/// Categorization of error types
enum ErrorType {
  // Network errors
  network,
  timeout,
  noConnection,

  // API errors
  serverError,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  rateLimited,

  // Auth errors
  authInvalidCredentials,
  authSessionExpired,
  authEmailNotVerified,
  authAccountDisabled,

  // Validation errors
  validation,

  // Resource errors
  tokenLimitExceeded,
  quotaExceeded,
  resourceNotFound,

  // Data errors
  parseError,
  cacheError,
  storageError,

  // Unknown
  unknown,
}

/// Network-specific exception
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException({
    required String message,
    String? code,
    ErrorType type = ErrorType.network,
    this.statusCode,
    dynamic originalError,
    StackTrace? stackTrace,
    bool isRecoverable = true,
  }) : super(
          message: message,
          code: code,
          type: type,
          originalError: originalError,
          stackTrace: stackTrace,
          isRecoverable: isRecoverable,
        );

  factory NetworkException.noConnection() => const NetworkException(
        message: 'No internet connection',
        code: 'NO_CONNECTION',
        type: ErrorType.noConnection,
      );

  factory NetworkException.timeout() => const NetworkException(
        message: 'Request timed out',
        code: 'TIMEOUT',
        type: ErrorType.timeout,
      );

  factory NetworkException.serverError([int? statusCode]) => NetworkException(
        message: 'Server error occurred',
        code: 'SERVER_ERROR',
        statusCode: statusCode,
        type: ErrorType.serverError,
      );

  factory NetworkException.fromStatusCode(int statusCode, [String? message]) {
    switch (statusCode) {
      case 400:
        return NetworkException(
          message: message ?? 'Bad request',
          code: 'BAD_REQUEST',
          statusCode: statusCode,
          type: ErrorType.badRequest,
        );
      case 401:
        return NetworkException(
          message: message ?? 'Unauthorized',
          code: 'UNAUTHORIZED',
          statusCode: statusCode,
          type: ErrorType.unauthorized,
          isRecoverable: false,
        );
      case 403:
        return NetworkException(
          message: message ?? 'Access forbidden',
          code: 'FORBIDDEN',
          statusCode: statusCode,
          type: ErrorType.forbidden,
          isRecoverable: false,
        );
      case 404:
        return NetworkException(
          message: message ?? 'Resource not found',
          code: 'NOT_FOUND',
          statusCode: statusCode,
          type: ErrorType.notFound,
        );
      case 429:
        return NetworkException(
          message: message ?? 'Too many requests',
          code: 'RATE_LIMITED',
          statusCode: statusCode,
          type: ErrorType.rateLimited,
        );
      default:
        if (statusCode >= 500) {
          return NetworkException.serverError(statusCode);
        }
        return NetworkException(
          message: message ?? 'Request failed',
          code: 'HTTP_$statusCode',
          statusCode: statusCode,
        );
    }
  }
}

/// Authentication-specific exception (renamed to avoid conflict with Supabase)
class AppAuthException extends AppException {
  const AppAuthException({
    required String message,
    String? code,
    ErrorType type = ErrorType.authInvalidCredentials,
    dynamic originalError,
    StackTrace? stackTrace,
    bool isRecoverable = false,
  }) : super(
          message: message,
          code: code,
          type: type,
          originalError: originalError,
          stackTrace: stackTrace,
          isRecoverable: isRecoverable,
        );

  factory AppAuthException.invalidCredentials() => const AppAuthException(
        message: 'Invalid email or password',
        code: 'INVALID_CREDENTIALS',
        type: ErrorType.authInvalidCredentials,
      );

  factory AppAuthException.sessionExpired() => const AppAuthException(
        message: 'Your session has expired. Please sign in again.',
        code: 'SESSION_EXPIRED',
        type: ErrorType.authSessionExpired,
      );

  factory AppAuthException.emailNotVerified() => const AppAuthException(
        message: 'Please verify your email address',
        code: 'EMAIL_NOT_VERIFIED',
        type: ErrorType.authEmailNotVerified,
        isRecoverable: true,
      );
}

/// Token/quota-specific exception
class QuotaException extends AppException {
  final int? used;
  final int? limit;

  const QuotaException({
    required String message,
    String? code,
    this.used,
    this.limit,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          type: ErrorType.tokenLimitExceeded,
          originalError: originalError,
          stackTrace: stackTrace,
          isRecoverable: false,
        );

  factory QuotaException.tokenLimitExceeded({int? used, int? limit}) =>
      QuotaException(
        message: 'You have reached your AI usage limit for today',
        code: 'TOKEN_LIMIT',
        used: used,
        limit: limit,
      );
}

/// Validation exception
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required String message,
    String? code,
    this.fieldErrors,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          type: ErrorType.validation,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  factory ValidationException.field(String field, String message) =>
      ValidationException(
        message: message,
        code: 'VALIDATION_ERROR',
        fieldErrors: {field: message},
      );
}

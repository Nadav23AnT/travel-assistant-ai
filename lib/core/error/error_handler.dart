import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'app_exception.dart';

/// Centralized error handler for the app
/// Transforms various exceptions into AppException types
class ErrorHandler {
  /// Transform any error into an AppException
  static AppException handle(dynamic error, [StackTrace? stackTrace]) {
    debugPrint('ErrorHandler.handle: ${error.runtimeType} - $error');

    if (error is AppException) {
      return error;
    }

    // Dio exceptions (network)
    if (error is DioException) {
      return _handleDioException(error);
    }

    // Supabase exceptions
    if (error is supabase.AuthException) {
      return _handleSupabaseAuthException(error);
    }
    if (error is supabase.PostgrestException) {
      return _handlePostgrestException(error);
    }

    // Socket/Network exceptions
    if (error is SocketException) {
      return NetworkException.noConnection();
    }
    if (error is TimeoutException) {
      return NetworkException.timeout();
    }

    // Format exceptions
    if (error is FormatException) {
      return AppException(
        message: 'Invalid data format',
        type: ErrorType.parseError,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Default fallback
    return AppException(
      message: error.toString(),
      type: ErrorType.unknown,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Handle Dio (HTTP) exceptions
  static AppException _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException.timeout();

      case DioExceptionType.connectionError:
        return NetworkException.noConnection();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String? message;

        // Try to extract error message from response
        if (data is Map) {
          message = data['error']?.toString() ??
                   data['message']?.toString() ??
                   data['error_description']?.toString();
        }

        if (statusCode != null) {
          return NetworkException.fromStatusCode(statusCode, message);
        }
        return NetworkException(
          message: message ?? 'Request failed',
          originalError: error,
        );

      case DioExceptionType.cancel:
        return const AppException(
          message: 'Request was cancelled',
          type: ErrorType.network,
        );

      default:
        return NetworkException(
          message: error.message ?? 'Network error occurred',
          originalError: error,
        );
    }
  }

  /// Handle Supabase Auth exceptions
  static AppException _handleSupabaseAuthException(supabase.AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login') || message.contains('invalid credentials')) {
      return const AppException(
        message: 'Invalid email or password',
        code: 'INVALID_CREDENTIALS',
        type: ErrorType.authInvalidCredentials,
        isRecoverable: false,
      );
    }

    if (message.contains('email not confirmed')) {
      return const AppException(
        message: 'Please verify your email address',
        code: 'EMAIL_NOT_VERIFIED',
        type: ErrorType.authEmailNotVerified,
        isRecoverable: true,
      );
    }

    if (message.contains('session') || message.contains('expired') || message.contains('refresh')) {
      return const AppException(
        message: 'Your session has expired. Please sign in again.',
        code: 'SESSION_EXPIRED',
        type: ErrorType.authSessionExpired,
        isRecoverable: false,
      );
    }

    if (message.contains('already registered') || message.contains('already exists')) {
      return const AppException(
        message: 'An account with this email already exists',
        code: 'EMAIL_EXISTS',
        type: ErrorType.validation,
        isRecoverable: true,
      );
    }

    return AppException(
      message: error.message,
      type: ErrorType.unknown,
      originalError: error,
    );
  }

  /// Handle Supabase Postgrest exceptions
  static AppException _handlePostgrestException(supabase.PostgrestException error) {
    final code = error.code;

    // Row level security violation
    if (code == '42501' || error.message.contains('policy')) {
      return const AppException(
        message: 'You do not have permission to perform this action',
        code: 'PERMISSION_DENIED',
        type: ErrorType.forbidden,
        isRecoverable: false,
      );
    }

    // Unique constraint violation
    if (code == '23505') {
      return const AppException(
        message: 'This item already exists',
        code: 'DUPLICATE',
        type: ErrorType.validation,
      );
    }

    // Foreign key violation
    if (code == '23503') {
      return const AppException(
        message: 'Referenced item not found',
        code: 'NOT_FOUND',
        type: ErrorType.notFound,
      );
    }

    return AppException(
      message: error.message,
      code: code,
      type: ErrorType.unknown,
      originalError: error,
    );
  }

  /// Execute an async function with error handling
  static Future<T> runAsync<T>(
    Future<T> Function() fn, {
    T Function(AppException error)? onError,
  }) async {
    try {
      return await fn();
    } catch (e, stackTrace) {
      final appError = handle(e, stackTrace);
      if (onError != null) {
        return onError(appError);
      }
      throw appError;
    }
  }

  /// Execute a sync function with error handling
  static T run<T>(
    T Function() fn, {
    T Function(AppException error)? onError,
  }) {
    try {
      return fn();
    } catch (e, stackTrace) {
      final appError = handle(e, stackTrace);
      if (onError != null) {
        return onError(appError);
      }
      throw appError;
    }
  }
}

/// Extension to easily convert errors to AppException
extension ErrorExtension on Object {
  AppException toAppException([StackTrace? stackTrace]) {
    return ErrorHandler.handle(this, stackTrace);
  }
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../error/app_exception.dart';
import '../error/error_handler.dart';

/// Configuration for retry behavior
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final bool Function(AppException)? shouldRetry;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.shouldRetry,
  });

  /// Default config for network operations
  static const network = RetryConfig(
    maxAttempts: 3,
    initialDelay: Duration(milliseconds: 500),
    maxDelay: Duration(seconds: 10),
  );

  /// Config for AI/API calls with longer delays
  static const api = RetryConfig(
    maxAttempts: 2,
    initialDelay: Duration(seconds: 1),
    maxDelay: Duration(seconds: 30),
  );

  /// No retry - just execute once
  static const none = RetryConfig(maxAttempts: 1);
}

/// Handler for retrying failed operations with exponential backoff
class RetryHandler {
  /// Execute a function with retry logic
  static Future<T> run<T>(
    Future<T> Function() fn, {
    RetryConfig config = RetryConfig.network,
    void Function(AppException error, int attempt)? onRetry,
  }) async {
    int attempt = 0;
    Duration delay = config.initialDelay;

    while (true) {
      attempt++;
      try {
        return await fn();
      } catch (e, stackTrace) {
        final error = ErrorHandler.handle(e, stackTrace);

        // Check if we should retry
        if (attempt >= config.maxAttempts || !_shouldRetry(error, config)) {
          throw error;
        }

        // Notify about retry
        onRetry?.call(error, attempt);
        debugPrint('Retry attempt $attempt/${config.maxAttempts} after ${delay.inMilliseconds}ms');

        // Wait before retrying
        await Future.delayed(delay);

        // Calculate next delay with jitter
        final jitter = Random().nextDouble() * 0.3; // 0-30% jitter
        delay = Duration(
          milliseconds: min(
            (delay.inMilliseconds * config.backoffMultiplier * (1 + jitter)).toInt(),
            config.maxDelay.inMilliseconds,
          ),
        );
      }
    }
  }

  /// Determine if an error should be retried
  static bool _shouldRetry(AppException error, RetryConfig config) {
    // Use custom retry logic if provided
    if (config.shouldRetry != null) {
      return config.shouldRetry!(error);
    }

    // Default retry logic - only retry transient errors
    switch (error.type) {
      case ErrorType.network:
      case ErrorType.timeout:
      case ErrorType.noConnection:
      case ErrorType.serverError:
        return true;
      case ErrorType.rateLimited:
        // Rate limiting should have longer delays
        return true;
      default:
        // Don't retry auth errors, validation errors, etc.
        return false;
    }
  }

  /// Execute with single retry on transient failure
  static Future<T> withSingleRetry<T>(
    Future<T> Function() fn, {
    Duration delay = const Duration(seconds: 1),
  }) {
    return run(
      fn,
      config: RetryConfig(
        maxAttempts: 2,
        initialDelay: delay,
      ),
    );
  }
}

/// Extension to add retry capability to futures
extension RetryFutureExtension<T> on Future<T> Function() {
  /// Execute this function with retry logic
  Future<T> withRetry({
    RetryConfig config = RetryConfig.network,
    void Function(AppException error, int attempt)? onRetry,
  }) {
    return RetryHandler.run(this, config: config, onRetry: onRetry);
  }
}

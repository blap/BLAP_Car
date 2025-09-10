import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class ErrorHandlingService {
  static final ErrorHandlingService _instance = ErrorHandlingService._internal();
  factory ErrorHandlingService() => _instance;
  ErrorHandlingService._internal();

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: false,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Fixed deprecated member
    ),
  );

  // Handle and log errors
  void handleError(Object error, [StackTrace? stackTrace, String? context]) {
    final errorMessage = error.toString();
    final errorContext = context ?? 'Unknown context';
    
    // Log the error
    if (stackTrace != null) {
      _logger.e('Error in $errorContext: $errorMessage\nStack trace: $stackTrace');
    } else {
      _logger.e('Error in $errorContext: $errorMessage');
    }
    
    // In production, you might want to send this to a remote logging service
    if (kReleaseMode) {
      // Send to remote logging service
      _sendToRemoteLoggingService(errorMessage, stackTrace, errorContext);
    }
  }

  // Handle async errors
  void handleAsyncError(Object error, StackTrace stackTrace, [String? context]) {
    handleError(error, stackTrace, context);
  }

  // Handle Flutter framework errors
  void handleFlutterError(FlutterErrorDetails details) {
    final errorMessage = details.exception.toString();
    final context = details.context?.toString() ?? 'Unknown Flutter context';
    
    if (details.stack != null) {
      _logger.e('Flutter Error in $context: $errorMessage\nStack trace: ${details.stack}');
    } else {
      _logger.e('Flutter Error in $context: $errorMessage');
    }
    
    if (kReleaseMode) {
      _sendToRemoteLoggingService(errorMessage, details.stack, context);
    }
  }

  // Handle zone errors
  void handleZoneError(Object error, StackTrace stackTrace) {
    handleError(error, stackTrace, 'Zone error');
  }

  // Send error to remote logging service (placeholder)
  void _sendToRemoteLoggingService(String message, StackTrace? stackTrace, String context) {
    // In a real implementation, this would send to a service like Sentry, Crashlytics, etc.
    // For now, we'll just print to console
    debugPrint('REMOTE LOG: Error in $context: $message');
    if (stackTrace != null) {
      debugPrint('STACK TRACE: $stackTrace');
    }
  }

  // Wrap a function with error handling
  T safeCall<T>(T Function() function, [T Function(Object error, StackTrace stackTrace)? onError]) {
    try {
      return function();
    } catch (error, stackTrace) {
      handleError(error, stackTrace, 'safeCall');
      if (onError != null) {
        return onError(error, stackTrace);
      }
      return _getDefaultReturnValue<T>();
    }
  }

  // Wrap an async function with error handling
  Future<T> safeAsyncCall<T>(Future<T> Function() function, [Future<T> Function(Object error, StackTrace stackTrace)? onError]) async {
    try {
      return await function();
    } catch (error, stackTrace) {
      handleError(error, stackTrace, 'safeAsyncCall');
      if (onError != null) {
        return await onError(error, stackTrace);
      }
      return _getDefaultReturnValue<T>();
    }
  }

  // Get default return value for a type
  T _getDefaultReturnValue<T>() {
    // This is a simple implementation - in practice, you might want more sophisticated logic
    if (T == String) {
      return '' as T;
    } else if (T == int) {
      return 0 as T;
    } else if (T == double) {
      return 0.0 as T;
    } else if (T == bool) {
      return false as T;
    } else if (T == List) {
      return [] as T;
    } else if (T == Map) {
      return {} as T;
    }
    return null as T;
  }

  // Create a zone with error handling
  R runZoned<R>(R Function() body, {Function? onError}) {
    return Zone.current.fork(
      specification: ZoneSpecification(
        handleUncaughtError: (Zone self, ZoneDelegate parent, Zone zone, Object error, StackTrace stackTrace) {
          handleZoneError(error, stackTrace);
          if (onError != null) {
            onError();
          }
        },
      ),
    ).run(body);
  }

  // Log info messages
  void logInfo(String message, [Object? object]) {
    if (object != null) {
      _logger.i('$message: $object');
    } else {
      _logger.i(message);
    }
  }

  // Log warning messages
  void logWarning(String message, [Object? object]) {
    if (object != null) {
      _logger.w('$message: $object');
    } else {
      _logger.w(message);
    }
  }

  // Log debug messages
  void logDebug(String message, [Object? object]) {
    if (object != null) {
      _logger.d('$message: $object');
    } else {
      _logger.d(message);
    }
  }

  // Set up global error handling
  void setupGlobalErrorHandling() {
    // Handle Flutter framework errors
    FlutterError.onError = handleFlutterError;
    
    // Handle async errors
    PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
      handleAsyncError(error, stackTrace);
      return true; // Return true to indicate we've handled the error
    };
  }
}
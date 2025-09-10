import 'package:flutter/foundation.dart';
import 'package:blap_car/services/error_handling_service.dart';

/// Base state class for all providers
abstract class BaseState {
  const BaseState();
}

/// Initial state
class InitialState extends BaseState {
  const InitialState();
}

/// Loading state
class LoadingState extends BaseState {
  final String? message;
  const LoadingState({this.message});
}

/// Success state with data
class SuccessState<T> extends BaseState {
  final T data;
  const SuccessState(this.data);
}

/// Error state
class ErrorState extends BaseState {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  
  const ErrorState(this.message, {this.error, this.stackTrace});
}

/// Base provider class with improved state management
class BaseProvider extends ChangeNotifier {
  final ErrorHandlingService _errorHandlingService = ErrorHandlingService();
  
  BaseState _state = const InitialState();
  BaseState get state => _state;
  
  bool get isLoading => _state is LoadingState;
  bool get hasError => _state is ErrorState;
  bool get isSuccess => _state is SuccessState;
  
  /// Set the state and notify listeners
  void setState(BaseState state) {
    _state = state;
    notifyListeners();
  }
  
  /// Set loading state
  void setLoading([String? message]) {
    setState(LoadingState(message: message));
  }
  
  /// Set success state with data
  void setSuccess<T>(T data) {
    setState(SuccessState<T>(data));
  }
  
  /// Set error state
  void setError(String message, {Object? error, StackTrace? stackTrace}) {
    _errorHandlingService.handleError(error ?? message, stackTrace, 'BaseProvider');
    setState(ErrorState(message, error: error, stackTrace: stackTrace));
  }
  
  /// Execute an async operation with proper state management
  Future<T?> executeAsync<T>(Future<T> Function() operation, {String? loadingMessage}) async {
    try {
      setLoading(loadingMessage);
      final result = await operation();
      setSuccess(result);
      return result;
    } catch (error, stackTrace) {
      setError('An error occurred: ${error.toString()}', error: error, stackTrace: stackTrace);
      return null;
    }
  }
  
  /// Execute a sync operation with proper state management
  T? executeSync<T>(T Function() operation, {String? loadingMessage}) {
    try {
      setLoading(loadingMessage);
      final result = operation();
      setSuccess(result);
      return result;
    } catch (error, stackTrace) {
      setError('An error occurred: ${error.toString()}', error: error, stackTrace: stackTrace);
      return null;
    }
  }
}
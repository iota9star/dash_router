/// Comprehensive navigation result types for Dash Router.
///
/// This library defines all possible outcomes of navigation operations,
/// providing type-safe handling of success, failure, cancellation,
/// and redirection scenarios.
///
/// ## Result Types
///
/// - **Success**: Navigation completed successfully
/// - **Cancelled**: Navigation was aborted (by user or guard)
/// - **Redirected**: Navigation was redirected to another route
/// - **Failed**: Navigation encountered an error
/// - **Pending**: Navigation is waiting for async operation
///
/// ## Pattern Matching
///
/// Use pattern matching or extension methods to handle results:
/// ```dart
/// final result = await router.pushNamed('/user/123');
/// switch (result) {
///   case NavigationSuccess(value: final value):
///     print('Navigated successfully: $value');
///   case NavigationCancelled(reason: final reason):
///     print('Navigation cancelled: $reason');
///   case NavigationRedirected(redirectedTo: final to, originalPath: final from):
///     print('Redirected from $from to $to');
///   case NavigationFailed(error: final error):
///     print('Navigation failed: $error');
///   case NavigationPending():
///     print('Navigation is pending...');
/// }
/// ```
///
/// ## Extension Methods
///
/// The library provides convenient extension methods for checking result type:
/// ```dart
/// if (result.isSuccess) {
///   final value = result.valueOrNull;
///   // Handle success
/// } else if (result.isFailed) {
///   // Handle failure
/// }
/// ```
library;

/// Sealed class representing the result of a navigation operation.
///
/// This is the base class for all navigation result types.
/// Use pattern matching or extension methods to handle different outcomes.
///
/// ## Type Parameter
///
/// [T] represents the type of value returned from navigation.
/// For navigation that doesn't return values, use `void` or `dynamic`.
///
/// ## Example
///
/// ```dart
/// Future<NavigationResult<String>> navigateAndLogin() async {
///   return await router.pushNamed('/login');
/// }
/// ```
sealed class NavigationResult<T> {
  const NavigationResult();
}

/// Represents successful navigation operation.
///
/// This result type indicates that navigation completed successfully
/// and, optionally, returned a value from the navigated route.
///
/// ## Value Type
///
/// [T] represents the type of value returned. If the route
/// doesn't return a value, this will be `void` or `dynamic`.
///
/// ## Example
///
/// ```dart
/// // Route that returns a string
/// final result = await router.pushNamed('/user/save');
/// switch (result) {
///   case NavigationSuccess(value: final message):
///     ScaffoldMessenger.of(context).showSnackBar(
///       SnackBar(content: Text(message)),
///     );
///   default:
///     // Handle other cases
/// }
///
/// // Route that doesn't return a value
/// final voidResult = await router.pushNamed('/home');
/// if (voidResult case NavigationSuccess()) {
///   print('Successfully navigated to home');
/// }
/// ```
class NavigationSuccess<T> extends NavigationResult<T> {
  /// The value returned from the navigated route.
  ///
  /// This will be null if the route doesn't return a value.
  /// The type matches the generic parameter [T].
  ///
  /// Example: For navigation to `/user/save`, this might contain
  /// the saved user ID or a confirmation message.
  final T? value;

  /// Creates a successful navigation result.
  ///
  /// [value] is optional and represents the return value from navigation.
  const NavigationSuccess([this.value]);

  @override
  String toString() => 'NavigationSuccess($value)';
}

/// Navigation was cancelled (e.g., by user or guard)
class NavigationCancelled<T> extends NavigationResult<T> {
  /// Reason for cancellation
  final String? reason;

  const NavigationCancelled([this.reason]);

  @override
  String toString() => 'NavigationCancelled($reason)';
}

/// Navigation was redirected to another route
class NavigationRedirected<T> extends NavigationResult<T> {
  /// The path that was redirected to
  final String redirectedTo;

  /// The original path
  final String originalPath;

  const NavigationRedirected({
    required this.redirectedTo,
    required this.originalPath,
  });

  @override
  String toString() => 'NavigationRedirected($originalPath -> $redirectedTo)';
}

/// Navigation failed with an error
class NavigationFailed<T> extends NavigationResult<T> {
  /// The error that caused the failure
  final Object error;

  /// Stack trace
  final StackTrace? stackTrace;

  const NavigationFailed(this.error, [this.stackTrace]);

  @override
  String toString() => 'NavigationFailed($error)';
}

/// Navigation is pending (async guard/middleware)
class NavigationPending<T> extends NavigationResult<T> {
  const NavigationPending();

  @override
  String toString() => 'NavigationPending';
}

/// Extension methods for NavigationResult
extension NavigationResultExtension<T> on NavigationResult<T> {
  /// Check if navigation was successful
  bool get isSuccess => this is NavigationSuccess<T>;

  /// Check if navigation was cancelled
  bool get isCancelled => this is NavigationCancelled<T>;

  /// Check if navigation was redirected
  bool get isRedirected => this is NavigationRedirected<T>;

  /// Check if navigation failed
  bool get isFailed => this is NavigationFailed<T>;

  /// Get the value if successful
  T? get valueOrNull {
    if (this is NavigationSuccess<T>) {
      return (this as NavigationSuccess<T>).value;
    }
    return null;
  }

  /// Map success value
  NavigationResult<R> map<R>(R Function(T? value) mapper) {
    if (this is NavigationSuccess<T>) {
      return NavigationSuccess<R>(mapper((this as NavigationSuccess<T>).value));
    }
    if (this is NavigationCancelled<T>) {
      return NavigationCancelled<R>((this as NavigationCancelled<T>).reason);
    }
    if (this is NavigationRedirected<T>) {
      final redirected = this as NavigationRedirected<T>;
      return NavigationRedirected<R>(
        redirectedTo: redirected.redirectedTo,
        originalPath: redirected.originalPath,
      );
    }
    if (this is NavigationFailed<T>) {
      final failed = this as NavigationFailed<T>;
      return NavigationFailed<R>(failed.error, failed.stackTrace);
    }
    return const NavigationPending();
  }

  /// Fold the result into a single value
  R fold<R>({
    required R Function(T? value) onSuccess,
    required R Function(String? reason) onCancelled,
    required R Function(String redirectedTo, String originalPath) onRedirected,
    required R Function(Object error, StackTrace? stackTrace) onFailed,
    required R Function() onPending,
  }) {
    return switch (this) {
      NavigationSuccess<T>(:final value) => onSuccess(value),
      NavigationCancelled<T>(:final reason) => onCancelled(reason),
      NavigationRedirected<T>(:final redirectedTo, :final originalPath) =>
        onRedirected(redirectedTo, originalPath),
      NavigationFailed<T>(:final error, :final stackTrace) => onFailed(
          error,
          stackTrace,
        ),
      NavigationPending<T>() => onPending(),
    };
  }
}

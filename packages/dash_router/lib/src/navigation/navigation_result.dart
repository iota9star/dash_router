/// Navigation result types
library;

/// Result of a navigation operation
sealed class NavigationResult<T> {
  const NavigationResult();
}

/// Navigation was successful
class NavigationSuccess<T> extends NavigationResult<T> {
  /// The result value returned from the route
  final T? value;

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

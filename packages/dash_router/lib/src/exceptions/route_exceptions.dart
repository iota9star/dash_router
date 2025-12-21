/// Base class for all dash_router exceptions.
///
/// All Dash Router-specific exceptions extend this class, providing
/// a common base for exception handling and error recovery.
///
/// ## Example
///
/// ```dart
/// try {
///   await router.pushNamed('/user/123');
/// } on DashRouterException catch (e) {
///   print('Router error: ${e.message}');
///   print('Stack trace: ${e.stackTrace}');
///   // Handle router-specific errors
/// }
/// ```
abstract class DashRouterException implements Exception {
  /// Human-readable error message.
  final String message;

  /// Stack trace at the time the exception was thrown.
  final StackTrace? stackTrace;

  /// Creates a router exception.
  ///
  /// [message] - Error message describing the exception
  /// [stackTrace] - Optional stack trace for debugging
  ///
  /// Example:
  /// ```dart
  /// class MyException extends DashRouterException {
  ///   MyException() : super('Something went wrong');
  /// }
  /// ```
  const DashRouterException(this.message, [this.stackTrace]);

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a route is not found.
///
/// This exception occurs when trying to navigate to a path
/// that doesn't match any registered route pattern.
///
/// ## Example
///
/// ```dart
/// try {
///   await router.pushNamed('/nonexistent/route');
/// } on RouteNotFoundException catch (e) {
///   print('Route not found: ${e.path}');
///   // Redirect to 404 page
///   await router.pushNamed('/404');
/// }
/// ```
class RouteNotFoundException extends DashRouterException {
  /// The path that was not found.
  final String path;

  /// Creates a route not found exception.
  ///
  /// [path] - The path that was attempted
  /// [stackTrace] - Optional stack trace for debugging
  ///
  /// Example:
  /// ```dart
  /// throw RouteNotFoundException('/user/999');
  /// ```
  const RouteNotFoundException(this.path, [StackTrace? stackTrace])
      : super('Route not found: $path', stackTrace);
}

/// Thrown when route configuration is invalid.
///
/// This exception occurs when route definitions contain
/// configuration errors like invalid patterns, missing
/// required fields, or conflicting settings.
///
/// ## Example
///
/// ```dart
/// try {
///   // Invalid route configuration
///   router.registerRoute(RouteEntry(
///     pattern: '', // Empty pattern
///     name: '',
///     builder: (context, data) => Container(),
///   ));
/// } on InvalidRouteConfigException catch (e) {
///   print('Invalid configuration: ${e.message}');
///   // Fix configuration issues
/// }
/// ```
class InvalidRouteConfigException extends DashRouterException {
  /// Creates an invalid route configuration exception.
  ///
  /// [message] - Error message describing configuration issue
  /// [stackTrace] - Optional stack trace for debugging
  ///
  /// Example:
  /// ```dart
  /// throw InvalidRouteConfigException(
  ///     'Route pattern cannot be empty',
  ///   );
  /// ```
  const InvalidRouteConfigException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Thrown when a route guard blocks navigation
class RouteGuardException extends DashRouterException {
  final String routePath;
  final String? redirectTo;

  const RouteGuardException(
    this.routePath, {
    this.redirectTo,
    String? message,
    StackTrace? stackTrace,
  }) : super(
          message ?? 'Navigation blocked by guard for: $routePath',
          stackTrace,
        );
}

/// Thrown when navigation is cancelled
class NavigationCancelledException extends DashRouterException {
  final String routePath;

  const NavigationCancelledException(this.routePath, [StackTrace? stackTrace])
      : super('Navigation cancelled to: $routePath', stackTrace);
}

/// Thrown when router is not initialized
class RouterNotInitializedException extends DashRouterException {
  const RouterNotInitializedException([StackTrace? stackTrace])
      : super(
          'DashRouter has not been initialized. '
          'Call DashRouter.init() before using the router.',
          stackTrace,
        );
}

/// Thrown when duplicate route is registered
class DuplicateRouteException extends DashRouterException {
  final String path;

  const DuplicateRouteException(this.path, [StackTrace? stackTrace])
      : super('Duplicate route registered: $path', stackTrace);
}

/// Thrown when a redirect loop is detected
class RedirectLoopException extends DashRouterException {
  final List<String> redirectChain;

  RedirectLoopException(this.redirectChain, [StackTrace? stackTrace])
      : super(
          'Redirect loop detected: ${redirectChain.join(' -> ')}',
          stackTrace,
        );
}

/// Thrown when route building fails
class RouteBuildException extends DashRouterException {
  final String routePath;
  final Object? originalError;

  const RouteBuildException(
    this.routePath, {
    this.originalError,
    String? message,
    StackTrace? stackTrace,
  }) : super(message ?? 'Failed to build route: $routePath', stackTrace);
}

/// Base class for all dash_router exceptions
abstract class DashRouterException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const DashRouterException(this.message, [this.stackTrace]);

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when a route is not found
class RouteNotFoundException extends DashRouterException {
  final String path;

  const RouteNotFoundException(this.path, [StackTrace? stackTrace])
      : super('Route not found: $path', stackTrace);
}

/// Thrown when route configuration is invalid
class InvalidRouteConfigException extends DashRouterException {
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

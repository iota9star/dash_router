import '../utils/route_utils.dart';
import 'middleware_context.dart';

/// Base class for route middleware.
///
/// Middleware provides a powerful way to intercept and process navigation events.
/// Unlike guards which focus on access control, middleware is designed for
/// cross-cutting concerns like logging, analytics, caching, and request modification.
///
/// ## Middleware vs Guards
///
/// | Feature | Middleware | Guards |
/// |---------|------------|--------|
/// | Purpose | Cross-cutting concerns | Access control |
/// | Execution | Runs on every matching route | Runs only on protected routes |
/// | Result | Continue, Abort, or Redirect | Allow, Deny, or Redirect |
/// | Order | Priority-based | Declaration order |
///
/// ## Lifecycle
///
/// Middleware has three lifecycle hooks:
/// 1. [handle] - Called before navigation, can modify or abort the request
/// 2. [afterNavigation] - Called after successful navigation
/// 3. [onAborted] - Called when navigation is aborted
///
/// ## Route Matching
///
/// Use [routes] and [excludeRoutes] with glob patterns to control which routes
/// the middleware applies to:
/// - `*` - Matches any single segment
/// - `**` - Matches any number of segments
/// - `/admin/**` - Matches all routes starting with `/admin/`
/// - `/api/*` - Matches `/api/users` but not `/api/users/123`
///
/// ## Example
///
/// ```dart
/// class AnalyticsMiddleware extends DashMiddleware {
///   final AnalyticsService analytics;
///
///   AnalyticsMiddleware(this.analytics);
///
///   @override
///   int get priority => 100; // Run early
///
///   @override
///   List<String>? get excludeRoutes => ['/debug/**']; // Skip debug routes
///
///   @override
///   Future<MiddlewareResult> handle(MiddlewareContext context) async {
///     analytics.trackPageView(
///       path: context.targetPath,
///       previousPath: context.currentPath,
///     );
///     return const MiddlewareContinue();
///   }
///
///   @override
///   Future<void> afterNavigation(MiddlewareContext context) async {
///     analytics.trackPageLoadTime(
///       path: context.targetPath,
///       duration: context.elapsed,
///     );
///   }
/// }
/// ```
///
/// ## Registration
///
/// Register middleware with the router:
///
/// ```dart
/// final router = DashRouter.builder()
///     .addMiddleware(AnalyticsMiddleware(analytics))
///     .addMiddleware(LoggingMiddleware())
///     .build();
/// ```
///
/// See also:
/// - [FunctionalMiddleware] for simple function-based middleware
/// - [LoggingMiddleware] for built-in logging support
/// - [DashGuard] for access control
abstract class DashMiddleware {
  /// Priority of this middleware (higher values run first).
  ///
  /// Middleware with higher priority values are executed before those with
  /// lower values. The default priority is 0.
  ///
  /// Example priorities:
  /// - 1000: Security/authentication checks
  /// - 100: Analytics/tracking
  /// - 0: General middleware (default)
  /// - -100: Post-processing middleware
  int get priority => 0;

  /// Routes this middleware applies to (glob patterns).
  ///
  /// If null, the middleware runs for all routes (subject to [excludeRoutes]).
  ///
  /// Supports glob patterns:
  /// - `*` matches any single path segment
  /// - `**` matches any number of path segments
  ///
  /// Examples:
  /// - `['/admin/**']` - Only admin routes
  /// - `['/api/*', '/api/v2/*']` - API routes at specific depth
  /// - `['/users/:id']` - Specific parameterized route
  List<String>? get routes => null;

  /// Routes this middleware excludes.
  ///
  /// Exclusions take precedence over [routes]. If a route matches both
  /// [routes] and [excludeRoutes], it will be excluded.
  ///
  /// Examples:
  /// - `['/health', '/metrics']` - Skip monitoring endpoints
  /// - `['/public/**']` - Skip all public routes
  List<String>? get excludeRoutes => null;

  /// Check if middleware should run for this route.
  ///
  /// Returns true if the middleware should process this route, based on
  /// the [routes] and [excludeRoutes] configuration.
  bool shouldRun(String path) {
    // Check exclusions first
    if (excludeRoutes != null) {
      for (final pattern in excludeRoutes!) {
        if (RouteUtils.matchGlobPattern(pattern, path)) {
          return false;
        }
      }
    }

    // If no specific routes defined, run for all
    if (routes == null) return true;

    // Check if matches any defined routes
    for (final pattern in routes!) {
      if (RouteUtils.matchGlobPattern(pattern, path)) {
        return true;
      }
    }

    return false;
  }

  /// Handle the navigation request.
  ///
  /// This method is called before navigation occurs. Return:
  /// - [MiddlewareContinue] to proceed with navigation
  /// - [MiddlewareAbort] to cancel navigation
  /// - [MiddlewareRedirect] to redirect to a different route
  ///
  /// The [context] provides access to:
  /// - Current and target paths
  /// - Route data and parameters
  /// - Navigation timestamp for timing calculations
  Future<MiddlewareResult> handle(MiddlewareContext context);

  /// Called after successful navigation.
  ///
  /// Use this hook for post-navigation tasks like:
  /// - Logging navigation completion
  /// - Tracking page load times via [MiddlewareContext.elapsed]
  /// - Updating analytics
  Future<void> afterNavigation(MiddlewareContext context) async {}

  /// Called when navigation is aborted.
  ///
  /// This is called when this or another middleware/guard aborts the navigation.
  /// The [reason] parameter contains the abort reason if provided.
  Future<void> onAborted(MiddlewareContext context, String? reason) async {}
}

/// Function-based middleware for simple use cases.
///
/// Use this when you don't need to create a full middleware class.
///
/// ## Example
///
/// ```dart
/// final loggingMiddleware = FunctionalMiddleware(
///   handle: (context) async {
///     print('Navigating to: ${context.targetPath}');
///     return const MiddlewareContinue();
///   },
///   afterNavigation: (context) async {
///     print('Navigation took: ${context.elapsed.inMilliseconds}ms');
///   },
///   priority: 50,
///   routes: ['/app/**'],
///   excludeRoutes: ['/app/debug/**'],
/// );
/// ```
class FunctionalMiddleware extends DashMiddleware {
  final Future<MiddlewareResult> Function(MiddlewareContext context) _handle;
  final Future<void> Function(MiddlewareContext context)? _afterNavigation;

  @override
  final int priority;

  @override
  final List<String>? routes;

  @override
  final List<String>? excludeRoutes;

  /// Creates a function-based middleware.
  ///
  /// - [handle]: Required function called before navigation
  /// - [afterNavigation]: Optional function called after successful navigation
  /// - [priority]: Middleware priority (default: 0)
  /// - [routes]: Optional list of route patterns to apply to
  /// - [excludeRoutes]: Optional list of route patterns to exclude
  FunctionalMiddleware({
    required Future<MiddlewareResult> Function(MiddlewareContext context)
        handle,
    Future<void> Function(MiddlewareContext context)? afterNavigation,
    this.priority = 0,
    this.routes,
    this.excludeRoutes,
  })  : _handle = handle,
        _afterNavigation = afterNavigation;

  @override
  Future<MiddlewareResult> handle(MiddlewareContext context) =>
      _handle(context);

  @override
  Future<void> afterNavigation(MiddlewareContext context) async {
    await _afterNavigation?.call(context);
  }
}

/// Built-in logging middleware.
///
/// Provides automatic logging of navigation events including:
/// - Route transitions (from -> to)
/// - Navigation completion
/// - Optional timing information
///
/// ## Example
///
/// ```dart
/// // Basic usage with default print
/// final middleware = LoggingMiddleware();
///
/// // Custom logger
/// final middleware = LoggingMiddleware(
///   log: (message) => logger.info(message),
///   logTiming: true,
///   logAfterNavigation: true,
/// );
/// ```
///
/// Output example:
/// ```
/// [Navigation] /home -> /users/123
/// [Navigation Complete] /users/123 (45ms)
/// ```
class LoggingMiddleware extends DashMiddleware {
  /// The logging function to use.
  final void Function(String message) log;

  /// Whether to log after navigation completes.
  final bool logAfterNavigation;

  /// Whether to include timing information in logs.
  final bool logTiming;

  /// Creates a logging middleware.
  ///
  /// - [log]: Custom logging function (defaults to [print])
  /// - [logAfterNavigation]: Log after navigation completes (default: true)
  /// - [logTiming]: Include timing in after-navigation log (default: true)
  LoggingMiddleware({
    void Function(String message)? log,
    this.logAfterNavigation = true,
    this.logTiming = true,
  }) : log = log ?? print;

  @override
  Future<MiddlewareResult> handle(MiddlewareContext context) async {
    final from = context.currentPath ?? 'null';
    final to = context.targetPath;
    log('[Navigation] $from -> $to');
    return const MiddlewareContinue();
  }

  @override
  Future<void> afterNavigation(MiddlewareContext context) async {
    if (logAfterNavigation) {
      var message = '[Navigation Complete] ${context.targetPath}';
      if (logTiming) {
        message += ' (${context.elapsed.inMilliseconds}ms)';
      }
      log(message);
    }
  }
}

/// Delay middleware for testing and debugging.
///
/// Introduces an artificial delay before navigation proceeds.
/// Useful for testing loading states, animations, or simulating
/// slow network conditions.
///
/// ## Example
///
/// ```dart
/// // Add 500ms delay to all navigation
/// final middleware = DelayMiddleware(
///   delay: Duration(milliseconds: 500),
/// );
/// ```
///
/// **Warning**: This middleware is intended for development/testing only.
/// Do not use in production.
class DelayMiddleware extends DashMiddleware {
  /// The delay duration before navigation proceeds.
  final Duration delay;

  /// Creates a delay middleware.
  ///
  /// - [delay]: Duration to wait (default: 100ms)
  DelayMiddleware({this.delay = const Duration(milliseconds: 100)});

  @override
  Future<MiddlewareResult> handle(MiddlewareContext context) async {
    await Future.delayed(delay);
    return const MiddlewareContinue();
  }
}

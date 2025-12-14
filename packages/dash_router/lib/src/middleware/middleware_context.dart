import '../router/route_data.dart';

/// Context information passed to middleware during navigation.
///
/// [MiddlewareContext] provides access to:
/// - Target route information ([targetRoute], [targetPath], [targetName])
/// - Current route information ([currentRoute], [currentPath], [currentName])
/// - Extra navigation data ([extra])
/// - Timing information ([startTime], [elapsed])
/// - Custom data storage for passing data between middleware ([set], [get])
///
/// ## Example
///
/// ```dart
/// class MyMiddleware extends DashMiddleware {
///   @override
///   Future<MiddlewareResult> handle(MiddlewareContext context) async {
///     // Access navigation info
///     print('From: ${context.currentPath}');
///     print('To: ${context.targetPath}');
///
///     // Store data for other middleware
///     context.set('startedAt', DateTime.now());
///
///     return const MiddlewareContinue();
///   }
///
///   @override
///   Future<void> afterNavigation(MiddlewareContext context) async {
///     // Access stored data
///     final startedAt = context.get<DateTime>('startedAt');
///     print('Navigation took: ${context.elapsed.inMilliseconds}ms');
///   }
/// }
/// ```
class MiddlewareContext {
  /// The route being navigated to.
  final RouteData targetRoute;

  /// The current route before navigation (null if this is the initial route).
  final RouteData? currentRoute;

  /// Extra data passed with the navigation request.
  final Map<String, dynamic> extra;

  /// Timestamp when navigation started.
  ///
  /// Used to calculate [elapsed] time for performance tracking.
  final DateTime startTime;

  /// Custom data storage for passing data between middleware in the chain.
  final Map<String, dynamic> _data = {};

  /// Creates a middleware context.
  ///
  /// - [targetRoute]: Required route being navigated to
  /// - [currentRoute]: Optional current route (null for initial navigation)
  /// - [extra]: Optional extra data map
  /// - [startTime]: Optional start time (defaults to now)
  MiddlewareContext({
    required this.targetRoute,
    this.currentRoute,
    Map<String, dynamic>? extra,
    DateTime? startTime,
  })  : extra = extra ?? {},
        startTime = startTime ?? DateTime.now();

  /// The path of the route being navigated to.
  String get targetPath => targetRoute.path;

  /// The name of the route being navigated to.
  String get targetName => targetRoute.name;

  /// The path of the current route, or null if this is initial navigation.
  String? get currentPath => currentRoute?.path;

  /// The name of the current route, or null if this is initial navigation.
  String? get currentName => currentRoute?.name;

  /// Store data for use by subsequent middleware in the chain.
  ///
  /// ```dart
  /// context.set('userId', user.id);
  /// context.set('permissions', ['read', 'write']);
  /// ```
  void set<T>(String key, T value) {
    _data[key] = value;
  }

  /// Retrieve data stored by previous middleware.
  ///
  /// Returns null if the key doesn't exist or the type doesn't match.
  ///
  /// ```dart
  /// final userId = context.get<String>('userId');
  /// final permissions = context.get<List<String>>('permissions');
  /// ```
  T? get<T>(String key) {
    final value = _data[key];
    if (value is T) return value;
    return null;
  }

  /// Check if data exists for the given key.
  bool has(String key) => _data.containsKey(key);

  /// Remove data for the given key.
  void remove(String key) => _data.remove(key);

  /// Time elapsed since navigation started.
  ///
  /// Useful for performance tracking in [DashMiddleware.afterNavigation]:
  ///
  /// ```dart
  /// @override
  /// Future<void> afterNavigation(MiddlewareContext context) async {
  ///   analytics.trackPageLoadTime(
  ///     path: context.targetPath,
  ///     duration: context.elapsed,
  ///   );
  /// }
  /// ```
  Duration get elapsed => DateTime.now().difference(startTime);
}

/// Result of middleware execution.
///
/// Middleware returns one of three result types:
/// - [MiddlewareContinue]: Proceed with navigation
/// - [MiddlewareAbort]: Cancel navigation
/// - [MiddlewareRedirect]: Redirect to a different route
///
/// ## Example
///
/// ```dart
/// @override
/// Future<MiddlewareResult> handle(MiddlewareContext context) async {
///   // Continue normally
///   if (isAllowed) {
///     return const MiddlewareContinue();
///   }
///
///   // Abort with reason
///   if (shouldBlock) {
///     return const MiddlewareAbort('Access denied');
///   }
///
///   // Redirect to login
///   return const MiddlewareRedirect('/login');
/// }
/// ```
sealed class MiddlewareResult {
  const MiddlewareResult();
}

/// Continue to the next middleware or proceed with navigation.
///
/// Optionally pass a [modifiedContext] if you need to modify the context
/// for subsequent middleware.
///
/// ```dart
/// // Simple continue
/// return const MiddlewareContinue();
///
/// // Continue with modified context
/// return MiddlewareContinue(modifiedContext);
/// ```
class MiddlewareContinue extends MiddlewareResult {
  /// Optional modified context to pass to subsequent middleware.
  final MiddlewareContext? modifiedContext;

  /// Creates a continue result.
  const MiddlewareContinue([this.modifiedContext]);
}

/// Abort navigation with an optional reason.
///
/// When middleware returns this, navigation is cancelled and
/// [DashMiddleware.onAborted] is called on all middleware that ran.
///
/// ```dart
/// // Simple abort
/// return const MiddlewareAbort();
///
/// // Abort with reason
/// return const MiddlewareAbort('Insufficient permissions');
/// ```
class MiddlewareAbort extends MiddlewareResult {
  /// Optional reason for aborting navigation.
  final String? reason;

  /// Creates an abort result with an optional reason.
  const MiddlewareAbort([this.reason]);
}

/// Redirect to a different route.
///
/// Use this to change the navigation target. The redirect will go through
/// the full middleware chain for the new route.
///
/// ```dart
/// // Simple redirect
/// return const MiddlewareRedirect('/login');
///
/// // Redirect with query parameters
/// return MiddlewareRedirect(
///   '/error',
///   queryParams: {'code': '403', 'message': 'Forbidden'},
/// );
///
/// // Redirect with extra data
/// return MiddlewareRedirect(
///   '/login',
///   extra: LoginRedirectData(returnUrl: context.targetPath),
/// );
/// ```
class MiddlewareRedirect extends MiddlewareResult {
  /// The path to redirect to.
  final String redirectTo;

  /// Optional query parameters for the redirect.
  final Map<String, dynamic>? queryParams;

  /// Optional extra data to pass with the redirect.
  final Object? extra;

  /// Creates a redirect result.
  const MiddlewareRedirect(this.redirectTo, {this.queryParams, this.extra});
}

/// Extension methods for [MiddlewareResult].
///
/// Provides convenient type checking and property access without
/// explicit casting.
///
/// ```dart
/// final result = await middleware.handle(context);
///
/// if (result.shouldContinue) {
///   // Proceed with navigation
/// } else if (result.shouldRedirect) {
///   // Navigate to result.redirectPath
/// } else if (result.shouldAbort) {
///   // Handle abort with result.abortReason
/// }
/// ```
extension MiddlewareResultExtension on MiddlewareResult {
  /// Returns true if this result allows navigation to continue.
  bool get shouldContinue => this is MiddlewareContinue;

  /// Returns true if this result aborts navigation.
  bool get shouldAbort => this is MiddlewareAbort;

  /// Returns true if this result redirects to a different route.
  bool get shouldRedirect => this is MiddlewareRedirect;

  /// The redirect path if this is a [MiddlewareRedirect], otherwise null.
  String? get redirectPath {
    if (this is MiddlewareRedirect) {
      return (this as MiddlewareRedirect).redirectTo;
    }
    return null;
  }

  /// The abort reason if this is a [MiddlewareAbort], otherwise null.
  String? get abortReason {
    if (this is MiddlewareAbort) {
      return (this as MiddlewareAbort).reason;
    }
    return null;
  }
}

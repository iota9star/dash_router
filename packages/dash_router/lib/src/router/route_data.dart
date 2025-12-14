import 'package:flutter/widgets.dart';

import 'package:dash_router_annotations/dash_router_annotations.dart';

import '../guards/guard.dart';
import '../middleware/middleware.dart';
import '../params/params_types.dart';

/// Data associated with a route entry
class RouteData {
  /// The route path pattern (e.g., '/user/:id')
  final String pattern;

  /// The actual matched path (e.g., '/user/123')
  final String path;

  /// The full URL including query string
  final String fullPath;

  /// Route name
  final String name;

  /// Route parameters
  final RouteParams params;

  /// Route settings
  final RouteSettings? settings;

  /// Whether this is the initial route
  final bool isInitial;

  /// Parent route pattern (for nested routes)
  final String? parentPattern;

  /// Child routes patterns
  final List<String> childPatterns;

  /// Route metadata
  final Map<String, dynamic> metadata;

  /// Timestamp when this route was created
  final DateTime createdAt;

  /// Unique identifier for this route entry
  final String id;

  RouteData({
    required this.pattern,
    required this.path,
    required this.fullPath,
    required this.name,
    this.params = const RouteParams(),
    this.settings,
    this.isInitial = false,
    this.parentPattern,
    this.childPatterns = const [],
    this.metadata = const {},
    DateTime? createdAt,
    String? id,
  })  : createdAt = createdAt ?? DateTime.now(),
        id = id ?? _generateId();

  static int _idCounter = 0;
  static String _generateId() {
    return 'route_${++_idCounter}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Create a copy with modifications
  RouteData copyWith({
    String? pattern,
    String? path,
    String? fullPath,
    String? name,
    RouteParams? params,
    RouteSettings? settings,
    bool? isInitial,
    String? parentPattern,
    List<String>? childPatterns,
    Map<String, dynamic>? metadata,
  }) {
    return RouteData(
      pattern: pattern ?? this.pattern,
      path: path ?? this.path,
      fullPath: fullPath ?? this.fullPath,
      name: name ?? this.name,
      params: params ?? this.params,
      settings: settings ?? this.settings,
      isInitial: isInitial ?? this.isInitial,
      parentPattern: parentPattern ?? this.parentPattern,
      childPatterns: childPatterns ?? this.childPatterns,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      id: id,
    );
  }

  /// Check if this route has path parameters
  bool get hasPathParams => params.pathParams.isNotEmpty;

  /// Check if this route has query parameters
  bool get hasQueryParams => params.queryParams.isNotEmpty;

  /// Check if this route has body parameters
  bool get hasBodyParams => params.bodyParams.isNotEmpty;

  /// Check if this route has any parameters
  bool get hasParams => params.isNotEmpty;

  /// Get depth of this route (number of path segments)
  int get depth => path.split('/').where((s) => s.isNotEmpty).length;

  @override
  String toString() => 'RouteData(path: $path, name: $name, params: $params)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteData &&
          pattern == other.pattern &&
          path == other.path &&
          name == other.name &&
          params == other.params;

  @override
  int get hashCode => Object.hash(pattern, path, name, params);
}

/// Configuration for a route entry.
///
/// Each route in the application is defined by a [RouteEntry] that specifies
/// its pattern, builder, and optional configuration like guards and middleware.
///
/// Example:
/// ```dart
/// final userRoute = RouteEntry(
///   pattern: '/user/:id',
///   name: 'userDetail',
///   builder: (context, data) => UserPage(id: data.params['id']),
///   guards: const [AuthGuard()],
///   middleware: const [LoggingMiddleware()],
/// );
/// ```
class RouteEntry {
  /// The route path pattern.
  ///
  /// Supports path parameters with `:paramName` syntax:
  /// - `/user/:id` - matches `/user/123`
  /// - `/user/:userId/post/:postId` - matches `/user/1/post/2`
  final String pattern;

  /// Route name for named navigation.
  final String name;

  /// Builder function for creating the route's widget.
  final Widget Function(BuildContext context, RouteData data) builder;

  /// Whether this is the initial route.
  final bool isInitial;

  /// Parent route pattern for nested routing.
  final String? parent;

  /// Route metadata for custom use cases.
  final Map<String, dynamic> metadata;

  /// Guards for this route.
  ///
  /// Guards are executed before navigation and can allow, deny, or redirect.
  /// Use const instances for type-safe guard registration.
  ///
  /// Example:
  /// ```dart
  /// guards: const [AuthGuard(), AdminGuard()],
  /// ```
  final List<DashGuard> guards;

  /// Middleware for this route.
  ///
  /// Middleware executes during navigation for cross-cutting concerns like
  /// logging, analytics, or request modification.
  ///
  /// Example:
  /// ```dart
  /// middleware: const [LoggingMiddleware(), AnalyticsMiddleware()],
  /// ```
  final List<DashMiddleware> middleware;

  /// Transition configuration key.
  final String? transitionKey;

  /// Transition for this route.
  ///
  /// If provided, this overrides `DashRouter.config.defaultTransition` for this
  /// route.
  final DashTransition? transition;

  /// Optional shell builder for nested routing.
  ///
  /// When set, this route can act as a wrapper (shell) for its child routes.
  /// Child routes that declare `parent: <this.pattern>` will be wrapped by this
  /// builder when they are built.
  final Widget Function(BuildContext context, RouteData data, Widget child)?
      shellBuilder;

  /// Whether this route should be kept alive.
  final bool keepAlive;

  /// Whether this route is a fullscreen dialog.
  final bool fullscreenDialog;

  /// Whether to maintain state when navigating away.
  final bool maintainState;

  /// Creates a route entry.
  const RouteEntry({
    required this.pattern,
    required this.name,
    required this.builder,
    this.isInitial = false,
    this.parent,
    this.metadata = const {},
    this.guards = const [],
    this.middleware = const [],
    this.transitionKey,
    this.transition,
    this.shellBuilder,
    this.keepAlive = false,
    this.fullscreenDialog = false,
    this.maintainState = true,
  });

  @override
  String toString() => 'RouteEntry(pattern: $pattern, name: $name)';
}

/// Redirect configuration
class RedirectEntry {
  /// The path to redirect from
  final String from;

  /// The path to redirect to
  final String to;

  /// Whether this is a permanent redirect
  final bool permanent;

  /// Optional condition for the redirect
  final bool Function(RouteData data)? condition;

  const RedirectEntry({
    required this.from,
    required this.to,
    this.permanent = false,
    this.condition,
  });

  /// Check if this redirect should apply
  bool shouldRedirect(RouteData data) {
    if (condition != null) {
      return condition!(data);
    }
    return true;
  }
}

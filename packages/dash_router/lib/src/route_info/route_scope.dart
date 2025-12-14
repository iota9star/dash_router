import 'package:flutter/widgets.dart';

import '../params/params_types.dart';
import '../params/typed_params_resolver.dart';
import '../router/navigation_history.dart';
import '../router/route_data.dart';

/// Core InheritedWidget - provides route info to the widget tree.
///
/// This is the foundation of the route info system. It ensures route info
/// is available to all descendant widgets.
///
/// You don't need to use this class directly - just use `context.route`.
class DashRouteScope extends InheritedWidget {
  /// Current route data
  final RouteData data;

  /// Navigation history (optional)
  final NavigationHistory? history;

  /// Cached params resolver, O(1) access
  final TypedParamsResolver _paramsResolver;

  /// Create route scope
  DashRouteScope({
    super.key,
    required this.data,
    this.history,
    required super.child,
  }) : _paramsResolver =
            TypedParamsResolver(data.params, data.settings?.arguments);

  /// Get route scope from widget tree.
  ///
  /// Returns null if not found (e.g., outside DashRouter).
  static DashRouteScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DashRouteScope>();
  }

  /// Get route scope from widget tree.
  ///
  /// Throws [StateError] if not found.
  ///
  /// Use [maybeOf] for a null-safe alternative.
  static DashRouteScope of(BuildContext context) {
    final scope = maybeOf(context);
    if (scope == null) {
      throw StateError(
        'No DashRouteScope found in context. '
        'Make sure you are using DashRouter and the widget is inside the route tree.',
      );
    }
    return scope;
  }

  /// Get params resolver
  TypedParamsResolver get paramsResolver => _paramsResolver;

  @override
  bool updateShouldNotify(DashRouteScope oldWidget) {
    return data != oldWidget.data;
  }
}

/// Widget that wraps child with [DashRouteScope].
///
/// This is used internally by router. You typically don't need to use it directly.
class DashRouteScopeProvider extends StatelessWidget {
  /// Route data to provide
  final RouteData data;

  /// Navigation history
  final NavigationHistory? history;

  /// Child widget
  final Widget child;

  const DashRouteScopeProvider({
    super.key,
    required this.data,
    this.history,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DashRouteScope(
      data: data,
      history: history,
      child: child,
    );
  }
}

/// Scoped route info - main interface for accessing route information.
///
/// This class provides a clean, type-safe API for accessing route info
/// provided by [DashRouteScope]. This is what you get from `context.route`.
///
/// All access operations are O(1) complexity.
///
/// ## Usage Example
///
/// ```dart
/// class MyPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final route = context.route;
///
///     // Basic info
///     print(route.uri);      // '/user/123'
///     print(route.name);     // 'userDetail'
///     print(route.fullPath); // '/user/123?tab=profile'
///
///     // Parameter access - O(1) complexity
///     // Use generated extensions for type-safe access:
///     //   route.path.userId    // String (typed by codegen)
///     //   route.query.tab      // String? (typed by codegen)
///     //   route.body           // (UserData, Product) (typed by codegen)
///     //
///     // Or use generic fallback:
///     final id = route.path.get<String>('id');
///     final tab = route.query.get<String>('tab');
///
///     // Raw route data
///     final rawData = route.raw;
///
///     return Text('User: $id');
///   }
/// }
/// ```
class ScopedRouteInfo {
  final DashRouteScope _scope;

  const ScopedRouteInfo._(this._scope);

  /// Create from BuildContext.
  ///
  /// Returns null if route scope not found.
  static ScopedRouteInfo? maybeOf(BuildContext context) {
    final scope = DashRouteScope.maybeOf(context);
    if (scope == null) return null;
    return ScopedRouteInfo._(scope);
  }

  /// Create from BuildContext.
  ///
  /// Throws if route scope not found.
  static ScopedRouteInfo of(BuildContext context) {
    return ScopedRouteInfo._(DashRouteScope.of(context));
  }

  // ============================================================
  // Basic Route Info
  // ============================================================

  /// Current route URI (e.g., '/user/123')
  String get uri => _scope.data.path;

  /// Route name (e.g., 'userDetail')
  String get name => _scope.data.name;

  /// Full path with query string (e.g., '/user/123?tab=profile')
  String get fullPath => _scope.data.fullPath;

  /// Route pattern (e.g., '/user/:id')
  String get pattern => _scope.data.pattern;

  /// Whether this is the initial/home route
  bool get isInitial => _scope.data.isInitial;

  /// Route metadata
  Map<String, dynamic> get metadata => _scope.data.metadata;

  /// Raw Flutter route settings
  RouteSettings? get settings => _scope.data.settings;

  // ============================================================
  // Parameter Access - Simplified API (O(1) complexity)
  // ============================================================

  /// Path parameters accessor.
  ///
  /// Generated code extends this with typed properties:
  /// ```dart
  /// route.path.userId    // String (typed)
  /// route.path.get<String>('id')  // Generic fallback
  /// ```
  TypedPathParams get path => _scope.paramsResolver.path;

  /// Query parameters accessor.
  ///
  /// Generated code extends this with typed properties:
  /// ```dart
  /// route.query.initialTab  // String? (typed)
  /// route.query.get<int>('page', defaultValue: 1)  // Generic fallback
  /// ```
  TypedQueryParams get query => _scope.paramsResolver.query;

  /// Body parameters accessor.
  ///
  /// Generated code extends this with typed properties:
  /// ```dart
  /// // Raw arguments access:
  /// final args = route.body.arguments;
  ///
  /// // Named body params:
  /// route.body.get<UserData>('userData');
  ///
  /// // With generated extension (type-safe):
  /// final (user, product) = route.arguments;  // Typed as (UserData, Product)
  /// ```
  TypedBodyParams get body => _scope.paramsResolver.body;

  /// All parameters (for debugging)
  Map<String, dynamic> get allParams => _scope.paramsResolver.all;

  // ============================================================
  // Raw Data Access
  // ============================================================

  /// Get raw route data.
  ///
  /// Use this for advanced scenarios or debugging.
  RouteData get raw => _scope.data;

  // ============================================================
  // Navigation History
  // ============================================================

  /// Navigation history (if available)
  NavigationHistory? get history => _scope.history;

  /// Previous route path
  String? get previousPath => _scope.history?.previousPath;

  /// Next route path (if navigated back)
  String? get nextPath => _scope.history?.nextPath;

  /// Whether can go back
  bool get canGoBack => _scope.history?.canGoBack ?? false;

  /// Whether can go forward
  bool get canGoForward => _scope.history?.canGoForward ?? false;

  // ============================================================
  // Nested Route Info
  // ============================================================

  /// Parent route pattern (for nested routes)
  String? get parentPattern => _scope.data.parentPattern;

  /// Child route patterns
  List<String> get childPatterns => _scope.data.childPatterns;

  /// Whether has parent route
  bool get hasParent => parentPattern != null;

  /// Whether has child routes
  bool get hasChildren => childPatterns.isNotEmpty;

  @override
  String toString() =>
      'ScopedRouteInfo(uri: $uri, name: $name, params: $allParams)';
}

/// Fallback route info created from ModalRoute.
///
/// Used when `context.route` is called outside of DashRouter.
class FallbackRouteInfo extends ScopedRouteInfo {
  final RouteData _fallbackData;
  final TypedParamsResolver _fallbackResolver;

  FallbackRouteInfo._({
    required RouteData data,
  })  : _fallbackData = data,
        _fallbackResolver = TypedParamsResolver(data.params),
        super._(
          _FallbackScope(data: data),
        );

  /// Create fallback route info from Flutter's ModalRoute
  factory FallbackRouteInfo.fromModalRoute(BuildContext context) {
    final modalRoute = ModalRoute.of(context);
    if (modalRoute == null) {
      return FallbackRouteInfo.empty();
    }

    final settings = modalRoute.settings;
    final name = settings.name ?? '/';
    final uri = Uri.parse(name);

    final queryParams = uri.queryParameters;
    final bodyParams = <String, dynamic>{};

    if (settings.arguments is Map<String, dynamic>) {
      bodyParams.addAll(settings.arguments as Map<String, dynamic>);
    } else if (settings.arguments != null) {
      bodyParams['_body'] = settings.arguments;
    }

    final data = RouteData(
      pattern: uri.path,
      path: uri.path,
      fullPath: name,
      name: _extractRouteName(uri.path),
      params: RouteParams(queryParams: queryParams, bodyParams: bodyParams),
      settings: settings,
    );

    return FallbackRouteInfo._(data: data);
  }

  /// Create empty fallback route info
  factory FallbackRouteInfo.empty() {
    return FallbackRouteInfo._(
      data: RouteData(
        pattern: '/',
        path: '/',
        fullPath: '/',
        name: 'unknown',
      ),
    );
  }

  static String _extractRouteName(String path) {
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return 'root';
    return segments.last.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  }

  @override
  TypedPathParams get path => _fallbackResolver.path;

  @override
  TypedQueryParams get query => _fallbackResolver.query;

  @override
  Map<String, dynamic> get allParams => _fallbackResolver.all;

  @override
  RouteData get raw => _fallbackData;
}

/// Internal fallback scope implementation
class _FallbackScope extends DashRouteScope {
  _FallbackScope({required super.data}) : super(child: const SizedBox.shrink());
}

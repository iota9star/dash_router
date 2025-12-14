import 'package:flutter/widgets.dart';

import '../route_info/route_scope.dart';

/// Core route extension - the only entry point you need to remember.
///
/// Just use `context.route` to access all route data.
///
/// ## Basic Usage
///
/// ```dart
/// class MyPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     // Get route info - this is all you need to remember!
///     final route = context.route;
///
///     // Access basic info
///     print(route.uri);        // '/user/123'
///     print(route.name);       // 'userDetail'
///     print(route.fullPath);   // '/user/123?tab=profile'
///
///     // Access params (O(1) complexity)
///     final id = route.path.get<String>('id');              // '123'
///     final tab = route.query.get<String>('tab');           // 'profile'
///     final page = route.query.get<int>('page', defaultValue: 1);
///     final user = route.body.get<User>('user');            // User object
///
///     return Text('User: $id');
///   }
/// }
/// ```
///
/// ## Design Philosophy
///
/// 1. **Single entry point**: Just remember `context.route`
/// 2. **Type-safe**: All parameter access is type-safe
/// 3. **O(1) access**: Params are cached, access is instant
/// 4. **Available everywhere**: Works anywhere in the widget tree
/// 5. **Reactive**: Auto-rebuilds on route changes (via InheritedWidget)
extension DashRouteExtension on BuildContext {
  /// Get route info for the current context.
  ///
  /// This is the only method you need to remember. All other info can be
  /// obtained from the returned [ScopedRouteInfo] object.
  ///
  /// The returned [ScopedRouteInfo] provides:
  ///
  /// **Basic Info:**
  /// - `uri` - Current route path (e.g., '/user/123')
  /// - `name` - Route name (e.g., 'userDetail')
  /// - `fullPath` - Full path with query string
  /// - `pattern` - Route pattern (e.g., '/user/:id')
  /// - `isInitial` - Whether this is the initial route
  /// - `metadata` - Custom route metadata
  ///
  /// **Parameter Access (O(1) complexity):**
  /// - `path.get<T>(name)` - Get path parameter
  /// - `query.get<T>(name, defaultValue: ...)` - Get query parameter
  /// - `body.get<T>(name)` - Get body parameter
  /// - `path.has(name)` - Check if path param exists
  /// - `query.has(name)` - Check if query param exists
  /// - `body.has(name)` - Check if body param exists
  /// - `allParams` - Get all params
  ///
  /// **Navigation History:**
  /// - `previousPath` - Previous route path
  /// - `nextPath` - Next route path
  /// - `canGoBack` - Whether can go back
  /// - `canGoForward` - Whether can go forward
  /// - `history` - Full navigation history object
  ///
  /// **Nested Routes:**
  /// - `parentPattern` - Parent route pattern
  /// - `childPatterns` - Child route pattern list
  /// - `hasParent` - Whether has parent route
  /// - `hasChildren` - Whether has child routes
  ScopedRouteInfo get route {
    // First try to get from DashRouteScope (preferred - always accurate)
    final scoped = ScopedRouteInfo.maybeOf(this);
    if (scoped != null) return scoped;

    // Fallback: Try to create from ModalRoute (for compatibility)
    return FallbackRouteInfo.fromModalRoute(this);
  }

  /// Check if route info is from DashRouter.
  ///
  /// Returns true if the current context is inside a DashRouter-managed route.
  bool get hasRouteScope => DashRouteScope.maybeOf(this) != null;
}

/// Builder Widget that rebuilds on route changes.
///
/// Use when you need to respond to route changes in a subtree.
///
/// ```dart
/// RouteBuilder(
///   builder: (context, route) {
///     return Text('Current path: ${route.uri}');
///   },
/// )
/// ```
class RouteBuilder extends StatelessWidget {
  /// Builder function that receives route info
  final Widget Function(BuildContext context, ScopedRouteInfo route) builder;

  const RouteBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(context, context.route);
  }
}

/// Renders widget based on route condition.
///
/// ```dart
/// RouteWhen(
///   condition: (route) => route.name == 'home',
///   builder: (context, route) => HomeContent(),
///   orElse: (context, route) => OtherContent(),
/// )
/// ```
class RouteWhen extends StatelessWidget {
  /// Condition to evaluate
  final bool Function(ScopedRouteInfo route) condition;

  /// Builder when condition is true
  final Widget Function(BuildContext context, ScopedRouteInfo route) builder;

  /// Builder when condition is false (optional)
  final Widget Function(BuildContext context, ScopedRouteInfo route)? orElse;

  const RouteWhen({
    super.key,
    required this.condition,
    required this.builder,
    this.orElse,
  });

  @override
  Widget build(BuildContext context) {
    final route = context.route;
    if (condition(route)) {
      return builder(context, route);
    }
    return orElse?.call(context, route) ?? const SizedBox.shrink();
  }
}

/// Displays different widgets based on route name.
///
/// ```dart
/// RouteSwitch(
///   routes: {
///     'home': (context, route) => HomeContent(),
///     'settings': (context, route) => SettingsContent(),
///   },
///   orElse: (context, route) => NotFoundContent(),
/// )
/// ```
class RouteSwitch extends StatelessWidget {
  /// Route name to builder mapping
  final Map<String, Widget Function(BuildContext, ScopedRouteInfo)> routes;

  /// Fallback builder
  final Widget Function(BuildContext, ScopedRouteInfo)? orElse;

  const RouteSwitch({
    super.key,
    required this.routes,
    this.orElse,
  });

  @override
  Widget build(BuildContext context) {
    final route = context.route;
    final builder = routes[route.name];
    if (builder != null) {
      return builder(context, route);
    }
    return orElse?.call(context, route) ?? const SizedBox.shrink();
  }
}

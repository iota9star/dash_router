import 'package:dash_router_annotations/dash_router_annotations.dart';
import 'package:flutter/widgets.dart';

import '../router/dash_router.dart';
import '../router/route_data.dart';

/// Navigation manager providing high-level navigation API.
///
/// This class wraps the core DashRouter functionality in a
/// convenient, high-level API for common navigation operations.
/// It provides type-safe methods for all navigation patterns.
///
/// ## Example
///
/// ```dart
/// class MyWidget extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final nav = context.navigationManager;
///     
///     return Column(
///       children: [
///         ElevatedButton(
///           onPressed: () => nav.push('/user/123'),
///           child: Text('Push User'),
///         ),
///         ElevatedButton(
///           onPressed: () => nav.replace('/settings'),
///           child: Text('Replace Settings'),
///         ),
///         if (nav.canGoBack)
///           ElevatedButton(
///             onPressed: () => nav.back(),
///             child: Text('Back'),
///           ),
///       ],
///     );
///   }
/// }
/// ```
class NavigationManager {
  /// The underlying router instance.
  final DashRouter _router;

  /// Creates a navigation manager.
  ///
  /// [_router] - The DashRouter instance to wrap
  NavigationManager(this._router);

  /// Gets the currently active route.
  ///
  /// Returns null if no route is currently active.
  ///
  /// Example:
  /// ```dart
  /// final current = nav.currentRoute;
  /// if (current != null) {
  ///   print('Current path: ${current.path}');
  /// }
  /// ```
  RouteData? get currentRoute => _router.currentRoute;

  /// Gets the path of the previous route.
  ///
  /// Returns null if there's no previous route in history.
  ///
  /// Example:
  /// ```dart
  /// final previous = nav.previousPath;
  /// if (previous != null) {
  ///   print('Came from: $previous');
  /// }
  /// ```
  String? get previousPath => _router.history.previousPath;

  /// Checks if navigation can go back.
  ///
  /// Returns false if at the root of navigation stack.
  /// This respects route guards that might prevent popping.
  ///
  /// Example:
  /// ```dart
  /// if (nav.canGoBack) {
  ///   nav.back();
  /// }
  /// ```
  bool get canGoBack => _router.canPop();

  /// Pushes a new route onto the navigation stack.
  ///
  /// [path] - The route path to navigate to
  /// [query] - Optional query parameters
  /// [extra] - Optional extra data to pass
  /// [transition] - Optional custom transition
  ///
  /// Returns the result from the pushed route if any.
  ///
  /// Example:
  /// ```dart
  /// final result = await nav.push(
  ///   '/user/123',
  ///   query: {'tab': 'profile'},
  ///   extra: {'source': 'search'},
  /// );
  /// ```
  Future<T?> push<T>(
    String path, {
    Map<String, dynamic>? query,
    Object? extra,
    DashTransition? transition,
  }) async {
    return _router.pushNamed<T>(
      path,
      query: query,
      body: _buildArguments(extra, transition),
    );
  }

  /// Push and replace current route
  Future<T?> replace<T, TO extends Object?>(
    String path, {
    Map<String, dynamic>? query,
    Object? extra,
    TO? result,
    DashTransition? transition,
  }) async {
    return _router.pushReplacementNamed<T, TO>(
      path,
      query: query,
      body: _buildArguments(extra, transition),
      result: result,
    );
  }

  /// Pop current route and push new route
  Future<T?> popAndPush<T, TO extends Object?>(
    String path, {
    Map<String, dynamic>? query,
    Object? extra,
    TO? result,
    DashTransition? transition,
  }) async {
    return _router.popAndPushNamed<T, TO>(
      path,
      query: query,
      body: _buildArguments(extra, transition),
      result: result,
    );
  }

  /// Push and remove all routes until predicate
  Future<T?> pushAndRemoveUntil<T>(
    String path,
    bool Function(Route<dynamic>) predicate, {
    Map<String, dynamic>? query,
    Object? extra,
    DashTransition? transition,
  }) async {
    return _router.pushNamedAndRemoveUntil<T>(
      path,
      predicate,
      query: query,
      body: _buildArguments(extra, transition),
    );
  }

  /// Push and remove all routes
  Future<T?> pushAndRemoveAll<T>(
    String path, {
    Map<String, dynamic>? query,
    Object? extra,
    DashTransition? transition,
  }) async {
    return pushAndRemoveUntil<T>(
      path,
      (_) => false,
      query: query,
      extra: extra,
      transition: transition,
    );
  }

  /// Pop current route
  void pop<T>([T? result]) {
    _router.pop<T>(result);
  }

  /// Pop until predicate
  void popUntil(bool Function(Route<dynamic>) predicate) {
    _router.popUntil(predicate);
  }

  /// Pop until route name
  void popUntilNamed(String path) {
    _router.popUntilNamed(path);
  }

  /// Pop to root route
  void popToRoot() {
    popUntil((route) => route.isFirst);
  }

  /// Maybe pop (respects route guards)
  Future<bool> maybePop<T>([T? result]) {
    return _router.maybePop<T>(result);
  }

  /// Go back in history
  void back<T>([T? result]) {
    if (canGoBack) {
      pop<T>(result);
    }
  }

  Object? _buildArguments(Object? extra, DashTransition? transition) {
    if (transition == null && extra == null) return null;
    if (transition == null) return extra;
    if (extra == null) {
      return {'_transition': transition};
    }
    if (extra is Map<String, dynamic>) {
      return {...extra, '_transition': transition};
    }
    return {'_body': extra, '_transition': transition};
  }
}

/// Navigation intent for declarative navigation
class NavigationIntent {
  /// Target path
  final String path;

  /// Query parameters
  final Map<String, dynamic>? query;

  /// Extra data
  final Object? extra;

  /// Transition animation
  final DashTransition? transition;

  /// Navigation action type
  final NavigationAction action;

  const NavigationIntent({
    required this.path,
    this.query,
    this.extra,
    this.transition,
    this.action = NavigationAction.push,
  });

  /// Create push intent
  const NavigationIntent.push(
    this.path, {
    this.query,
    this.extra,
    this.transition,
  }) : action = NavigationAction.push;

  /// Create replace intent
  const NavigationIntent.replace(
    this.path, {
    this.query,
    this.extra,
    this.transition,
  }) : action = NavigationAction.replace;

  /// Create pop and push intent
  const NavigationIntent.popAndPush(
    this.path, {
    this.query,
    this.extra,
    this.transition,
  }) : action = NavigationAction.popAndPush;

  /// Create pop intent
  const NavigationIntent.pop()
      : path = '',
        query = null,
        extra = null,
        transition = null,
        action = NavigationAction.pop;
}

/// Navigation action types
enum NavigationAction {
  push,
  replace,
  popAndPush,
  pushAndRemoveAll,
  pop,
  popUntil,
}

/// Execute a navigation intent
extension NavigationIntentExecutor on NavigationManager {
  Future<T?> execute<T>(NavigationIntent intent) async {
    switch (intent.action) {
      case NavigationAction.push:
        return push<T>(
          intent.path,
          query: intent.query,
          extra: intent.extra,
          transition: intent.transition,
        );
      case NavigationAction.replace:
        return replace<T, Object?>(
          intent.path,
          query: intent.query,
          extra: intent.extra,
          transition: intent.transition,
        );
      case NavigationAction.popAndPush:
        return popAndPush<T, Object?>(
          intent.path,
          query: intent.query,
          extra: intent.extra,
          transition: intent.transition,
        );
      case NavigationAction.pushAndRemoveAll:
        return pushAndRemoveAll<T>(
          intent.path,
          query: intent.query,
          extra: intent.extra,
          transition: intent.transition,
        );
      case NavigationAction.pop:
        pop<T>();
        return null;
      case NavigationAction.popUntil:
        popUntilNamed(intent.path);
        return null;
    }
  }
}

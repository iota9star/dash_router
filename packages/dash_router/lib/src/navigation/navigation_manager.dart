import 'package:dash_router_annotations/dash_router_annotations.dart';
import 'package:flutter/widgets.dart';

import '../router/dash_router.dart';
import '../router/route_data.dart';

/// Navigation manager providing high-level navigation API
class NavigationManager {
  final DashRouter _router;

  NavigationManager(this._router);

  /// Get current route
  RouteData? get currentRoute => _router.currentRoute;

  /// Get previous route path
  String? get previousPath => _router.history.previousPath;

  /// Check if can go back
  bool get canGoBack => _router.canPop();

  /// Push a new route
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

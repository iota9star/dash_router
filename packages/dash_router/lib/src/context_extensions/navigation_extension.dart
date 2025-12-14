// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dash_router_annotations/dash_router_annotations.dart';
import 'package:flutter/widgets.dart';

import '../navigation/navigation_manager.dart';
import '../router/dash_router.dart';
import '../typed_routes/typed_route.dart';

/// Navigation context extension.
///
/// Provides convenient navigation methods directly on [BuildContext].
/// Separates typed route navigation from string-path navigation for clarity.
///
/// ## Typed Route Navigation (Recommended)
///
/// ```dart
/// // Push with typed route
/// context.push(AppUser$IdRoute(id: '123', tab: 'profile'));
///
/// // Replace with typed route
/// context.replace(AppSettingsRoute());
///
/// // Pop and push
/// context.popAndPush(AppHomeRoute());
/// ```
///
/// ## String Path Navigation
///
/// ```dart
/// // Push with path
/// context.pushNamed('/user/123', query: {'tab': 'profile'});
///
/// // Replace with path
/// context.replaceNamed('/home');
///
/// // Push with body arguments
/// context.pushNamed('/order', body: orderData);
/// ```
///
/// ## Pop Operations
///
/// ```dart
/// context.pop();           // Pop current route
/// context.pop(result);     // Pop with result
/// context.popToRoot();     // Pop to root route
/// context.maybePop();      // Respects route guards
/// ```
extension NavigationContextExtension on BuildContext {
  /// Get the navigation manager.
  NavigationManager get navigation => NavigationManager(DashRouter.of(this));

  /// Get the router instance.
  DashRouter get router => DashRouter.of(this);

  // ============================================
  // Typed Route Navigation
  // ============================================

  /// Push a typed route onto the navigation stack.
  ///
  /// This is the recommended way to navigate with type safety.
  ///
  /// ```dart
  /// context.push(AppUser$IdRoute(id: '123', tab: 'profile'));
  /// ```
  ///
  /// The route's `$transition` property is used if set, allowing per-navigation
  /// custom transitions:
  ///
  /// ```dart
  /// context.push(AppSettingsRoute($transition: DashSlideTransition.bottom()));
  /// ```
  Future<T?> push<T>(DashTypedRoute route) {
    return router.pushRoute<T>(route);
  }

  /// Replace the current route with a typed route.
  ///
  /// ```dart
  /// context.replace(AppHomeRoute());
  /// context.replace<void, String>(AppHomeRoute(), result: 'done');
  /// ```
  Future<T?> replace<T, TO extends Object?>(
    DashTypedRoute route, {
    TO? result,
  }) {
    return router.replaceRoute<T, TO>(route, result: result);
  }

  /// Pop current route and push a typed route.
  ///
  /// ```dart
  /// context.popAndPush(AppLoginRoute());
  /// context.popAndPush<void, String>(AppLoginRoute(), result: 'logged_out');
  /// ```
  Future<T?> popAndPush<T, TO extends Object?>(
    DashTypedRoute route, {
    TO? result,
  }) {
    return router.popAndPushNamed<T, TO>(
      route.$path,
      query: route.$query,
      body: route.$body,
      result: result,
      transition: route.$transition,
    );
  }

  /// Push a typed route and remove all routes until predicate.
  ///
  /// ```dart
  /// // Remove all routes except root
  /// context.pushAndRemoveUntil(
  ///   AppHomeRoute(),
  ///   (route) => route.isFirst,
  /// );
  /// ```
  Future<T?> pushAndRemoveUntil<T>(
    DashTypedRoute route,
    bool Function(Route<dynamic>) predicate,
  ) {
    return router.pushNamedAndRemoveUntil<T>(
      route.$path,
      predicate,
      query: route.$query,
      body: route.$body,
      transition: route.$transition,
    );
  }

  /// Push a typed route and remove all other routes (clear stack).
  ///
  /// Commonly used for login/logout flows.
  ///
  /// ```dart
  /// // Clear stack and show login
  /// context.pushAndRemoveAll(AppLoginRoute());
  /// ```
  Future<T?> pushAndRemoveAll<T>(DashTypedRoute route) {
    return pushAndRemoveUntil<T>(route, (_) => false);
  }

  // ============================================
  // String Path Navigation
  // ============================================

  /// Push a route by path string.
  ///
  /// Use this when you need to navigate with a dynamic path or when
  /// typed routes are not available.
  ///
  /// ```dart
  /// context.pushNamed('/user/123');
  /// context.pushNamed('/search', query: {'q': 'flutter'});
  /// context.pushNamed('/order', body: orderData);
  /// context.pushNamed('/modal', transition: DashSlideTransition.bottom());
  /// ```
  Future<T?> pushNamed<T>(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    DashTransition? transition,
  }) {
    return navigation.push<T>(
      path,
      query: query,
      extra: body,
      transition: transition,
    );
  }

  /// Replace current route with a path string.
  ///
  /// ```dart
  /// context.replaceNamed('/home');
  /// context.replaceNamed<void, String>('/home', result: 'done');
  /// ```
  Future<T?> replaceNamed<T, TO extends Object?>(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    TO? result,
    DashTransition? transition,
  }) {
    return navigation.replace<T, TO>(
      path,
      query: query,
      extra: body,
      result: result,
      transition: transition,
    );
  }

  /// Pop current route and push by path string.
  ///
  /// ```dart
  /// context.popAndPushNamed('/login');
  /// ```
  Future<T?> popAndPushNamed<T, TO extends Object?>(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    TO? result,
    DashTransition? transition,
  }) {
    return navigation.popAndPush<T, TO>(
      path,
      query: query,
      extra: body,
      result: result,
      transition: transition,
    );
  }

  /// Push by path and remove routes until predicate.
  ///
  /// ```dart
  /// context.pushNamedAndRemoveUntil('/home', (route) => false);
  /// ```
  Future<T?> pushNamedAndRemoveUntil<T>(
    String path,
    bool Function(Route<dynamic>) predicate, {
    Map<String, dynamic>? query,
    Object? body,
    DashTransition? transition,
  }) {
    return navigation.pushAndRemoveUntil<T>(
      path,
      predicate,
      query: query,
      extra: body,
      transition: transition,
    );
  }

  /// Push by path and remove all routes (clear stack).
  ///
  /// ```dart
  /// context.pushNamedAndRemoveAll('/login');
  /// ```
  Future<T?> pushNamedAndRemoveAll<T>(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    DashTransition? transition,
  }) {
    return pushNamedAndRemoveUntil<T>(
      path,
      (_) => false,
      query: query,
      body: body,
      transition: transition,
    );
  }

  // ============================================
  // Pop Operations
  // ============================================

  /// Pop the current route.
  ///
  /// Optionally return a result to the previous route.
  ///
  /// ```dart
  /// context.pop();
  /// context.pop('result');
  /// context.pop<String>('success');
  /// ```
  void pop<T>([T? result]) {
    navigation.pop<T>(result);
  }

  /// Pop routes until predicate returns true.
  ///
  /// ```dart
  /// context.popUntil((route) => route.isFirst);
  /// ```
  void popUntil(bool Function(Route<dynamic>) predicate) {
    navigation.popUntil(predicate);
  }

  /// Pop routes until reaching the specified path.
  ///
  /// ```dart
  /// context.popUntilNamed('/home');
  /// ```
  void popUntilNamed(String path) {
    navigation.popUntilNamed(path);
  }

  /// Pop all routes to return to the root.
  ///
  /// ```dart
  /// context.popToRoot();
  /// ```
  void popToRoot() {
    navigation.popToRoot();
  }

  /// Attempt to pop, respecting route guards.
  ///
  /// Returns `true` if the pop was successful, `false` otherwise.
  ///
  /// ```dart
  /// final didPop = await context.maybePop();
  /// if (!didPop) {
  ///   // Handle case where pop was prevented
  /// }
  /// ```
  Future<bool> maybePop<T>([T? result]) {
    return navigation.maybePop<T>(result);
  }

  /// Go back (alias for [pop]).
  ///
  /// ```dart
  /// context.back();
  /// context.back('result');
  /// ```
  void back<T>([T? result]) {
    navigation.back<T>(result);
  }

  // ============================================
  // Navigation State
  // ============================================

  /// Check if navigation can go back.
  ///
  /// Returns `true` if there is a previous route in the stack.
  bool get canGoBack => navigation.canGoBack;

  /// Get the previous route path, if available.
  String? get previousPath => navigation.previousPath;
}

/// Navigator state extension for convenience methods.
extension NavigatorStateExtension on NavigatorState {
  /// Push a named route with convenience parameters.
  ///
  /// Automatically builds the full path with query parameters.
  ///
  /// ```dart
  /// Navigator.of(context).pushPath('/user/123', query: {'tab': 'profile'});
  /// ```
  Future<T?> pushPath<T>(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) {
    String fullPath = path;
    if (query != null && query.isNotEmpty) {
      final queryString = query.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}',
          )
          .join('&');
      fullPath = '$path?$queryString';
    }
    return pushNamed<T>(fullPath, arguments: body);
  }
}

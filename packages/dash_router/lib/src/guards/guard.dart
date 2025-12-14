// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../utils/route_utils.dart';
import 'guard_result.dart';

/// Base class for route guards.
///
/// Route guards intercept navigation and can:
/// - Allow navigation to proceed
/// - Deny navigation with a message
/// - Redirect to a different route
///
/// Guards are executed before navigation completes. They can perform
/// async operations like checking authentication status.
///
/// ## Creating a Guard
///
/// Extend [DashGuard] and implement [canActivate]:
///
/// ```dart
/// class AuthGuard extends DashGuard {
///   final AuthService authService;
///
///   const AuthGuard(this.authService);
///
///   @override
///   Future<GuardResult> canActivate(GuardContext context) async {
///     if (await authService.isAuthenticated()) {
///       return const GuardAllow();
///     }
///     return const GuardRedirect('/login');
///   }
/// }
/// ```
///
/// ## Registering Guards
///
/// Register guards with the router:
///
/// ```dart
/// router.guards.register(AuthGuard(authService));
/// ```
///
/// ## Applying Guards to Routes
///
/// In route annotations, specify guard types:
///
/// ```dart
/// @DashRoute(
///   path: '/admin',
///   guards: [AuthGuard, AdminGuard],
/// )
/// class AdminPage extends StatelessWidget { ... }
/// ```
///
/// The guard is matched by its [runtimeType] name.
///
/// ## Guard Execution Order
///
/// Guards run in order of [priority] (higher priority runs first).
/// If any guard denies access, subsequent guards are not executed.
///
/// ## Route Filtering
///
/// Override [routes] and [excludeRoutes] to control which paths
/// the guard applies to:
///
/// ```dart
/// class AuthGuard extends DashGuard {
///   @override
///   List<String>? get routes => ['/admin/**', '/user/**'];
///
///   @override
///   List<String>? get excludeRoutes => ['/admin/public'];
///
///   @override
///   Future<GuardResult> canActivate(GuardContext context) async {
///     // Only called for matching routes
///   }
/// }
/// ```
abstract class DashGuard {
  /// Creates a route guard.
  const DashGuard();

  /// Priority of this guard (higher runs first).
  ///
  /// Default is 0. Use positive values for higher priority.
  int get priority => 0;

  /// Routes this guard applies to (glob patterns).
  ///
  /// If null, the guard can apply to all routes (subject to route config).
  ///
  /// Supported patterns:
  /// - Exact match: `/user/profile`
  /// - Single segment wildcard: `/user/*`
  /// - Multi-segment wildcard: `/admin/**`
  List<String>? get routes => null;

  /// Routes this guard excludes (glob patterns).
  ///
  /// Exclusions take precedence over [routes].
  List<String>? get excludeRoutes => null;

  /// Checks if this guard should run for the given path.
  ///
  /// Returns true if:
  /// 1. The path is not in [excludeRoutes]
  /// 2. AND either [routes] is null OR the path matches a pattern in [routes]
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

  /// Determines if navigation should be allowed.
  ///
  /// Return one of:
  /// - [GuardAllow] to allow navigation
  /// - [GuardDeny] to block with a message
  /// - [GuardRedirect] to redirect to another path
  ///
  /// The [context] provides information about the navigation request.
  Future<GuardResult> canActivate(GuardContext context);

  /// Called after navigation is successfully allowed.
  ///
  /// Override to perform post-navigation actions like analytics.
  Future<void> onActivated(GuardContext context) async {}

  /// Called when navigation is denied by this guard.
  ///
  /// Override to handle denied navigation, like showing a message.
  Future<void> onDenied(GuardContext context, GuardResult result) async {}
}

/// A function-based route guard.
///
/// Use this when you need a simple guard without creating a class:
///
/// ```dart
/// router.guards.register(
///   FunctionalGuard(
///     canActivate: (context) async {
///       if (isLoggedIn) return const GuardAllow();
///       return const GuardRedirect('/login');
///     },
///     routes: ['/protected/**'],
///   ),
/// );
/// ```
class FunctionalGuard extends DashGuard {
  /// Creates a functional guard.
  FunctionalGuard({
    required Future<GuardResult> Function(GuardContext context) canActivate,
    this.priority = 0,
    this.routes,
    this.excludeRoutes,
  }) : _canActivate = canActivate;

  final Future<GuardResult> Function(GuardContext context) _canActivate;

  @override
  final int priority;

  @override
  final List<String>? routes;

  @override
  final List<String>? excludeRoutes;

  @override
  Future<GuardResult> canActivate(GuardContext context) =>
      _canActivate(context);
}

/// A guard that checks a synchronous condition.
///
/// ```dart
/// router.guards.register(
///   ConditionalGuard(
///     condition: () => authService.isLoggedIn,
///     redirectTo: '/login',
///   ),
/// );
/// ```
class ConditionalGuard extends DashGuard {
  /// Creates a conditional guard.
  ConditionalGuard({
    required this.condition,
    required this.redirectTo,
    this.redirectParams,
    this.priority = 0,
    this.routes,
    this.excludeRoutes,
  });

  /// The condition to check. Return true to allow navigation.
  final bool Function() condition;

  /// Path to redirect to when condition is false.
  final String redirectTo;

  /// Optional query parameters for the redirect.
  final Map<String, dynamic>? redirectParams;

  @override
  final int priority;

  @override
  final List<String>? routes;

  @override
  final List<String>? excludeRoutes;

  @override
  Future<GuardResult> canActivate(GuardContext context) async {
    if (condition()) {
      return const GuardAllow();
    }
    return GuardRedirect(redirectTo, queryParams: redirectParams);
  }
}

/// A guard that checks an asynchronous condition.
///
/// ```dart
/// router.guards.register(
///   AsyncConditionalGuard(
///     condition: () => authService.checkAuth(),
///     redirectTo: '/login',
///   ),
/// );
/// ```
class AsyncConditionalGuard extends DashGuard {
  /// Creates an async conditional guard.
  AsyncConditionalGuard({
    required this.condition,
    required this.redirectTo,
    this.redirectParams,
    this.priority = 0,
    this.routes,
    this.excludeRoutes,
  });

  /// The async condition to check. Return true to allow navigation.
  final Future<bool> Function() condition;

  /// Path to redirect to when condition is false.
  final String redirectTo;

  /// Optional query parameters for the redirect.
  final Map<String, dynamic>? redirectParams;

  @override
  final int priority;

  @override
  final List<String>? routes;

  @override
  final List<String>? excludeRoutes;

  @override
  Future<GuardResult> canActivate(GuardContext context) async {
    if (await condition()) {
      return const GuardAllow();
    }
    return GuardRedirect(redirectTo, queryParams: redirectParams);
  }
}

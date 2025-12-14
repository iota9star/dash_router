// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dash_router/dash_router.dart';

/// Example authentication guard.
///
/// Protects routes matching `/user/**` pattern, redirecting
/// unauthenticated users to the login page.
///
/// ## Usage in route annotation
///
/// ```dart
/// @DashRoute(
///   path: '/app/user/:id',
///   guards: [AuthGuard()],
/// )
/// class UserPage extends StatelessWidget { ... }
/// ```
class AuthGuard extends DashGuard {
  /// Creates an authentication guard.
  const AuthGuard();

  /// Simulated login state.
  ///
  /// In production, this would be managed by an auth service.
  static bool isLoggedIn = false;

  @override
  int get priority => 100;

  @override
  List<String>? get routes => const ['/user/**'];

  @override
  Future<GuardResult> canActivate(GuardContext context) async {
    if (isLoggedIn) {
      return const GuardAllow();
    }
    return const GuardRedirect('/login');
  }
}

/// Role-based access guard example.
///
/// Checks if the user has the required role to access a route.
class RoleGuard extends DashGuard {
  /// Creates a role guard with allowed roles.
  RoleGuard({required this.allowedRoles});

  /// List of roles allowed to access protected routes.
  final List<String> allowedRoles;

  @override
  int get priority => 90;

  @override
  Future<GuardResult> canActivate(GuardContext context) async {
    // In production, fetch user role from auth service
    const userRole = 'user';

    if (allowedRoles.contains(userRole)) {
      return const GuardAllow();
    }
    return const GuardDeny('Insufficient permissions');
  }
}

/// Guard that validates required route parameters.
///
/// Ensures all required parameters are present before navigation.
class ParamRequiredGuard extends DashGuard {
  /// Creates a param required guard.
  ParamRequiredGuard({required this.requiredParams});

  /// List of required parameter names.
  final List<String> requiredParams;

  @override
  int get priority => 80;

  @override
  Future<GuardResult> canActivate(GuardContext context) async {
    final params = context.targetRoute.params.all;
    for (final param in requiredParams) {
      if (!params.containsKey(param) || params[param] == null) {
        return GuardDeny('Missing required parameter: $param');
      }
    }
    return const GuardAllow();
  }
}

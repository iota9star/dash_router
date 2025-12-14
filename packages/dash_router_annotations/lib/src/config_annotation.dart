// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

/// Global router configuration annotation.
///
/// Place this annotation on your main app class or a configuration class
/// to customize the code generation behavior of dash_router.
///
/// ## Example
///
/// ```dart
/// @DashRouterConfig(
///   generateNavigation: true,
///   generateRouteInfo: true,
///   defaultTransition: 'platform',
/// )
/// class MyApp extends StatelessWidget {
///   const MyApp({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp.router(
///       routerConfig: dashRouter,
///     );
///   }
/// }
/// ```
///
/// ## Configuration Options
///
/// - [generateNavigation] - Generate type-safe navigation extension methods
/// - [generateRouteInfo] - Generate route information classes
/// - [defaultTransition] - Default transition type for all routes
/// - [outputPath] - Custom output path for generated code
/// - [includeObserver] - Whether to include route observer in generated code
@immutable
class DashRouterConfig {
  /// Creates a router configuration annotation.
  ///
  /// [generateNavigation] - Whether to generate type-safe navigation extensions.
  ///   Defaults to true.
  /// [generateRouteInfo] - Whether to generate route info classes.
  ///   Defaults to true.
  /// [defaultTransition] - Default transition type name.
  ///   Defaults to 'platform'. Options: 'platform', 'material', 'cupertino',
  ///   'fade', 'slide', 'scale', 'none'.
  /// [outputPath] - Custom output file path for generated routes.
  /// [includeObserver] - Whether to include route observer.
  ///   Defaults to true.
  ///
  /// Example:
  /// ```dart
  /// @DashRouterConfig(
  ///   generateNavigation: true,
  ///   generateRouteInfo: true,
  ///   defaultTransition: 'cupertino',
  ///   includeObserver: true,
  /// )
  /// class AppConfig {}
  /// ```
  const DashRouterConfig({
    this.generateNavigation = true,
    this.generateRouteInfo = true,
    this.defaultTransition = 'platform',
    this.outputPath,
    this.includeObserver = true,
  });

  /// Whether to generate type-safe navigation extensions.
  ///
  /// When true, generates extension methods on [BuildContext] for
  /// type-safe navigation to each route.
  ///
  /// Example generated code:
  /// ```dart
  /// extension UserPageNavigation on BuildContext {
  ///   Future<T?> pushUserPage<T>({required String id}) {
  ///     return push<T>('/user/$id');
  ///   }
  /// }
  /// ```
  final bool generateNavigation;

  /// Whether to generate route info classes.
  ///
  /// When true, generates classes containing route information
  /// such as path patterns, parameter types, and metadata.
  ///
  /// Example generated code:
  /// ```dart
  /// class UserPageRouteInfo {
  ///   static const String path = '/user/:id';
  ///   static const String name = 'userPage';
  /// }
  /// ```
  final bool generateRouteInfo;

  /// Default transition type name for all routes.
  ///
  /// This transition is used when a route doesn't specify its own transition.
  /// Available options:
  /// - `'platform'` - Platform-adaptive (iOS: slide, Android: fade)
  /// - `'material'` - Material Design transition
  /// - `'cupertino'` - iOS-style slide transition
  /// - `'fade'` - Fade in/out transition
  /// - `'slide'` - Slide from right transition
  /// - `'scale'` - Scale/zoom transition
  /// - `'none'` - No transition (instant)
  ///
  /// Example:
  /// ```dart
  /// @DashRouterConfig(defaultTransition: 'cupertino')
  /// ```
  final String defaultTransition;

  /// Output file path for generated routes.
  ///
  /// If not specified, the generated file will be placed next to the
  /// annotated file with a `.g.dart` extension.
  ///
  /// Example:
  /// ```dart
  /// @DashRouterConfig(outputPath: 'lib/generated/routes.g.dart')
  /// ```
  final String? outputPath;

  /// Whether to include route observer in generated code.
  ///
  /// When true, generates a route observer that can be used to
  /// track navigation events for analytics or debugging.
  ///
  /// Example:
  /// ```dart
  /// @DashRouterConfig(includeObserver: true)
  /// // Generated code will include:
  /// // final routeObserver = DashRouteObserver();
  /// ```
  final bool includeObserver;
}

/// Annotation to mark a class as a route guard.
///
/// Route guards can prevent navigation or redirect to another route
/// based on conditions like authentication state.
///
/// ## Example
///
/// ```dart
/// @RouteGuard(priority: 100)
/// class AuthGuard implements DashGuard {
///   const AuthGuard();
///
///   @override
///   Future<GuardResult> canActivate(RouteContext context) async {
///     final isLoggedIn = await checkAuth();
///     if (isLoggedIn) {
///       return GuardResult.proceed();
///     }
///     return GuardResult.redirect('/login');
///   }
/// }
/// ```
///
/// ## Usage in Routes
///
/// ```dart
/// @DashRoute(path: '/profile', guards: [AuthGuard])
/// class ProfilePage extends StatelessWidget { ... }
/// ```
@immutable
class RouteGuard {
  /// Creates a route guard annotation.
  ///
  /// [priority] - Execution priority (higher runs first). Defaults to 0.
  /// [routes] - Glob patterns of routes this guard applies to.
  /// [exclude] - Glob patterns of routes to exclude from this guard.
  ///
  /// Example:
  /// ```dart
  /// @RouteGuard(
  ///   priority: 100,
  ///   routes: ['/admin/*', '/settings/*'],
  ///   exclude: ['/admin/public'],
  /// )
  /// class AdminGuard implements DashGuard { ... }
  /// ```
  const RouteGuard({
    this.priority = 0,
    this.routes,
    this.exclude,
  });

  /// Execution priority (higher runs first).
  ///
  /// Guards with higher priority values execute before guards with
  /// lower priority values. Default is 0.
  ///
  /// Example:
  /// ```dart
  /// @RouteGuard(priority: 100)  // Runs first
  /// class AuthGuard implements DashGuard { ... }
  ///
  /// @RouteGuard(priority: 50)   // Runs second
  /// class RoleGuard implements DashGuard { ... }
  /// ```
  final int priority;

  /// Glob patterns of routes this guard applies to.
  ///
  /// If null, the guard applies to all routes where it's explicitly added.
  /// Use glob patterns like `/admin/*` to match multiple routes.
  ///
  /// Example:
  /// ```dart
  /// @RouteGuard(routes: ['/admin/*', '/settings'])
  /// class AdminGuard implements DashGuard { ... }
  /// ```
  final List<String>? routes;

  /// Glob patterns of routes to exclude from this guard.
  ///
  /// Use this to exclude specific routes from a guard that would
  /// otherwise apply to them.
  ///
  /// Example:
  /// ```dart
  /// @RouteGuard(
  ///   routes: ['/admin/*'],
  ///   exclude: ['/admin/public', '/admin/login'],
  /// )
  /// class AdminGuard implements DashGuard { ... }
  /// ```
  final List<String>? exclude;
}

/// Annotation to mark a class as route middleware.
///
/// Middleware can intercept and modify navigation requests,
/// perform logging, or execute side effects.
///
/// ## Example
///
/// ```dart
/// @RouteMiddleware(priority: 10)
/// class LoggingMiddleware implements DashMiddleware {
///   const LoggingMiddleware();
///
///   @override
///   Future<void> onNavigate(MiddlewareContext context) async {
///     print('Navigating to: ${context.path}');
///     await context.next();
///     print('Navigation completed');
///   }
/// }
/// ```
///
/// ## Usage in Routes
///
/// ```dart
/// @DashRoute(path: '/tracked', middleware: [LoggingMiddleware])
/// class TrackedPage extends StatelessWidget { ... }
/// ```
@immutable
class RouteMiddleware {
  /// Creates a route middleware annotation.
  ///
  /// [priority] - Execution priority (higher runs first). Defaults to 0.
  /// [routes] - Glob patterns of routes this middleware applies to.
  /// [exclude] - Glob patterns of routes to exclude from this middleware.
  ///
  /// Example:
  /// ```dart
  /// @RouteMiddleware(
  ///   priority: 50,
  ///   routes: ['/api/*'],
  /// )
  /// class ApiMiddleware implements DashMiddleware { ... }
  /// ```
  const RouteMiddleware({
    this.priority = 0,
    this.routes,
    this.exclude,
  });

  /// Execution priority (higher runs first).
  ///
  /// Middleware with higher priority values execute before middleware
  /// with lower priority values. Default is 0.
  final int priority;

  /// Glob patterns of routes this middleware applies to.
  ///
  /// If null, the middleware applies to all routes where it's
  /// explicitly added.
  final List<String>? routes;

  /// Glob patterns of routes to exclude from this middleware.
  ///
  /// Use this to exclude specific routes from middleware that would
  /// otherwise apply to them.
  final List<String>? exclude;
}

/// Annotation to mark a page as requiring authentication.
///
/// This is a convenience annotation that automatically adds an
/// authentication guard to the route.
///
/// ## Example
///
/// ```dart
/// @RequiresAuth(redirectTo: '/login')
/// @DashRoute(path: '/profile')
/// class ProfilePage extends StatelessWidget {
///   const ProfilePage({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Profile');
/// }
/// ```
///
/// ## With Role Requirements
///
/// ```dart
/// @RequiresAuth(
///   redirectTo: '/unauthorized',
///   roles: ['admin', 'moderator'],
/// )
/// @DashRoute(path: '/admin')
/// class AdminPage extends StatelessWidget { ... }
/// ```
@immutable
class RequiresAuth {
  /// Creates an authentication requirement annotation.
  ///
  /// [redirectTo] - Path to redirect to when not authenticated.
  ///   Defaults to '/login'.
  /// [roles] - Required roles for this route.
  ///   If specified, user must have at least one of these roles.
  ///
  /// Example:
  /// ```dart
  /// @RequiresAuth(
  ///   redirectTo: '/signin',
  ///   roles: ['premium', 'enterprise'],
  /// )
  /// @DashRoute(path: '/premium-content')
  /// class PremiumContentPage extends StatelessWidget { ... }
  /// ```
  const RequiresAuth({
    this.redirectTo = '/login',
    this.roles,
  });

  /// Path to redirect to when not authenticated.
  ///
  /// This path will be navigated to if the user is not authenticated
  /// when trying to access the protected route.
  final String redirectTo;

  /// Required roles for this route.
  ///
  /// If specified, the authenticated user must have at least one of
  /// these roles to access the route. If the user doesn't have any
  /// of the required roles, they will be redirected to [redirectTo].
  final List<String>? roles;
}

/// Annotation to exclude a field from route parameters.
///
/// Use this on widget constructor parameters that should not be
/// treated as route parameters (path, query, or body params).
///
/// ## Example
///
/// ```dart
/// @DashRoute(path: '/user/:id')
/// class UserPage extends StatelessWidget {
///   const UserPage({
///     super.key,
///     required this.id,
///     @IgnoreParam() this.onTap,
///   });
///
///   final String id;       // Route parameter
///   final VoidCallback? onTap;  // Ignored - not a route parameter
///
///   @override
///   Widget build(BuildContext context) => Text('User: $id');
/// }
/// ```
@immutable
class IgnoreParam {
  /// Creates an ignore parameter annotation.
  ///
  /// Example:
  /// ```dart
  /// @DashRoute(path: '/item/:id')
  /// class ItemPage extends StatelessWidget {
  ///   const ItemPage({
  ///     super.key,
  ///     required this.id,
  ///     @IgnoreParam() this.controller,
  ///   });
  ///
  ///   final String id;
  ///   final ScrollController? controller;
  ///
  ///   @override
  ///   Widget build(BuildContext context) => Text('Item: $id');
  /// }
  /// ```
  const IgnoreParam();
}

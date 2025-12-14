// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import 'dash_transition.dart';

/// Main annotation for defining routes in dash_router.
///
/// This annotation is used to mark a widget class as a route destination.
/// The generator will create type-safe navigation code based on these
/// annotations.
///
/// ## Basic Page Route
///
/// ```dart
/// @DashRoute(path: '/user/:id')
/// class UserPage extends StatelessWidget {
///   const UserPage({super.key, required this.id});
///
///   final String id;
///
///   @override
///   Widget build(BuildContext context) => Text('User: $id');
/// }
/// ```
///
/// ## Shell Route (for nested navigation)
///
/// Shell routes wrap child routes with a common layout like a navigation bar.
/// The shell widget must have a `child` parameter.
///
/// ```dart
/// @DashRoute(path: '/app', shell: true)
/// class AppShell extends StatelessWidget {
///   const AppShell({super.key, required this.child});
///
///   final Widget child;
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: child,
///       bottomNavigationBar: const MyNavBar(),
///     );
///   }
/// }
/// ```
///
/// ## Redirect Route
///
/// ```dart
/// @DashRoute(path: '/', redirectTo: '/app/home')
/// class RootRedirect {}
/// ```
///
/// ## Route with Custom Transition
///
/// ```dart
/// @DashRoute(
///   path: '/details',
///   transition: DashSlideTransition.right(),
/// )
/// class DetailsPage extends StatelessWidget {
///   const DetailsPage({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Details');
/// }
/// ```
///
/// ## Route with Guards
///
/// ```dart
/// @DashRoute(
///   path: '/admin',
///   guards: [AuthGuard, AdminGuard],
/// )
/// class AdminPage extends StatelessWidget {
///   const AdminPage({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Admin');
/// }
/// ```
@immutable
class DashRoute {
  /// Creates a route annotation.
  ///
  /// [path] - The path pattern for this route. Required.
  /// [name] - Optional name for named navigation.
  /// [transition] - Custom transition animation for this route.
  /// [initial] - Whether this is the initial/home route.
  /// [parent] - Parent route path for nested routing.
  /// [metadata] - Additional metadata for the route.
  /// [guards] - Route guards that run before navigation.
  /// [middleware] - Middleware that runs during navigation.
  /// [keepAlive] - Whether to preserve state when navigating away.
  /// [fullscreenDialog] - Whether this route is a fullscreen dialog.
  /// [maintainState] - Whether to maintain state when inactive.
  /// [shell] - Whether this is a shell/wrapper route.
  /// [redirectTo] - Target path for redirect routes.
  /// [permanentRedirect] - Whether the redirect is permanent (HTTP 308).
  ///
  /// Example:
  /// ```dart
  /// @DashRoute(
  ///   path: '/user/:id',
  ///   transition: DashFadeTransition(),
  ///   guards: [AuthGuard],
  /// )
  /// class UserPage extends StatelessWidget {
  ///   const UserPage({super.key, required this.id});
  ///   final String id;
  ///
  ///   @override
  ///   Widget build(BuildContext context) => Text('User: $id');
  /// }
  /// ```
  const DashRoute({
    required this.path,
    this.name,
    this.transition,
    this.initial = false,
    this.parent,
    this.metadata,
    this.guards,
    this.middleware,
    this.keepAlive = false,
    this.fullscreenDialog = false,
    this.maintainState = true,
    this.shell = false,
    this.redirectTo,
    this.permanentRedirect = false,
    this.arguments,
  });

  /// Argument types for Record-based body parameters.
  ///
  /// When specified, the generator creates a Record type from these types
  /// that can be accessed via the route info. This allows pages to have
  /// const constructors while still receiving body arguments.
  ///
  /// The generated extension provides a `arguments` getter that returns
  /// the body as a typed Record, e.g., `(UserData, Product)`.
  ///
  /// Example:
  /// ```dart
  /// @DashRoute(
  ///   path: '/order',
  ///   arguments: [UserData, Product],
  /// )
  /// class OrderPage extends StatelessWidget {
  ///   const OrderPage({super.key});
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final route = context.route;
  ///     // Access body as Record type
  ///     final (user, product) = route.arguments;
  ///     return Text(user.displayName);
  ///   }
  /// }
  /// ```
  final List<Type>? arguments;

  /// The path pattern for this route.
  ///
  /// Supports path parameters with `:paramName` syntax:
  /// - `/home` - static path
  /// - `/user/:id` - single path parameter
  /// - `/user/:userId/post/:postId` - multiple path parameters
  /// - `/files/*` - wildcard path (matches all sub-paths)
  ///
  /// Example:
  /// ```dart
  /// @DashRoute(path: '/user/:id/posts/:postId')
  /// class UserPostPage extends StatelessWidget {
  ///   const UserPostPage({super.key, required this.id, required this.postId});
  ///   final String id;
  ///   final String postId;
  ///
  ///   @override
  ///   Widget build(BuildContext context) => Text('Post $postId by User $id');
  /// }
  /// ```
  final String path;

  /// Optional name for this route.
  ///
  /// Used for named navigation like `context.pushNamed('userDetail')`.
  /// If not provided, a name is generated from the class name.
  ///
  /// Example:
  /// ```dart
  /// @DashRoute(path: '/user/:id', name: 'userProfile')
  /// class UserPage extends StatelessWidget { ... }
  ///
  /// // Then navigate using:
  /// context.pushNamed('userProfile', arguments: {'id': '123'});
  /// ```
  final String? name;

  /// The transition animation for this route.
  ///
  /// If not specified, the default transition from router config is used.
  /// See [DashTransition] for available transition types.
  ///
  /// Example:
  /// ```dart
  /// @DashRoute(
  ///   path: '/modal',
  ///   transition: DashSlideTransition.bottom(),
  /// )
  /// class ModalPage extends StatelessWidget { ... }
  /// ```
  final DashTransition? transition;

  /// Whether this is the initial/home route.
  ///
  /// Only one route should have this set to true. This route will be
  /// displayed when the app first starts or when navigating to '/'.
  ///
  /// Example:
  /// ```dart
  /// @DashRoute(path: '/', initial: true)
  /// class HomePage extends StatelessWidget { ... }
  /// ```
  final bool initial;

  /// Parent route path for nested routing.
  ///
  /// When set, this route will be rendered inside the parent's shell.
  ///
  /// Example:
  /// ```dart
  /// @DashRoute(path: '/app/home', parent: '/app')
  /// class HomePage extends StatelessWidget { ... }
  /// ```
  final String? parent;

  /// Route metadata for custom use cases.
  ///
  /// This can be used to store additional data about the route
  /// that can be accessed at runtime.
  ///
  /// Example:
  /// ```dart
  /// @DashRoute(
  ///   path: '/settings',
  ///   metadata: {'requiresAuth': true, 'title': 'Settings'},
  /// )
  /// class SettingsPage extends StatelessWidget { ... }
  /// ```
  final Map<String, dynamic>? metadata;

  /// Route guards that should run before navigating to this route.
  ///
  /// Guards can prevent navigation or redirect to another route.
  /// Specify const guard instances that extend DashGuard.
  ///
  /// Example:
  /// ```dart
  /// @DashRoute(
  ///   path: '/admin',
  ///   guards: [const AuthGuard(), const AdminRoleGuard()],
  /// )
  /// class AdminPage extends StatelessWidget { ... }
  /// ```
  final List<Object>? guards;

  /// Middleware that should run when navigating to this route.
  ///
  /// Middleware can modify navigation behavior or perform side effects.
  /// Specify const middleware instances that extend DashMiddleware.
  ///
  /// Example:
  /// ```dart
  /// @DashRoute(
  ///   path: '/analytics',
  ///   middleware: [const TrackingMiddleware(), const LoggingMiddleware()],
  /// )
  /// class AnalyticsPage extends StatelessWidget { ... }
  /// ```
  final List<Object>? middleware;

  /// Whether this route should be kept alive in memory.
  ///
  /// When true, the route's state is preserved when navigating away.
  /// Useful for pages with expensive state that shouldn't be rebuilt.
  ///
  /// Example:
  /// ```dart
  /// @DashRoute(path: '/chat', keepAlive: true)
  /// class ChatPage extends StatefulWidget { ... }
  /// ```
  final bool keepAlive;

  /// Whether this route is a fullscreen dialog.
  ///
  /// Fullscreen dialogs have a different transition and close behavior.
  /// On iOS, they slide up from the bottom and have a close button.
  ///
  /// Example:
  /// ```dart
  /// @DashRoute(path: '/settings', fullscreenDialog: true)
  /// class SettingsPage extends StatelessWidget { ... }
  /// ```
  final bool fullscreenDialog;

  /// Whether to maintain state when navigating away.
  ///
  /// When false, the route will be rebuilt each time it's navigated to.
  /// Defaults to true for most routes.
  ///
  /// Example:
  /// ```dart
  /// @DashRoute(path: '/temporary', maintainState: false)
  /// class TemporaryPage extends StatelessWidget { ... }
  /// ```
  final bool maintainState;

  /// Whether this is a shell/wrapper route.
  ///
  /// Shell routes wrap child routes with a common layout like a navigation
  /// bar or drawer. The shell widget must have a `child` parameter.
  ///
  /// Example:
  /// ```dart
  /// @DashRoute(path: '/app', shell: true)
  /// class AppShell extends StatelessWidget {
  ///   const AppShell({super.key, required this.child});
  ///   final Widget child;
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return Scaffold(
  ///       body: child,
  ///       bottomNavigationBar: const BottomNavBar(),
  ///     );
  ///   }
  /// }
  /// ```
  final bool shell;

  /// Target path for redirect.
  ///
  /// When set, this route becomes a redirect-only route.
  /// Navigation to this route will redirect to the target path.
  ///
  /// Example:
  /// ```dart
  /// @DashRoute(path: '/old-path', redirectTo: '/new-path')
  /// class OldPathRedirect {}
  /// ```
  final String? redirectTo;

  /// Whether this redirect is permanent (HTTP 308) or temporary (HTTP 307).
  ///
  /// Only relevant for web applications with SEO considerations.
  /// Defaults to false (temporary redirect).
  ///
  /// Example:
  /// ```dart
  /// @DashRoute(
  ///   path: '/old-page',
  ///   redirectTo: '/new-page',
  ///   permanentRedirect: true,
  /// )
  /// class OldPageRedirect {}
  /// ```
  final bool permanentRedirect;

  /// Whether this is a redirect-only route.
  bool get isRedirect => redirectTo != null;

  /// Whether this is a shell route.
  bool get isShell => shell;
}

/// Shorthand annotation for the initial/home route.
///
/// Use this annotation for the app's entry point route instead of
/// setting `initial: true` on [DashRoute].
///
/// ## Example
///
/// ```dart
/// @InitialRoute()
/// class HomePage extends StatelessWidget {
///   const HomePage({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Home');
/// }
///
/// // With custom path
/// @InitialRoute(path: '/home')
/// class HomePage extends StatelessWidget {
///   const HomePage({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Home');
/// }
/// ```
@immutable
class InitialRoute extends DashRoute {
  /// Creates an initial route annotation.
  ///
  /// [path] - The path for the initial route. Defaults to '/'.
  /// [name] - Optional route name.
  /// [transition] - Custom transition animation.
  /// [metadata] - Route metadata.
  /// [guards] - Route guards.
  /// [middleware] - Route middleware.
  /// [keepAlive] - Whether to preserve state.
  /// [fullscreenDialog] - Whether this is a fullscreen dialog.
  /// [maintainState] - Whether to maintain state when inactive.
  ///
  /// Example:
  /// ```dart
  /// @InitialRoute(
  ///   path: '/dashboard',
  ///   transition: DashFadeTransition(),
  /// )
  /// class DashboardPage extends StatelessWidget { ... }
  /// ```
  const InitialRoute({
    super.path = '/',
    super.name,
    super.transition,
    super.metadata,
    super.guards,
    super.middleware,
    super.keepAlive,
    super.fullscreenDialog,
    super.maintainState,
  }) : super(initial: true);
}

/// Shorthand annotation for fullscreen dialog routes.
///
/// Use this annotation for routes that should be displayed as fullscreen
/// dialogs, which have a different transition and close behavior.
///
/// ## Example
///
/// ```dart
/// @DialogRoute(path: '/settings')
/// class SettingsPage extends StatelessWidget {
///   const SettingsPage({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Settings');
/// }
/// ```
@immutable
class DialogRoute extends DashRoute {
  /// Creates a dialog route annotation.
  ///
  /// [path] - The path for this dialog route. Required.
  /// [name] - Optional route name.
  /// [transition] - Custom transition animation.
  /// [initial] - Whether this is the initial route.
  /// [parent] - Parent route path for nested routing.
  /// [metadata] - Route metadata.
  /// [guards] - Route guards.
  /// [middleware] - Route middleware.
  /// [keepAlive] - Whether to preserve state.
  /// [maintainState] - Whether to maintain state when inactive.
  ///
  /// Example:
  /// ```dart
  /// @DialogRoute(
  ///   path: '/edit-profile',
  ///   transition: DashSlideTransition.bottom(),
  ///   guards: [AuthGuard],
  /// )
  /// class EditProfilePage extends StatelessWidget { ... }
  /// ```
  const DialogRoute({
    required super.path,
    super.name,
    super.transition,
    super.initial,
    super.parent,
    super.metadata,
    super.guards,
    super.middleware,
    super.keepAlive,
    super.maintainState,
  }) : super(fullscreenDialog: true);
}

/// Shorthand annotation for shell/wrapper routes.
///
/// Shell routes wrap child routes with a common layout like a navigation
/// bar or drawer. Use this instead of setting `shell: true` on [DashRoute].
///
/// ## Example
///
/// ```dart
/// @ShellRoute(path: '/app')
/// class AppShell extends StatelessWidget {
///   const AppShell({super.key, required this.child});
///
///   final Widget child;
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: child,
///       bottomNavigationBar: const BottomNavBar(),
///     );
///   }
/// }
/// ```
@immutable
class ShellRoute extends DashRoute {
  /// Creates a shell route annotation.
  ///
  /// [path] - The path for this shell route. Required.
  /// [name] - Optional route name.
  /// [transition] - Custom transition animation.
  /// [metadata] - Route metadata.
  /// [guards] - Route guards.
  /// [middleware] - Route middleware.
  ///
  /// Example:
  /// ```dart
  /// @ShellRoute(
  ///   path: '/dashboard',
  ///   guards: [AuthGuard],
  /// )
  /// class DashboardShell extends StatelessWidget {
  ///   const DashboardShell({super.key, required this.child});
  ///   final Widget child;
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return Row(
  ///       children: [const Sidebar(), Expanded(child: child)],
  ///     );
  ///   }
  /// }
  /// ```
  const ShellRoute({
    required super.path,
    super.name,
    super.transition,
    super.metadata,
    super.guards,
    super.middleware,
  }) : super(shell: true);
}

/// Shorthand annotation for redirect routes.
///
/// Use this to create routes that automatically redirect to another path.
///
/// ## Example
///
/// ```dart
/// @RedirectRoute(path: '/', redirectTo: '/home')
/// class RootRedirect {}
///
/// @RedirectRoute(
///   path: '/old-settings',
///   redirectTo: '/settings',
///   permanent: true,
/// )
/// class OldSettingsRedirect {}
/// ```
@immutable
class RedirectRoute extends DashRoute {
  /// Creates a redirect route annotation.
  ///
  /// [path] - The path that triggers the redirect. Required.
  /// [redirectTo] - The target path to redirect to. Required.
  /// [permanent] - Whether this is a permanent redirect (HTTP 308).
  ///
  /// Example:
  /// ```dart
  /// @RedirectRoute(
  ///   path: '/legacy',
  ///   redirectTo: '/modern',
  ///   permanent: true,
  /// )
  /// class LegacyRedirect {}
  /// ```
  const RedirectRoute({
    required super.path,
    required String redirectTo,
    bool permanent = false,
  }) : super(redirectTo: redirectTo, permanentRedirect: permanent);
}

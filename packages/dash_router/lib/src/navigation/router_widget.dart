// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../router/dash_router.dart';

/// A convenience widget that sets up the [Router] with [DashRouter].
///
/// This widget is the recommended way to use DashRouter with Navigator 2.0.
/// It provides full support for deep linking, browser history integration,
/// and declarative navigation.
///
/// ## Basic Usage (Navigator 2.0)
///
/// ```dart
/// class MyApp extends StatelessWidget {
///   final router = DashRouter(
///     config: DashRouterOptions(initialPath: '/'),
///     routes: generatedRoutes,
///   );
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp.router(
///       routerConfig: router.routerConfig,
///       // Or use individual components:
///       // routerDelegate: router.buildDelegate(),
///       // routeInformationParser: router.buildParser(),
///       // backButtonDispatcher: RootBackButtonDispatcher(),
///     );
///   }
/// }
/// ```
///
/// ## Alternative: Using DashRouterWidget
///
/// ```dart
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return DashRouterWidget(
///       router: DashRouter(
///         config: DashRouterOptions(initialPath: '/'),
///         routes: generatedRoutes,
///       ),
///       builder: (context, router) => MaterialApp.router(
///         routerConfig: router.routerConfig,
///         theme: ThemeData.light(),
///       ),
///     );
///   }
/// }
/// ```
///
/// ## Navigator 1.0 Compatibility
///
/// For Navigator 1.0 style usage (recommended for simpler apps):
///
/// ```dart
/// MaterialApp(
///   navigatorKey: router.navigatorKey,
///   initialRoute: router.config.initialPath,
///   onGenerateRoute: router.generateRoute,
///   navigatorObservers: router.observers.all,
/// )
/// ```
class DashRouterWidget extends StatefulWidget {
  /// The [DashRouter] instance to use.
  final DashRouter router;

  /// Builder function that receives the router and returns the app widget.
  final Widget Function(BuildContext context, DashRouter router) builder;

  /// Whether to dispose the router when this widget is disposed.
  ///
  /// Defaults to false since the router is typically managed externally.
  final bool disposeRouter;

  /// Creates a [DashRouterWidget].
  const DashRouterWidget({
    super.key,
    required this.router,
    required this.builder,
    this.disposeRouter = false,
  });

  @override
  State<DashRouterWidget> createState() => _DashRouterWidgetState();
}

class _DashRouterWidgetState extends State<DashRouterWidget> {
  @override
  void dispose() {
    if (widget.disposeRouter) {
      widget.router.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.router);
  }
}

/// A simple wrapper that provides a [DashRouter] to its descendants.
///
/// This is useful when you need to access the router from anywhere in the
/// widget tree without passing it through constructors.
///
/// ```dart
/// class MyApp extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return DashRouterScope(
///       router: myRouter,
///       child: MaterialApp.router(
///         routerConfig: myRouter.routerConfig,
///       ),
///     );
///   }
/// }
///
/// // Access from anywhere:
/// final router = DashRouterScope.of(context);
/// ```
class DashRouterScope extends InheritedWidget {
  /// The router instance.
  final DashRouter router;

  /// Creates a [DashRouterScope].
  const DashRouterScope({
    super.key,
    required this.router,
    required super.child,
  });

  /// Get the router from the widget tree.
  ///
  /// Throws if no [DashRouterScope] is found.
  static DashRouter of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DashRouterScope>();
    if (scope == null) {
      throw StateError(
        'No DashRouterScope found in context. '
        'Make sure you have wrapped your app with DashRouterScope.',
      );
    }
    return scope.router;
  }

  /// Get the router from the widget tree, or null if not found.
  static DashRouter? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DashRouterScope>()
        ?.router;
  }

  @override
  bool updateShouldNotify(DashRouterScope oldWidget) {
    return router != oldWidget.router;
  }
}

/// Extension on [DashRouter] to provide Router configuration.
extension DashRouterConfigExtension on DashRouter {
  /// Get a [RouterConfig] for use with [MaterialApp.router].
  ///
  /// This provides a complete Navigator 2.0 setup with:
  /// - Route delegate for managing navigation state
  /// - Route information parser for URL parsing
  /// - Back button dispatcher for system back button handling
  ///
  /// ```dart
  /// MaterialApp.router(
  ///   routerConfig: router.routerConfig,
  /// )
  /// ```
  RouterConfig<Object> get routerConfig {
    return RouterConfig<Object>(
      routerDelegate: buildDelegate(),
      routeInformationParser: buildParser(),
      backButtonDispatcher: RootBackButtonDispatcher(),
      routeInformationProvider: PlatformRouteInformationProvider(
        initialRouteInformation: RouteInformation(
          uri: Uri.parse(config.initialPath),
        ),
      ),
    );
  }
}

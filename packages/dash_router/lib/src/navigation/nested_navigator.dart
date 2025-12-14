// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import '../route_info/route_scope.dart';
import '../router/dash_router.dart';
import '../router/route_data.dart';

/// A nested navigator that handles child route transitions independently.
///
/// This widget creates a nested [Navigator] that manages child routes
/// separately from the parent shell. When child routes change, only the
/// nested navigator animates, keeping the parent shell static.
///
/// ## How It Works
///
/// The nested navigator intercepts navigation requests for routes that
/// belong to its shell and handles them internally. This ensures that:
///
/// 1. The parent shell widget is not rebuilt on child route changes
/// 2. Transitions only animate the child content area
/// 3. Shell state (like selected navigation index) is preserved
///
/// ## Example
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
///     // The child is a NestedNavigator that handles sub-route transitions
///     return Scaffold(
///       body: child, // Only this part animates on child route changes
///       bottomNavigationBar: const BottomNavBar(),
///     );
///   }
/// }
/// ```
class NestedNavigator extends StatefulWidget {
  /// Creates a nested navigator.
  ///
  /// [shellPattern] identifies the parent shell route pattern.
  /// [initialChild] is the initial child widget to display.
  /// [initialChildPath] is the initial child route path.
  /// [navigatorKey] is an optional key for the nested Navigator.
  const NestedNavigator({
    super.key,
    required this.shellPattern,
    required this.initialChild,
    required this.initialChildPath,
    this.navigatorKey,
  });

  /// The pattern of the parent shell route.
  ///
  /// Used to determine which child routes belong to this navigator.
  final String shellPattern;

  /// The initial child widget to display.
  final Widget initialChild;

  /// The initial child route path.
  final String initialChildPath;

  /// Optional key for the nested [Navigator].
  ///
  /// If not provided, a unique key is generated automatically.
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<NestedNavigator> createState() => NestedNavigatorState();
}

/// State for [NestedNavigator].
///
/// This state manages the nested navigation stack and provides methods
/// for navigating within the nested context.
class NestedNavigatorState extends State<NestedNavigator> {
  late GlobalKey<NavigatorState> _navigatorKey;

  /// The navigator key for this nested navigator.
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  /// The current navigator state, if available.
  NavigatorState? get navigator => _navigatorKey.currentState;

  @override
  void initState() {
    super.initState();
    _navigatorKey = widget.navigatorKey ?? GlobalKey<NavigatorState>();

    // Register this nested navigator with the router
    DashRouter.instance.registerNestedNavigator(
      widget.shellPattern,
      _navigatorKey,
    );
  }

  @override
  void dispose() {
    // Unregister this nested navigator
    DashRouter.instance.unregisterNestedNavigator(widget.shellPattern);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = DashRouter.instance;

    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) {
        final path = settings.name ?? widget.initialChildPath;
        return router.generateNestedRoute(
          settings.copyWith(name: path),
          shellPattern: widget.shellPattern,
        );
      },
      onGenerateInitialRoutes: (navigator, initialRoute) {
        return [
          router.generateNestedRoute(
                RouteSettings(name: widget.initialChildPath),
                shellPattern: widget.shellPattern,
              ) ??
              _buildFallbackRoute(),
        ];
      },
      observers: [
        _NestedNavigatorObserver(shellPattern: widget.shellPattern),
      ],
    );
  }

  Route<dynamic> _buildFallbackRoute() {
    return PageRouteBuilder<void>(
      settings: RouteSettings(name: widget.initialChildPath),
      pageBuilder: (context, animation, secondaryAnimation) {
        return widget.initialChild;
      },
    );
  }
}

/// Observer for nested navigator events.
///
/// This observer tracks navigation events within the nested navigator
/// and optionally notifies the parent router of changes.
class _NestedNavigatorObserver extends NavigatorObserver {
  /// Creates a nested navigator observer.
  _NestedNavigatorObserver({required this.shellPattern});

  /// The shell pattern this observer belongs to.
  final String shellPattern;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _notifyRouteChange(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _notifyRouteChange(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _notifyRouteChange(newRoute);
    }
  }

  void _notifyRouteChange(Route<dynamic> route) {
    // Update the router's current route tracking
    final router = DashRouter.instance;
    final path = route.settings.name;
    if (path != null) {
      router.onNestedRouteChanged(shellPattern, path);
    }
  }
}

/// A stateful shell wrapper that maintains shell state across child navigation.
///
/// This widget ensures that the shell widget itself is not rebuilt when
/// child routes change. The child content is managed by a [NestedNavigator].
///
/// ## Usage
///
/// This is typically used internally by the router. You don't need to
/// use this directly in most cases.
///
/// ## Example
///
/// ```dart
/// StatefulShellScope(
///   shellBuilder: (context, data, child) => AppShell(child: child),
///   shellPattern: '/app',
///   childPath: '/app/home',
///   shellData: shellRouteData,
///   childWidget: HomePageWidget(),
/// )
/// ```
class StatefulShellScope extends StatefulWidget {
  /// Creates a stateful shell scope.
  const StatefulShellScope({
    super.key,
    required this.shellBuilder,
    required this.shellPattern,
    required this.childPath,
    required this.shellData,
    required this.childWidget,
  });

  /// Builder function for the shell widget.
  final Widget Function(BuildContext context, RouteData data, Widget child)
      shellBuilder;

  /// The pattern of this shell route.
  final String shellPattern;

  /// The current child route path.
  final String childPath;

  /// Route data for the shell.
  final RouteData shellData;

  /// The child widget to display.
  final Widget childWidget;

  @override
  State<StatefulShellScope> createState() => _StatefulShellScopeState();
}

class _StatefulShellScopeState extends State<StatefulShellScope> {
  late GlobalKey<NavigatorState> _nestedNavigatorKey;

  @override
  void initState() {
    super.initState();
    _nestedNavigatorKey = GlobalKey<NavigatorState>();
  }

  @override
  Widget build(BuildContext context) {
    final router = DashRouter.instance;

    // Create nested navigator for child routes
    final nestedNavigator = NestedNavigator(
      shellPattern: widget.shellPattern,
      initialChild: widget.childWidget,
      initialChildPath: widget.childPath,
      navigatorKey: _nestedNavigatorKey,
    );

    // Wrap with route scope and build the shell
    return DashRouteScope(
      data: widget.shellData,
      history: router.history,
      child: widget.shellBuilder(context, widget.shellData, nestedNavigator),
    );
  }
}

/// Entry for tracking nested navigators by shell pattern.
///
/// This is used internally by the router to manage nested navigation stacks.
class NestedNavigatorEntry {
  /// Creates a nested navigator entry.
  NestedNavigatorEntry({
    required this.shellPattern,
    required this.navigatorKey,
  });

  /// The shell pattern this navigator belongs to.
  final String shellPattern;

  /// The navigator key for this nested navigator.
  final GlobalKey<NavigatorState> navigatorKey;
}

/// Extension on [RouteSettings] for convenient copying.
extension RouteSettingsExtension on RouteSettings {
  /// Creates a copy of this [RouteSettings] with the given fields replaced.
  RouteSettings copyWith({
    String? name,
    Object? arguments,
  }) {
    return RouteSettings(
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
    );
  }
}

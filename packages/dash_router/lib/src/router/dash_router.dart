// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:dash_router_annotations/dash_router_annotations.dart';
import 'package:flutter/widgets.dart';

import '../exceptions/route_exceptions.dart';
import '../guards/guard.dart';
import '../guards/guard_manager.dart';
import '../guards/guard_result.dart';
import '../middleware/middleware_manager.dart';
import '../navigation/nested_navigator.dart';
import '../observers/observer_manager.dart';
import '../params/params_types.dart';
import '../route_info/route_scope.dart';
import '../typed_routes/typed_route.dart';
import '../utils/route_matcher.dart';
import '../utils/route_parser.dart';
import 'navigation_history.dart';
import 'route_data.dart';
import 'router_config.dart';

/// Main router class for dash_router
///
/// Usage:
/// ```dart
/// final router = DashRouter(
///   config: DashRouterOptions(initialPath: '/'),
///   routes: generatedRoutes,
/// );
/// ```
class DashRouter extends ChangeNotifier {
  static const String _kTransitionArgKey = '_transition';

  static const int _kMaxRedirectDepth = 8;

  /// Router configuration
  final DashRouterOptions config;

  /// Registered routes
  final Map<String, RouteEntry> _routes = {};

  /// Parent -> child route patterns.
  final Map<String, List<String>> _childrenByParentPattern = {};

  /// Registered redirects
  final List<RedirectEntry> _redirects = [];

  /// Navigation history
  late final NavigationHistory _history;

  /// Current router state
  RouterState _state;

  /// Guard manager
  final GuardManager _guardManager = GuardManager();

  /// Middleware manager
  final MiddlewareManager _middlewareManager = MiddlewareManager();

  /// Observer manager
  final ObserverManager _observerManager = ObserverManager();

  /// Global navigator key
  final GlobalKey<NavigatorState> navigatorKey;

  /// Nested navigators by shell pattern.
  final Map<String, GlobalKey<NavigatorState>> _nestedNavigators = {};

  /// Singleton instance
  static DashRouter? _instance;

  /// Get singleton instance
  static DashRouter get instance {
    if (_instance == null) {
      throw RouterNotInitializedException();
    }
    return _instance!;
  }

  /// Check if router is initialized
  static bool get isInitialized => _instance != null;

  DashRouter({
    required this.config,
    List<RouteEntry> routes = const [],
    List<RedirectEntry> redirects = const [],
    GlobalKey<NavigatorState>? navigatorKey,
  })  : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
        _state = RouterState.initial(historyMaxSize: config.historyMaxSize) {
    _history = _state.history;

    // Register routes
    for (final route in routes) {
      registerRoute(route);
    }

    // Register redirects
    for (final redirect in redirects) {
      registerRedirect(redirect);
    }

    // Set singleton instance
    _instance = this;

    // Mark as initialized
    _state = _state.copyWith(isInitialized: true);

    _log('DashRouter initialized with ${_routes.length} routes');
  }

  /// Get router from context
  static DashRouter of(BuildContext context) {
    return instance;
  }

  /// Try to get router from context
  static DashRouter? maybeOf(BuildContext context) {
    return _instance;
  }

  /// Current state
  RouterState get state => _state;

  /// Current route data
  RouteData? get currentRoute => _state.currentRoute;

  /// Navigation history
  NavigationHistory get history => _history;

  /// Guard manager
  GuardManager get guards => _guardManager;

  /// Middleware manager
  MiddlewareManager get middleware => _middlewareManager;

  /// Observer manager
  ObserverManager get observers => _observerManager;

  /// Register a route
  void registerRoute(RouteEntry route) {
    final normalizedPattern = RouteParser.normalizePath(route.pattern);
    if (_routes.containsKey(normalizedPattern)) {
      throw DuplicateRouteException(normalizedPattern);
    }
    _routes[normalizedPattern] = route;

    final parent = route.parent;
    if (parent != null && parent.isNotEmpty) {
      final normalizedParent = RouteParser.normalizePath(parent);
      final children = _childrenByParentPattern.putIfAbsent(
        normalizedParent,
        () => <String>[],
      );
      if (!children.contains(normalizedPattern)) {
        children.add(normalizedPattern);
      }
    }
    _log('Registered route: $normalizedPattern');
  }

  /// Register a redirect
  void registerRedirect(RedirectEntry redirect) {
    _redirects.add(redirect);
    _log('Registered redirect: ${redirect.from} -> ${redirect.to}');
  }

  /// Unregister a route
  void unregisterRoute(String pattern) {
    final normalizedPattern = RouteParser.normalizePath(pattern);
    _routes.remove(normalizedPattern);
  }

  /// Get all registered route patterns
  List<String> get routePatterns => _routes.keys.toList();

  // ============================================================
  // Nested Navigator Support
  // ============================================================

  /// Registers a nested navigator for a shell pattern.
  ///
  /// This is called internally by [NestedNavigator] when it is created.
  /// You typically don't need to call this directly.
  void registerNestedNavigator(
    String shellPattern,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    final normalized = RouteParser.normalizePath(shellPattern);
    _nestedNavigators[normalized] = navigatorKey;
    _log('Registered nested navigator for: $normalized');
  }

  /// Unregisters a nested navigator for a shell pattern.
  ///
  /// This is called internally by [NestedNavigator] when it is disposed.
  void unregisterNestedNavigator(String shellPattern) {
    final normalized = RouteParser.normalizePath(shellPattern);
    _nestedNavigators.remove(normalized);
    _log('Unregistered nested navigator for: $normalized');
  }

  /// Gets the nested navigator for a shell pattern, if registered.
  NavigatorState? getNestedNavigator(String shellPattern) {
    final normalized = RouteParser.normalizePath(shellPattern);
    return _nestedNavigators[normalized]?.currentState;
  }

  /// Gets the appropriate navigator for a given path.
  ///
  /// Returns the nested navigator if the path belongs to a registered shell,
  /// otherwise returns the main navigator.
  ///
  /// Also returns the shell pattern if a nested navigator is being used.
  (NavigatorState?, String?) _getNavigatorForPath(String path) {
    final shellPattern = findShellForPath(path);
    if (shellPattern != null) {
      final nestedNav = getNestedNavigator(shellPattern);
      if (nestedNav != null) {
        return (nestedNav, shellPattern);
      }
    }
    return (navigatorKey.currentState, null);
  }

  /// Gets the active navigator for the current route.
  ///
  /// Returns the nested navigator if the current route is inside a shell,
  /// otherwise returns the main navigator.
  NavigatorState? get _activeNavigator {
    final currentPath = _state.currentRoute?.fullPath;
    if (currentPath != null) {
      final (navigator, _) = _getNavigatorForPath(currentPath);
      return navigator;
    }
    return navigatorKey.currentState;
  }

  /// Called when a nested route changes.
  ///
  /// This updates the router's tracking of the current route when
  /// navigation occurs within a nested navigator.
  void onNestedRouteChanged(String shellPattern, String childPath) {
    _log('Nested route changed in $shellPattern: $childPath');
    // Update current route tracking if needed
    final match = matchRoute(childPath);
    if (match != null) {
      final (entry, matchResult) = match;
      final settings = RouteSettings(name: childPath);
      final routeData =
          _buildRouteData(childPath, entry, matchResult, settings);
      _state = _state.copyWith(currentRoute: routeData);
      notifyListeners();
    }
  }

  /// Generates a route for a nested navigator.
  ///
  /// This method is similar to [generateRoute] but is used specifically
  /// for routes within a nested navigator context.
  Route<T>? generateNestedRoute<T>(
    RouteSettings settings, {
    required String shellPattern,
  }) {
    final path = settings.name ?? config.initialPath;
    final result = matchRoute(path);

    if (result == null) {
      _log('Nested route not found: $path');
      return _buildNotFoundRoute<T>(path, settings);
    }

    final (entry, matchResult) = result;

    // Build route data
    final routeData = _buildRouteData(path, entry, matchResult, settings);

    final customTransition =
        _extractTransitionFromArguments(settings.arguments);
    return _buildNestedRoute<T>(entry, routeData, settings, customTransition);
  }

  /// Builds a route for nested navigation (without shell wrapping).
  Route<T> _buildNestedRoute<T>(
    RouteEntry entry,
    RouteData routeData,
    RouteSettings settings,
    DashTransition? customTransition,
  ) {
    // Priority: per-navigation > route-level > global default
    final transition =
        customTransition ?? entry.transition ?? config.defaultTransition;

    // Build page without shell wrapping for nested routes
    final page = Builder(
      builder: (context) => DashRouteScope(
        data: routeData,
        history: _history,
        child: entry.builder(context, routeData),
      ),
    );

    final baseRoute = transition.buildPageRoute<T>(page, settings);

    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) =>
          baseRoute.buildPage(context, animation, secondaryAnimation),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          baseRoute.buildTransitions(
              context, animation, secondaryAnimation, child),
      transitionDuration: baseRoute.transitionDuration,
      reverseTransitionDuration: baseRoute.reverseTransitionDuration,
      fullscreenDialog: entry.fullscreenDialog,
      maintainState: entry.maintainState,
    );
  }

  /// Checks if a path belongs to a shell's children.
  bool _isChildOfShell(String path, String shellPattern) {
    final normalized = RouteParser.normalizePath(path);
    final normalizedShell = RouteParser.normalizePath(shellPattern);

    // Check if the path starts with shell pattern
    if (!normalized.startsWith(normalizedShell)) return false;

    // Check if path is a registered child of this shell
    final children = _childrenByParentPattern[normalizedShell] ?? [];
    for (final childPattern in children) {
      final match = RouteMatcher.match(childPattern, normalized);
      if (match.isMatch) return true;
    }

    return false;
  }

  /// Finds the appropriate shell for a given path.
  ///
  /// Returns the shell pattern that contains the given path as a child,
  /// or null if no shell contains this path.
  ///
  /// This is useful for determining which nested navigator should handle
  /// a navigation request.
  String? findShellForPath(String path) {
    final normalized = RouteParser.normalizePath(path);

    for (final shellPattern in _nestedNavigators.keys) {
      if (_isChildOfShell(normalized, shellPattern)) {
        return shellPattern;
      }
    }

    return null;
  }

  // ============================================================
  // End of Nested Navigator Support
  // ============================================================

  /// Build the router delegate
  RouterDelegate<Object> buildDelegate() {
    return _DashRouterDelegate(this);
  }

  /// Build route information parser
  RouteInformationParser<Object> buildParser() {
    return _DashRouteInformationParser(this);
  }

  /// Generate route for Navigator
  Route<T>? generateRoute<T>(RouteSettings settings) {
    final path = settings.name ?? config.initialPath;
    final result = matchRoute(path);

    if (result == null) {
      _log('Route not found: $path');
      return _buildNotFoundRoute<T>(path, settings);
    }

    final (entry, matchResult) = result;

    // Build route data
    final routeData = _buildRouteData(path, entry, matchResult, settings);

    // Update state
    _state = _state.copyWith(
      currentRoute: routeData,
      isNavigating: false,
    );
    _history.push(routeData);

    notifyListeners();

    final customTransition =
        _extractTransitionFromArguments(settings.arguments);
    return _buildRoute<T>(entry, routeData, settings, customTransition);
  }

  /// Match a path to a route
  (RouteEntry, RouteMatchResult)? matchRoute(String path) {
    final split = RouteParser.splitPathAndQuery(path);
    final normalized = RouteParser.normalizePath(split.path);

    // Check for redirects first
    final redirectPath = _checkRedirects(normalized);
    if (redirectPath != null && redirectPath != normalized) {
      return matchRoute(redirectPath);
    }

    final matchResult = RouteMatcher.findBestMatch(
      _routes.keys.toList(),
      normalized,
    );

    if (matchResult == null) return null;

    final (pattern, result) = matchResult;
    final entry = _routes[pattern];
    if (entry == null) return null;

    return (entry, result);
  }

  String? _checkRedirects(String path) {
    for (final redirect in _redirects) {
      final match = RouteMatcher.match(redirect.from, path);
      if (match.isMatch) {
        // Build target path with params
        return RouteMatcher.buildPath(redirect.to, match.pathParams);
      }
    }
    return null;
  }

  RouteData _buildRouteData(
    String fullPath,
    RouteEntry entry,
    RouteMatchResult matchResult,
    RouteSettings settings,
  ) {
    final split = RouteParser.splitPathAndQuery(fullPath);
    final path = split.path;
    final query = split.query;
    final queryParams = RouteParser.parseQueryString(query);

    // Get body params from settings arguments
    final bodyParams = <String, dynamic>{};
    if (settings.arguments is Map<String, dynamic>) {
      bodyParams.addAll(settings.arguments as Map<String, dynamic>);
      // Reserved key used internally for per-navigation transitions.
      bodyParams.remove(_kTransitionArgKey);
    } else if (settings.arguments != null) {
      bodyParams['_body'] = settings.arguments;
    }

    final normalizedPattern = RouteParser.normalizePath(entry.pattern);
    final childPatterns = List<String>.unmodifiable(
        _childrenByParentPattern[normalizedPattern] ?? const <String>[]);

    return RouteData(
      pattern: entry.pattern,
      path: RouteParser.normalizePath(path),
      fullPath: fullPath,
      name: entry.name,
      params: RouteParams(
        pathParams: matchResult.pathParams,
        queryParams: queryParams,
        bodyParams: bodyParams,
      ),
      settings: settings,
      isInitial: entry.isInitial,
      parentPattern: entry.parent,
      childPatterns: childPatterns,
      metadata: entry.metadata,
    );
  }

  RouteData _buildParentRouteData(
    String fullPath,
    RouteEntry parent,
    RouteSettings settings,
  ) {
    final split = RouteParser.splitPathAndQuery(fullPath);
    final path = split.path;
    final query = split.query;

    final prefixMatch = RouteMatcher.matchPrefix(parent.pattern, path);
    if (!prefixMatch.isMatch) {
      // Fallback to an empty match. This should not happen if parent/child are
      // configured correctly.
      return RouteData(
        pattern: parent.pattern,
        path: RouteParser.normalizePath(parent.pattern),
        fullPath: fullPath,
        name: parent.name,
        params: const RouteParams(),
        settings: settings,
        isInitial: parent.isInitial,
        parentPattern: parent.parent,
        childPatterns: List<String>.unmodifiable(
          _childrenByParentPattern[RouteParser.normalizePath(parent.pattern)] ??
              const <String>[],
        ),
        metadata: parent.metadata,
      );
    }

    final patternSegments = RouteParser.parseSegments(parent.pattern);
    final prefixSegments =
        RouteParser.parseSegments(path).take(patternSegments.length).toList();
    final parentPath =
        prefixSegments.isEmpty ? '/' : '/${prefixSegments.join('/')}';

    final queryParams = RouteParser.parseQueryString(query);

    return RouteData(
      pattern: parent.pattern,
      path: RouteParser.normalizePath(parentPath),
      fullPath:
          (query == null || query.isEmpty) ? parentPath : '$parentPath?$query',
      name: parent.name,
      params: RouteParams(
        pathParams: prefixMatch.pathParams,
        queryParams: queryParams,
      ),
      settings: settings,
      isInitial: parent.isInitial,
      parentPattern: parent.parent,
      childPatterns: List<String>.unmodifiable(
        _childrenByParentPattern[RouteParser.normalizePath(parent.pattern)] ??
            const <String>[],
      ),
      metadata: parent.metadata,
    );
  }

  Widget _buildWrappedWidget(RouteEntry entry, RouteData routeData) {
    // Build the page widget wrapped with DashRouteScope for route info access
    Widget current = Builder(
      builder: (context) => DashRouteScope(
        data: routeData,
        history: _history,
        child: entry.builder(context, routeData),
      ),
    );

    final seen = <String>{};
    var parentPattern = entry.parent;
    while (parentPattern?.isNotEmpty ?? false) {
      final parentPatternValue = parentPattern!;
      final normalizedParent = RouteParser.normalizePath(parentPatternValue);
      if (!seen.add(normalizedParent)) {
        // Cycle detected.
        break;
      }

      final parentEntry = _routes[normalizedParent];
      if (parentEntry == null) {
        break;
      }

      final shellBuilder = parentEntry.shellBuilder;
      if (shellBuilder != null) {
        final childWidget = current;
        final childPath = routeData.fullPath;

        // Use StatefulShellScope for shell routes to isolate animations
        current = Builder(
          builder: (context) {
            final settings =
                routeData.settings ?? RouteSettings(name: routeData.fullPath);
            final parentData = _buildParentRouteData(
              routeData.fullPath,
              parentEntry,
              settings,
            );

            // Use StatefulShellScope to manage nested navigation
            return StatefulShellScope(
              shellBuilder: shellBuilder,
              shellPattern: normalizedParent,
              childPath: childPath,
              shellData: parentData,
              childWidget: childWidget,
            );
          },
        );
      }

      parentPattern = parentEntry.parent;
    }

    return current;
  }

  Route<T> _buildRoute<T>(
    RouteEntry entry,
    RouteData routeData,
    RouteSettings settings,
    DashTransition? customTransition,
  ) {
    // Priority: per-navigation transition > route-level transition > global default.
    final transition =
        customTransition ?? entry.transition ?? config.defaultTransition;

    final page = Builder(
      builder: (context) => _buildWrappedWidget(entry, routeData),
    );

    final baseRoute = transition.buildPageRoute<T>(page, settings);

    // Apply fullscreenDialog and maintainState by wrapping the route
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) =>
          baseRoute.buildPage(context, animation, secondaryAnimation),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          baseRoute.buildTransitions(
              context, animation, secondaryAnimation, child),
      transitionDuration: baseRoute.transitionDuration,
      reverseTransitionDuration: baseRoute.reverseTransitionDuration,
      fullscreenDialog: entry.fullscreenDialog,
      maintainState: entry.maintainState,
    );
  }

  Route<T>? _buildNotFoundRoute<T>(String path, RouteSettings settings) {
    if (config.notFoundBuilder != null) {
      final page = Builder(
        builder: (context) => config.notFoundBuilder!(context, path),
      );
      return config.defaultTransition.buildPageRoute<T>(page, settings);
    }
    return null;
  }

  // Navigation methods

  Object? _stripReservedArguments(Object? arguments) {
    if (arguments is Map<String, dynamic>) {
      final copy = <String, dynamic>{...arguments};
      copy.remove(_kTransitionArgKey);
      return copy.isEmpty ? null : copy;
    }
    return arguments;
  }

  (RouteEntry, RouteData)? _resolveTarget(String fullPath, Object? arguments) {
    final match = matchRoute(fullPath);
    if (match == null) return null;

    final (entry, matchResult) = match;
    final settings = RouteSettings(
      name: fullPath,
      arguments: _stripReservedArguments(arguments),
    );
    final data = _buildRouteData(fullPath, entry, matchResult, settings);
    return (entry, data);
  }

  List<RouteEntry> _parentChainFor(RouteEntry entry) {
    final parents = <RouteEntry>[];
    final visited = <String>{};

    var parentPattern = entry.parent;
    while (parentPattern != null && visited.add(parentPattern)) {
      final parentEntry = _routes[parentPattern];
      if (parentEntry == null) break;
      parents.add(parentEntry);
      parentPattern = parentEntry.parent;
    }

    return parents;
  }

  List<DashGuard> _selectGuards(RouteEntry entry, RouteData targetRoute) {
    // Collect all guards from the route entry and its parent chain
    final routeGuards = <DashGuard>[...entry.guards];
    for (final parent in _parentChainFor(entry)) {
      routeGuards.addAll(parent.guards);
    }

    // Get global guards that should run for this path
    final globalGuards =
        _guardManager.all.where((g) => g.shouldRun(targetRoute.path)).toList();

    // Combine route guards with matching global guards
    final allGuards = <DashGuard>{...routeGuards, ...globalGuards};

    // Sort by priority (higher priority runs first)
    final sortedGuards = allGuards.toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    return sortedGuards;
  }

  List<DashMiddleware> _selectMiddleware(RouteEntry entry, RouteData target) {
    // Collect all middleware from the route entry and its parent chain
    final routeMiddleware = <DashMiddleware>[...entry.middleware];
    for (final parent in _parentChainFor(entry)) {
      routeMiddleware.addAll(parent.middleware);
    }

    // Get global middleware that should run for this path
    final globalMiddleware =
        _middlewareManager.all.where((m) => m.shouldRun(target.path)).toList();

    // Combine route middleware with matching global middleware
    final allMiddleware = <DashMiddleware>{
      ...routeMiddleware,
      ...globalMiddleware,
    };

    // Sort by priority (higher priority runs first)
    final sortedMiddleware = allMiddleware.toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));

    return sortedMiddleware;
  }

  Future<GuardResult> _runGuardsFor(
    RouteEntry entry,
    RouteData target,
    Object? arguments, {
    required bool isReplace,
  }) async {
    final guards = _selectGuards(entry, target);
    for (final guard in guards) {
      final result = await guard.canActivate(
        GuardContext(
          targetRoute: target,
          currentRoute: currentRoute,
          isReplace: isReplace,
          extra: _stripReservedArguments(arguments),
        ),
      );
      if (!result.isAllowed) {
        await guard.onDenied(
          GuardContext(
            targetRoute: target,
            currentRoute: currentRoute,
            isReplace: isReplace,
            extra: _stripReservedArguments(arguments),
          ),
          result,
        );
        return result;
      }
      await guard.onActivated(
        GuardContext(
          targetRoute: target,
          currentRoute: currentRoute,
          isReplace: isReplace,
          extra: _stripReservedArguments(arguments),
        ),
      );
    }
    return const GuardAllow();
  }

  Future<MiddlewareResult> _runMiddlewareFor(
    RouteEntry entry,
    RouteData target,
    Object? arguments,
  ) async {
    final middleware = _selectMiddleware(entry, target);
    if (middleware.isEmpty) return const MiddlewareContinue();

    final ctx = MiddlewareContext(
      targetRoute: target,
      currentRoute: currentRoute,
      extra: (arguments is Map<String, dynamic>)
          ? (<String, dynamic>{...arguments}..remove(_kTransitionArgKey))
          : const <String, dynamic>{},
    );

    final pipeline = MiddlewarePipeline(middleware);
    final result = await pipeline.execute(ctx);

    if (result is MiddlewareContinue) {
      // Do not await the push future; call afterNavigation ASAP.
      unawaited(pipeline.afterNavigation(ctx));
      return result;
    }

    if (result is MiddlewareAbort) {
      await pipeline.onAborted(ctx, result.reason);
    }

    return result;
  }

  Future<(String, Object?)?> _preNavigate(
    String fullPath,
    Object? arguments, {
    required bool isReplace,
    int depth = 0,
  }) async {
    if (depth > _kMaxRedirectDepth) {
      throw RedirectLoopException([fullPath]);
    }

    final resolved = _resolveTarget(fullPath, arguments);
    if (resolved == null) return null;
    final (entry, target) = resolved;

    final middlewareResult = await _runMiddlewareFor(entry, target, arguments);
    if (middlewareResult is MiddlewareAbort) {
      return null;
    }
    if (middlewareResult is MiddlewareRedirect) {
      final nextPath = _buildFullPath(
        middlewareResult.redirectTo,
        middlewareResult.queryParams,
      );
      return _preNavigate(
        nextPath,
        middlewareResult.extra ?? arguments,
        isReplace: isReplace,
        depth: depth + 1,
      );
    }

    final guardResult = await _runGuardsFor(
      entry,
      target,
      arguments,
      isReplace: isReplace,
    );
    if (guardResult is GuardDeny) {
      return null;
    }
    if (guardResult is GuardRedirect) {
      final nextPath = _buildFullPath(
        guardResult.redirectTo,
        guardResult.queryParams,
      );
      return _preNavigate(
        nextPath,
        guardResult.extra ?? arguments,
        isReplace: isReplace,
        depth: depth + 1,
      );
    }

    return (fullPath, arguments);
  }

  DashTransition? _extractTransitionFromArguments(Object? arguments) {
    if (arguments is Map<String, dynamic>) {
      final value = arguments[_kTransitionArgKey];
      if (value is DashTransition) return value;
    }
    return null;
  }

  Object? _withTransition(Object? arguments, DashTransition? transition) {
    if (transition == null) return arguments;

    if (arguments == null) {
      return <String, dynamic>{_kTransitionArgKey: transition};
    }

    if (arguments is Map<String, dynamic>) {
      return <String, dynamic>{...arguments, _kTransitionArgKey: transition};
    }

    return <String, dynamic>{
      '_body': arguments,
      _kTransitionArgKey: transition
    };
  }

  /// Push a named route.
  ///
  /// Automatically detects whether to use the main navigator or a nested
  /// navigator based on the target path. If the path belongs to a registered
  /// shell, the navigation will occur within that shell's nested navigator,
  /// preventing the parent shell from being rebuilt.
  ///
  /// Parameters:
  /// - [path]: The route path to navigate to.
  /// - [query]: Optional query parameters to append to the path.
  /// - [body]: Optional arguments/body data to pass to the route.
  /// - [transition]: Optional custom transition animation.
  ///
  /// Example:
  /// ```dart
  /// router.pushNamed('/user/123', query: {'tab': 'profile'});
  /// ```
  Future<T?> pushNamed<T extends Object?>(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    DashTransition? transition,
  }) async {
    final fullPath = _buildFullPath(path, query);
    _log('Pushing: $fullPath');

    final (navigator, shellPattern) = _getNavigatorForPath(fullPath);
    if (navigator == null) {
      throw RouterNotInitializedException();
    }

    final prepared = await _preNavigate(
      fullPath,
      body,
      isReplace: false,
    );
    if (prepared == null) return null;

    _state = _state.copyWith(isNavigating: true);
    notifyListeners();

    final (finalPath, finalArgs) = prepared;

    if (shellPattern != null) {
      _log('Using nested navigator for shell: $shellPattern');
    }

    return navigator.pushNamed<T>(
      finalPath,
      arguments: _withTransition(finalArgs, transition),
    );
  }

  /// Push replacement.
  ///
  /// Replaces the current route with a new route. Automatically detects
  /// whether to use the main navigator or a nested navigator based on
  /// the target path.
  ///
  /// Parameters:
  /// - [path]: The route path to navigate to.
  /// - [query]: Optional query parameters to append to the path.
  /// - [body]: Optional arguments/body data to pass to the route.
  /// - [result]: Optional result to pass back to the previous route.
  /// - [transition]: Optional custom transition animation.
  ///
  /// Example:
  /// ```dart
  /// router.pushReplacementNamed('/home', result: 'success');
  /// ```
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    TO? result,
    DashTransition? transition,
  }) async {
    final fullPath = _buildFullPath(path, query);
    _log('Push replacement: $fullPath');

    final (navigator, shellPattern) = _getNavigatorForPath(fullPath);
    if (navigator == null) {
      throw RouterNotInitializedException();
    }

    final prepared = await _preNavigate(
      fullPath,
      body,
      isReplace: true,
    );
    if (prepared == null) return null;

    _state = _state.copyWith(isNavigating: true);
    notifyListeners();

    final (finalPath, finalArgs) = prepared;
    return navigator.pushReplacementNamed<T, TO>(
      finalPath,
      arguments: _withTransition(finalArgs, transition),
      result: result,
    );
  }

  /// Pop and push.
  ///
  /// Pops the current route and pushes a new route. Automatically detects
  /// whether to use the main navigator or a nested navigator based on
  /// the target path.
  ///
  /// Parameters:
  /// - [path]: The route path to navigate to.
  /// - [query]: Optional query parameters to append to the path.
  /// - [body]: Optional arguments/body data to pass to the route.
  /// - [result]: Optional result to pass back to the previous route.
  /// - [transition]: Optional custom transition animation.
  ///
  /// Example:
  /// ```dart
  /// router.popAndPushNamed('/login');
  /// ```
  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    TO? result,
    DashTransition? transition,
  }) async {
    final fullPath = _buildFullPath(path, query);
    _log('Pop and push: $fullPath');

    final (navigator, _) = _getNavigatorForPath(fullPath);
    if (navigator == null) {
      throw RouterNotInitializedException();
    }

    final prepared = await _preNavigate(
      fullPath,
      body,
      isReplace: false,
    );
    if (prepared == null) return null;

    final (finalPath, finalArgs) = prepared;
    return navigator.popAndPushNamed<T, TO>(
      finalPath,
      arguments: _withTransition(finalArgs, transition),
      result: result,
    );
  }

  /// Push and remove until.
  ///
  /// Pushes a new route and removes all routes until the predicate returns
  /// true. Automatically detects whether to use the main navigator or a
  /// nested navigator based on the target path.
  ///
  /// Parameters:
  /// - [path]: The route path to navigate to.
  /// - [predicate]: Function that returns true for routes to keep.
  /// - [query]: Optional query parameters to append to the path.
  /// - [body]: Optional arguments/body data to pass to the route.
  /// - [transition]: Optional custom transition animation.
  ///
  /// Example:
  /// ```dart
  /// // Clear stack and push home
  /// router.pushNamedAndRemoveUntil('/home', (_) => false);
  /// ```
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String path,
    bool Function(Route<dynamic>) predicate, {
    Map<String, dynamic>? query,
    Object? body,
    DashTransition? transition,
  }) async {
    final fullPath = _buildFullPath(path, query);
    _log('Push and remove until: $fullPath');

    final (navigator, _) = _getNavigatorForPath(fullPath);
    if (navigator == null) {
      throw RouterNotInitializedException();
    }

    final prepared = await _preNavigate(
      fullPath,
      body,
      isReplace: false,
    );
    if (prepared == null) return null;

    final (finalPath, finalArgs) = prepared;
    return navigator.pushNamedAndRemoveUntil<T>(
      finalPath,
      predicate,
      arguments: _withTransition(finalArgs, transition),
    );
  }

  /// Push a typed route.
  ///
  /// This method is used by the navigation extension to push generated typed
  /// routes. The route's `$transition` property is used if no explicit
  /// transition is provided.
  ///
  /// Example:
  /// ```dart
  /// router.pushRoute(AppUser$IdRoute(id: '123'));
  /// ```
  Future<T?> pushRoute<T extends Object?>(DashTypedRoute route) {
    return pushNamed<T>(
      route.$path,
      query: route.$query,
      body: route.$body,
      transition: route.$transition,
    );
  }

  /// Replace the current route with a typed route.
  ///
  /// This method is used by the navigation extension to replace with generated
  /// typed routes. The route's `$transition` property is used if set.
  ///
  /// Example:
  /// ```dart
  /// router.replaceRoute(AppHomeRoute());
  /// ```
  Future<T?> replaceRoute<T extends Object?, TO extends Object?>(
    DashTypedRoute route, {
    TO? result,
  }) {
    return pushReplacementNamed<T, TO>(
      route.$path,
      query: route.$query,
      body: route.$body,
      result: result,
      transition: route.$transition,
    );
  }

  /// Pop current route
  ///
  /// Uses the active navigator (nested or main) based on current route.
  void pop<T extends Object?>([T? result]) {
    _log('Pop');
    final navigator = _activeNavigator;
    if (navigator != null && navigator.canPop()) {
      navigator.pop<T>(result);
    }
  }

  /// Pop until predicate
  ///
  /// Uses the active navigator (nested or main) based on current route.
  void popUntil(bool Function(Route<dynamic>) predicate) {
    _log('Pop until');
    _activeNavigator?.popUntil(predicate);
  }

  /// Pop until route name
  void popUntilNamed(String path) {
    final normalizedPath = RouteParser.normalizePath(path);
    popUntil((route) => route.settings.name == normalizedPath);
  }

  /// Check if can pop
  ///
  /// Uses the active navigator (nested or main) based on current route.
  bool canPop() {
    return _activeNavigator?.canPop() ?? false;
  }

  /// Maybe pop (respects route guards)
  ///
  /// Uses the active navigator (nested or main) based on current route.
  Future<bool> maybePop<T extends Object?>([T? result]) async {
    return await _activeNavigator?.maybePop<T>(result) ?? false;
  }

  // ============================================================
  // Traditional Navigator compatibility
  // ============================================================

  /// Push a route directly (for Navigator compatibility)
  ///
  /// This method is provided for compatibility with traditional Navigator API.
  /// For most cases, prefer using [pushNamed] or [pushRoute].
  Future<T?> push<T extends Object?>(Route<T> route) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      throw RouterNotInitializedException();
    }
    return navigator.push<T>(route);
  }

  /// Replace current route with another route directly
  ///
  /// This method is provided for compatibility with traditional Navigator API.
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Route<T> newRoute, {
    TO? result,
  }) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      throw RouterNotInitializedException();
    }
    return navigator.pushReplacement<T, TO>(newRoute, result: result);
  }

  /// Replace a route in the navigator
  void replace<T extends Object?>({
    required Route<dynamic> oldRoute,
    required Route<T> newRoute,
  }) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      throw RouterNotInitializedException();
    }
    navigator.replace<T>(oldRoute: oldRoute, newRoute: newRoute);
  }

  /// Replace route below the current route
  void replaceRouteBelow<T extends Object?>({
    required Route<dynamic> anchorRoute,
    required Route<T> newRoute,
  }) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      throw RouterNotInitializedException();
    }
    navigator.replaceRouteBelow<T>(
        anchorRoute: anchorRoute, newRoute: newRoute);
  }

  /// Remove a route from the navigator
  void removeRoute(Route<dynamic> route) {
    navigatorKey.currentState?.removeRoute(route);
  }

  /// Remove the route below a given route
  void removeRouteBelow(Route<dynamic> anchorRoute) {
    navigatorKey.currentState?.removeRouteBelow(anchorRoute);
  }

  /// Get the current navigator state (for advanced use)
  NavigatorState? get navigator => navigatorKey.currentState;

  /// Whether there is at least one route that can be popped
  bool get canGoBack => navigatorKey.currentState?.canPop() ?? false;

  /// Go back (alias for pop)
  void goBack<T extends Object?>([T? result]) => pop<T>(result);

  /// Go to the initial route, clearing all routes
  Future<T?> goToInitial<T extends Object?>({
    DashTransition? transition,
  }) {
    return pushNamedAndRemoveUntil<T>(
      config.initialPath,
      (_) => false,
      transition: transition,
    );
  }

  /// Reset the navigation stack to a single route.
  ///
  /// Clears all routes from the stack and pushes the specified route.
  ///
  /// Parameters:
  /// - [path]: The route path to navigate to.
  /// - [query]: Optional query parameters to append to the path.
  /// - [body]: Optional arguments/body data to pass to the route.
  /// - [transition]: Optional custom transition animation.
  ///
  /// Example:
  /// ```dart
  /// router.resetTo('/home');
  /// ```
  Future<T?> resetTo<T extends Object?>(
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

  String _buildFullPath(String path, Map<String, dynamic>? query) {
    final normalized = RouteParser.normalizePath(path);
    if (query == null || query.isEmpty) {
      return normalized;
    }
    return '$normalized${RouteParser.buildQueryString(query)}';
  }

  void _log(String message) {
    if (config.debugLog) {
      debugPrint('[DashRouter] $message');
    }
  }

  @override
  void dispose() {
    // Clear all internal state
    _routes.clear();
    _redirects.clear();
    _childrenByParentPattern.clear();
    _nestedNavigators.clear();

    // Clear singleton reference
    _instance = null;
    super.dispose();
  }
}

/// Router delegate implementation for Navigator 2.0.
///
/// This delegate manages the navigation state and integrates with the
/// [Router] widget to provide declarative navigation support.
///
/// ## Features
///
/// - Full Navigator 2.0 support with declarative routing
/// - System back button handling via [PopNavigatorRouterDelegateMixin]
/// - URL synchronization with browser history
/// - Deep linking support
///
/// ## Usage
///
/// The delegate is typically created via [DashRouter.buildDelegate]:
///
/// ```dart
/// MaterialApp.router(
///   routerDelegate: router.buildDelegate(),
///   routeInformationParser: router.buildParser(),
/// )
/// ```
class _DashRouterDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  final DashRouter router;

  /// The current route path being displayed.
  String? _currentPath;

  _DashRouterDelegate(this.router) {
    router.addListener(_onRouterChanged);
    _currentPath = router.config.initialPath;
  }

  void _onRouterChanged() {
    // Update current path from router state
    final currentRoute = router.currentRoute;
    if (currentRoute != null) {
      _currentPath = currentRoute.fullPath;
    }
    notifyListeners();
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => router.navigatorKey;

  @override
  Object get currentConfiguration => _currentPath ?? router.config.initialPath;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: router.config.initialPath,
      onGenerateRoute: router.generateRoute,
      observers: [
        _NavigatorObserverAdapter(
          onRouteChanged: (route) {
            // Update current path when route changes
            if (route?.settings.name != null) {
              _currentPath = route!.settings.name;
              notifyListeners();
            }
          },
        ),
        ...router.observers.all,
        ...router.config.observers,
      ],
    );
  }

  @override
  Future<void> setNewRoutePath(Object configuration) async {
    if (configuration is String && configuration != _currentPath) {
      _currentPath = configuration;
      // Navigate to the new path
      await router.pushNamed(configuration);
    }
  }

  @override
  Future<bool> popRoute() async {
    // First check if we can pop from nested navigators
    if (router.canPop()) {
      router.pop();
      return true;
    }
    return super.popRoute();
  }

  @override
  void dispose() {
    router.removeListener(_onRouterChanged);
    super.dispose();
  }
}

/// Navigator observer adapter to track route changes.
class _NavigatorObserverAdapter extends NavigatorObserver {
  final void Function(Route<dynamic>? route) onRouteChanged;

  _NavigatorObserverAdapter({required this.onRouteChanged});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    onRouteChanged(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    onRouteChanged(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    onRouteChanged(newRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    onRouteChanged(previousRoute);
  }
}

/// Route information parser for Navigator 2.0.
///
/// This parser converts between [RouteInformation] (URL) and route
/// configuration objects for the [Router] widget.
///
/// ## Features
///
/// - Parses incoming URLs to route configurations
/// - Restores URLs from route configurations for browser history
/// - Handles query parameters and fragments
///
/// ## Usage
///
/// ```dart
/// MaterialApp.router(
///   routeInformationParser: router.buildParser(),
///   routerDelegate: router.buildDelegate(),
/// )
/// ```
class _DashRouteInformationParser extends RouteInformationParser<Object> {
  final DashRouter router;

  _DashRouteInformationParser(this.router);

  @override
  Future<Object> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final uri = routeInformation.uri;
    final path = uri.path.isEmpty ? '/' : uri.path;

    // Build full path with query parameters
    if (uri.hasQuery) {
      return '$path?${uri.query}';
    }
    return path;
  }

  @override
  RouteInformation restoreRouteInformation(Object configuration) {
    if (configuration is String) {
      return RouteInformation(uri: Uri.parse(configuration));
    }
    return RouteInformation(uri: Uri.parse(router.config.initialPath));
  }
}

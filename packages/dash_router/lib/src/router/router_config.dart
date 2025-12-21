import 'package:dash_router_annotations/dash_router_annotations.dart';
import 'package:flutter/widgets.dart';

import '../guards/guard.dart';
import '../middleware/middleware.dart';
import 'navigation_history.dart';
import 'route_data.dart';

/// Comprehensive router configuration options for Dash Router.
///
/// This class provides all configuration options needed to customize
/// the behavior, appearance, and functionality of the router instance.
/// Each option has sensible defaults to get you started quickly.
///
/// ## Core Configuration
///
/// The most commonly used options are:
/// - [initialPath] - Where navigation starts
/// - [defaultTransition] - Animation style for routes
/// - [debugLog] - Enable console logging
///
/// ## Advanced Features
///
/// - **Deep Linking**: Handle incoming URLs with [enableDeepLinks]
/// - **Global Guards/Middleware**: Apply security and logging globally
/// - **State Restoration**: Save/restore navigation state
/// - **Custom Error Handling**: Handle 404s and navigation errors
///
/// ## Example Usage
///
/// ```dart
/// // Basic configuration
/// final router = DashRouter(
///   config: DashRouterOptions(
///     initialPath: '/home',
///     debugLog: true,
///     defaultTransition: DashSlideTransition.right(),
///   ),
///   routes: generatedRoutes,
/// );
///
/// // Advanced configuration with all features
/// final router = DashRouter(
///   config: DashRouterOptions(
///     initialPath: '/dashboard',
///     debugLog: kDebugMode,
///     defaultTransition: DashFadeTransition(),
///     historyMaxSize: 50,
///     enableDeepLinks: true,
///     restorable: true,
///     restorationId: 'main_router',
///     globalGuards: const [
///       AuthGuard(),
///       LoggingGuard(),
///     ],
///     globalMiddleware: const [
///       AnalyticsMiddleware(),
///       ErrorReportingMiddleware(),
///     ],
///     notFoundBuilder: (context, path) => NotFoundPage(path: path),
///     errorBuilder: (context, error) => ErrorPage(error: error),
///     loadingBuilder: (context) => LoadingSpinner(),
///     observers: [
///       NavigationObserver(),
///       RouteAnalyticsObserver(),
///     ],
///   ),
///   routes: generatedRoutes,
/// );
/// ```
///
/// ## Performance Considerations
///
/// - Keep [historyMaxSize] reasonable (default 100) for memory efficiency
/// - Use [debugLog] only in development builds
/// - Enable [enableDeepLinks] only if you handle URL schemes
/// - Configure [observers] sparingly as they affect navigation performance
///
/// See also:
/// - [DashRouter] - The main router class
/// - [RouteData] - Route data available during navigation
/// - [DashGuard] - Route guards for security
/// - [DashMiddleware] - Middleware for cross-cutting concerns
class DashRouterOptions {
  /// Initial route path.
  ///
  /// This is the path that will be navigated to when the app starts.
  /// Defaults to '/'.
  final String initialPath;

  /// Default transition for routes that don't specify one.
  ///
  /// This transition will be used for all routes that don't have
  /// a specific transition configured.
  ///
  /// Defaults to [PlatformTransition] which uses iOS-style transitions
  /// on iOS/macOS and Material transitions on other platforms.
  final DashTransition defaultTransition;

  /// Whether to enable debug logging.
  ///
  /// When enabled, the router will print navigation events to the console.
  final bool debugLog;

  /// Maximum size of the navigation history.
  ///
  /// Older entries will be removed when this limit is reached.
  final int historyMaxSize;

  /// Whether to enable deep linking.
  ///
  /// When enabled, the router will handle incoming URLs and
  /// navigate to the appropriate route.
  final bool enableDeepLinks;

  /// Builder for error pages.
  ///
  /// This is called when an error occurs during navigation.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Builder for not found pages.
  ///
  /// This is called when no route matches the requested path.
  final Widget Function(BuildContext context, String path)? notFoundBuilder;

  /// Builder for loading pages.
  ///
  /// This is displayed while async route data is being loaded.
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Global navigation observers.
  ///
  /// These observers will receive notifications for all navigation events.
  final List<NavigatorObserver> observers;

  /// Global route guards.
  ///
  /// These guards will run for all routes in addition to route-specific guards.
  /// Use const instances for type-safe guard registration.
  ///
  /// Example:
  /// ```dart
  /// globalGuards: const [AuthGuard(), LoggingGuard()],
  /// ```
  final List<DashGuard> globalGuards;

  /// Global middleware.
  ///
  /// This middleware will run for all routes in addition to route-specific
  /// middleware. Use const instances for type-safe middleware registration.
  ///
  /// Example:
  /// ```dart
  /// globalMiddleware: const [LoggingMiddleware(), AnalyticsMiddleware()],
  /// ```
  final List<DashMiddleware> globalMiddleware;

  /// Whether to enable state restoration.
  ///
  /// When enabled, the navigation state will be saved and restored
  /// when the app is backgrounded and resumed.
  final bool restorable;

  /// Restoration ID for state restoration.
  ///
  /// This must be unique across your app.
  final String? restorationId;

  /// Creates router configuration options.
  const DashRouterOptions({
    this.initialPath = '/',
    this.defaultTransition = const PlatformTransition(),
    this.debugLog = false,
    this.historyMaxSize = 100,
    this.enableDeepLinks = true,
    this.errorBuilder,
    this.notFoundBuilder,
    this.loadingBuilder,
    this.observers = const [],
    this.globalGuards = const [],
    this.globalMiddleware = const [],
    this.restorable = false,
    this.restorationId,
  });

  /// Creates a copy with modifications.
  DashRouterOptions copyWith({
    String? initialPath,
    DashTransition? defaultTransition,
    bool? debugLog,
    int? historyMaxSize,
    bool? enableDeepLinks,
    Widget Function(BuildContext context, Object error)? errorBuilder,
    Widget Function(BuildContext context, String path)? notFoundBuilder,
    Widget Function(BuildContext context)? loadingBuilder,
    List<NavigatorObserver>? observers,
    List<DashGuard>? globalGuards,
    List<DashMiddleware>? globalMiddleware,
    bool? restorable,
    String? restorationId,
  }) {
    return DashRouterOptions(
      initialPath: initialPath ?? this.initialPath,
      defaultTransition: defaultTransition ?? this.defaultTransition,
      debugLog: debugLog ?? this.debugLog,
      historyMaxSize: historyMaxSize ?? this.historyMaxSize,
      enableDeepLinks: enableDeepLinks ?? this.enableDeepLinks,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      notFoundBuilder: notFoundBuilder ?? this.notFoundBuilder,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      observers: observers ?? this.observers,
      globalGuards: globalGuards ?? this.globalGuards,
      globalMiddleware: globalMiddleware ?? this.globalMiddleware,
      restorable: restorable ?? this.restorable,
      restorationId: restorationId ?? this.restorationId,
    );
  }
}

/// Immutable state representation of the router.
///
/// This class contains all information about the current navigation state
/// at a given moment. Router state changes trigger notifications to
/// listeners and can be used to build reactive UI.
///
/// ## State Properties
///
/// - **Current Route**: The actively displayed route
/// - **Navigation History**: Stack of visited routes
/// - **Operation Status**: Whether navigation is in progress
/// - **Initialization State**: Whether router is ready for use
///
/// ## State Management
///
/// Router state is immutable - each change creates a new state instance.
/// This ensures predictable state updates and enables time-travel debugging.
///
/// ## Example Usage
///
/// ```dart
/// class NavigationStatus extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final state = DashRouter.instance.state;
///     
///     return Column(
///       children: [
///         Text('Current: ${state.currentRoute?.path ?? 'None'}'),
///         Text('History: ${state.history.length} routes'),
///         Text('Navigating: ${state.isNavigating}'),
///         
///         if (state.canGoBack)
///           ElevatedButton(
///             onPressed: () => state.history.pop(),
///             child: Text('Back'),
///           ),
///       ],
///     );
///   }
/// }
/// ```
///
/// ## State Changes
///
/// Listen to state changes via router's change notifications:
/// ```dart
/// final router = DashRouter.instance;
/// router.addListener(() {
///   final state = router.state;
///   print('Route changed to: ${state.currentRoute?.path}');
/// });
/// ```
///
/// See also:
/// - [DashRouter] - The main router class
/// - [NavigationHistory] - Detailed history management
/// - [RouteData] - Information about current route
class RouterState {
  /// Current route data.
  final RouteData? currentRoute;

  /// Navigation history.
  final NavigationHistory history;

  /// Whether the router has been initialized.
  final bool isInitialized;

  /// Whether a navigation operation is in progress.
  final bool isNavigating;

  /// Pending redirect path, if any.
  final String? pendingRedirect;

  /// Creates a router state.
  const RouterState({
    this.currentRoute,
    required this.history,
    this.isInitialized = false,
    this.isNavigating = false,
    this.pendingRedirect,
  });

  /// Creates the initial router state.
  factory RouterState.initial({int historyMaxSize = 100}) {
    return RouterState(history: NavigationHistory(maxSize: historyMaxSize));
  }

  /// Creates a copy with modifications.
  RouterState copyWith({
    RouteData? currentRoute,
    NavigationHistory? history,
    bool? isInitialized,
    bool? isNavigating,
    String? pendingRedirect,
    bool clearPendingRedirect = false,
  }) {
    return RouterState(
      currentRoute: currentRoute ?? this.currentRoute,
      history: history ?? this.history,
      isInitialized: isInitialized ?? this.isInitialized,
      isNavigating: isNavigating ?? this.isNavigating,
      pendingRedirect: clearPendingRedirect
          ? null
          : (pendingRedirect ?? this.pendingRedirect),
    );
  }

  /// Gets the previous route from history.
  RouteData? get previousRoute => history.previous;

  /// Whether navigation can go back.
  bool get canGoBack => history.canGoBack;

  /// Whether navigation can go forward.
  bool get canGoForward => history.canGoForward;

  @override
  String toString() => 'RouterState('
      'currentRoute: ${currentRoute?.path}, '
      'isInitialized: $isInitialized, '
      'isNavigating: $isNavigating)';
}

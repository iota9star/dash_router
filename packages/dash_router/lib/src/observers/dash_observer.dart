import 'package:flutter/widgets.dart';

import 'route_context.dart';

/// Enhanced route observer for Dash Router.
///
/// Extends Flutter's NavigatorObserver to provide comprehensive route
/// event tracking with callbacks for push, pop, replace, and remove operations.
/// Ideal for analytics, debugging, or custom navigation behavior.
///
/// ## Features
///
/// - **Event Callbacks**: Separate callbacks for each navigation event type
/// - **Event History**: Maintains a configurable history of events
/// - **Rich Context**: Access to current and previous routes
/// - **Logging Support**: Built-in optional logging for debugging
/// - **Custom Observers**: Pre-built observers for common use cases
///
/// ## Example
///
/// ```dart
/// // Basic usage
/// final observer = DashObserver(
///   onPush: (context) => analytics.trackScreenView(context.path),
///   onPop: (context) => analytics.trackBackNavigation(),
///   enableLogging: true,
/// );
///
/// // Advanced usage with custom event handling
/// final advancedObserver = DashObserver(
///   onRouteEvent: (event) {
///     switch (event.type) {
///       case RouteEventType.push:
///         logNavigation('Screen opened', event.context.path);
///       case RouteEventType.pop:
///         logNavigation('Screen closed', event.context.path);
///     }
///   },
///   maxHistorySize: 50,
/// );
/// ```
///
/// ## Registration
///
/// Register with router:
/// ```dart
/// DashRouter.builder()
///     .addObserver(analyticsObserver)
///     .addObserver(debugObserver)
///     .build();
/// ```
///
/// ## Built-in Observers
///
/// - [AnalyticsObserver] - Screen view tracking for analytics services
/// - [DebugObserver] - Simple logging observer for debugging
class DashObserver extends NavigatorObserver {
  /// Callback for push events
  final void Function(RouteEventContext context)? onPush;

  /// Callback for pop events
  final void Function(RouteEventContext context)? onPop;

  /// Callback for replace events
  final void Function(RouteEventContext context)? onReplace;

  /// Callback for remove events
  final void Function(RouteEventContext context)? onRemove;

  /// Callback for any route event
  final void Function(RouteEvent event)? onRouteEvent;

  /// History of route events
  final List<RouteEvent> _history = [];

  /// Maximum history size
  final int maxHistorySize;

  /// Whether to log events
  final bool enableLogging;

  DashObserver({
    this.onPush,
    this.onPop,
    this.onReplace,
    this.onRemove,
    this.onRouteEvent,
    this.maxHistorySize = 100,
    this.enableLogging = false,
  });

  /// Get route history
  List<RouteEvent> get history => List.unmodifiable(_history);

  /// Get last event
  RouteEvent? get lastEvent => _history.isEmpty ? null : _history.last;

  /// Clear history
  void clearHistory() {
    _history.clear();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final context = RouteEventContext(
      route: route,
      previousRoute: previousRoute,
    );

    _recordEvent(RouteEvent(type: RouteEventType.push, context: context));

    onPush?.call(context);

    if (enableLogging) {
      _log('Push: ${context.previousPath} -> ${context.path}');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final context = RouteEventContext(
      route: route,
      previousRoute: previousRoute,
    );

    _recordEvent(RouteEvent(type: RouteEventType.pop, context: context));

    onPop?.call(context);

    if (enableLogging) {
      _log('Pop: ${context.path} -> ${context.previousPath}');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final context = RouteEventContext(route: newRoute, previousRoute: oldRoute);

    _recordEvent(RouteEvent(type: RouteEventType.replace, context: context));

    onReplace?.call(context);

    if (enableLogging) {
      _log('Replace: ${context.previousPath} -> ${context.path}');
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final context = RouteEventContext(
      route: route,
      previousRoute: previousRoute,
    );

    _recordEvent(RouteEvent(type: RouteEventType.remove, context: context));

    onRemove?.call(context);

    if (enableLogging) {
      _log('Remove: ${context.path}');
    }
  }

  void _recordEvent(RouteEvent event) {
    _history.add(event);
    while (_history.length > maxHistorySize) {
      _history.removeAt(0);
    }
    onRouteEvent?.call(event);
  }

  void _log(String message) {
    // ignore: avoid_print
    print('[DashRouter] $message');
  }
}

/// Analytics-focused observer
class AnalyticsObserver extends DashObserver {
  final void Function(String screenName, Map<String, dynamic>? params)?
      onScreenView;

  AnalyticsObserver({this.onScreenView, super.enableLogging});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackScreenView(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackScreenView(newRoute);
    }
  }

  void _trackScreenView(Route<dynamic> route) {
    final name = route.settings.name ?? 'unknown';
    final arguments = route.settings.arguments;

    Map<String, dynamic>? params;
    if (arguments is Map<String, dynamic>) {
      params = arguments;
    }

    onScreenView?.call(name, params);
  }
}

/// Debug observer that logs all events
class DebugObserver extends DashObserver {
  DebugObserver() : super(enableLogging: true);
}

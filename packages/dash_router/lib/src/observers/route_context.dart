import 'package:flutter/widgets.dart';

import '../router/route_data.dart';

/// Context for route observer callbacks
class RouteEventContext {
  /// The route associated with this event
  final Route<dynamic>? route;

  /// The previous route (for push/replace events)
  final Route<dynamic>? previousRoute;

  /// Parsed route data (if available)
  final RouteData? routeData;

  /// Parsed previous route data (if available)
  final RouteData? previousRouteData;

  /// Timestamp of the event
  final DateTime timestamp;

  RouteEventContext({
    this.route,
    this.previousRoute,
    this.routeData,
    this.previousRouteData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Get current route path
  String? get path => route?.settings.name;

  /// Get previous route path
  String? get previousPath => previousRoute?.settings.name;

  /// Get current route name
  String? get routeName => routeData?.name ?? _extractName(path);

  /// Get previous route name
  String? get previousRouteName =>
      previousRouteData?.name ?? _extractName(previousPath);

  String? _extractName(String? path) {
    if (path == null) return null;
    final segments = path.split('/').where((s) => s.isNotEmpty);
    return segments.isEmpty ? 'root' : segments.last;
  }
}

/// Types of route events
enum RouteEventType { push, pop, replace, remove }

/// Route event data
class RouteEvent {
  /// Type of the event
  final RouteEventType type;

  /// Event context
  final RouteEventContext context;

  const RouteEvent({required this.type, required this.context});

  /// Check event type
  bool get isPush => type == RouteEventType.push;
  bool get isPop => type == RouteEventType.pop;
  bool get isReplace => type == RouteEventType.replace;
  bool get isRemove => type == RouteEventType.remove;

  @override
  String toString() =>
      'RouteEvent($type: ${context.previousPath} -> ${context.path})';
}

import 'package:flutter/widgets.dart';

import 'dash_observer.dart';
import 'route_context.dart';

/// Manager for route observers
class ObserverManager {
  final List<NavigatorObserver> _observers = [];

  /// Internal dash observer for event aggregation
  late final DashObserver _internalObserver;

  /// Event listeners
  final List<void Function(RouteEvent)> _eventListeners = [];

  ObserverManager() {
    _internalObserver = DashObserver(onRouteEvent: _notifyEventListeners);
    _observers.add(_internalObserver);
  }

  /// Get all observers
  List<NavigatorObserver> get all => List.unmodifiable(_observers);

  /// Add an observer
  void add(NavigatorObserver observer) {
    _observers.add(observer);
  }

  /// Add multiple observers
  void addAll(List<NavigatorObserver> observers) {
    _observers.addAll(observers);
  }

  /// Remove an observer
  void remove(NavigatorObserver observer) {
    _observers.remove(observer);
  }

  /// Clear all observers (except internal)
  void clear() {
    _observers.clear();
    _observers.add(_internalObserver);
  }

  /// Get event history
  List<RouteEvent> get history => _internalObserver.history;

  /// Add event listener
  void addEventListener(void Function(RouteEvent) listener) {
    _eventListeners.add(listener);
  }

  /// Remove event listener
  void removeEventListener(void Function(RouteEvent) listener) {
    _eventListeners.remove(listener);
  }

  void _notifyEventListeners(RouteEvent event) {
    for (final listener in _eventListeners) {
      listener(event);
    }
  }

  /// Add a simple observer with callbacks
  void addSimple({
    void Function(RouteEventContext)? onPush,
    void Function(RouteEventContext)? onPop,
    void Function(RouteEventContext)? onReplace,
    void Function(RouteEventContext)? onRemove,
  }) {
    add(
      DashObserver(
        onPush: onPush,
        onPop: onPop,
        onReplace: onReplace,
        onRemove: onRemove,
      ),
    );
  }

  /// Add analytics observer
  void addAnalytics({
    required void Function(String screenName, Map<String, dynamic>? params)
        onScreenView,
    bool enableLogging = false,
  }) {
    add(
      AnalyticsObserver(
        onScreenView: onScreenView,
        enableLogging: enableLogging,
      ),
    );
  }

  /// Add debug observer
  void addDebug() {
    add(DebugObserver());
  }
}

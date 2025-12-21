import 'route_data.dart';

/// Navigation history management for Dash Router.
///
/// This class maintains a stack of visited routes, enabling back/forward
/// navigation, history inspection, and route tracking throughout the app.
///
/// ## Features
///
/// - **Back/Forward Navigation**: Track position in navigation stack
/// - **Size Limits**: Automatically trim history to prevent memory issues
/// - **Route Lookup**: Find routes by path or name
/// - **Event Listeners**: Get notified of history changes
///
/// ## Example
///
/// ```dart
/// class NavigationWidget extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final history = DashRouter.instance.history;
///     
///     return Column(
///       children: [
///         Text('Current: ${history.currentPath}'),
///         Text('Can go back: ${history.canGoBack}'),
///         
///         if (history.canGoBack)
///           ElevatedButton(
///             onPressed: () => history.pop(),
///             child: Text('Back'),
///           ),
///             
///         Text('History (${history.length} routes):'),
///         ...history.entries.map((route) => Text('  ${route.path}')),
///       ],
///     );
///   }
/// }
/// ```
///
/// ## Memory Management
///
/// The history automatically trims itself to [maxSize] entries to prevent
/// memory growth in long-running applications. The oldest entries are removed
/// when the limit is exceeded.
class NavigationHistory {
  /// Maximum number of entries to keep in history
  final int maxSize;

  /// History entries (newest first)
  final List<RouteData> _entries = [];

  /// Current position in history (for back/forward)
  int _currentIndex = -1;

  /// Listeners for history changes
  final List<void Function(NavigationHistory)> _listeners = [];

  NavigationHistory({this.maxSize = 100});

  /// Gets all history entries with newest first.
  ///
  /// Returns an unmodifiable list to prevent external modification.
  /// The list maintains the order of navigation visits.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final allVisited = history.entries;
  /// print('Visited ${allVisited.length} routes');
  /// for (final route in allVisited.take(10)) {
  ///   print('  ${route.path}');
  /// }
  /// ```
  List<RouteData> get entries => List.unmodifiable(_entries);

  /// Gets the currently active route in history.
  ///
  /// Returns null if no route is currently selected or if the
  /// current index is out of bounds (empty history).
  ///
  /// ## Example
  ///
  /// ```dart
  /// final current = history.current;
  /// if (current != null) {
  ///   print('Currently at: ${current.path}');
  /// }
  /// ```
  RouteData? get current =>
      _currentIndex >= 0 && _currentIndex < _entries.length
          ? _entries[_currentIndex]
          : null;

  /// Gets the previously visited route.
  ///
  /// Returns null if there's no previous route (at start of history)
  /// or if the current route is the first one.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final previous = history.previous;
  /// if (previous != null) {
  ///   print('Came from: ${previous.path}');
  /// }
  /// ```
  RouteData? get previous =>
      _currentIndex > 0 ? _entries[_currentIndex - 1] : null;

  /// Get next route (if navigated back)
  RouteData? get next =>
      _currentIndex < _entries.length - 1 ? _entries[_currentIndex + 1] : null;

  /// Check if can go back
  bool get canGoBack => _currentIndex > 0;

  /// Check if can go forward
  bool get canGoForward => _currentIndex < _entries.length - 1;

  /// Get history length
  int get length => _entries.length;

  /// Get current index
  int get currentIndex => _currentIndex;

  /// Check if history is empty
  bool get isEmpty => _entries.isEmpty;

  /// Check if history is not empty
  bool get isNotEmpty => _entries.isNotEmpty;

  /// Pushes a new route entry to the history.
  ///
  /// This method adds a route to the history stack, updating the
  /// current index and managing memory constraints. Any forward navigation
  /// history (routes after current position) is automatically cleared.
  ///
  /// ## Behavior
  ///
  /// - Adds new route as most recent entry
  /// - Updates current index to point to new entry
  /// - Removes any forward history entries
  /// - Automatically trims history to [maxSize] if exceeded
  /// - Notifies all listeners of the change
  ///
  /// ## Example
  ///
  /// ```dart
  /// final route = RouteData(
  ///   pattern: '/user/:id',
  ///   path: '/user/123',
  ///   name: 'userDetail',
  /// );
  /// history.push(route);
  /// print('Current: ${history.currentPath}');
  /// print('History length: ${history.length}');
  /// ```
  ///
  /// [data] - The route data to add to history
  void push(RouteData data) {
    // Remove forward history if we're not at the end
    if (_currentIndex < _entries.length - 1) {
      _entries.removeRange(_currentIndex + 1, _entries.length);
    }

    _entries.add(data);
    _currentIndex = _entries.length - 1;

    // Trim to max size
    while (_entries.length > maxSize) {
      _entries.removeAt(0);
      _currentIndex--;
    }

    _notifyListeners();
  }

  /// Pop the current entry (go back)
  RouteData? pop() {
    if (!canGoBack) return null;
    _currentIndex--;
    _notifyListeners();
    return current;
  }

  /// Go forward in history
  RouteData? forward() {
    if (!canGoForward) return null;
    _currentIndex++;
    _notifyListeners();
    return current;
  }

  /// Go to a specific index
  RouteData? goToIndex(int index) {
    if (index < 0 || index >= _entries.length) return null;
    _currentIndex = index;
    _notifyListeners();
    return current;
  }

  /// Replace the current entry
  void replaceCurrent(RouteData data) {
    if (_currentIndex >= 0 && _currentIndex < _entries.length) {
      _entries[_currentIndex] = data;
      _notifyListeners();
    } else {
      push(data);
    }
  }

  /// Pop until a specific path
  List<RouteData> popUntil(String path) {
    final popped = <RouteData>[];
    while (canGoBack && current?.path != path) {
      popped.add(_entries.removeAt(_currentIndex));
      _currentIndex--;
    }
    _notifyListeners();
    return popped;
  }

  /// Pop until a condition is met
  List<RouteData> popUntilWhere(bool Function(RouteData) predicate) {
    final popped = <RouteData>[];
    while (canGoBack && current != null && !predicate(current!)) {
      popped.add(_entries.removeAt(_currentIndex));
      _currentIndex--;
    }
    _notifyListeners();
    return popped;
  }

  /// Clear all history
  void clear() {
    _entries.clear();
    _currentIndex = -1;
    _notifyListeners();
  }

  /// Find entry by path
  RouteData? findByPath(String path) {
    try {
      return _entries.firstWhere((e) => e.path == path);
    } catch (_) {
      return null;
    }
  }

  /// Find entry by name
  RouteData? findByName(String name) {
    try {
      return _entries.firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Check if a path exists in history
  bool containsPath(String path) {
    return _entries.any((e) => e.path == path);
  }

  /// Get the path at a specific index
  String? pathAt(int index) {
    if (index < 0 || index >= _entries.length) return null;
    return _entries[index].path;
  }

  /// Add a listener for history changes
  void addListener(void Function(NavigationHistory) listener) {
    _listeners.add(listener);
  }

  /// Remove a listener
  void removeListener(void Function(NavigationHistory) listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(this);
    }
  }

  /// Get history stack as list of paths
  List<String> get pathStack => _entries.map((e) => e.path).toList();

  /// Get previous route path
  String? get previousPath => previous?.path;

  /// Get next route path
  String? get nextPath => next?.path;

  /// Get current route path
  String? get currentPath => current?.path;

  @override
  String toString() =>
      'NavigationHistory(length: $length, currentIndex: $_currentIndex)';
}

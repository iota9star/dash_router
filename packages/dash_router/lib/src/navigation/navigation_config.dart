/// Navigation action types.
enum NavAction {
  /// Push a new route onto the stack.
  push,

  /// Replace the current route with a new one.
  replace,

  /// Pop the current route and push a new one.
  popAndPush,

  /// Clear all routes and push a new one.
  clearStack,
}

/// Navigation action types for programmatic navigation.
///
/// These actions define different navigation behaviors
/// when using declarative navigation patterns.
///
/// ## Example
///
/// ```dart
/// // Define navigation intent
/// final intent = NavIntent(
///   path: '/user/123',
///   action: NavAction.push,  // Add to stack
/// );
///
/// final replaceIntent = NavIntent(
///   path: '/settings',
///   action: NavAction.replace,  // Replace current
/// );
/// ```
enum NavAction {
  /// Pushes a new route onto the navigation stack.
  ///
  /// This is the most common navigation action.
  /// The current route remains in the stack below the new route.
  ///
  /// Use when you want users to be able to navigate back.
  push,

  /// Replaces the current route with a new one.
  ///
  /// The current route is removed from the stack
  /// and replaced with the new route.
  ///
  /// Use when navigating to a completely different section
  /// where back navigation should return to the previous section.
  replace,

  /// Pops the current route and pushes a new one.
  ///
  /// This combines popping and pushing into a single atomic action.
  /// Useful when you need to remove the current route
  /// and navigate to a new one without showing the intermediate.
  popAndPush,

  /// Clears all routes and pushes a new one.
  ///
  /// This completely resets the navigation stack.
  /// Useful for logout scenarios or app reset.
  clearStack,
}

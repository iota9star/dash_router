# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-12-13

### Added

- Initial stable release of dash_router
- Core `DashRouter` class for route management and navigation
- `RouteEntry` class for defining route configurations
- `RedirectEntry` class for route redirects
- `DashRouterOptions` for router configuration
- Type-safe parameter access via `RouteData` and `TypedParamsResolver`
- `RouteInfoCache` for O(1) parameter access using InheritedWidget
- `DashTypedRoute` base class for generated typed routes with `$`-prefixed API:
  - `$pattern` - Route pattern with parameter placeholders
  - `$name` - Route name for named navigation
  - `$path` - Concrete path with interpolated values
  - `$query` - Query parameters map
  - `$body` - Body arguments (supports Record types)
  - `$transition` - Optional custom transition per-navigation
- Navigation extensions on `BuildContext`:
  - **Typed Route Navigation** (recommended):
    - `push(DashTypedRoute)` - Push typed route
    - `replace(DashTypedRoute)` - Replace with typed route
    - `popAndPush(DashTypedRoute)` - Pop and push typed route
    - `pushAndRemoveUntil(DashTypedRoute, predicate)` - Push and remove
    - `pushAndRemoveAll(DashTypedRoute)` - Clear stack and push
  - **String Path Navigation**:
    - `pushNamed(path, {query, body, transition})` - Push by path
    - `replaceNamed(path, ...)` - Replace by path
    - `popAndPushNamed(path, ...)` - Pop and push by path
    - `pushNamedAndRemoveUntil(path, predicate, ...)` - Push and remove
    - `pushNamedAndRemoveAll(path, ...)` - Clear stack and push
  - **Pop Operations**:
    - `pop([result])` - Pop current route
    - `popUntil(predicate)` - Pop until predicate
    - `popUntilNamed(path)` - Pop until reaching path
    - `popToRoot()` - Pop to root route
    - `maybePop([result])` - Respects route guards
    - `back([result])` - Alias for pop
  - **Navigation State**:
    - `canGoBack` - Check if can go back
    - `previousPath` - Get previous route path
- Built-in transitions:
  - `DashFadeTransition` - Fade animation
  - `DashSlideTransition` - Slide from any direction
  - `DashScaleTransition` - Scale animation
  - `DashRotationTransition` - Rotation animation
  - `DashScaleFadeTransition` - Combined scale and fade
  - `DashSlideFadeTransition` - Combined slide and fade
  - `PlatformTransition` - Platform-adaptive transition
  - `MaterialTransition` - Material Design transition
  - `CupertinoTransition` - iOS-style transition
  - `NoTransition` - Instant transition without animation
- `CustomAnimatedTransition` for runtime custom transitions
- Route guards system with `DashGuard` base class:
  - `canActivate()` - Check if navigation is allowed
  - `onActivated()` - Called after successful navigation
  - `onDenied()` - Called when navigation is denied
  - `routes` and `excludeRoutes` for glob pattern filtering
  - `priority` for execution order control
- Guard results: `GuardAllow`, `GuardDeny`, `GuardRedirect`
- Utility guards: `FunctionalGuard`, `ConditionalGuard`, `AsyncConditionalGuard`
- Middleware system with `DashMiddleware` base class:
  - `handle()` - Process navigation request
  - `afterNavigation()` - Called after successful navigation
  - `onAborted()` - Called when navigation is aborted
- Middleware results: `MiddlewareContinue`, `MiddlewareAbort`, `MiddlewareRedirect`
- Utility middleware: `FunctionalMiddleware`, `LoggingMiddleware`, `DelayMiddleware`
- Navigation history tracking with `NavigationHistory`
- Shell routes support for nested navigation with isolated animations
- Nested navigator support via `NestedNavigator` and `StatefulShellScope`
- Automatic nested navigation detection in navigation methods
- Full cross-platform support (iOS, Android, Web, macOS, Windows, Linux)

### API Design

- **Typed Routes**: Use `$`-prefixed properties to avoid conflicts with user parameters
- **Naming Convention**: Path-based class names (e.g., `/app/user/:id` → `AppUser$IdRoute`)
- **Navigation Separation**: Clear distinction between typed route and string path navigation
- **Body Parameters**: Support for complex types via Record tuples or Map

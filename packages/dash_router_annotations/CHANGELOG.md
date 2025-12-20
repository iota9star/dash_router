# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-12-20

### Changed

- Version bump to align with dash_router 1.1.0 release
- Improved documentation consistency across all packages

### Documentation

- Updated installation version in README to ^1.1.0

## [1.0.1] - 2025-12-14

### Fixed

- Fixed documentation to accurately reflect the API
- Corrected annotation documentation - removed references to non-existent `@PathParam`, `@QueryParam`, `@BodyParam`
- Updated README to show automatic parameter inference from constructor parameters
- Clarified that guards and middleware should be passed as instances, not types

### Documentation

- Rewrote README with accurate API examples
- Added documentation for unified `@DashRoute` usage for all route types
- Added documentation for `@IgnoreParam` annotation
- Updated Chinese documentation (README_zh.md) with correct examples

## [1.0.0] - 2025-12-13

### Added

- Initial stable release of dash_router_annotations
- Core route annotation `@DashRoute` with full configuration options:
  - `path` - Route path pattern with dynamic parameters support
  - `name` - Optional custom route name
  - `parent` - Parent route for nested routing
  - `transition` - Route transition animation
  - `guards` - Route guard types
  - `middleware` - Route middleware types
  - `keepAlive` - Keep route alive when not visible
  - `fullscreenDialog` - Present as fullscreen dialog
  - `maintainState` - Maintain state when not visible
  - `metadata` - Custom metadata map
- `@DashRouterConfig` annotation for generator configuration:
  - `generateNavigation` - Generate navigation extensions
  - `generateTypedRoutes` - Generate typed route classes
- Parameter annotations:
  - `@PathParam` - Path parameter binding
  - `@QueryParam` - Query parameter binding with default value support
  - `@BodyParam` - Body/arguments parameter binding
- Special route annotations:
  - `@InitialRoute` - Mark as initial/home route
  - `@ShellRoute` - Define shell routes for nested navigation
  - `@RedirectRoute` - Define route redirects
  - `@DialogRoute` - Define dialog routes
- Built-in transition classes (all `const` constructible):
  - `DashTransition` - Abstract base class
  - `DashFadeTransition` - Fade animation
  - `DashSlideTransition` - Slide from any direction (left, right, top, bottom)
  - `DashScaleTransition` - Scale animation with configurable alignment
  - `DashRotationTransition` - Rotation animation
  - `DashScaleFadeTransition` - Combined scale and fade
  - `DashSlideFadeTransition` - Combined slide and fade
  - `PlatformTransition` - Platform-adaptive (Material on Android, Cupertino on iOS)
  - `MaterialTransition` - Material Design transition
  - `CupertinoTransition` - iOS-style slide transition
  - `NoTransition` - Instant transition without animation

### Changed

- N/A (initial release)

### Deprecated

- N/A (initial release)

### Removed

- Removed `DashCurve` class - transitions now use `Curves.easeInOut` by default
  - This simplifies the API while maintaining smooth animations
  - Custom curves can still be used via `CustomAnimatedTransition` at runtime

### Fixed

- N/A (initial release)

### Security

- N/A (initial release)

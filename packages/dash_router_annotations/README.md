# dash_router_annotations

[![pub package](https://img.shields.io/pub/v/dash_router_annotations.svg)](https://pub.dev/packages/dash_router_annotations)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Annotation definitions for the dash_router routing library. This package provides the annotations used to define routes and configure code generation.

## Features

- 📝 **Route Annotations** - Define routes with `@DashRoute` and related annotations
- 🎯 **Parameter Annotations** - Type-safe parameter definitions with `@PathParam`, `@QueryParam`, `@BodyParam`
- 🎨 **Transition Definitions** - Built-in transition classes for route animations
- ⚙️ **Configuration** - `@DashRouterConfig` for code generation settings

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  dash_router_annotations: ^1.0.0
```

## Annotations

### @DashRoute

Define a route for a page widget:

```dart
@DashRoute(
  path: '/user/:id',
  transition: CupertinoTransition(),
  guards: [AuthGuard],
  middleware: [LoggingMiddleware],
)
class UserPage extends StatelessWidget {
  final String id;
  const UserPage({super.key, required this.id});
  // ...
}
```

### @DashRouterConfig

Configure the route generator:

```dart
@DashRouterConfig(
  generateNavigation: true,
  generateTypedRoutes: true,
)
class AppRouter {}
```

### Parameter Annotations

```dart
@DashRoute(path: '/search')
class SearchPage extends StatelessWidget {
  @PathParam()
  final String? category;
  
  @QueryParam(defaultValue: '1')
  final int page;
  
  @QueryParam(name: 'sort_by')
  final String? sortBy;
  
  @BodyParam()
  final SearchFilter? filter;
  
  const SearchPage({
    super.key,
    this.category,
    this.page = 1,
    this.sortBy,
    this.filter,
  });
}
```

### @ShellRoute

Define a shell route for nested navigation:

```dart
@ShellRoute(path: '/app')
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});
  // ...
}
```

### @InitialRoute

Mark a route as the initial route:

```dart
@InitialRoute()
@DashRoute(path: '/')
class HomePage extends StatelessWidget { ... }
```

### @RedirectRoute

Define a route redirect:

```dart
@RedirectRoute(from: '/old-path', to: '/new-path')
class OldPageRedirect {}
```

## Transitions

All transitions support `const` construction:

```dart
// Platform adaptive
const PlatformTransition()

// Material Design
const MaterialTransition()

// iOS style
const CupertinoTransition()

// No animation
const NoTransition()

// Custom animations
const DashFadeTransition()
const DashFadeTransition(duration: Duration(milliseconds: 300))

const DashSlideTransition.right()
const DashSlideTransition.bottom()
const DashSlideTransition(begin: Offset(-1, 0))

const DashScaleTransition()
const DashScaleTransition(alignment: Alignment.center)

const DashRotationTransition()

const DashScaleFadeTransition()
const DashSlideFadeTransition.right()
```

## Naming Convention

Generated code follows a path-based naming convention:

| Path | Generated Class | Generated Field |
|------|-----------------|-----------------|
| `/app/user/:id` | `AppUser$IdRoute` | `appUser$Id` |
| `/app/settings` | `AppSettingsRoute` | `appSettings` |
| `/` | `RootRoute` | `root` |

Dynamic parameters use `$` prefix to distinguish from static segments.

## API Reference

See the [API documentation](https://pub.dev/documentation/dash_router_annotations/latest/) for complete details.

## Related Packages

- [dash_router](https://pub.dev/packages/dash_router) - Core routing library
- [dash_router_generator](https://pub.dev/packages/dash_router_generator) - Code generator
- [dash_router_cli](https://pub.dev/packages/dash_router_cli) - CLI tools

## License

MIT License - See [LICENSE](LICENSE) for details.

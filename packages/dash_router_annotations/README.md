# dash_router_annotations

[![pub package](https://img.shields.io/pub/v/dash_router_annotations.svg)](https://pub.dev/packages/dash_router_annotations)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Annotation definitions for the dash_router routing library. This package provides the annotations used to define routes and configure code generation.

## Features

- 📝 **Route Annotations** - Define routes with `@DashRoute` and related annotations
- 🎯 **Automatic Parameter Inference** - Parameters are automatically inferred from constructor
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

Define a route for a page widget. Parameters are automatically inferred from the constructor:
- Path parameters from `:param` patterns in path
- Query parameters from optional constructor parameters
- Body parameters via `arguments` property

```dart
@DashRoute(
  path: '/user/:id',
  transition: CupertinoTransition(),
  guards: [AuthGuard()],
  middleware: [LoggingMiddleware()],
)
class UserPage extends StatelessWidget {
  final String id;         // Path parameter (from :id)
  final String? tab;       // Query parameter (optional)
  
  const UserPage({
    super.key,
    required this.id,
    this.tab,
  });
  // ...
}
```

### @DashRouterConfig

Configure the route generator:

```dart
@DashRouterConfig(
  generateNavigation: true,
  generateRouteInfo: true,
)
class AppRouter {}
```

### Parameter Handling

Parameters are **automatically inferred** from constructor parameters:

```dart
@DashRoute(path: '/search/:category')
class SearchPage extends StatelessWidget {
  // Path parameter - matches :category in path
  final String category;
  
  // Query parameters - optional parameters become query params
  final int page;
  final String? sortBy;
  
  const SearchPage({
    super.key,
    required this.category,
    this.page = 1,
    this.sortBy,
  });
}

// Navigate with:
// context.pushSearch(category: 'books', page: 2, sortBy: 'price');
// Generates URL: /search/books?page=2&sortBy=price
```

### Body Parameters (Complex Types)

Use `arguments` for passing complex objects:

```dart
@DashRoute(
  path: '/checkout',
  arguments: [UserData, Product],  // Record type: (UserData, Product)
)
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Type-safe access via generated extension
    final (user, product) = context.route.arguments;
    return Text(user.name);
  }
}
```

### Shell Routes

Define a shell route for nested navigation using `shell: true`:

```dart
@DashRoute(path: '/app', shell: true)
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const MyNavBar(),
    );
  }
}
```

### Initial Routes

Mark a route as the initial route using `initial: true`:

```dart
@DashRoute(path: '/', initial: true)
class HomePage extends StatelessWidget { ... }
```

### Redirect Routes

Define a route redirect using `redirectTo`:

```dart
@DashRoute(path: '/old-path', redirectTo: '/new-path')
class OldPageRedirect {}

// Permanent redirect
@DashRoute(path: '/legacy', redirectTo: '/modern', permanentRedirect: true)
class LegacyRedirect {}
```

### Fullscreen Dialog Routes

Define a fullscreen dialog route using `fullscreenDialog: true`:

```dart
@DashRoute(
  path: '/edit-profile',
  fullscreenDialog: true,
  transition: DashSlideTransition.bottom(),
)
class EditProfilePage extends StatelessWidget { ... }
```

### @IgnoreParam

Exclude a constructor parameter from route parameters:

```dart
@DashRoute(path: '/user/:id')
class UserPage extends StatelessWidget {
  final String id;
  
  @IgnoreParam()
  final VoidCallback? onTap;  // Not a route parameter
  
  const UserPage({
    super.key,
    required this.id,
    this.onTap,
  });
}
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

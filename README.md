# Dash Router

<p align="center">
  <strong>🚀 Zero mental overhead, fully type-safe Flutter routing library</strong>
</p>

<p align="center">
  <a href="https://pub.dev/packages/dash_router"><img src="https://img.shields.io/pub/v/dash_router.svg" alt="Pub Version"></a>
  <a href="https://github.com/iota9star/dash_router/actions"><img src="https://github.com/iota9star/dash_router/workflows/CI/badge.svg" alt="Build Status"></a>
  <a href="https://codecov.io/gh/iota9star/dash_router"><img src="https://codecov.io/gh/iota9star/dash_router/branch/main/graph/badge.svg" alt="Coverage"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License"></a>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#examples">Examples</a> •
  <a href="./README_zh.md">中文</a>
</p>

---

## Features

- ✅ **O(1) Parameter Access** - Instant parameter retrieval via InheritedWidget caching
- ✅ **Fully Type-Safe** - Compile-time type checking, zero runtime errors
- ✅ **Single Entry Point** - Just remember `context.route`
- ✅ **Rich Transitions** - Built-in Material, Cupertino, and custom animations (all `const` supported)
- ✅ **Route Guards** - Flexible permission control and authentication protection
- ✅ **Middleware Support** - Logging, analytics, rate limiting, and other cross-cutting concerns
- ✅ **Code Generation** - Auto-generate type-safe navigation extensions
- ✅ **CLI Tools** - Convenient command-line utilities
- ✅ **Cross-Platform** - iOS, Android, Web, macOS, Windows, Linux

## Quick Start

### 1. Add Dependencies

```yaml
dependencies:
  dash_router: ^1.0.0
  dash_router_annotations: ^1.0.0

dev_dependencies:
  build_runner: ^2.4.0
  dash_router_generator: ^1.0.0
```

### 2. Define Routes

Use annotations to define page routes:

```dart
import 'package:flutter/material.dart';
import 'package:dash_router/dash_router.dart';

// Basic page route
@DashRoute(path: '/user/:id')
class UserPage extends StatelessWidget {
  final String id;
  final String? tab;
  
  const UserPage({
    super.key,
    required this.id,
    this.tab,
  });
  
  @override
  Widget build(BuildContext context) {
    // Access route info via context.route - O(1) complexity
    final route = context.route;
    
    return Scaffold(
      appBar: AppBar(title: Text('User $id')),
      body: Column(
        children: [
          Text('Route: ${route.name}'),
          Text('Path: ${route.fullPath}'),
          Text('Tab: $tab'),
        ],
      ),
    );
  }
}

// Route with custom transition
@DashRoute(
  path: '/settings',
  transition: CupertinoTransition(),
)
class SettingsPage extends StatelessWidget { ... }
```

### 3. Generate Code

```bash
# Option 1: Using build_runner
dart run build_runner build

# Option 2: Using CLI tool
dart run dash_router_cli:dash_router generate
```

### 4. Configure Router

```dart
import 'generated/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  static final _router = DashRouter(
    config: DashRouterOptions(
      initialPath: '/',
      debugLog: true,
    ),
    routes: generatedRoutes,
    redirects: generatedRedirects,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      navigatorKey: _router.navigatorKey,
      initialRoute: _router.config.initialPath,
      onGenerateRoute: _router.generateRoute,
    );
  }
}
```

### 5. Navigate

```dart
// Using generated type-safe extensions
context.pushUser$Id(id: '123', tab: 'profile');

// Or using string path
context.push('/user/123?tab=profile');

// Replace current route
context.replace('/home');

// Go back
context.pop();

// With return value
context.pop<String>('success');

// Clear stack and navigate
context.pushAndRemoveAll('/login');
```

## Documentation

### Naming Convention

Generated code follows a path-based naming convention:

| Path | Route Class | Field Name | Extension |
|------|-------------|------------|-----------|
| `/app/user/:id` | `AppUser$IdRoute` | `appUser$Id` | `AppUser$IdNavigation` |
| `/app/settings` | `AppSettingsRoute` | `appSettings` | `AppSettingsNavigation` |
| `/` | `RootRoute` | `root` | `RootNavigation` |

Dynamic parameters use `$` prefix to distinguish from static segments.

### Transitions

All built-in transitions support `const` construction:

```dart
// Platform adaptive
@DashRoute(path: '/a', transition: PlatformTransition())

// Material Design
@DashRoute(path: '/b', transition: MaterialTransition())

// iOS style
@DashRoute(path: '/c', transition: CupertinoTransition())

// No animation
@DashRoute(path: '/d', transition: NoTransition())

// Fade
@DashRoute(path: '/e', transition: DashFadeTransition())

// Slide
@DashRoute(path: '/f', transition: DashSlideTransition.right())
@DashRoute(path: '/g', transition: DashSlideTransition.bottom())

// Scale
@DashRoute(path: '/h', transition: DashScaleTransition())

// Combined animations
@DashRoute(path: '/i', transition: DashScaleFadeTransition())
@DashRoute(path: '/j', transition: DashSlideFadeTransition.right())
```

Runtime custom transition:

```dart
context.push(
  '/custom',
  transition: CustomAnimatedTransition(
    duration: Duration(milliseconds: 500),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return RotationTransition(turns: animation, child: child);
    },
  ),
);
```

### Route Guards

```dart
class AuthGuard extends DashGuard {
  const AuthGuard();
  
  @override
  Future<GuardResult> canActivate(GuardContext context) async {
    if (await AuthService.isLoggedIn()) {
      return const GuardAllow();
    }
    return const GuardRedirect('/login');
  }
}

// Register guard globally
router.guards.register(const AuthGuard());

// Use on specific route with instance
@DashRoute(
  path: '/admin',
  guards: [AuthGuard()],
)
class AdminPage extends StatelessWidget { ... }
```

### Middleware

```dart
class LoggingMiddleware extends DashMiddleware {
  @override
  Future<MiddlewareResult> handle(MiddlewareContext context) async {
    print('Navigating to: ${context.targetPath}');
    return const MiddlewareContinue();
  }
  
  @override
  Future<void> afterNavigation(MiddlewareContext context) async {
    print('Navigation completed in ${context.elapsed.inMilliseconds}ms');
  }
}

// Register middleware
router.middleware.register(LoggingMiddleware());
```

### Parameter Access

```dart
@override
Widget build(BuildContext context) {
  final route = context.route;
  
  // Path parameters
  final id = route.path.get<String>('id');
  
  // Query parameters
  final page = route.query.get<int>('page', defaultValue: 1);
  
  // Body arguments (raw)
  final user = route.body as User?;
  
  // With generated extension (type-safe):
  // final (user, product) = route.typedBody;
  
  // All parameters
  final allParams = route.allParams;
  
  return ...;
}
```

### Parameter Types

#### Path Parameters

```dart
@DashRoute(path: '/user/:id/post/:postId')
class PostPage extends StatelessWidget {
  @PathParam()
  final String id;
  
  @PathParam()
  final String postId;
}
```

#### Query Parameters

```dart
@DashRoute(path: '/search')
class SearchPage extends StatelessWidget {
  @QueryParam()
  final String? keyword;
  
  @QueryParam(defaultValue: '1')
  final int page;
  
  @QueryParam(name: 'sort_by')
  final String? sortBy;
}
```

#### Body Parameters

```dart
// Using arguments annotation for type-safe body access
@DashRoute(
  path: '/edit',
  arguments: [User],  // Generates typedBody getter
)
class EditPage extends StatelessWidget {
  const EditPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Type-safe access via generated extension
    final user = context.route.typedBody;
    return Text(user.name);
  }
}

// Pass when navigating
context.pushEditPage(body: user);
// or
context.push('/edit', arguments: user);
```

## CLI Tool

```bash
# Initialize configuration (in your app package root)
dart run dash_router_cli:dash_router init

# Generate route code
dart run dash_router_cli:dash_router generate

# Watch file changes and auto-generate
dart run dash_router_cli:dash_router watch

# Validate configuration
dart run dash_router_cli:dash_router validate

# Clean generated files
dart run dash_router_cli:dash_router clean

# Monorepo: use --config to point to target package config
dart run dash_router_cli:dash_router generate --config example/dash_router.yaml
```

## Architecture

```
dash_router/
├── packages/
│   ├── dash_router/              # Core routing library
│   ├── dash_router_annotations/  # Annotation definitions
│   ├── dash_router_generator/    # Code generator
│   └── dash_router_cli/          # CLI tools
└── example/                      # Example application
```

## Performance

- **O(1) Parameter Access**: InheritedWidget + caching mechanism
- **Lazy Loading**: Route info created on demand
- **Compile-time Optimization**: Code generation with zero runtime overhead
- **LRU Cache**: Smart navigation history management

## Examples

See the [example](./example) directory for complete examples.

## Contributing

Contributions welcome! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for details.

## License

MIT License - See [LICENSE](./LICENSE) file for details

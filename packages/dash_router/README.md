# dash_router

[![pub package](https://img.shields.io/pub/v/dash_router.svg)](https://pub.dev/packages/dash_router)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

The core routing library for Flutter applications. Provides type-safe navigation, route guards, middleware, and rich transition animations.

## Features

- 🚀 **O(1) Parameter Access** - InheritedWidget-based caching for instant parameter retrieval
- 🔒 **Type-Safe** - Compile-time type checking for all route parameters
- 🎨 **Rich Transitions** - Built-in Material, Cupertino, and custom animations
- 🛡️ **Route Guards** - Authentication and authorization protection
- 🔌 **Middleware** - Logging, analytics, and cross-cutting concerns
- 📱 **Cross-Platform** - Works on iOS, Android, Web, macOS, Windows, Linux

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  dash_router: ^1.0.0
```

## Usage

### Basic Setup

```dart
import 'package:dash_router/dash_router.dart';
import 'generated/routes.dart';

class MyApp extends StatelessWidget {
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
      navigatorKey: _router.navigatorKey,
      initialRoute: _router.config.initialPath,
      onGenerateRoute: _router.generateRoute,
    );
  }
}
```

### Navigation

```dart
// Push a new route
context.push('/user/123');

// Replace current route
context.replace('/home');

// Pop current route
context.pop();

// Pop with result
context.pop<String>('result');

// Clear stack and push
context.pushAndRemoveAll('/login');
```

### Accessing Route Parameters

```dart
@override
Widget build(BuildContext context) {
  final route = context.route;
  
  // Path parameters - O(1) access
  final id = route.path.get<String>('id');
  
  // Query parameters
  final page = route.query.get<int>('page', defaultValue: 1);
  
  // Body parameters - unified API
  final user = route.body.get<User>('user');
  
  // Raw arguments access
  final rawArgs = route.body.arguments;
  
  // With generated extension (type-safe):
  // final (user, product) = route.typedBody; // Returns typed Record
  
  return ...;
}
```

### Transitions

Use built-in transitions or create custom ones:

```dart
// Push with transition
context.push(
  '/details',
  transition: const DashSlideTransition.right(),
);

// Custom transition
context.push(
  '/custom',
  transition: CustomAnimatedTransition(
    duration: Duration(milliseconds: 500),
    transitionBuilder: (context, animation, secondary, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
);
```

### Route Guards

```dart
class AuthGuard extends DashGuard {
  @override
  Future<GuardResult> canActivate(GuardContext context) async {
    if (await isAuthenticated()) {
      return const GuardAllow();
    }
    return const GuardRedirect('/login');
  }
}

// Register
router.guards.register(AuthGuard());
```

### Middleware

```dart
class AnalyticsMiddleware extends DashMiddleware {
  @override
  Future<MiddlewareResult> handle(MiddlewareContext context) async {
    analytics.logScreenView(context.targetPath);
    return const MiddlewareContinue();
  }
}

// Register
router.middleware.register(AnalyticsMiddleware());
```

## API Reference

See the [API documentation](https://pub.dev/documentation/dash_router/latest/) for complete details.

## Related Packages

- [dash_router_annotations](https://pub.dev/packages/dash_router_annotations) - Route annotations
- [dash_router_generator](https://pub.dev/packages/dash_router_generator) - Code generator
- [dash_router_cli](https://pub.dev/packages/dash_router_cli) - CLI tools

## License

MIT License - See [LICENSE](LICENSE) for details.

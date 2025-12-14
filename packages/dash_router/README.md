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
// Push a typed route (recommended)
context.push(AppUserRoute(id: '123', tab: 'profile'));

// Push by path
context.pushNamed('/user/123');

// Replace current route
context.replace(AppHomeRoute());
context.replaceNamed('/home');

// Pop current route
context.pop();

// Pop with result
context.pop<String>('result');

// Clear stack and push
context.pushAndRemoveAll(AppLoginRoute());
context.pushNamedAndRemoveAll('/login');
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
  
  // Body parameters (raw arguments)
  final args = route.body.arguments;
  
  // Named body parameter access
  final user = route.body.get<User>('user');
  
  // With generated extension for typed body (Record type):
  // final (user, product) = route.arguments;
  
  return ...;
}
```

### Transitions

Use built-in transitions or create custom ones:

```dart
// Push with transition
context.pushNamed(
  '/details',
  transition: const DashSlideTransition.right(),
);

// Custom transition
context.pushNamed(
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
  final AuthService authService;
  
  const AuthGuard(this.authService);
  
  @override
  Future<GuardResult> canActivate(GuardContext context) async {
    if (await authService.isAuthenticated()) {
      return const GuardAllow();
    }
    return const GuardRedirect('/login');
  }
}

// Register
router.guards.register(AuthGuard(authService));
```

### Middleware

```dart
class AnalyticsMiddleware extends DashMiddleware {
  final AnalyticsService analytics;
  
  AnalyticsMiddleware(this.analytics);
  
  @override
  Future<MiddlewareResult> handle(MiddlewareContext context) async {
    analytics.logScreenView(context.targetPath);
    return const MiddlewareContinue();
  }
  
  @override
  Future<void> afterNavigation(MiddlewareContext context) async {
    analytics.logPageLoadTime(context.elapsed);
  }
}

// Register
router.middleware.register(AnalyticsMiddleware(analytics));
```

## API Reference

See the [API documentation](https://pub.dev/documentation/dash_router/latest/) for complete details.

## Related Packages

- [dash_router_annotations](https://pub.dev/packages/dash_router_annotations) - Route annotations
- [dash_router_generator](https://pub.dev/packages/dash_router_generator) - Code generator
- [dash_router_cli](https://pub.dev/packages/dash_router_cli) - CLI tools

## License

MIT License - See [LICENSE](LICENSE) for details.

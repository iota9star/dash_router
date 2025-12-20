# dash_router_generator

[![pub package](https://img.shields.io/pub/v/dash_router_generator.svg)](https://pub.dev/packages/dash_router_generator)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Code generator for dash_router. Generates type-safe route code from `@DashRoute` annotations.

## Features

- 🔧 **CLI-Based Generation** - Fast code generation without build_runner overhead
- 📁 **Per-Route Info Files** - Generates separate files for each route's type info
- 🎯 **Type-Safe Navigation** - Generates navigation extensions with full type safety
- 🔄 **Watch Mode** - Auto-regenerate on file changes
- ⚙️ **Configurable** - Customize output paths and generation options

## Installation

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  dash_router_generator: any
  dash_router_cli: any
```

## Usage

### CLI Generation

```bash
# Generate routes
dart run dash_router_cli generate

# Watch for changes
dart run dash_router_cli watch

# Dry run (preview without writing)
dart run dash_router_cli generate --dry-run
```

### Configuration

Create `dash_router.yaml` in your project root:

```yaml
dash_router:
  scan:
    - "lib/**/*.dart"
  generate:
    output: "lib/generated/routes.dart"
    route_info_output: "lib/generated/route_info/"
  options:
    generate_navigation: true
    generate_typed_routes: true
    generate_route_info: true
```

### Generated Code

The generator produces:

1. **Routes File** (`routes.dart`)
   - `generatedRoutes` - List of all route entries
   - `generatedRedirects` - List of redirect entries

2. **Route Info Files** (per route)
   - Type-safe parameter access extensions
   - Route pattern checking

3. **Navigation Extensions**
   - `context.pushUserPage(id: '123')`
   - `context.replaceWithHomePage()`
   - etc.

## Example Generated Code

For a route defined as:

```dart
@DashRoute(
  path: '/user/:id',
  arguments: [UserData],
)
class UserPage extends StatelessWidget { ... }
```

The generator produces:

```dart
// In route_info/user_$id.route.dart
extension User$IdRouteInfoX on ScopedRouteInfo {
  bool get isUser$IdRoute => pattern == '/user/:id';
  UserData get typedBody => body.arguments as UserData;
}

// Navigation extensions
extension UserPageNavigation on BuildContext {
  Future<T?> pushUserPage<T>({required String id, UserData? userData}) { ... }
  Future<T?> replaceWithUserPage<T>({required String id}) { ... }
}
```

## API Reference

See the [API documentation](https://pub.dev/documentation/dash_router_generator/latest/) for complete details.

## Related Packages

- [dash_router](https://pub.dev/packages/dash_router) - Core routing library
- [dash_router_annotations](https://pub.dev/packages/dash_router_annotations) - Route annotations
- [dash_router_cli](https://pub.dev/packages/dash_router_cli) - CLI tools

## License

MIT License - See [LICENSE](LICENSE) for details.

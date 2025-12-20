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

- Fixed documentation with accurate API references and examples
- Updated README to reflect correct parameter inference behavior

### Documentation

- Rewrote README with working code examples
- Updated Chinese documentation (README_zh.md)

## [1.0.0] - 2025-12-13

### Added

- Initial stable release of dash_router_generator
- **CLI-based code generation** via `CliCodegen`:
  - Scans Dart files for `@DashRoute` annotations
  - Generates type-safe route code automatically
  - Supports configuration via `dash_router.yaml`
  - Outputs generated files to configurable locations

- **Route visitor** (`RouteVisitor`):
  - Parses `@DashRoute` annotations from source files
  - Extracts route configuration including path, name, parent, guards, middleware
  - Supports all annotation variants:
    - `@DashRoute` - Standard page route
    - `@InitialRoute` - Initial/home route
    - `@ShellRoute` - Shell route for nested navigation
    - `@RedirectRoute` - Redirect route
    - `@DialogRoute` - Dialog route

- **Parameter visitor** (`ParamVisitor`):
  - Analyzes constructor parameters for route pages
  - Automatically infers parameter types:
    - Path parameters (from `:param` in route path)
    - Query parameters (inferred from parameter position)
    - Body parameters (complex types passed via navigation)
  - Supports optional parameters with default values
  - Handles nullable types correctly

- **Code generation templates**:
  - `RouteTemplate` - Generates `Routes` class with all route entries as static constants
  - `NavigationTemplate` - Generates type-safe navigation extensions for BuildContext
  - `TypedRouteTemplate` - Generates typed route classes with `$`-prefixed API:
    - Path-based class naming: `/app/user/:id` → `AppUser$IdRoute`
    - Generated properties: `$pattern`, `$name`, `$path`, `$query`, `$body`, `$transition`
  - `RouteInfoTemplate` - Generates route info extensions for parameter access from RouteData

- **Path-based route class naming convention**:
  - Route classes are named based on their path, not the page class name
  - Path segments are converted to PascalCase
  - Path parameters use `$` prefix: `:id` → `$Id`
  - Examples:
    - `/app/home` → `AppHomeRoute`
    - `/app/user/:id` → `AppUser$IdRoute`
    - `/app/catalog/:category/:subcategory/:itemId` → `AppCatalog$Category$Subcategory$ItemIdRoute`

- **`$`-prefixed property API**:
  - All generated route properties use `$` prefix to avoid conflicts with user parameters
  - `$pattern` - The route pattern with parameter placeholders
  - `$name` - The unique route name
  - `$path` - The resolved path with parameters substituted
  - `$query` - Query parameters map
  - `$body` - Body data object
  - `$transition` - Page transition configuration

- **Configuration support**:
  - `OutputConfig` - Configure output file locations
  - Support for `dash_router.yaml` configuration file:
    ```yaml
    dash_router:
      output:
        routes: lib/generated/routes.dart
        typed_routes: lib/generated/typed_routes.dart
        navigation: lib/generated/navigation.dart
        route_info: lib/generated/route_info.dart
    ```

- **Utility classes**:
  - `CodeFormatter` - Format generated code using dart_style
  - `TypeResolver` - Resolve and analyze Dart types
  - `StringUtils` - String manipulation utilities for code generation

- **Model classes**:
  - `RouteConfigModel` - Route configuration data
  - `ParamConfigModel` - Parameter configuration data
  - `RouteInfoModel` - Route tree information

### API Design

The generator creates route classes that follow these conventions:

```dart
// Generated from: @DashRoute('/app/user/:id')
class AppUser$IdRoute extends DashTypedRoute {
  const AppUser$IdRoute({
    required this.id,
    this.tab,
    this.userData,
    this.transition,
  });

  final String id;
  final String? tab;
  final UserData? userData;
  @override
  final DashTransition? transition;

  @override
  String get $pattern => '/app/user/:id';
  
  @override
  String get $name => 'user';
  
  @override
  String get $path => '/app/user/$id';
  
  @override
  Map<String, dynamic> get $query => {
    if (tab != null) 'tab': tab,
  };
  
  @override
  Object? get $body => userData;
}
```

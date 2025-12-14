# dash_router_cli

[![pub package](https://img.shields.io/pub/v/dash_router_cli.svg)](https://pub.dev/packages/dash_router_cli)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Command-line interface for the dash_router routing library. Provides commands for code generation, configuration management, and development workflow automation.

## Features

- 🚀 **Fast Generation** - Generate route code without build_runner overhead
- 👁️ **Watch Mode** - Auto-regenerate on file changes
- ✅ **Validation** - Validate route configurations
- 🧹 **Clean** - Remove generated files
- ⚙️ **Configuration** - Auto-detect or explicit config file support

## Installation

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  dash_router_cli: ^1.0.0
```

## Commands

### generate

Generate route code from annotated classes:

```bash
# Basic generation
dart run dash_router_cli:dash_router generate

# With verbose output
dart run dash_router_cli:dash_router generate --verbose

# Dry run (show what would be generated)
dart run dash_router_cli:dash_router generate --dry-run

# Use build_runner instead of CLI generator
dart run dash_router_cli:dash_router generate --build-runner

# With explicit config file (for monorepo)
dart run dash_router_cli:dash_router generate --config example/dash_router.yaml
```

Aliases: `gen`, `g`

### watch

Watch for file changes and auto-regenerate:

```bash
# Start watching
dart run dash_router_cli:dash_router watch

# With verbose output
dart run dash_router_cli:dash_router watch --verbose
```

Aliases: `w`

### init

Initialize dash_router configuration in your project:

```bash
# Create dash_router.yaml configuration file
dart run dash_router_cli:dash_router init

# Force overwrite existing config
dart run dash_router_cli:dash_router init --force
```

### validate

Validate route configuration:

```bash
# Validate configuration
dart run dash_router_cli:dash_router validate

# With verbose output
dart run dash_router_cli:dash_router validate --verbose
```

### clean

Remove generated files:

```bash
# Clean generated files
dart run dash_router_cli:dash_router clean

# Dry run
dart run dash_router_cli:dash_router clean --dry-run
```

## Configuration

Configuration is auto-detected from:

1. `dash_router.yaml` in project root
2. `dash_router` key in `pubspec.yaml`
3. Default configuration (if neither exists)

### dash_router.yaml

```yaml
# File paths to scan for routes
paths:
  - lib/**/*.dart

# Generation options
generate:
  output: lib/generated/routes.dart
  route_info_output: lib/generated/route_info/
  options:
    generate_route_info: true
    generate_navigation: true
    generate_typed_extensions: true

# Exclude patterns
exclude:
  - "**/*.g.dart"
  - "**/*.freezed.dart"
```

### Monorepo Usage

For monorepo projects, specify the config file path:

```bash
# Generate for specific package
dart run dash_router_cli:dash_router generate --config packages/app/dash_router.yaml

# Generate for example
dart run dash_router_cli:dash_router generate --config example/dash_router.yaml
```

## Output

The CLI generates the same code as the build_runner generator:

- Route entries in `Routes` class
- Route list `generatedRoutes`
- Redirect list `generatedRedirects`
- Typed route classes (e.g., `AppUser$IdRoute`)
- Navigation extensions (e.g., `AppUser$IdNavigation`)
- Route info classes (optional)

## API Reference

See the [API documentation](https://pub.dev/documentation/dash_router_cli/latest/) for complete details.

## Related Packages

- [dash_router](https://pub.dev/packages/dash_router) - Core routing library
- [dash_router_annotations](https://pub.dev/packages/dash_router_annotations) - Annotation definitions
- [dash_router_generator](https://pub.dev/packages/dash_router_generator) - Code generator

## License

MIT License - See [LICENSE](LICENSE) for details.

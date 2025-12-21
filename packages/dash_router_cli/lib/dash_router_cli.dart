/// Command-line interface for Dash Router.
///
/// This CLI tool provides comprehensive commands for managing Dash Router projects,
/// including code generation, file watching, validation, and project initialization.
///
/// ## Installation
///
/// Add to your `pubspec.yaml`:
/// ```yaml
/// dev_dependencies:
///   dash_router_cli: ^1.0.0
/// ```
///
/// ## Available Commands
///
/// ### Generate Routes
///
/// ```bash
/// dart run dash_router generate
/// ```
///
/// Scans your Dart files for route annotations and generates type-safe navigation code.
/// This is the most commonly used command during development.
///
/// ### Watch Mode
///
/// ```bash
/// dart run dash_router watch
/// ```
///
/// Continuously watches for file changes and automatically regenerates routes.
/// Ideal for active development sessions.
///
/// ### Initialize Project
///
/// ```bash
/// dart run dash_router init
/// ```
///
/// Sets up a new Flutter project with Dash Router, including example routes
/// and configuration files.
///
/// ### Validate Routes
///
/// ```bash
/// dart run dash_router validate
/// ```
///
/// Checks your route annotations for common issues and potential problems.
///
/// ### Clean Generated Files
///
/// ```bash
/// dart run dash_router clean
/// ```
///
/// Removes all generated route files. Useful before major refactoring.
///
/// ## Configuration
///
/// The CLI can be configured through a `dash_router.yaml` file in your project root:
///
/// ```yaml
/// # Files and directories to scan
/// include:
///   - lib/**/*.dart
///   - src/**/*.dart
///
/// # Files and directories to exclude
/// exclude:
///   - lib/generated/
///   - lib/**/*.g.dart
///
/// # Output configuration
/// output:
///   path: lib/generated/routes.dart
///   format: true   # Format generated code
///
/// # Watch configuration
/// watch:
///   debounce: 300ms  # Wait time before regenerating
///   quiet: false     # Suppress status messages
/// ```
///
/// ## Global Options
///
/// All commands support these global options:
///
/// - `--config, -c` - Path to configuration file (default: dash_router.yaml)
/// - `--verbose, -v` - Enable verbose logging
/// - `--quiet, -q` - Suppress informational output
/// - `--no-color` - Disable colored output
///
/// ## Examples
///
/// Basic usage:
/// ```bash
/// # Generate routes once
/// dart run dash_router generate
///
/// # Watch for changes
/// dart run dash_router watch
///
/// # Use custom config
/// dart run dash_router generate --config=my_config.yaml
///
/// # Enable verbose logging
/// dart run dash_router generate --verbose
/// ```
///
/// ## Integration with Build Runner
///
/// The CLI integrates with Dart's build_runner system:
/// ```bash
/// # Use build_runner
/// dart run build_runner build
///
/// # Or use build_runner watch
/// dart run build_runner watch
/// ```
///
library dash_router_cli;

export 'src/commands/init_command.dart';
export 'src/commands/generate_command.dart';
export 'src/commands/watch_command.dart';
export 'src/commands/validate_command.dart';
export 'src/commands/clean_command.dart';

export 'src/config/config_loader.dart';
export 'src/config/config_validator.dart';
export 'src/config/file_scanner.dart';

export 'src/utils/logger.dart';
export 'src/utils/file_watcher.dart';

// Re-export from dash_router_generator
export 'package:dash_router_generator/dash_router_generator.dart';

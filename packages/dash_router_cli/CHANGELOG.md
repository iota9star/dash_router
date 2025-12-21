# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2025-12-21

### Changed

- **Enhanced Code Documentation**: Improved documentation accuracy and clarity across the codebase

## [1.1.0] - 2025-12-20

### Changed

- Version bump to align with dash_router 1.1.0 release
- Improved documentation consistency across all packages

### Documentation

- Updated installation version in README to ^1.1.0

## [1.0.1] - 2025-12-14

### Fixed

- Fixed documentation with accurate command examples

### Documentation

- Updated README with correct CLI usage examples
- Updated Chinese documentation (README_zh.md)

## [1.0.0] - 2025-12-13

### Added

- Initial stable release of dash_router_cli
- **Command-line interface** with the following commands:

  - **`generate`** (aliases: `gen`, `g`) - Generate route code from annotations
    - `--config` - Explicit config file path
    - `--verbose` - Enable verbose output
    - `--dry-run` - Preview without writing files
    - `--build-runner` - Use build_runner instead of CLI generator
    ```bash
    # Generate routes
    dart run dash_router generate
    
    # Generate with verbose output
    dart run dash_router gen --verbose
    
    # Preview without writing
    dart run dash_router g --dry-run
    ```

  - **`watch`** (alias: `w`) - Watch files and auto-regenerate on changes
    - `--verbose` - Enable verbose output
    ```bash
    # Watch and auto-regenerate
    dart run dash_router watch
    ```

  - **`init`** - Initialize dash_router configuration
    - `--force` - Overwrite existing configuration
    ```bash
    # Initialize config file
    dart run dash_router init
    
    # Force overwrite existing config
    dart run dash_router init --force
    ```

  - **`validate`** - Validate route configuration
    - `--verbose` - Enable verbose output
    ```bash
    # Validate routes
    dart run dash_router validate
    ```

  - **`clean`** - Remove generated files
    - `--dry-run` - Preview without deleting files
    ```bash
    # Clean generated files
    dart run dash_router clean
    
    # Preview what would be deleted
    dart run dash_router clean --dry-run
    ```

- **Configuration system**:
  - `ConfigLoader` - Load configuration from multiple sources
  - `ConfigValidator` - Validate configuration
  - Auto-detection from `dash_router.yaml` or `pubspec.yaml`
  - Default configuration when no config file exists
  - Example `dash_router.yaml`:
    ```yaml
    dash_router:
      input:
        include:
          - lib/**/*.dart
        exclude:
          - lib/generated/**
      output:
        routes: lib/generated/routes.dart
        typed_routes: lib/generated/typed_routes/
        navigation: lib/generated/navigation.dart
        route_info: lib/generated/route_info.dart
    ```

- **File scanning** with `FileScanner`:
  - Glob pattern support
  - Exclude pattern support
  - Smart file filtering

- **File watching** with `FileWatcher`:
  - Debounced regeneration
  - Efficient file system monitoring

- **Logging utilities**:
  - `Logger` - Colored console output
  - Verbose mode support
  - Info, warning, error, and success messages

- **CLI utilities**:
  - Working directory management
  - Process execution helpers

- **Monorepo support** via `--config` flag

- **Integration** with `dash_router_generator` for code generation

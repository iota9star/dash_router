// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Code generator for Dash Router.
///
/// This library provides automatic code generation for type-safe navigation
/// from route annotations. It offers both CLI-based generation and
/// integration with Dart's build_runner system.
///
/// ## Overview
///
/// The generator scans your Dart files for route annotations and produces
/// comprehensive, type-safe navigation code including:
///
/// - Route definitions with proper typing
/// - Navigation extensions on BuildContext
/// - Typed route classes for programmatic use
/// - Route information for runtime inspection
/// - Parameter extraction and validation
///
/// ## Generation Methods
///
/// ### CLI Generation
///
/// Use the dedicated CLI for simple, explicit code generation:
///
/// ```bash
/// # Generate routes once
/// dart run dash_router_cli generate
///
/// # Watch for file changes and auto-regenerate
/// dart run dash_router_cli watch
///
/// # Validate route definitions
/// dart run dash_router_cli validate
///
/// # Clean generated files
/// dart run dash_router_cli clean
/// ```
///
/// ### Build Runner Integration
///
/// For integration with build_runner, add to your `build.yaml`:
///
/// ```yaml
/// targets:
///   $default:
///     builders:
///       dash_router_generator:
///         enabled: true
///         options:
///           output: "lib/generated/routes.dart"
///           generate_navigation: true
///           generate_typed_routes: true
/// ```
///
/// Then run with build_runner:
///
/// ```bash
/// # Single generation
/// dart run build_runner build
///
/// # Watch mode with build_runner
/// dart run build_runner watch
///
/// # Delete previous builds
/// dart run build_runner clean
/// ```
///
/// ## Generated Code Structure
///
/// The generator produces multiple types of code:
///
/// ### Route Definitions
///
/// ```dart
/// class Routes {
///   static const user = RouteEntry(
///     pattern: '/user/:id',
///     name: 'user',
///     builder: _UserRouteBuilder.build,
///   );
///   
///   static const profile = RouteEntry(
///     pattern: '/profile',
///     name: 'profile',
///     builder: _ProfileRouteBuilder.build,
///   );
/// }
/// ```
///
/// ### Navigation Extensions
///
/// ```dart
/// extension UserRouteNavigation on BuildContext {
///   Future<T?> pushUserPage<T extends Object?>(
///     String id, {
///     Map<String, dynamic>? query,
///     Object? body,
///     DashTransition? transition,
///   }) {
///     return pushNamed<T>(
///       '/user/$id',
///       query: query,
///       body: body,
///       transition: transition,
///     );
///   }
///   
///   Future<T?> replaceUserPage<T extends Object?, TO extends Object?>(
///     String id, {
///     TO? result,
///     Map<String, dynamic>? query,
///     Object? body,
///     DashTransition? transition,
///   }) {
///     return pushReplacementNamed<T, TO>(
///       '/user/$id',
///       result: result,
///       query: query,
///       body: body,
///       transition: transition,
///     );
///   }
/// }
/// ```
///
/// ### Typed Route Classes
///
/// ```dart
/// class UserPageRoute implements DashTypedRoute {
///   const UserPageRoute({
///     required this.id,
///     this.query,
///     this.body,
///     this.transition,
///   });
///
///   final String id;
///   final Map<String, dynamic>? query;
///   final Object? body;
///   final DashTransition? transition;
///
///   @override
///   String get $path => '/user/$id';
///
///   @override
///   Map<String, dynamic>? get $query => query;
///
///   @override
///   Object? get $body => body;
///
///   @override
///   DashTransition? get $transition => transition;
/// }
/// ```
///
/// ### Route Information Classes
///
/// ```dart
/// class UserPageRouteInfo {
///   static const String pattern = '/user/:id';
///   static const String name = 'user';
///   static const List<String> pathParams = ['id'];
///   static const Map<String, Type> paramTypes = {'id': String};
///   static const Map<String, dynamic> metadata = {};
/// }
/// ```
///
/// ## Configuration
///
/// ### YAML Configuration
///
/// Configure generation behavior via `dash_router.yaml`:
///
/// ```yaml
/// dash_router:
///   # Files and directories to scan
///   scan:
///     - "lib/**/*.dart"
///     - "src/**/*.dart"
///   
///   # Files and directories to exclude
///   exclude:
///     - "lib/generated/**"
///     - "**/*.g.dart"
///   
///   # Output configuration
///   generate:
///     output: "lib/generated/routes.dart"           # Main routes file
///     route_info_output: "lib/generated/route_info/"  # Per-route info files
///     format: true                               # Format generated code
///   
///   # Generation options
///   options:
///     generate_navigation: true     # Generate navigation extensions
///     generate_typed_routes: true   # Generate typed route classes
///     generate_route_info: true     # Generate route info classes
///     default_transition: "platform" # Default transition type
///     include_observer: true        # Include route observer
///   
///   # Advanced options
///   advanced:
///     code_style: "dart_style"     # Code formatter to use
///     line_length: 80             # Maximum line length
///     null_safety: true           # Generate null-safe code
/// ```
///
/// ## Supported Annotations
///
/// The generator recognizes these annotations:
///
/// - `@DashRoute` - Main route definition
/// - `@InitialRoute` - Initial/home route shorthand
/// - `@DialogRoute` - Dialog route shorthand
/// - `@ShellRoute` - Shell/wrapper route shorthand
/// - `@RedirectRoute` - Redirect route shorthand
/// - `@DashRouterConfig` - Global configuration
/// - `@RouteGuard` - Route guard definition
/// - `@RouteMiddleware` - Route middleware definition
/// - `@RequiresAuth` - Authentication requirement
/// - `@IgnoreParam` - Parameter exclusion
///
/// ## Advanced Features
///
/// ### Parameter Type Inference
///
/// The generator automatically infers parameter types from constructor
/// signatures:
///
/// ```dart
/// @DashRoute(path: '/user/:id')
/// class UserPage extends StatelessWidget {
///   const UserPage({
///     super.key,
///     required this.id,           // Infer: String
///     this.isAdmin = false,       // Infer: bool
///     this.profile,               // Infer: UserProfile?
///   });
///   
///   final String id;
///   final bool isAdmin;
///   final UserProfile? profile;
/// }
/// ```
///
/// ### Nested Route Generation
///
/// Automatic parent-child relationship handling for shell routes:
///
/// ```dart
/// @ShellRoute(path: '/app')
/// class AppShell extends StatelessWidget { ... }
///
/// @DashRoute(path: '/app/home', parent: '/app')
/// class HomePage extends StatelessWidget { ... }
///
/// @DashRoute(path: '/app/settings', parent: '/app')
/// class SettingsPage extends StatelessWidget { ... }
/// ```
///
/// ### Guard and Middleware Integration
///
/// Generates code that integrates guards and middleware:
///
/// ```dart
/// @RouteGuard(priority: 100)
/// class AuthGuard implements DashGuard { ... }
///
/// @RouteMiddleware(priority: 10)
/// class LoggingMiddleware implements DashMiddleware { ... }
///
/// @DashRoute(
///   path: '/profile',
///   guards: [AuthGuard],
///   middleware: [LoggingMiddleware],
/// )
/// class ProfilePage extends StatelessWidget { ... }
/// ```
///
/// ## Error Handling and Validation
///
/// The generator includes comprehensive validation:
///
/// - Duplicate route detection
/// - Invalid parameter name checking
/// - Circular dependency detection
/// - Invalid path pattern validation
/// - Missing required parameter detection
///
/// ## Performance Considerations
///
/// - Generated code is optimized for performance
/// - O(1) parameter access using typed getters
/// - Minimal runtime overhead
/// - Efficient string interpolation for paths
/// - Lazy initialization where appropriate
library;

// CLI code generation
export 'src/cli/cli_codegen.dart';

// Models
export 'src/models/param_config_model.dart';
export 'src/models/route_config_model.dart';
export 'src/models/route_info_model.dart';

// Visitors
export 'src/visitors/param_visitor.dart';
export 'src/visitors/route_visitor.dart';

// Templates
export 'src/templates/navigation_template.dart';
export 'src/templates/route_info_template.dart';
export 'src/templates/route_template.dart';
export 'src/templates/typed_route_template.dart';

// Config
export 'src/config/output_config.dart';

// Utils
export 'src/utils/code_formatter.dart';
export 'src/utils/string_utils.dart';
export 'src/utils/type_resolver.dart';

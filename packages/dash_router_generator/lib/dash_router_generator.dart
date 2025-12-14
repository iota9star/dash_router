// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Code generator for dash_router.
///
/// This library generates type-safe route code from `@DashRoute` annotations.
/// It provides both a CLI-based generator and integration with build_runner.
///
/// ## Usage
///
/// ### CLI Generation
///
/// ```bash
/// # Generate routes using CLI
/// dart run dash_router_cli generate
///
/// # Watch for changes
/// dart run dash_router_cli watch
/// ```
///
/// ### Build Runner Integration
///
/// Add to your `build.yaml`:
///
/// ```yaml
/// targets:
///   $default:
///     builders:
///       dash_router_generator:
///         enabled: true
/// ```
///
/// Then run:
///
/// ```bash
/// dart run build_runner build
/// ```
///
/// ## Generated Code
///
/// The generator produces:
///
/// - Route entries (`Routes` class with all route definitions)
/// - Navigation extensions (type-safe `push*` methods)
/// - Typed route classes (for programmatic navigation)
/// - Route info extensions (for typed parameter access)
///
/// ## Configuration
///
/// Configure via `dash_router.yaml`:
///
/// ```yaml
/// dash_router:
///   scan:
///     - "lib/**/*.dart"
///   generate:
///     output: "lib/generated/routes.dart"
///     route_info_output: "lib/generated/route_info/"
///   options:
///     generate_navigation: true
///     generate_typed_routes: true
///     generate_route_info: true
/// ```
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

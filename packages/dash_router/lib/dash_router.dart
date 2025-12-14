// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A powerful, type-safe Flutter routing library with zero mental overhead.
///
/// ## Getting Started
///
/// 1. Define routes using `@DashRoute` annotation:
///
/// ```dart
/// @DashRoute(path: '/user/:id')
/// class UserPage extends StatelessWidget {
///   const UserPage({super.key, required this.id});
///   final String id;
///
///   @override
///   Widget build(BuildContext context) => Text('User: $id');
/// }
/// ```
///
/// 2. Initialize the router:
///
/// ```dart
/// final router = DashRouter(
///   config: DashRouterOptions(initialPath: '/'),
///   routes: generatedRoutes,
/// );
/// ```
///
/// 3. Navigate using type-safe extensions:
///
/// ```dart
/// context.push('/user/123');
/// // or with generated methods
/// context.pushUserPage(id: '123');
/// ```
///
/// 4. Access route info anywhere:
///
/// ```dart
/// final route = context.route;
/// print(route.params.path['id']);
/// ```
library dash_router;

// Core exports
export 'src/router/dash_router.dart';
export 'src/router/router_config.dart';
export 'src/router/route_data.dart';
export 'src/router/navigation_history.dart';

// Navigation
export 'src/navigation/navigation_manager.dart';
export 'src/navigation/navigation_result.dart';
export 'src/navigation/navigation_config.dart';
export 'src/navigation/nested_navigator.dart';

// Route Info (core feature - InheritedWidget based)
export 'src/route_info/route_scope.dart';

// Params (O(1) access)
export 'src/params/params_types.dart';
export 'src/params/typed_params_resolver.dart';
export 'src/params/params_decoder.dart';
export 'src/params/params_validator.dart';

// Typed routes (generated navigation)
export 'src/typed_routes/typed_route.dart';

// Context Extensions
export 'src/context_extensions/route_extension.dart';
export 'src/context_extensions/navigation_extension.dart';

// Observers
export 'src/observers/dash_observer.dart';
export 'src/observers/route_context.dart';
export 'src/observers/observer_manager.dart';

// Guards
export 'src/guards/guard.dart';
export 'src/guards/guard_result.dart';
export 'src/guards/guard_manager.dart';

// Middleware
export 'src/middleware/middleware.dart';
export 'src/middleware/middleware_context.dart';
export 'src/middleware/middleware_pipeline.dart';
export 'src/middleware/middleware_manager.dart';

// App Links
export 'src/app_links/app_link_handler.dart';
export 'src/app_links/deep_link_manager.dart';

// Utils
export 'src/utils/route_parser.dart';
export 'src/utils/route_matcher.dart';
export 'src/utils/route_utils.dart';

// Exceptions
export 'src/exceptions/route_exceptions.dart';
export 'src/exceptions/params_exceptions.dart';

// Re-export annotations for convenience
export 'package:dash_router_annotations/dash_router_annotations.dart';

// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dash_router_annotations/dash_router_annotations.dart';

/// A typed route object for type-safe navigation.
///
/// This abstract class serves as the base for generated typed route classes.
/// Each route class provides compile-time type safety for navigation parameters
/// while coexisting with string-path navigation.
///
/// ## API Design
///
/// All getters use `$` prefix to avoid conflicts with user-defined parameters:
/// - `$pattern` - Route pattern with placeholders (e.g., `/user/:id`)
/// - `$name` - Route name for named navigation
/// - `$path` - Concrete path with interpolated values
/// - `$query` - Query parameters as a map
/// - `$body` - Body/arguments for the route
/// - `$transition` - Optional custom transition
///
/// ## Usage
///
/// ```dart
/// // Generated route class
/// class AppUser$IdRoute extends DashTypedRoute {
///   final String id;
///   final String? tab;
///
///   const AppUser$IdRoute({required this.id, this.tab, this.$transition});
///
///   @override
///   String get $pattern => '/app/user/:id';
///
///   @override
///   String get $path => '/app/user/$id';
///   // ...
/// }
///
/// // Navigate with type-safe parameters
/// context.push(AppUser$IdRoute(id: '123', tab: 'profile'));
/// ```
abstract class DashTypedRoute {
  /// Creates a typed route.
  const DashTypedRoute();

  /// Route pattern with parameter placeholders.
  ///
  /// Example: `/user/:id`, `/app/products/:productId`
  String get $pattern;

  /// Route name for named navigation.
  ///
  /// This is used when navigating by name rather than path.
  String get $name;

  /// Concrete path with interpolated parameter values.
  ///
  /// Example: For pattern `/user/:id` with `id='123'`, returns `/user/123`
  String get $path;

  /// Query parameters for the route.
  ///
  /// Returns `null` if no query parameters are defined.
  /// Example: `{'tab': 'profile', 'sort': 'name'}`
  Map<String, dynamic>? get $query;

  /// Body arguments for the route.
  ///
  /// Can be any object type, including:
  /// - Single object: `user`
  /// - Record tuple: `(user, product)`
  /// - Map: `{'user': user, 'product': product}`
  Object? get $body;

  /// Optional custom transition for this navigation.
  ///
  /// When provided, overrides the default transition for this navigation only.
  DashTransition? get $transition;
}

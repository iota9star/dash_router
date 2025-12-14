// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Annotations for dash_router - A type-safe Flutter routing library.
///
/// This library provides annotations used to define routes in your Flutter app.
/// The dash_router_generator package uses these annotations to generate
/// type-safe routing code.
///
/// ## Getting Started
///
/// 1. Add the dependencies to your `pubspec.yaml`:
///
/// ```yaml
/// dependencies:
///   dash_router: ^1.0.0
///   dash_router_annotations: ^1.0.0
///
/// dev_dependencies:
///   build_runner: ^2.4.0
///   dash_router_generator: ^1.0.0
/// ```
///
/// 2. Define routes using annotations:
///
/// ```dart
/// import 'package:dash_router_annotations/dash_router_annotations.dart';
/// import 'package:flutter/material.dart';
///
/// @DashRoute(path: '/user/:id')
/// class UserPage extends StatelessWidget {
///   const UserPage({super.key, required this.id});
///
///   final String id;
///
///   @override
///   Widget build(BuildContext context) => Text('User: $id');
/// }
/// ```
///
/// 3. Run the code generator:
///
/// ```bash
/// dart run build_runner build
/// ```
///
/// ## Available Annotations
///
/// - [DashRoute] - Main route annotation
/// - [InitialRoute] - Shorthand for initial/home route
/// - [DialogRoute] - Shorthand for fullscreen dialog routes
/// - [ShellRoute] - Shorthand for shell/wrapper routes
/// - [RedirectRoute] - Shorthand for redirect routes
/// - [DashRouterConfig] - Global router configuration
/// - [RouteGuard] - Mark a class as a route guard
/// - [RouteMiddleware] - Mark a class as route middleware
/// - [RequiresAuth] - Mark a route as requiring authentication
/// - [IgnoreParam] - Exclude a parameter from route params
///
/// ## Available Transitions
///
/// - [DashFadeTransition] - Fade in/out animation
/// - [DashSlideTransition] - Slide from any direction
/// - [DashScaleTransition] - Scale (zoom) animation
/// - [DashRotationTransition] - Rotation animation
/// - [DashScaleFadeTransition] - Combined scale and fade
/// - [DashSlideFadeTransition] - Combined slide and fade
/// - [PlatformTransition] - Platform-adaptive transition
/// - [MaterialTransition] - Material Design transition
/// - [CupertinoTransition] - iOS-style transition
/// - [NoTransition] - Instant transition (no animation)
library dash_router_annotations;

export 'src/config_annotation.dart';
export 'src/dash_transition.dart';
export 'src/route_annotation.dart';

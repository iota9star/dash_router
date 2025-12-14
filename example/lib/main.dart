// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'app.dart';

/// Entry point for the Dash Router example application.
///
/// This example demonstrates all features of the dash_router library:
///
/// - **Type-safe navigation**: Using generated route classes and extensions
/// - **Path parameters**: Dynamic segments like `/user/:id`
/// - **Query parameters**: Optional URL parameters like `?tab=profile`
/// - **Body parameters**: Complex objects passed during navigation
/// - **Nested routes**: Shell routes with child navigation
/// - **Route guards**: Authentication and authorization
/// - **Middleware**: Logging, analytics, rate limiting
/// - **Custom transitions**: Slide, fade, Cupertino, and custom animations
/// - **Responsive layout**: Adaptive navigation for mobile/tablet/desktop
///
/// ## Getting Started
///
/// ```dart
/// // Type-safe navigation
/// context.push(const UserPageRoute(id: '123'));
///
/// // Generated extension methods
/// context.pushUserPage(id: '456', tab: 'profile');
///
/// // Standard path navigation
/// context.go('/app/settings');
/// ```
void main() {
  runApp(const DashRouterExampleApp());
}

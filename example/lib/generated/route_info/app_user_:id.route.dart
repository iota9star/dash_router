// GENERATED CODE - DO NOT MODIFY BY HAND
// Route: /app/user/:id -> UserPage
// ignore_for_file: type=lint, unused_import, unused_element, unused_field

import 'package:dash_router/dash_router.dart';
import 'package:dash_router_example/shared/user_data.dart';
import 'package:flutter/widgets.dart';

/// Typed path parameters for UserPage
///
/// Usage: `route.path.id`
extension AppUser$IdPathParamsX on TypedPathParams {
  /// Path parameter: id
  String get id => get<String>('id');
}

/// Typed query parameters for UserPage
///
/// Usage: `route.query.tab`
extension AppUser$IdQueryParamsX on TypedQueryParams {
  /// Query parameter: tab
  String? get tab => get<String?>('tab');
}

/// Route info extension for UserPage
extension AppUser$IdRouteInfoX on ScopedRouteInfo {
  /// Check if current route is UserPage
  bool get isAppUser$IdRoute => pattern == '/app/user/:id';
}

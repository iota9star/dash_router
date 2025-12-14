// GENERATED CODE - DO NOT MODIFY BY HAND
// Route: /app/admin/users/:userId -> AdminUserDetailPage
// ignore_for_file: type=lint, unused_import, unused_element, unused_field

import 'package:dash_router/dash_router.dart';
import 'package:flutter/widgets.dart';

/// Typed path parameters for AdminUserDetailPage
///
/// Usage: `route.path.id`
extension AppAdminUsers$UserIdPathParamsX on TypedPathParams {
  /// Path parameter: userId
  String get userId => get<String>('userId');
}

/// Route info extension for AdminUserDetailPage
extension AppAdminUsers$UserIdRouteInfoX on ScopedRouteInfo {
  /// Check if current route is AdminUserDetailPage
  bool get isAppAdminUsers$UserIdRoute => pattern == '/app/admin/users/:userId';
}

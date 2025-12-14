// GENERATED CODE - DO NOT MODIFY BY HAND
// Route: /app/order -> OrderPage
// ignore_for_file: type=lint, unused_import, unused_element, unused_field

import 'package:dash_router/dash_router.dart';
import 'package:dash_router_example/shared/product.dart';
import 'package:dash_router_example/shared/user_data.dart';
import 'package:flutter/widgets.dart';

/// Typed body accessor for OrderPage
///
/// Usage: `final (a, b) = route.arguments; // Typed as (UserData, Product)`
/// Note: Generated extension provides type-safe access.
extension AppOrderRouteInfoX on ScopedRouteInfo {
  /// Check if current route is OrderPage
  bool get isAppOrderRoute => pattern == '/app/order';

  /// Typed body for OrderPage
  ///
  /// Returns body as Record: `(UserData, Product)`.
  (UserData, Product) get arguments => body.arguments as (UserData, Product);
}

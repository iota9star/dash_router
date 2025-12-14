// GENERATED CODE - DO NOT MODIFY BY HAND
// Route: /app/checkout -> CheckoutPage
// ignore_for_file: type=lint, unused_import, unused_element, unused_field

import 'package:dash_router/dash_router.dart';
import 'package:dash_router_example/shared/product.dart';
import 'package:dash_router_example/shared/shipping_info.dart';
import 'package:dash_router_example/shared/user_data.dart';
import 'package:flutter/widgets.dart';

/// Typed body accessor for CheckoutPage
///
/// Usage: `final (a, b) = route.arguments; // Typed as (UserData, Product, ShippingInfo)`
/// Note: Generated extension provides type-safe access.
extension AppCheckoutRouteInfoX on ScopedRouteInfo {
  /// Check if current route is CheckoutPage
  bool get isAppCheckoutRoute => pattern == '/app/checkout';

  /// Typed body for CheckoutPage
  ///
  /// Returns body as Record: `(UserData, Product, ShippingInfo)`.
  (UserData, Product, ShippingInfo) get arguments =>
      body.arguments as (UserData, Product, ShippingInfo);
}

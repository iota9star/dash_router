// GENERATED CODE - DO NOT MODIFY BY HAND
// Route: /app/products/:productId -> ProductDetailPage
// ignore_for_file: type=lint, unused_import, unused_element, unused_field

import 'package:dash_router/dash_router.dart';
import 'package:dash_router_example/shared/product.dart';
import 'package:flutter/widgets.dart';

/// Typed path parameters for ProductDetailPage
///
/// Usage: `route.path.id`
extension AppProducts$ProductIdPathParamsX on TypedPathParams {
  /// Path parameter: productId
  String get productId => get<String>('productId');
}

/// Typed query parameters for ProductDetailPage
///
/// Usage: `route.query.tab`
extension AppProducts$ProductIdQueryParamsX on TypedQueryParams {
  /// Query parameter: highlight
  String get highlight => get<String>('highlight', defaultValue: 'false');

  /// Query parameter: referralCode
  String? get referralCode => get<String?>('referralCode');
}

/// Route info extension for ProductDetailPage
extension AppProducts$ProductIdRouteInfoX on ScopedRouteInfo {
  /// Check if current route is ProductDetailPage
  bool get isAppProducts$ProductIdRoute =>
      pattern == '/app/products/:productId';
}

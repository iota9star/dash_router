// GENERATED CODE - DO NOT MODIFY BY HAND
// Route: /app/catalog/:category/:subcategory/:itemId -> CatalogPage
// ignore_for_file: type=lint, unused_import, unused_element, unused_field

import 'package:dash_router/dash_router.dart';
import 'package:flutter/widgets.dart';

/// Typed path parameters for CatalogPage
///
/// Usage: `route.path.id`
extension AppCatalog$Category$Subcategory$ItemIdPathParamsX on TypedPathParams {
  /// Path parameter: category
  String get category => get<String>('category');

  /// Path parameter: subcategory
  String get subcategory => get<String>('subcategory');

  /// Path parameter: itemId
  String get itemId => get<String>('itemId');
}

/// Typed query parameters for CatalogPage
///
/// Usage: `route.query.tab`
extension AppCatalog$Category$Subcategory$ItemIdQueryParamsX
    on TypedQueryParams {
  /// Query parameter: sort
  String? get sort => get<String?>('sort');

  /// Query parameter: filter
  String? get filter => get<String?>('filter');
}

/// Route info extension for CatalogPage
extension AppCatalog$Category$Subcategory$ItemIdRouteInfoX on ScopedRouteInfo {
  /// Check if current route is CatalogPage
  bool get isAppCatalog$Category$Subcategory$ItemIdRoute =>
      pattern == '/app/catalog/:category/:subcategory/:itemId';
}

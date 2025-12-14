// GENERATED CODE - DO NOT MODIFY BY HAND
// Route: /app/search/:query -> SearchResultsPage
// ignore_for_file: type=lint, unused_import, unused_element, unused_field

import 'package:dash_router/dash_router.dart';
import 'package:flutter/widgets.dart';

/// Typed path parameters for SearchResultsPage
///
/// Usage: `route.path.id`
extension AppSearch$QueryPathParamsX on TypedPathParams {
  /// Path parameter: query
  String get query => get<String>('query');
}

/// Typed query parameters for SearchResultsPage
///
/// Usage: `route.query.tab`
extension AppSearch$QueryQueryParamsX on TypedQueryParams {
  /// Query parameter: page
  String get page => get<String>('page', defaultValue: '1');

  /// Query parameter: filter
  String? get filter => get<String?>('filter');
}

/// Route info extension for SearchResultsPage
extension AppSearch$QueryRouteInfoX on ScopedRouteInfo {
  /// Check if current route is SearchResultsPage
  bool get isAppSearch$QueryRoute => pattern == '/app/search/:query';
}

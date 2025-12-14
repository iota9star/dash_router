// GENERATED CODE - DO NOT MODIFY BY HAND
// Route: /app/dashboard/reports -> DashboardReportsPage
// ignore_for_file: type=lint, unused_import, unused_element, unused_field

import 'package:dash_router/dash_router.dart';
import 'package:flutter/widgets.dart';

/// Typed query parameters for DashboardReportsPage
///
/// Usage: `route.query.tab`
extension AppDashboardReportsQueryParamsX on TypedQueryParams {
  /// Query parameter: dateRange
  String get dateRange => get<String>('dateRange', defaultValue: 'last_7_days');

  /// Query parameter: reportType
  String? get reportType => get<String?>('reportType');
}

/// Route info extension for DashboardReportsPage
extension AppDashboardReportsRouteInfoX on ScopedRouteInfo {
  /// Check if current route is DashboardReportsPage
  bool get isAppDashboardReportsRoute => pattern == '/app/dashboard/reports';
}

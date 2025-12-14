// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'route_config_model.dart';

/// Model for generating route info class.
///
/// This model generates route info class names based on the route path,
/// following the naming convention:
///
/// - `/app/user/:id` -> `AppUser$IdRouteInfo`
/// - `/app/settings` -> `AppSettingsRouteInfo`
///
/// Example:
/// ```dart
/// // For a route:
/// @DashRoute(path: '/user/:id')
/// class UserPage extends StatelessWidget { ... }
///
/// // Generated route info class:
/// // class User$IdRouteInfo implements TypedRouteInfo { ... }
/// ```
class RouteInfoModel {
  /// The route configuration.
  final RouteConfigModel config;

  /// Generated class name for route info (path-based).
  final String className;

  /// Generated file name (path-based).
  final String fileName;

  /// Import statements needed.
  final Set<String> imports;

  /// Creates a route info model.
  RouteInfoModel({
    required this.config,
    required this.className,
    required this.fileName,
    required this.imports,
  });

  /// Creates a route info model from a route configuration.
  ///
  /// The class name and file name are derived from the route path:
  /// - `/app/user/:id` -> class: `AppUser$IdRouteInfo`, file: `app_user_id_route_info.dart`
  factory RouteInfoModel.fromConfig(RouteConfigModel config) {
    final baseClassName = config.routeClassName.replaceAll('Route', '');
    return RouteInfoModel(
      config: config,
      className: '${baseClassName}RouteInfo',
      fileName: '${_pathToFileName(config.path)}_route_info.dart',
      imports: _collectImports(config),
    );
  }

  /// Page class name.
  String get pageClassName => config.className;

  /// Route path.
  String get path => config.path;

  /// Route name (camelCase based on path).
  String get routeName => config.routeName;

  /// Whether has path params.
  bool get hasPathParams => config.hasPathParams;

  /// Whether has query params.
  bool get hasQueryParams => config.hasQueryParams;

  /// Whether has body params.
  bool get hasBodyParams => config.hasBodyParams;

  /// Whether has any params.
  bool get hasParams => config.hasParams;

  /// Path parameters.
  List<ParamConfigModel> get pathParams => config.pathParams;

  /// Query parameters.
  List<ParamConfigModel> get queryParams => config.queryParams;

  /// Body parameters.
  List<ParamConfigModel> get bodyParams => config.bodyParams;

  /// Get params class name (path-based).
  String get paramsClassName {
    final baseName = config.routeClassName.replaceAll('Route', '');
    return '${baseName}Params';
  }

  /// Get path params class name (path-based, private).
  String get pathParamsClassName {
    final baseName = config.routeClassName.replaceAll('Route', '');
    return '_${baseName}PathParams';
  }

  /// Get query params class name (path-based, private).
  String get queryParamsClassName {
    final baseName = config.routeClassName.replaceAll('Route', '');
    return '_${baseName}QueryParams';
  }

  /// Get body params class name (path-based, private).
  String get bodyParamsClassName {
    final baseName = config.routeClassName.replaceAll('Route', '');
    return '_${baseName}BodyParams';
  }

  /// Converts a path to a snake_case file name.
  ///
  /// - `/app/user/:id` -> `app_user_id`
  /// - `/` -> `root`
  static String _pathToFileName(String path) {
    if (path == '/') return 'root';

    final segments = path.split('/').where((s) => s.isNotEmpty).map((segment) {
      if (segment.startsWith(':')) {
        return segment.substring(1); // Remove ':' prefix
      }
      return segment;
    }).toList();

    if (segments.isEmpty) return 'root';

    return segments.join('_').toLowerCase();
  }

  static Set<String> _collectImports(RouteConfigModel config) {
    final imports = <String>{
      'package:flutter/widgets.dart',
      'package:dash_router/dash_router.dart',
    };

    // Add import for the page class
    imports.add(config.importPath);

    // Add imports for custom types in parameters
    for (final param in config.allParams) {
      if (!_isBuiltinType(param.typeString)) {
        // Try to get the import from the type element
        final element = param.type.element;
        if (element != null && element.library != null) {
          imports.add(element.library!.identifier);
        }
      }
    }

    return imports;
  }

  static bool _isBuiltinType(String type) {
    final baseType = type.replaceAll('?', '').replaceAll(RegExp(r'<.*>'), '');
    return const [
      'String',
      'int',
      'double',
      'num',
      'bool',
      'DateTime',
      'List',
      'Map',
      'Set',
      'dynamic',
      'Object',
      'void',
    ].contains(baseType);
  }
}

/// Model for route tree structure
class RouteTreeModel {
  /// Root routes (no parent)
  final List<RouteConfigModel> rootRoutes;

  /// All routes indexed by name
  final Map<String, RouteConfigModel> routesByName;

  /// Child routes indexed by parent name
  final Map<String, List<RouteConfigModel>> childRoutes;

  RouteTreeModel({
    required this.rootRoutes,
    required this.routesByName,
    required this.childRoutes,
  });

  factory RouteTreeModel.build(List<RouteConfigModel> routes) {
    final routesByName = <String, RouteConfigModel>{};
    final childRoutes = <String, List<RouteConfigModel>>{};
    final rootRoutes = <RouteConfigModel>[];

    for (final route in routes) {
      routesByName[route.routeName] = route;

      if (route.parent != null) {
        childRoutes.putIfAbsent(route.parent!, () => []).add(route);
      } else {
        rootRoutes.add(route);
      }
    }

    return RouteTreeModel(
      rootRoutes: rootRoutes,
      routesByName: routesByName,
      childRoutes: childRoutes,
    );
  }

  /// Get children of a route
  List<RouteConfigModel> getChildren(String routeName) {
    return childRoutes[routeName] ?? [];
  }

  /// Check if a route has children
  bool hasChildren(String routeName) {
    return childRoutes.containsKey(routeName) &&
        childRoutes[routeName]!.isNotEmpty;
  }

  /// Get the initial route
  RouteConfigModel? get initialRoute {
    return rootRoutes.where((r) => r.isInitial).firstOrNull ??
        rootRoutes.firstOrNull;
  }
}

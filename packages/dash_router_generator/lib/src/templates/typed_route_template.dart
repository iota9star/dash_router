// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../models/route_config_model.dart';
import '../utils/string_utils.dart';

/// Template for generating typed route objects.
///
/// Generates [DashTypedRoute] subclasses that provide fully type-safe
/// navigation parameters while coexisting with string-path navigation.
///
/// ## Naming Convention
///
/// Route class names are derived from path patterns:
/// - `/app/user/:id` -> `AppUser$IdRoute`
/// - `/app/settings` -> `AppSettingsRoute`
/// - `/` -> `RootRoute`
///
/// ## Generated API
///
/// Each route class includes:
/// - `$pattern` - The route pattern (e.g., `/user/:id`)
/// - `$name` - The route name for named navigation
/// - `$path` - The concrete path with interpolated parameters
/// - `$query` - Query parameters as a map
/// - `$body` - Body/arguments for the route
/// - `$transition` - Optional custom transition
///
/// The `$` prefix prevents conflicts with user-defined parameters.
class TypedRouteTemplate {
  /// Generate typed route classes for all routes.
  ///
  /// Skips redirect-only routes as they don't need typed navigation.
  static String generateBody(List<RouteConfigModel> routes) {
    final buffer = StringBuffer();

    buffer.writeln('// ============================================');
    buffer.writeln('// Typed Route Objects (Type-Safe Navigation)');
    buffer.writeln('// ============================================');
    buffer.writeln();
    buffer.writeln('/// Typed route objects provide compile-time type safety');
    buffer.writeln('/// for navigation parameters.');
    buffer.writeln('///');
    buffer.writeln('/// Usage:');
    buffer.writeln('/// ```dart');
    buffer.writeln('/// // Navigate with type-safe parameters');
    buffer.writeln("/// context.push(AppUser\$IdRoute(id: '123'));");
    buffer.writeln('///');
    buffer.writeln('/// // With query parameters');
    buffer.writeln(
        "/// context.push(AppUser\$IdRoute(id: '123', tab: 'profile'));");
    buffer.writeln('/// ```');
    buffer.writeln();

    for (final route in routes) {
      if (route.redirectTo != null) continue;
      buffer.writeln(_generateTypedRoute(route));
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Generate a single typed route class.
  static String _generateTypedRoute(RouteConfigModel route) {
    // Use path-based naming: /app/user/:id -> AppUser$IdRoute
    final routeClassName = StringUtils.generateRouteClassName(route.path);

    final buffer = StringBuffer();

    // Class documentation
    buffer.writeln(
        '/// Typed route for [${route.className}] at `${route.path}`.');
    buffer.writeln('///');
    buffer.writeln('/// This route class provides type-safe navigation to');
    buffer.writeln('/// the ${route.className} widget.');
    buffer.writeln('///');
    if (route.pathParams.isNotEmpty) {
      buffer.writeln('/// ## Path Parameters');
      buffer.writeln('///');
      for (final param in route.pathParams) {
        final required = param.isRequired ? 'required' : 'optional';
        buffer.writeln(
            '/// - `${param.fieldName}` (${param.typeString}) - $required path parameter');
      }
      buffer.writeln('///');
    }
    if (route.queryParams.isNotEmpty) {
      buffer.writeln('/// ## Query Parameters');
      buffer.writeln('///');
      for (final param in route.queryParams) {
        final def = param.defaultValue != null
            ? ', default: ${param.defaultValue}'
            : '';
        buffer.writeln('/// - `${param.fieldName}` (${param.typeString}$def)');
      }
      buffer.writeln('///');
    }
    buffer.writeln('/// ## Example');
    buffer.writeln('///');
    buffer.writeln('/// ```dart');
    buffer.writeln('/// context.push($routeClassName(');
    _writeExampleParams(buffer, route);
    buffer.writeln('/// ));');
    buffer.writeln('/// ```');

    buffer.writeln('class $routeClassName extends DashTypedRoute {');

    // Check for argument types from annotation (Record-type body)
    final argumentTypes =
        route.metadata['argumentTypes'] as List<String>? ?? [];
    final hasArgumentTypes = argumentTypes.isNotEmpty;

    // Generate field names for argument types
    final argumentFieldNames = <String>[];
    for (final type in argumentTypes) {
      argumentFieldNames.add(StringUtils.typeNameToFieldName(type));
    }

    final hasAnyParams = route.pathParams.isNotEmpty ||
        route.queryParams.isNotEmpty ||
        route.bodyParams.isNotEmpty ||
        hasArgumentTypes;

    // Fields from path params
    for (final param in route.pathParams) {
      buffer.writeln('  /// Path parameter: ${param.name}');
      buffer.writeln('  final ${param.typeString} ${param.fieldName};');
      buffer.writeln();
    }

    // Fields from query params
    for (final param in route.queryParams) {
      final typeString = _navParamType(routeParam: param);
      buffer.writeln('  /// Query parameter: ${param.name}');
      if (param.defaultValue != null) {
        buffer.writeln('  ///');
        buffer.writeln('  /// Default: `${param.defaultValue}`');
      }
      buffer.writeln('  final $typeString ${param.fieldName};');
      buffer.writeln();
    }

    // Fields from body params (constructor params, skip Key params)
    for (final param in route.bodyParams) {
      if (param.isKey) continue;
      buffer.writeln('  /// Body parameter: ${param.name}');
      buffer.writeln('  final ${param.typeString} ${param.fieldName};');
      buffer.writeln();
    }

    // Fields from arguments annotation (Record-type body)
    for (int i = 0; i < argumentTypes.length; i++) {
      buffer.writeln('  /// Body argument: ${argumentTypes[i]}');
      buffer.writeln('  final ${argumentTypes[i]} ${argumentFieldNames[i]};');
      buffer.writeln();
    }

    // Transition field
    buffer.writeln('  /// Optional custom transition for this navigation.');
    buffer.writeln('  @override');
    buffer.writeln('  final DashTransition? \$transition;');
    buffer.writeln();

    // Constructor
    buffer.writeln('  /// Creates a typed route for ${route.className}.');
    if (!hasAnyParams) {
      buffer.writeln('  const $routeClassName({this.\$transition});');
    } else {
      buffer.write('  const $routeClassName({');

      // Required path params
      for (final param in route.pathParams) {
        if (param.isRequired) {
          buffer.write('required this.${param.fieldName}, ');
        }
      }

      // Optional path params
      for (final param in route.pathParams) {
        if (!param.isRequired) {
          buffer.write('this.${param.fieldName}, ');
        }
      }

      // Query params
      for (final param in route.queryParams) {
        if (param.defaultValue != null) {
          buffer.write('this.${param.fieldName} = ${param.defaultValue}, ');
        } else if (param.isRequired) {
          buffer.write('required this.${param.fieldName}, ');
        } else {
          buffer.write('this.${param.fieldName}, ');
        }
      }

      // Body params from constructor (skip Key params)
      for (final param in route.bodyParams) {
        if (param.isKey) continue;
        if (param.isRequired) {
          buffer.write('required this.${param.fieldName}, ');
        } else {
          buffer.write('this.${param.fieldName}, ');
        }
      }

      // Arguments annotation params (all required)
      for (final fieldName in argumentFieldNames) {
        buffer.write('required this.$fieldName, ');
      }

      // Transition param
      buffer.write('this.\$transition, ');

      buffer.writeln('});');
    }

    buffer.writeln();

    // Pattern getter
    buffer.writeln('  /// Route pattern: `${route.path}`');
    buffer.writeln('  @override');
    buffer.writeln("  String get \$pattern => '${route.path}';");
    buffer.writeln();

    // Name getter
    buffer.writeln('  /// Route name: `${route.routeName}`');
    buffer.writeln('  @override');
    buffer.writeln("  String get \$name => '${route.routeName}';");
    buffer.writeln();

    // Path getter with interpolation
    buffer.writeln('  /// Concrete path with interpolated parameters.');
    buffer.writeln('  @override');
    buffer.writeln('  String get \$path => ${_generatePathBuilder(route)};');
    buffer.writeln();

    // Query params getter
    buffer.writeln('  /// Query parameters for this route.');
    buffer.writeln('  @override');
    buffer.writeln(
        '  Map<String, dynamic>? get \$query => ${_generateQueryParams(route)};');
    buffer.writeln();

    // Body/arguments getter
    buffer.writeln('  /// Body arguments for this route.');
    buffer.writeln('  @override');
    buffer.writeln(
        '  Object? get \$body => ${_generateArguments(route, argumentTypes, argumentFieldNames)};');

    buffer.writeln('}');

    return buffer.toString();
  }

  static void _writeExampleParams(StringBuffer buffer, RouteConfigModel route) {
    for (final param in route.pathParams) {
      if (param.isRequired) {
        buffer.writeln("///   ${param.fieldName}: '<value>',");
      }
    }
    for (final param in route.queryParams) {
      if (param.isRequired) {
        buffer.writeln("///   ${param.fieldName}: '<value>',");
      }
    }
  }

  static String _navParamType({required ParamConfigModel routeParam}) {
    if (routeParam.defaultValue != null) {
      return routeParam.nonNullableTypeString;
    }
    return routeParam.typeString;
  }

  static String _generatePathBuilder(RouteConfigModel route) {
    var path = route.path;

    if (!route.hasPathParams) {
      return "'$path'";
    }

    for (final param in route.pathParams) {
      path = path.replaceAll(':${param.name}', '\${${param.fieldName}}');
    }

    return "'$path'";
  }

  static String _generateQueryParams(RouteConfigModel route) {
    if (!route.hasQueryParams) return 'null';

    final buffer = StringBuffer();
    buffer.writeln('{');

    for (final param in route.queryParams) {
      if (param.defaultValue != null || !param.isNullable) {
        buffer.writeln("      '${param.name}': ${param.fieldName},");
      } else {
        buffer.writeln(
          "      if (${param.fieldName} != null) '${param.name}': ${param.fieldName},",
        );
      }
    }

    buffer.write('    }');
    return buffer.toString();
  }

  static String _generateArguments(
    RouteConfigModel route,
    List<String> argumentTypes,
    List<String> argumentFieldNames,
  ) {
    // If has argument types from annotation, generate Record
    if (argumentTypes.isNotEmpty) {
      if (argumentTypes.length == 1) {
        // Single argument: return directly
        return argumentFieldNames.first;
      } else {
        // Multiple arguments: return as Record tuple
        return '(${argumentFieldNames.join(', ')})';
      }
    }

    // Fall back to body params from constructor (excluding Key params)
    final nonKeyBodyParams = route.bodyParams.where((p) => !p.isKey).toList();
    if (nonKeyBodyParams.isEmpty) return 'null';

    final buffer = StringBuffer();
    buffer.writeln('{');
    for (final param in nonKeyBodyParams) {
      buffer.writeln("      '${param.name}': ${param.fieldName},");
    }
    buffer.write('    }');
    return buffer.toString();
  }
}

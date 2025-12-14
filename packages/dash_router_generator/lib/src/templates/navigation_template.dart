// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../models/route_config_model.dart';
import '../utils/string_utils.dart';

/// Template for generating type-safe navigation extensions.
///
/// Navigation extension names follow the path-based naming convention:
///
/// - `/app/user/:id` -> `AppUser$IdNavigation`
/// - `/app/user/id` -> `AppUserIdNavigation`
/// - `/app/settings` -> `AppSettingsNavigation`
///
/// Generated methods follow consistent naming patterns with route-specific names
/// to avoid conflicts with core `NavigationContextExtension`:
///
/// - `pushAppUser$Id()` - Push route onto stack
/// - `replaceWithAppUser$Id()` - Replace current route
/// - `popAndPushAppUser$Id()` - Pop and push
/// - `pushAppUser$IdAndRemoveUntil()` - Clear stack and push
///
/// Example generated code:
/// ```dart
/// extension AppUser$IdNavigation on BuildContext {
///   Future<T?> pushAppUser$Id<T>({required String id}) {
///     // ...
///   }
/// }
/// ```
class NavigationTemplate {
  /// Generate navigation extensions for all routes
  static String generate(List<RouteConfigModel> routes) {
    final buffer = StringBuffer();

    buffer.writeln(_generateHeader());
    buffer.writeln();

    for (final route in routes) {
      if (route.redirectTo != null) continue;
      buffer.writeln(_generateNavigationExtension(route));
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Generate navigation extensions without file header/imports.
  static String generateBody(List<RouteConfigModel> routes) {
    final buffer = StringBuffer();

    for (final route in routes) {
      if (route.redirectTo != null) continue;
      buffer.writeln(_generateNavigationExtension(route));
      buffer.writeln();
    }

    return buffer.toString();
  }

  static String _generateHeader() {
    return '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element, unnecessary_cast

import 'package:flutter/widgets.dart';
import 'package:dash_router/dash_router.dart';
''';
  }

  static String _generateNavigationExtension(RouteConfigModel route) {
    final buffer = StringBuffer();
    // Use path-based naming: /app/user/:id -> AppUser$Id
    final pascalName = StringUtils.pathToIdentifier(route.path);
    final extensionName = '${pascalName}Navigation';

    buffer.writeln(
        '/// Navigation extension for [${route.className}] at `${route.path}`.');
    buffer.writeln('///');
    buffer.writeln('/// Provides type-safe navigation methods:');
    buffer.writeln('/// - `push$pascalName()` - Push route onto stack');
    buffer.writeln('/// - `replaceWith$pascalName()` - Replace current route');
    buffer.writeln('/// - `popAndPush$pascalName()` - Pop and push');
    buffer.writeln(
        '/// - `push${pascalName}AndRemoveUntil()` - Push and remove until');
    buffer.writeln('extension $extensionName on BuildContext {');

    // Generate all navigation methods
    buffer.writeln(_generatePushMethod(route, pascalName));
    buffer.writeln();
    buffer.writeln(_generateReplaceMethod(route, pascalName));
    buffer.writeln();
    buffer.writeln(_generatePopAndPushMethod(route, pascalName));
    buffer.writeln();
    buffer.writeln(_generatePushAndRemoveUntilMethod(route, pascalName));

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate push method: context.pushAppUser$Id(...)
  static String _generatePushMethod(RouteConfigModel route, String pascalName) {
    final buffer = StringBuffer();
    final methodName = 'push$pascalName';

    buffer.writeln('  /// Push `${route.path}` onto navigation stack.');
    buffer.writeln('  ///');
    buffer.writeln('  /// Example:');
    buffer.writeln('  /// ```dart');
    buffer.writeln(
        '  /// context.$methodName(${_generateExampleParams(route)});');
    buffer.writeln('  /// ```');
    buffer.write('  Future<T?> $methodName<T>({');

    _writeParams(buffer, route);
    buffer.write('DashTransition? \$transition, ');
    buffer.writeln('}) {');

    _writeMethodBody(buffer, route, 'pushNamed');

    buffer.writeln('  }');

    return buffer.toString();
  }

  /// Generate replace method: context.replaceWithAppUser$Id(...)
  static String _generateReplaceMethod(
      RouteConfigModel route, String pascalName) {
    final buffer = StringBuffer();
    final methodName = 'replaceWith$pascalName';

    buffer.writeln('  /// Replace current route with `${route.path}`.');
    buffer.write('  Future<T?> $methodName<T, TO extends Object?>({');

    _writeParams(buffer, route);
    buffer.write('TO? result, DashTransition? \$transition, ');
    buffer.writeln('}) {');

    _writeMethodBody(buffer, route, 'pushReplacementNamed', hasResult: true);

    buffer.writeln('  }');

    return buffer.toString();
  }

  /// Generate popAndPush method: context.popAndPushAppUser$Id(...)
  static String _generatePopAndPushMethod(
      RouteConfigModel route, String pascalName) {
    final buffer = StringBuffer();
    final methodName = 'popAndPush$pascalName';

    buffer.writeln('  /// Pop current route and push `${route.path}`.');
    buffer.write('  Future<T?> $methodName<T, TO extends Object?>({');

    _writeParams(buffer, route);
    buffer.write('TO? result, DashTransition? \$transition, ');
    buffer.writeln('}) {');

    _writeMethodBody(buffer, route, 'popAndPushNamed', hasResult: true);

    buffer.writeln('  }');

    return buffer.toString();
  }

  /// Generate pushAndRemoveUntil method: context.pushAppUser$IdAndRemoveUntil(...)
  static String _generatePushAndRemoveUntilMethod(
      RouteConfigModel route, String pascalName) {
    final buffer = StringBuffer();
    final methodName = 'push${pascalName}AndRemoveUntil';

    buffer.writeln(
        '  /// Push `${route.path}` and remove routes until predicate returns true.');
    buffer.write('  Future<T?> $methodName<T>({');

    _writeParams(buffer, route);
    buffer.write(
        'required bool Function(Route<dynamic>) predicate, DashTransition? \$transition, ');
    buffer.writeln('}) {');

    _writeMethodBody(buffer, route, 'pushNamedAndRemoveUntil',
        hasPredicate: true);

    buffer.writeln('  }');

    return buffer.toString();
  }

  static void _writeParams(StringBuffer buffer, RouteConfigModel route) {
    // Required path params
    for (final param in route.pathParams) {
      if (param.isRequired) {
        buffer.write('required ${param.typeString} ${param.fieldName}, ');
      }
    }

    // Optional path params
    for (final param in route.pathParams) {
      if (!param.isRequired) {
        buffer.write('${param.typeString} ${param.fieldName}, ');
      }
    }

    // Query params
    for (final param in route.queryParams) {
      if (param.defaultValue != null) {
        buffer.write(
          '${param.nonNullableTypeString} ${param.fieldName} = ${param.defaultValue}, ',
        );
      } else {
        buffer.write('${param.typeString} ${param.fieldName}, ');
      }
    }

    // Body params
    for (final param in route.bodyParams) {
      if (param.isRequired) {
        buffer.write('required ${param.typeString} ${param.fieldName}, ');
      } else {
        buffer.write('${param.typeString} ${param.fieldName}, ');
      }
    }
  }

  static void _writeMethodBody(
    StringBuffer buffer,
    RouteConfigModel route,
    String method, {
    bool hasResult = false,
    bool hasPredicate = false,
  }) {
    buffer.writeln('    final path_ = ${_generatePathBuilder(route)};');

    if (route.hasQueryParams) {
      buffer.writeln('    final query_ = <String, dynamic>{');
      for (final param in route.queryParams) {
        if (param.defaultValue == null && param.isNullable) {
          buffer.writeln(
            "      if (${param.fieldName} != null) '${param.name}': ${param.fieldName}.toString(),",
          );
        } else {
          buffer.writeln(
            "      '${param.name}': ${param.fieldName}.toString(),",
          );
        }
      }
      buffer.writeln('    };');
    }

    if (route.hasBodyParams) {
      buffer.writeln('    final body_ = <String, dynamic>{');
      for (final param in route.bodyParams) {
        buffer.writeln("      '${param.name}': ${param.fieldName},");
      }
      buffer.writeln('    };');
    }

    buffer.writeln('    final router = DashRouter.of(this);');

    if (hasPredicate) {
      buffer.writeln('    return router.$method<T>(');
      buffer.writeln('      path_,');
      buffer.writeln('      predicate,');
    } else if (hasResult) {
      buffer.writeln('    return router.$method<T, TO>(');
      buffer.writeln('      path_,');
    } else {
      buffer.writeln('    return router.$method<T>(');
      buffer.writeln('      path_,');
    }

    if (route.hasQueryParams) {
      buffer.writeln('      query: query_,');
    }
    if (route.hasBodyParams) {
      buffer.writeln('      body: body_,');
    }
    if (hasResult) {
      buffer.writeln('      result: result,');
    }
    buffer.writeln('      transition: \$transition,');
    buffer.writeln('    );');
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

  static String _generateExampleParams(RouteConfigModel route) {
    final params = <String>[];
    for (final param in route.pathParams) {
      if (param.isRequired) {
        params.add("${param.fieldName}: '...'");
      }
    }
    return params.join(', ');
  }
}

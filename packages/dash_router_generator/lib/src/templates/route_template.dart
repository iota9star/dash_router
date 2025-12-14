import 'package:analyzer/dart/element/type.dart';

import '../models/route_config_model.dart';
import '../utils/string_utils.dart';
import '../utils/type_resolver.dart';

/// Template for generating the main routes file
class RouteTemplate {
  /// Generate the complete routes file
  static String generate(List<RouteConfigModel> routes) {
    final buffer = StringBuffer();

    buffer.writeln(_generateHeader());
    buffer.writeln(_generateImports(routes));
    buffer.writeln();
    buffer.writeln(_generateRoutesClass(routes));
    buffer.writeln();
    buffer.writeln(_generateRouteList(routes));
    buffer.writeln();
    buffer.writeln(_generateRedirectEntries(routes));

    return buffer.toString();
  }

  static String _generateHeader() {
    return '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element, unnecessary_cast, unused_local_variable

import 'package:flutter/widgets.dart';
import 'package:dash_router/dash_router.dart';
''';
  }

  static String _generateImports(List<RouteConfigModel> routes) {
    final imports = <String>{};

    for (final route in routes) {
      if (route.redirectTo != null) continue;
      imports.add(route.importPath);

      for (final param in route.allParams) {
        final type = param.type;
        if (TypeResolver.needsImport(type)) {
          final uri = TypeResolver.getImportUri(type);
          if (uri != null && !uri.startsWith('package:flutter/src/')) {
            imports.add(uri);
          }
        }

        if (type is ParameterizedType) {
          for (final arg in type.typeArguments) {
            if (TypeResolver.needsImport(arg)) {
              final uri = TypeResolver.getImportUri(arg);
              if (uri != null && !uri.startsWith('package:flutter/src/')) {
                imports.add(uri);
              }
            }
          }
        }
      }

      // Add imports for guards
      for (final imp in route.guardImports) {
        if (!imp.startsWith('package:flutter/src/')) {
          imports.add(imp);
        }
      }

      // Add imports for middleware
      for (final imp in route.middlewareImports) {
        if (!imp.startsWith('package:flutter/src/')) {
          imports.add(imp);
        }
      }

      // Add imports for custom transitions
      for (final transitionImport in route.transitionImports) {
        if (!transitionImport.startsWith('package:flutter/src/')) {
          imports.add(transitionImport);
        }
      }

      // Add imports for argument types from annotation
      final argumentImports =
          (route.metadata['argumentImports'] as List?)?.cast<String>() ?? [];
      for (final imp in argumentImports) {
        if (!imp.startsWith('package:flutter/src/')) {
          imports.add(imp);
        }
      }
    }

    return imports.map((i) => "import '$i';").join('\n');
  }

  /// Generate unique route field name from path.
  ///
  /// Rules:
  /// - `/app/settings` -> `appSettings`
  /// - `/app/user/:id` -> `appUser$Id` (dynamic param with $ prefix)
  /// - `/app/user/:id/:section` -> `appUser$Id$Section` (multiple dynamic params)
  /// - `/app/user/id` -> `appUserId` (static path)
  /// - `/` -> `root`
  ///
  /// Dynamic parameters use `$` prefix to distinguish from static segments.
  static String _generateRouteName(String path, Set<String> existingNames) {
    return StringUtils.generateRouteFieldName(path, existingNames);
  }

  static String _generateRoutesClass(List<RouteConfigModel> routes) {
    final buffer = StringBuffer();
    final usedNames = <String>{};

    // Generate all route entries with unique names in a single pass
    final routeEntries = <_RouteEntryInfo>[];
    for (final route in routes) {
      final name = _generateRouteName(route.path, usedNames);
      usedNames.add(name);
      routeEntries.add(_RouteEntryInfo(
        route: route,
        fieldName: name,
      ));
    }

    // Sort: static routes first (for matching priority), then dynamic
    routeEntries.sort((a, b) {
      final aHasDynamic = a.route.path.contains(':');
      final bHasDynamic = b.route.path.contains(':');
      if (aHasDynamic != bHasDynamic) {
        return aHasDynamic ? 1 : -1; // Static first
      }
      return a.route.path.compareTo(b.route.path);
    });

    buffer.writeln('/// Generated routes with static priority over dynamic.');
    buffer.writeln('///');
    buffer.writeln('/// Usage:');
    buffer.writeln('/// ```dart');
    buffer.writeln('/// // Access route entry');
    buffer.writeln("/// Routes.appSettings.pattern // '/app/settings'");
    buffer.writeln("/// Routes.appUserId.pattern   // '/app/user/:id'");
    buffer.writeln('/// ```');
    buffer.writeln('abstract final class Routes {');

    for (final entry in routeEntries) {
      final route = entry.route;
      final fieldName = entry.fieldName;

      if (route.redirectTo != null) {
        // Redirect entry
        buffer.writeln("  /// Redirect: ${route.path} → ${route.redirectTo}");
        buffer.writeln('  static const ${fieldName}Redirect = RedirectEntry(');
        buffer.writeln("    from: '${route.path}',");
        buffer.writeln("    to: '${route.redirectTo}',");
        if (route.redirectPermanent) {
          buffer.writeln('    permanent: true,');
        }
        buffer.writeln('  );');
        buffer.writeln();
      } else {
        // Route entry
        buffer.writeln("  /// Route: ${route.path} → ${route.className}");
        buffer.writeln(
            '  static final $fieldName = ${_generateRouteEntry(route)};');
        buffer.writeln();
      }
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  static String _generateRouteList(List<RouteConfigModel> routes) {
    final buffer = StringBuffer();
    final usedNames = <String>{};

    // Collect route entries with names (single pass)
    final routeEntries = <_RouteEntryInfo>[];
    for (final route in routes) {
      if (route.redirectTo != null) continue;
      final name = _generateRouteName(route.path, usedNames);
      usedNames.add(name);
      routeEntries.add(_RouteEntryInfo(route: route, fieldName: name));
    }

    // Sort for matching priority: static first, then by path
    routeEntries.sort((a, b) {
      final aHasDynamic = a.route.path.contains(':');
      final bHasDynamic = b.route.path.contains(':');
      if (aHasDynamic != bHasDynamic) {
        return aHasDynamic ? 1 : -1;
      }
      return a.route.path.compareTo(b.route.path);
    });

    buffer.writeln('/// Generated route entries for DashRouter.');
    buffer.writeln('///');
    buffer.writeln(
        '/// Routes are ordered with static paths before dynamic paths,');
    buffer.writeln(
        '/// ensuring `/app/user/admin` matches before `/app/user/:id`.');
    buffer.writeln('final List<RouteEntry> generatedRoutes = [');

    for (final entry in routeEntries) {
      buffer.writeln('  Routes.${entry.fieldName},');
    }

    buffer.writeln('];');

    return buffer.toString();
  }

  static String _generateRouteEntry(RouteConfigModel route) {
    final buffer = StringBuffer();

    buffer.writeln('RouteEntry(');
    buffer.writeln("    pattern: '${route.path}',");
    buffer.writeln("    name: '${route.routeName}',");
    buffer.writeln(
      '    builder: (context, data) => ${_generateBuilder(route)},',
    );

    if (route.isShell) {
      buffer.writeln(
        '    shellBuilder: (context, data, child) => ${_generateShellBuilder(route)},',
      );
    }

    if (route.isInitial) {
      buffer.writeln('    isInitial: true,');
    }

    if (route.parent != null) {
      buffer.writeln("    parent: '${route.parent}',");
    }

    if (route.metadata.isNotEmpty) {
      buffer.writeln(
          '    metadata: ${_generateMetadataLiteral(route.metadata)},');
    }

    if (route.guardsCode != null) {
      buffer.writeln('    guards: ${route.guardsCode},');
    }

    if (route.middlewareCode != null) {
      buffer.writeln('    middleware: ${route.middlewareCode},');
    }

    if (route.transitionCode != null) {
      buffer.writeln('    transition: const ${route.transitionCode},');
    }

    if (route.keepAlive) {
      buffer.writeln('    keepAlive: true,');
    }

    if (route.fullscreenDialog) {
      buffer.writeln('    fullscreenDialog: true,');
    }

    if (!route.maintainState) {
      buffer.writeln('    maintainState: false,');
    }

    buffer.write('  )');

    return buffer.toString();
  }

  static String _generateRedirectEntries(List<RouteConfigModel> routes) {
    final buffer = StringBuffer();
    final usedNames = <String>{};

    // Collect redirect names
    for (final route in routes) {
      if (route.redirectTo != null) {
        final name = _generateRouteName(route.path, usedNames);
        usedNames.add(name);
      }
    }

    buffer.writeln('/// Generated redirect entries for DashRouter');
    buffer.writeln('final List<RedirectEntry> generatedRedirects = [');

    usedNames.clear();
    for (final route in routes) {
      if (route.redirectTo == null) continue;
      final name = _generateRouteName(route.path, usedNames);
      usedNames.add(name);
      buffer.writeln('  Routes.${name}Redirect,');
    }

    buffer.writeln('];');

    return buffer.toString();
  }

  static String _generateBuilder(RouteConfigModel route) {
    final buffer = StringBuffer();
    buffer.writeln('(() {');

    // Filter out key params - they're handled specially
    final pathParams = route.pathParams.where((p) => !p.isKey).toList();
    final queryParams = route.queryParams.where((p) => !p.isKey).toList();
    final bodyParams = route.bodyParams.where((p) => !p.isKey).toList();
    final keyParams = route.allParams.where((p) => p.isKey).toList();

    // Need params resolver if we have any params (including key params)
    final needsParamsResolver = pathParams.isNotEmpty ||
        queryParams.isNotEmpty ||
        bodyParams.isNotEmpty ||
        keyParams.isNotEmpty;
    if (needsParamsResolver) {
      buffer.writeln('      final params = TypedParamsResolver(data.params);');
    }
    buffer.write('      return ${route.className}(');

    // Shell routes are wrappers; allow direct navigation by providing an empty
    // child.
    final params = <String>[];
    if (route.isShell) {
      params.add('child: const SizedBox.shrink()');
    }

    // Add key parameter if present
    for (final param in keyParams) {
      params.add(
          "${param.fieldName}: params.body.get<${param.typeString}>('${param.name}')");
    }

    for (final param in pathParams) {
      if (route.isShell && param.fieldName == 'child') continue;
      if (param.isRequired) {
        params.add(
          "${param.fieldName}: params.path.get<${param.nonNullableTypeString}>('${param.name}')",
        );
      } else {
        params.add(
          "${param.fieldName}: params.path.get<${param.typeString}>('${param.name}')",
        );
      }
    }

    for (final param in queryParams) {
      if (route.isShell && param.fieldName == 'child') continue;
      if (param.isRequired) {
        params.add(
          "${param.fieldName}: params.query.get<${param.nonNullableTypeString}>('${param.name}')",
        );
      } else if (param.defaultValue != null) {
        params.add(
          "${param.fieldName}: params.query.get<${param.nonNullableTypeString}>('${param.name}', defaultValue: ${param.defaultValue})",
        );
      } else {
        params.add(
          "${param.fieldName}: params.query.get<${param.typeString}>('${param.name}')",
        );
      }
    }

    for (final param in bodyParams) {
      if (route.isShell && param.fieldName == 'child') continue;
      if (param.isRequired) {
        params.add(
          "${param.fieldName}: params.body.get<${param.nonNullableTypeString}>('${param.name}')!",
        );
      } else {
        params.add(
          "${param.fieldName}: params.body.get<${param.typeString}>('${param.name}')",
        );
      }
    }

    buffer.write(params.join(', '));
    buffer.writeln(');');
    buffer.writeln('    })()');

    return buffer.toString();
  }

  static String _generateShellBuilder(RouteConfigModel route) {
    final buffer = StringBuffer();
    buffer.writeln('(() {');

    // Filter out key params
    final pathParams = route.pathParams.where((p) => !p.isKey).toList();
    final queryParams = route.queryParams.where((p) => !p.isKey).toList();
    final bodyParams = route.bodyParams.where((p) => !p.isKey).toList();
    final keyParams = route.allParams.where((p) => p.isKey).toList();

    // Need params resolver if we have any params (including key params)
    final needsParamsResolver = pathParams.isNotEmpty ||
        queryParams.isNotEmpty ||
        bodyParams.isNotEmpty ||
        keyParams.isNotEmpty;
    if (needsParamsResolver) {
      buffer.writeln('      final params = TypedParamsResolver(data.params);');
    }

    buffer.write('      return ${route.className}(');

    final args = <String>['child: child'];

    // Add key parameter if present
    for (final param in keyParams) {
      args.add(
          "${param.fieldName}: params.body.get<${param.typeString}>('${param.name}')");
    }

    for (final param in pathParams) {
      if (route.isShell && param.fieldName == 'child') continue;
      if (param.isRequired) {
        args.add(
          "${param.fieldName}: params.path.get<${param.nonNullableTypeString}>('${param.name}')",
        );
      } else {
        args.add(
          "${param.fieldName}: params.path.get<${param.typeString}>('${param.name}')",
        );
      }
    }

    for (final param in queryParams) {
      if (route.isShell && param.fieldName == 'child') continue;
      if (param.isRequired) {
        args.add(
          "${param.fieldName}: params.query.get<${param.nonNullableTypeString}>('${param.name}')",
        );
      } else if (param.defaultValue != null) {
        args.add(
          "${param.fieldName}: params.query.get<${param.nonNullableTypeString}>('${param.name}', defaultValue: ${param.defaultValue})",
        );
      } else {
        args.add(
          "${param.fieldName}: params.query.get<${param.typeString}>('${param.name}')",
        );
      }
    }

    for (final param in bodyParams) {
      if (route.isShell && param.fieldName == 'child') continue;
      if (param.isRequired) {
        args.add(
          "${param.fieldName}: params.body.get<${param.nonNullableTypeString}>('${param.name}')!",
        );
      } else {
        args.add(
          "${param.fieldName}: params.body.get<${param.typeString}>('${param.name}')",
        );
      }
    }

    buffer.write(args.join(', '));
    buffer.writeln(');');
    buffer.writeln('    })()');

    return buffer.toString();
  }

  static String _generateMetadataLiteral(Map<String, dynamic> metadata) {
    final entries = <String>[];
    for (final entry in metadata.entries) {
      final key = entry.key;
      final value = entry.value;
      final literal = _literalForValue(value);
      if (literal == null) continue;
      entries.add("'$key': $literal");
    }
    if (entries.isEmpty) return 'const <String, dynamic>{}';
    final joined = entries.join(', ');
    return 'const <String, dynamic>{$joined}';
  }

  static String? _literalForValue(dynamic value) {
    if (value == null) return 'null';
    if (value is bool) return value ? 'true' : 'false';
    if (value is int || value is double) return value.toString();
    if (value is String) {
      final escaped = value.replaceAll('\\', '\\\\').replaceAll("'", "\\'");
      return "'$escaped'";
    }
    return null;
  }
}

/// Internal helper for route entry generation
class _RouteEntryInfo {
  final RouteConfigModel route;
  final String fieldName;

  _RouteEntryInfo({required this.route, required this.fieldName});
}

// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:path/path.dart' as p;

import '../models/route_config_model.dart';
import '../templates/navigation_template.dart';
import '../templates/route_template.dart';
import '../templates/typed_route_template.dart';
import '../utils/code_formatter.dart';
import '../utils/string_utils.dart';
import '../utils/type_resolver.dart';
import '../visitors/route_visitor.dart';

class DashRouterCliCodegenOptions {
  final String routesOutput;
  final String routeInfoOutputDir;

  final bool generateNavigation;
  final bool generateTypedRoutes;
  final bool generateRouteInfo;
  final bool generateTypedExtensions;

  const DashRouterCliCodegenOptions({
    required this.routesOutput,
    required this.routeInfoOutputDir,
    this.generateNavigation = true,
    this.generateTypedRoutes = true,
    this.generateRouteInfo = true,
    this.generateTypedExtensions = true,
  });
}

class DashRouterCliCodegenResult {
  final List<RouteConfigModel> routes;
  final List<String> writtenFiles;

  const DashRouterCliCodegenResult({
    required this.routes,
    required this.writtenFiles,
  });
}

/// CLI code generator that writes directory-based outputs (no build_runner).
class DashRouterCliCodegen {
  DashRouterCliCodegen._();

  static Future<DashRouterCliCodegenResult> generate({
    required String packageRoot,
    required List<String> inputFiles,
    required DashRouterCliCodegenOptions options,
    bool dryRun = false,
    bool format = true,
  }) async {
    final absRoot = p.normalize(p.absolute(packageRoot));

    final included = <String>[p.join(absRoot, 'lib')];
    final collection = AnalysisContextCollection(includedPaths: included);

    final visitor = RouteVisitor();
    final routes = <RouteConfigModel>[];

    for (final rel in inputFiles) {
      final abs = p.normalize(p.absolute(absRoot, rel));
      if (!abs.startsWith(absRoot)) continue;
      if (!p.isWithin(p.join(absRoot, 'lib'), abs)) continue;
      if (!File(abs).existsSync()) continue;

      final context = collection.contextFor(abs);
      final result = await context.currentSession.getResolvedUnit(abs);
      if (result is! ResolvedUnitResult) continue;

      final library = result.libraryElement;
      for (final element in library.classes) {
        final route = visitor.visitClass(element);
        if (route != null) {
          routes.add(route);
        }
      }
    }

    if (routes.isEmpty) {
      return const DashRouterCliCodegenResult(routes: [], writtenFiles: []);
    }

    final written = <String>[];

    // 1) routes.dart (global)
    var routesContent = StringBuffer();
    routesContent.writeln(
      RouteTemplate.generate(routes),
    );
    routesContent.writeln();

    if (options.generateTypedRoutes) {
      routesContent.writeln(TypedRouteTemplate.generateBody(routes));
      routesContent.writeln();
    }

    if (options.generateNavigation) {
      routesContent.writeln(NavigationTemplate.generateBody(routes));
      routesContent.writeln();
    }

    var routesOut = p.normalize(p.absolute(absRoot, options.routesOutput));
    if (format) {
      routesContent =
          StringBuffer(CodeFormatter.format(routesContent.toString()));
    }
    if (!dryRun) {
      await File(routesOut).parent.create(recursive: true);
      await File(routesOut).writeAsString(routesContent.toString());
    }
    written.add(p.relative(routesOut, from: absRoot));

    if (options.generateRouteInfo) {
      final routeInfoDir = p.normalize(
        p.absolute(absRoot, options.routeInfoOutputDir),
      );

      // Delete existing route_info directory before regenerating
      final routeInfoDirObj = Directory(routeInfoDir);
      if (!dryRun && await routeInfoDirObj.exists()) {
        await routeInfoDirObj.delete(recursive: true);
      }

      for (final route in routes) {
        if (route.redirectTo != null) continue;

        final fileName = _generateRouteFileName(route);
        final outPath = p.join(routeInfoDir, fileName);

        var content = _generatePerRouteInfoFile(route);
        if (format) {
          content = CodeFormatter.format(content);
        }

        if (!dryRun) {
          await File(outPath).parent.create(recursive: true);
          await File(outPath).writeAsString(content);
        }

        written.add(p.relative(outPath, from: absRoot));
      }
    }

    return DashRouterCliCodegenResult(routes: routes, writtenFiles: written);
  }

  /// Generates per-route info file with path-based naming convention.
  ///
  /// Naming follows the pattern:
  /// - `/app/user/:id` -> Extension: `AppUser$IdRouteInfoX`, Check: `isAppUser$IdRoute`
  /// - `/app/settings` -> Extension: `AppSettingsRouteInfoX`, Check: `isAppSettingsRoute`
  static String _generatePerRouteInfoFile(RouteConfigModel route) {
    final className = route.className;
    // Use path-based naming for extensions to avoid conflicts
    final pathBasedName = StringUtils.pathToIdentifier(route.path);

    // Check for arguments (Record type body)
    final argumentTypes =
        route.metadata['argumentTypes'] as List<String>? ?? [];
    final argumentImports =
        (route.metadata['argumentImports'] as List?)?.cast<String>() ?? [];
    final hasArgumentTypes = argumentTypes.isNotEmpty;

    // Determine body type for arguments Record
    String? bodyType;
    if (hasArgumentTypes) {
      if (argumentTypes.length == 1) {
        bodyType = argumentTypes.first;
      } else {
        bodyType = '(${argumentTypes.join(', ')})';
      }
    }

    final imports = <String>{
      'package:flutter/widgets.dart',
      'package:dash_router/dash_router.dart',
    };

    // Add imports for argument types
    for (final imp in argumentImports) {
      if (!imp.startsWith('package:flutter/src/')) {
        imports.add(imp);
      }
    }

    // Collect imports for any non-core parameter types.
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

    final buffer = StringBuffer();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// Route: ${route.path} -> $className');
    buffer.writeln(
      '// ignore_for_file: type=lint, unused_import, unused_element, unused_field',
    );
    buffer.writeln();

    for (final imp in (imports.toList()..sort())) {
      buffer.writeln("import '$imp';");
    }
    buffer.writeln();

    // ============================================================
    // Generate extensions on TypedPathParams for this route
    // Path-based naming: /app/user/:id -> AppUser$IdPathParamsX
    // ============================================================
    if (route.pathParams.isNotEmpty) {
      buffer.writeln('/// Typed path parameters for $className');
      buffer.writeln('///');
      buffer.writeln('/// Usage: `route.path.id`');
      buffer.writeln(
          'extension ${pathBasedName}PathParamsX on TypedPathParams {');
      for (final p0 in route.pathParams) {
        buffer.writeln('  /// Path parameter: ${p0.name}');
        buffer.writeln(
          '  ${p0.nonNullableTypeString} get ${p0.fieldName} => get<${p0.nonNullableTypeString}>(\'${p0.name}\');',
        );
      }
      buffer.writeln('}');
      buffer.writeln();
    }

    // ============================================================
    // Generate extensions on TypedQueryParams for this route
    // Path-based naming: /app/user/:id -> AppUser$IdQueryParamsX
    // ============================================================
    if (route.queryParams.isNotEmpty) {
      buffer.writeln('/// Typed query parameters for $className');
      buffer.writeln('///');
      buffer.writeln('/// Usage: `route.query.tab`');
      buffer.writeln(
          'extension ${pathBasedName}QueryParamsX on TypedQueryParams {');
      for (final q0 in route.queryParams) {
        buffer.writeln('  /// Query parameter: ${q0.name}');
        if (q0.defaultValue != null) {
          buffer.writeln(
            '  ${q0.nonNullableTypeString} get ${q0.fieldName} => get<${q0.nonNullableTypeString}>(\'${q0.name}\', defaultValue: ${q0.defaultValue});',
          );
        } else {
          buffer.writeln(
            '  ${q0.typeString} get ${q0.fieldName} => get<${q0.typeString}>(\'${q0.name}\');',
          );
        }
      }
      buffer.writeln('}');
      buffer.writeln();
    }

    // ============================================================
    // Generate typed body getter on ScopedRouteInfo for this route
    // Path-based naming: /app/user/:id -> AppUser$IdRouteInfoX, isAppUser$IdRoute
    // ============================================================
    if (hasArgumentTypes) {
      buffer.writeln('/// Typed body accessor for $className');
      buffer.writeln('///');
      if (argumentTypes.length == 1) {
        buffer.writeln(
            '/// Usage: `final data = route.arguments; // Typed as $bodyType`');
      } else {
        buffer.writeln(
            '/// Usage: `final (a, b) = route.arguments; // Typed as $bodyType`');
      }
      buffer
          .writeln('/// Note: Generated extension provides type-safe access.');
      buffer
          .writeln('extension ${pathBasedName}RouteInfoX on ScopedRouteInfo {');
      buffer.writeln('  /// Check if current route is $className');
      buffer.writeln(
          '  bool get is${pathBasedName}Route => pattern == \'${route.path}\';');
      buffer.writeln();
      buffer.writeln('  /// Typed body for $className');
      buffer.writeln('  ///');
      if (argumentTypes.length == 1) {
        buffer.writeln('  /// Returns body as `$bodyType`.');
      } else {
        buffer.writeln('  /// Returns body as Record: `$bodyType`.');
      }
      buffer
          .writeln('  $bodyType get arguments => body.arguments as $bodyType;');
      buffer.writeln('}');
    } else {
      // Still generate route check even without body
      buffer.writeln('/// Route info extension for $className');
      buffer
          .writeln('extension ${pathBasedName}RouteInfoX on ScopedRouteInfo {');
      buffer.writeln('  /// Check if current route is $className');
      buffer.writeln(
          '  bool get is${pathBasedName}Route => pattern == \'${route.path}\';');
      buffer.writeln('}');
    }

    return buffer.toString();
  }

  /// Generate a unique file name for route_info file based on path pattern.
  ///
  /// Rules:
  /// - `/app/user/:id` → `app_user_$id.route.dart`
  /// - `/app/user/:id/:section` → `app_user_$id_$section.route.dart`
  /// - `/app/user/id` → `app_user_id.route.dart`
  /// - `/app/settings` → `app_settings.route.dart`
  static String _generateRouteFileName(RouteConfigModel route) {
    final path = route.path;

    if (path == '/') {
      return 'root.route.dart';
    }

    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) {
      return 'root.route.dart';
    }

    final nameParts = <String>[];
    for (final segment in segments) {
      // if (segment.startsWith(':')) {
      //   // Dynamic parameter: `:id` → `$id`
      //   final paramName = segment.substring(1);
      //   nameParts.add('\$${StringUtils.toSnakeCase(paramName)}');
      // } else {
      // Static segment: `UserSettings` → `user_settings`
      nameParts.add(StringUtils.toSnakeCase(segment));
      // }
    }

    return '${nameParts.join('_')}.route.dart';
  }
}

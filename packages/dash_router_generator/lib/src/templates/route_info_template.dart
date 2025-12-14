import '../models/route_info_model.dart';

/// Template for generating route info classes
class RouteInfoTemplate {
  /// Generate a route info file for a single route
  static String generate(RouteInfoModel model) {
    final buffer = StringBuffer();

    buffer.writeln(_generateHeader());
    buffer.writeln(_generateImports(model));
    buffer.writeln();
    buffer.writeln(_generateRouteInfoClass(model));

    if (model.hasParams) {
      buffer.writeln();
      buffer.writeln(_generateParamsClass(model));

      if (model.hasPathParams) {
        buffer.writeln();
        buffer.writeln(_generatePathParamsClass(model));
      }

      if (model.hasQueryParams) {
        buffer.writeln();
        buffer.writeln(_generateQueryParamsClass(model));
      }

      if (model.hasBodyParams) {
        buffer.writeln();
        buffer.writeln(_generateBodyParamsClass(model));
      }
    }

    return buffer.toString();
  }

  static String _generateHeader() {
    return '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element, unnecessary_cast
''';
  }

  static String _generateImports(RouteInfoModel model) {
    final imports = model.imports.toList()..sort();
    return imports.map((i) => "import '$i';").join('\n');
  }

  static String _generateRouteInfoClass(RouteInfoModel model) {
    final buffer = StringBuffer();

    buffer.writeln('/// Type-safe route info for ${model.pageClassName}');
    buffer.writeln('class ${model.className} implements TypedRouteInfo {');

    // Private constructor
    buffer.writeln('  const ${model.className}._({');
    buffer.writeln('    required this.routeData,');
    buffer.writeln('  });');
    buffer.writeln();

    // Factory constructor
    buffer.writeln('  /// Create route info from BuildContext');
    buffer.writeln('  factory ${model.className}.of(BuildContext context) {');
    buffer.writeln(
      '    final routeData = RouteInfoCache.getRouteData(context);',
    );
    buffer.writeln('    return ${model.className}._(routeData: routeData);');
    buffer.writeln('  }');
    buffer.writeln();

    // Route data field
    buffer.writeln('  /// The underlying route data');
    buffer.writeln('  final RouteData routeData;');
    buffer.writeln();

    // Path constant
    buffer.writeln('  /// The route path pattern');
    buffer.writeln("  static const String pathPattern = '${model.path}';");
    buffer.writeln();

    // Name constant
    buffer.writeln('  /// The route name');
    buffer.writeln(
      "  static const String routeNameConst = '${model.routeName}';",
    );
    buffer.writeln();

    // Implement interface properties
    buffer.writeln('  @override');
    buffer.writeln('  String get path => routeData.path;');
    buffer.writeln();

    buffer.writeln('  @override');
    buffer.writeln('  String get name => routeData.name;');
    buffer.writeln();

    buffer.writeln('  @override');
    buffer.writeln("  String get fullPath => routeData.fullPath ?? '';");
    buffer.writeln();

    buffer.writeln('  @override');
    buffer.writeln('  RouteSettings? get settings => routeData.settings;');
    buffer.writeln();

    buffer.writeln('  @override');
    buffer.writeln(
      '  NavigationHistory? get history => DashRouter.instance?.history;',
    );
    buffer.writeln();

    buffer.writeln('  @override');
    buffer.writeln('  String? get previousRoute => history?.previous?.path;');
    buffer.writeln();

    buffer.writeln('  @override');
    buffer.writeln('  String? get nextRoute => null;');
    buffer.writeln();

    // Params accessor
    if (model.hasParams) {
      buffer.writeln('  @override');
      buffer.writeln(
        '  ${model.paramsClassName} get params => ${model.paramsClassName}._();',
      );
    } else {
      buffer.writeln('  @override');
      buffer.writeln(
        '  EmptyRouteParams get params => const EmptyRouteParams();',
      );
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  static String _generateParamsClass(RouteInfoModel model) {
    final buffer = StringBuffer();

    buffer.writeln('/// Type-safe parameters for ${model.pageClassName}');
    buffer.writeln(
      'class ${model.paramsClassName} implements TypedRouteParams {',
    );

    buffer.writeln('  const ${model.paramsClassName}._();');
    buffer.writeln();

    // Path params accessor
    if (model.hasPathParams) {
      buffer.writeln('  @override');
      buffer.writeln(
        '  ${model.pathParamsClassName} get path => const ${model.pathParamsClassName}._();',
      );
    } else {
      buffer.writeln('  @override');
      buffer.writeln('  EmptyPathParams get path => const EmptyPathParams();');
    }
    buffer.writeln();

    // Query params accessor
    if (model.hasQueryParams) {
      buffer.writeln('  @override');
      buffer.writeln(
        '  ${model.queryParamsClassName} get query => const ${model.queryParamsClassName}._();',
      );
    } else {
      buffer.writeln('  @override');
      buffer.writeln(
        '  EmptyQueryParams get query => const EmptyQueryParams();',
      );
    }
    buffer.writeln();

    // Body params accessor
    if (model.hasBodyParams) {
      buffer.writeln('  @override');
      buffer.writeln(
        '  ${model.bodyParamsClassName} get body => const ${model.bodyParamsClassName}._();',
      );
    } else {
      buffer.writeln('  @override');
      buffer.writeln('  EmptyBodyParams get body => const EmptyBodyParams();');
    }
    buffer.writeln();

    // All params
    buffer.writeln('  @override');
    buffer.writeln(
      '  Map<String, dynamic> get all => TypedParamsResolver.getAllParams();',
    );

    buffer.writeln('}');

    return buffer.toString();
  }

  static String _generatePathParamsClass(RouteInfoModel model) {
    final buffer = StringBuffer();

    buffer.writeln('/// Type-safe path parameters for ${model.pageClassName}');
    buffer.writeln(
      'class ${model.pathParamsClassName} implements TypedPathParams {',
    );

    buffer.writeln('  const ${model.pathParamsClassName}._();');
    buffer.writeln();

    // Generic param method
    buffer.writeln('  @override');
    buffer.writeln('  T param<T>(String name) {');
    buffer.writeln('    switch (name) {');
    for (final param in model.pathParams) {
      buffer.writeln("      case '${param.name}':");
      buffer.writeln(
        "        return TypedParamsResolver.getPathParam<${param.nonNullableTypeString}>('${param.name}') as T;",
      );
    }
    buffer.writeln('      default:');
    buffer.writeln(
      "        throw ParamNotFoundException('Unknown path parameter: \$name');",
    );
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln();

    // Quick access getters
    for (final param in model.pathParams) {
      buffer.writeln('  /// Get ${param.name} parameter, O(1) access');
      buffer.writeln(
        "  ${param.typeString} get ${param.fieldName} => TypedParamsResolver.getPathParam<${param.nonNullableTypeString}>('${param.name}');",
      );
      buffer.writeln();
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  static String _generateQueryParamsClass(RouteInfoModel model) {
    final buffer = StringBuffer();

    buffer.writeln('/// Type-safe query parameters for ${model.pageClassName}');
    buffer.writeln(
      'class ${model.queryParamsClassName} implements TypedQueryParams {',
    );

    buffer.writeln('  const ${model.queryParamsClassName}._();');
    buffer.writeln();

    // Generic param method
    buffer.writeln('  @override');
    buffer.writeln('  T param<T>(String name, {T? defaultValue}) {');
    buffer.writeln('    switch (name) {');
    for (final param in model.queryParams) {
      buffer.writeln("      case '${param.name}':");
      if (param.defaultValue != null) {
        buffer.writeln(
          "        return (TypedParamsResolver.getQueryParam<${param.nonNullableTypeString}>('${param.name}') ?? ${param.defaultValue}) as T;",
        );
      } else {
        buffer.writeln(
          "        return (TypedParamsResolver.getQueryParam<${param.typeString}>('${param.name}') ?? defaultValue) as T;",
        );
      }
    }
    buffer.writeln('      default:');
    buffer.writeln(
      "        throw ParamNotFoundException('Unknown query parameter: \$name');",
    );
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln();

    // Quick access getters
    for (final param in model.queryParams) {
      buffer.writeln('  /// Get ${param.name} parameter, O(1) access');
      if (param.defaultValue != null) {
        buffer.writeln(
          "  ${param.nonNullableTypeString} get ${param.fieldName} => TypedParamsResolver.getQueryParam<${param.nonNullableTypeString}>('${param.name}') ?? ${param.defaultValue};",
        );
      } else {
        buffer.writeln(
          "  ${param.typeString} get ${param.fieldName} => TypedParamsResolver.getQueryParam<${param.typeString}>('${param.name}');",
        );
      }
      buffer.writeln();
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  static String _generateBodyParamsClass(RouteInfoModel model) {
    final buffer = StringBuffer();

    buffer.writeln('/// Type-safe body parameters for ${model.pageClassName}');
    buffer.writeln(
      'class ${model.bodyParamsClassName} implements TypedBodyParams {',
    );

    buffer.writeln('  const ${model.bodyParamsClassName}._();');
    buffer.writeln();

    // Generic param method
    buffer.writeln('  @override');
    buffer.writeln('  T? param<T>(String name) {');
    buffer.writeln('    switch (name) {');
    for (final param in model.bodyParams) {
      buffer.writeln("      case '${param.name}':");
      buffer.writeln(
        "        return TypedParamsResolver.getBodyParam<${param.nonNullableTypeString}>('${param.name}') as T?;",
      );
    }
    buffer.writeln('      default:');
    buffer.writeln('        return null;');
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln();

    // Quick access getters
    for (final param in model.bodyParams) {
      buffer.writeln('  /// Get ${param.name} parameter, O(1) access');
      buffer.writeln(
        "  ${param.typeString} get ${param.fieldName} => TypedParamsResolver.getBodyParam<${param.nonNullableTypeString}>('${param.name}');",
      );
      buffer.writeln();
    }

    buffer.writeln('}');

    return buffer.toString();
  }
}

/// Empty params classes for routes without parameters
class EmptyParamsTemplate {
  static String generate() {
    return '''
/// Empty route params for routes without parameters
class EmptyRouteParams implements TypedRouteParams {
  const EmptyRouteParams();

  @override
  EmptyPathParams get path => const EmptyPathParams();

  @override
  EmptyQueryParams get query => const EmptyQueryParams();

  @override
  EmptyBodyParams get body => const EmptyBodyParams();

  @override
  Map<String, dynamic> get all => const {};
}

/// Empty path params
class EmptyPathParams implements TypedPathParams {
  const EmptyPathParams();

  @override
  T param<T>(String name) {
    throw ParamNotFoundException('No path parameters available');
  }
}

/// Empty query params
class EmptyQueryParams implements TypedQueryParams {
  const EmptyQueryParams();

  @override
  T param<T>(String name, {T? defaultValue}) {
    return defaultValue as T;
  }
}

/// Empty body params
class EmptyBodyParams implements TypedBodyParams {
  const EmptyBodyParams();

  @override
  T? param<T>(String name) => null;
}
''';
  }
}

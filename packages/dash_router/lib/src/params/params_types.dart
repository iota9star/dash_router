/// Types for route parameters
library;

/// Represents a path parameter configuration
class PathParamConfig {
  /// Parameter name
  final String name;

  /// Dart type of the parameter
  final Type type;

  /// Whether the parameter is required
  final bool required;

  /// Position in the path segments
  final int position;

  const PathParamConfig({
    required this.name,
    required this.type,
    this.required = true,
    this.position = -1,
  });
}

/// Represents a query parameter configuration
class QueryParamConfig {
  /// Parameter name
  final String name;

  /// Dart type of the parameter
  final Type type;

  /// Default value
  final dynamic defaultValue;

  /// Whether to URL decode the value
  final bool decode;

  const QueryParamConfig({
    required this.name,
    required this.type,
    this.defaultValue,
    this.decode = true,
  });
}

/// Represents a body parameter configuration
class BodyParamConfig {
  /// Parameter name
  final String name;

  /// Dart type of the parameter
  final Type type;

  /// Whether the parameter is required
  final bool required;

  const BodyParamConfig({
    required this.name,
    required this.type,
    this.required = false,
  });
}

/// Container for all route parameters
class RouteParams {
  /// Path parameters extracted from URL
  final Map<String, String> pathParams;

  /// Query parameters from URL query string
  final Map<String, String> queryParams;

  /// Body/extra parameters passed during navigation
  final Map<String, dynamic> bodyParams;

  const RouteParams({
    this.pathParams = const {},
    this.queryParams = const {},
    this.bodyParams = const {},
  });

  /// Check if empty
  bool get isEmpty =>
      pathParams.isEmpty && queryParams.isEmpty && bodyParams.isEmpty;

  /// Check if not empty
  bool get isNotEmpty => !isEmpty;

  /// Get all params as a single map
  Map<String, dynamic> get all => {
        ...pathParams,
        ...queryParams,
        ...bodyParams,
      };

  /// Create a copy with modifications
  RouteParams copyWith({
    Map<String, String>? pathParams,
    Map<String, String>? queryParams,
    Map<String, dynamic>? bodyParams,
  }) {
    return RouteParams(
      pathParams: pathParams ?? this.pathParams,
      queryParams: queryParams ?? this.queryParams,
      bodyParams: bodyParams ?? this.bodyParams,
    );
  }

  @override
  String toString() =>
      'RouteParams(path: $pathParams, query: $queryParams, body: $bodyParams)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteParams &&
          _mapEquals(pathParams, other.pathParams) &&
          _mapEquals(queryParams, other.queryParams) &&
          _mapEquals(bodyParams, other.bodyParams);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(pathParams.entries),
        Object.hashAll(queryParams.entries),
        Object.hashAll(bodyParams.entries),
      );

  static bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

/// Abstract interface for typed params access
abstract class TypedPathParams {
  /// Get a path parameter by name with type inference
  T get<T>(String name);

  /// Check if a path parameter exists
  bool has(String name);
}

/// Abstract interface for typed query params access
abstract class TypedQueryParams {
  /// Get a query parameter by name with type inference and optional default
  T get<T>(String name, {T? defaultValue});

  /// Check if a query parameter exists
  bool has(String name);
}

/// Abstract interface for typed body params access
abstract class TypedBodyParams {
  /// Get a body parameter by name with type inference
  T? get<T>(String name);

  /// Check if a body parameter exists
  bool has(String name);

  /// Raw arguments passed to the route.
  ///
  /// This is the original value from `RouteSettings.arguments`.
  /// Use generated extensions for type-safe access:
  /// ```dart
  /// // Generated extension provides typed access:
  /// extension OrderRouteInfoX on ScopedRouteInfo {
  ///   (UserData, Product) get arguments => body.arguments as (UserData, Product);
  /// }
  /// ```
  Object? get arguments;
}

/// Combined typed params interface
abstract class TypedRouteParams {
  /// Access path parameters
  TypedPathParams get path;

  /// Access query parameters
  TypedQueryParams get query;

  /// Access body parameters
  TypedBodyParams get body;

  /// Get all parameters as a map
  Map<String, dynamic> get all;
}

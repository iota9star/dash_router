import 'package:flutter/widgets.dart';

import '../exceptions/params_exceptions.dart';
import 'params_decoder.dart';
import 'params_types.dart';

/// Type-safe parameter resolver with O(1) access complexity
///
/// This class provides fast, cached access to route parameters
/// extracted from the current route.
class TypedParamsResolver implements TypedRouteParams {
  /// The raw route parameters
  final RouteParams _params;

  /// Raw arguments passed to the route
  final Object? _arguments;

  /// Cached typed values for O(1) access
  final Map<String, dynamic> _cache = {};

  /// Path params accessor
  late final _TypedPathParamsImpl _pathParams;

  /// Query params accessor
  late final _TypedQueryParamsImpl _queryParams;

  /// Body params accessor
  late final _TypedBodyParamsImpl _bodyParams;

  TypedParamsResolver(this._params, [this._arguments]) {
    _pathParams = _TypedPathParamsImpl(_params.pathParams, _cache);
    _queryParams = _TypedQueryParamsImpl(_params.queryParams, _cache);
    _bodyParams = _TypedBodyParamsImpl(_params.bodyParams, _cache, _arguments);
  }

  /// Create resolver from route settings
  factory TypedParamsResolver.fromSettings(RouteSettings settings) {
    final arguments = settings.arguments;
    final name = settings.name ?? '/';

    // Parse path and query from the route name
    final uri = Uri.parse(name);
    final queryParams = uri.queryParameters;

    // Body params come from arguments
    final bodyParams = <String, dynamic>{};
    if (arguments is Map<String, dynamic>) {
      bodyParams.addAll(arguments);
    } else if (arguments != null) {
      bodyParams['_body'] = arguments;
    }

    return TypedParamsResolver(
      RouteParams(queryParams: queryParams, bodyParams: bodyParams),
      arguments,
    );
  }

  @override
  TypedPathParams get path => _pathParams;

  @override
  TypedQueryParams get query => _queryParams;

  @override
  TypedBodyParams get body => _bodyParams;

  @override
  Map<String, dynamic> get all => _params.all;

  /// Get raw params
  RouteParams get raw => _params;

  /// Update params with new values
  TypedParamsResolver withPathParams(Map<String, String> pathParams) {
    return TypedParamsResolver(_params.copyWith(pathParams: pathParams));
  }

  /// Clear the cache
  void clearCache() {
    _cache.clear();
  }
}

/// Implementation of TypedPathParams with O(1) cached access
class _TypedPathParamsImpl implements TypedPathParams {
  final Map<String, String> _params;
  final Map<String, dynamic> _cache;

  _TypedPathParamsImpl(this._params, this._cache);

  @override
  T get<T>(String name) {
    final cacheKey = 'path:$name:$T';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as T;
    }

    final value = _params[name];
    if (value == null) {
      throw MissingParamException(name, paramType: 'path');
    }

    final decoded = ParamDecoders.decode<T>(value);
    _cache[cacheKey] = decoded;
    return decoded;
  }

  @override
  bool has(String name) => _params.containsKey(name);

  /// Get raw string value
  String? getRaw(String name) => _params[name];

  /// Get all path params
  Map<String, String> get all => Map.unmodifiable(_params);
}

/// Implementation of TypedQueryParams with O(1) cached access
class _TypedQueryParamsImpl implements TypedQueryParams {
  final Map<String, String> _params;
  final Map<String, dynamic> _cache;

  _TypedQueryParamsImpl(this._params, this._cache);

  @override
  T get<T>(String name, {T? defaultValue}) {
    final cacheKey = 'query:$name:$T:${defaultValue.hashCode}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as T;
    }

    final value = _params[name];
    if (value == null) {
      if (defaultValue != null) {
        _cache[cacheKey] = defaultValue;
        return defaultValue;
      }
      // For nullable types, return null
      if (null is T) {
        _cache[cacheKey] = null;
        return null as T;
      }
      throw MissingParamException(name, paramType: 'query');
    }

    final decoded = ParamDecoders.decode<T>(value, defaultValue: defaultValue);
    _cache[cacheKey] = decoded;
    return decoded;
  }

  @override
  bool has(String name) => _params.containsKey(name);

  /// Get raw string value
  String? getRaw(String name) => _params[name];

  /// Get all query params
  Map<String, String> get all => Map.unmodifiable(_params);
}

/// Implementation of TypedBodyParams with O(1) cached access
class _TypedBodyParamsImpl implements TypedBodyParams {
  final Map<String, dynamic> _params;
  final Map<String, dynamic> _cache;
  final Object? _arguments;

  _TypedBodyParamsImpl(this._params, this._cache, [this._arguments]);

  @override
  Object? get arguments => _arguments;

  @override
  T? get<T>(String name) {
    final cacheKey = 'body:$name:$T';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as T?;
    }

    final value = _params[name];
    if (value == null) {
      _cache[cacheKey] = null;
      return null;
    }

    // Direct type match
    if (value is T) {
      _cache[cacheKey] = value;
      return value;
    }

    // Try string conversion
    if (value is String) {
      try {
        final decoded = ParamDecoders.decode<T>(value);
        _cache[cacheKey] = decoded;
        return decoded;
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  @override
  bool has(String name) => _params.containsKey(name);

  /// Get raw value
  dynamic getRaw(String name) => _params[name];

  /// Get all body params
  Map<String, dynamic> get all => Map.unmodifiable(_params);
}

/// Extension to get TypedParamsResolver from BuildContext
extension TypedParamsResolverExtension on BuildContext {
  /// Get the typed params resolver for the current route
  TypedParamsResolver get routeParams {
    final route = ModalRoute.of(this);
    if (route == null) {
      return TypedParamsResolver(const RouteParams());
    }
    return TypedParamsResolver.fromSettings(route.settings);
  }
}

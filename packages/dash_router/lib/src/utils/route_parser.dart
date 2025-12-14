/// Route parsing utilities
class RouteParser {
  RouteParser._();

  /// Parse path segments from a path string
  static List<String> parseSegments(String path) {
    final normalized = normalizePath(path);
    if (normalized.isEmpty || normalized == '/') {
      return [];
    }
    return normalized.split('/').where((s) => s.isNotEmpty).toList();
  }

  /// Normalize a path string
  static String normalizePath(String path) {
    // Remove trailing slashes (except for root)
    var normalized = path.trim();
    while (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    // Ensure leading slash
    if (!normalized.startsWith('/')) {
      normalized = '/$normalized';
    }
    return normalized;
  }

  /// Extract path parameters from a pattern
  /// Returns a map of parameter names to their positions
  static Map<String, int> extractPathParams(String pattern) {
    final segments = parseSegments(pattern);
    final params = <String, int>{};
    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      if (segment.startsWith(':')) {
        params[segment.substring(1)] = i;
      }
    }
    return params;
  }

  /// Check if a segment is a parameter
  static bool isPathParam(String segment) => segment.startsWith(':');

  /// Check if a segment is a wildcard
  static bool isWildcard(String segment) => segment == '*' || segment == '**';

  /// Parse query string into a map
  static Map<String, String> parseQueryString(String? queryString) {
    if (queryString == null || queryString.isEmpty) {
      return {};
    }
    final query =
        queryString.startsWith('?') ? queryString.substring(1) : queryString;
    return Uri.splitQueryString(query);
  }

  /// Build query string from a map
  static String buildQueryString(Map<String, dynamic> params) {
    if (params.isEmpty) return '';
    final pairs = params.entries.where((e) => e.value != null).map(
          (e) => '${Uri.encodeComponent(e.key)}='
              '${Uri.encodeComponent(e.value.toString())}',
        );
    return '?${pairs.join('&')}';
  }

  /// Split path and query from a full URL
  static ({String path, String? query}) splitPathAndQuery(String fullPath) {
    final queryIndex = fullPath.indexOf('?');
    if (queryIndex == -1) {
      return (path: fullPath, query: null);
    }
    return (
      path: fullPath.substring(0, queryIndex),
      query: fullPath.substring(queryIndex + 1),
    );
  }

  /// Join base path with sub path
  static String joinPaths(String base, String sub) {
    final normalizedBase = normalizePath(base);
    final normalizedSub = normalizePath(sub);
    if (normalizedSub == '/') {
      return normalizedBase;
    }
    if (normalizedBase == '/') {
      return normalizedSub;
    }
    return '$normalizedBase$normalizedSub';
  }

  /// Extract parameter name from a parameter segment
  static String extractParamName(String segment) {
    if (segment.startsWith(':')) {
      return segment.substring(1);
    }
    return segment;
  }

  /// Check if path contains path parameters
  static bool hasPathParams(String path) {
    return parseSegments(path).any(isPathParam);
  }

  /// Get parent path
  static String? getParentPath(String path) {
    final segments = parseSegments(path);
    if (segments.isEmpty) return null;
    if (segments.length == 1) return '/';
    return '/${segments.sublist(0, segments.length - 1).join('/')}';
  }
}

/// Route parsing utilities for the Dash Router library.
///
/// This class provides static methods for parsing, normalizing, and
/// manipulating URL paths and query parameters. It handles path segments,
/// parameter extraction, and query string operations.
///
/// ## Example
///
/// ```dart
/// // Normalize paths
/// final normalized = RouteParser.normalizePath('/user/profile/');
/// // Returns: '/user/profile'
///
/// // Extract path parameters
/// final params = RouteParser.extractPathParams('/user/:id/posts/:postId');
/// // Returns: {'id': 1, 'postId': 3}
///
/// // Parse query strings
/// final query = RouteParser.parseQueryString('?name=John&age=30');
/// // Returns: {'name': 'John', 'age': '30'}
///
/// // Build query strings
/// final queryString = RouteParser.buildQueryString({'name': 'John', 'age': 30});
/// // Returns: '?name=John&age=30'
/// ```
class RouteParser {
  RouteParser._();

  /// Parse path segments from a path string.
  ///
  /// Splits the path into individual segments, excluding empty segments.
  /// For example, '/user/123/profile' becomes ['user', '123', 'profile'].
  ///
  /// ## Example
  ///
  /// ```dart
  /// RouteParser.parseSegments('/user/123/profile');
  /// // Returns: ['user', '123', 'profile']
  ///
  /// RouteParser.parseSegments('/');
  /// // Returns: []
  ///
  /// RouteParser.parseSegments('//user//profile//');
  /// // Returns: ['user', 'profile']
  /// ```
  ///
  /// [path] The path string to parse.
  /// Returns a list of path segments.
  static List<String> parseSegments(String path) {
    final normalized = normalizePath(path);
    if (normalized.isEmpty || normalized == '/') {
      return [];
    }
    return normalized.split('/').where((s) => s.isNotEmpty).toList();
  }

  /// Normalize a path string.
  ///
  /// Ensures the path follows a consistent format:
  /// - Always starts with a single slash
  /// - Never ends with a trailing slash (except for root '/')
  /// - Removes duplicate slashes
  ///
  /// ## Example
  ///
  /// ```dart
  /// RouteParser.normalizePath('user/profile/');
  /// // Returns: '/user/profile'
  ///
  /// RouteParser.normalizePath('/user//profile/');
  /// // Returns: '/user/profile'
  ///
  /// RouteParser.normalizePath('/');
  /// // Returns: '/'
  ///
  /// RouteParser.normalizePath('');
  /// // Returns: '/'
  /// ```
  ///
  /// [path] The path string to normalize.
  /// Returns the normalized path.
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

  /// Extract path parameters from a pattern.
  ///
  /// Identifies parameter segments (those starting with ':') and returns
  /// a mapping of parameter names to their position in the path segments.
  ///
  /// ## Example
  ///
  /// ```dart
  /// RouteParser.extractPathParams('/user/:id/posts/:postId');
  /// // Returns: {'id': 1, 'postId': 3}
  ///
  /// RouteParser.extractPathParams('/files/:userId/*');
  /// // Returns: {'userId': 1}
  ///
  /// RouteParser.extractPathParams('/dashboard');
  /// // Returns: {}
  /// ```
  ///
  /// [pattern] The path pattern to extract parameters from.
  /// Returns a map of parameter names to their positions.
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

  /// Check if a segment is a parameter.
  ///
  /// A parameter segment starts with ':' and represents a dynamic part
  /// of the URL path that will be matched and extracted.
  ///
  /// ## Example
  ///
  /// ```dart
  /// RouteParser.isPathParam(':id');
  /// // Returns: true
  ///
  /// RouteParser.isPathParam('user');
  /// // Returns: false
  ///
  /// RouteParser.isPathParam('*');
  /// // Returns: false
  /// ```
  ///
  /// [segment] The path segment to check.
  /// Returns true if the segment is a parameter.
  static bool isPathParam(String segment) => segment.startsWith(':');

  /// Check if a segment is a wildcard.
  ///
  /// Wildcard segments match any part of the URL path. '*' matches a single
  /// segment, while '**' matches zero or more segments.
  ///
  /// ## Example
  ///
  /// ```dart
  /// RouteParser.isWildcard('*');
  /// // Returns: true
  ///
  /// RouteParser.isWildcard('**');
  /// // Returns: true
  ///
  /// RouteParser.isWildcard(':id');
  /// // Returns: false
  ///
  /// RouteParser.isWildcard('user');
  /// // Returns: false
  /// ```
  ///
  /// [segment] The path segment to check.
  /// Returns true if the segment is a wildcard.
  static bool isWildcard(String segment) => segment == '*' || segment == '**';

  /// Parse query string into a map.
  ///
  /// Converts a URL query string into a key-value map. Handles strings with
  /// or without the leading '?'. Values are automatically URL-decoded.
  ///
  /// ## Example
  ///
  /// ```dart
  /// RouteParser.parseQueryString('?name=John&age=30');
  /// // Returns: {'name': 'John', 'age': '30'}
  ///
  /// RouteParser.parseQueryString('name=John%20Doe&city=New%20York');
  /// // Returns: {'name': 'John Doe', 'city': 'New York'}
  ///
  /// RouteParser.parseQueryString(null);
  /// // Returns: {}
  ///
  /// RouteParser.parseQueryString('');
  /// // Returns: {}
  /// ```
  ///
  /// [queryString] The query string to parse (with or without '?').
  /// Returns a map of query parameters.
  static Map<String, String> parseQueryString(String? queryString) {
    if (queryString == null || queryString.isEmpty) {
      return {};
    }
    final query =
        queryString.startsWith('?') ? queryString.substring(1) : queryString;
    return Uri.splitQueryString(query);
  }

  /// Build query string from a map.
  ///
  /// Converts a map of key-value pairs into a URL query string. Keys and
  /// values are automatically URL-encoded. Null values are excluded.
  ///
  /// ## Example
  ///
  /// ```dart
  /// RouteParser.buildQueryString({'name': 'John', 'age': 30});
  /// // Returns: '?name=John&age=30'
  ///
  /// RouteParser.buildQueryString({'search': 'hello world', 'page': 1});
  /// // Returns: '?search=hello%20world&page=1'
  ///
  /// RouteParser.buildQueryString({});
  /// // Returns: ''
  ///
  /// RouteParser.buildQueryString({'filter': null, 'type': 'user'});
  /// // Returns: '?type=user'
  /// ```
  ///
  /// [params] The map of parameters to convert.
  /// Returns a query string (with leading '?') or empty string if no params.
  static String buildQueryString(Map<String, dynamic> params) {
    if (params.isEmpty) return '';
    final pairs = params.entries.where((e) => e.value != null).map(
          (e) => '${Uri.encodeComponent(e.key)}='
              '${Uri.encodeComponent(e.value.toString())}',
        );
    return '?${pairs.join('&')}';
  }

  /// Split path and query from a full URL.
  ///
  /// Separates a full URL into its path and query string components.
  /// Returns a record with the path portion and optional query portion.
  ///
  /// ## Example
  ///
  /// ```dart
  /// RouteParser.splitPathAndQuery('/user/123?tab=profile&edit=true');
  /// // Returns: (path: '/user/123', query: 'tab=profile&edit=true')
  ///
  /// RouteParser.splitPathAndQuery('/dashboard');
  /// // Returns: (path: '/dashboard', query: null)
  ///
  /// RouteParser.splitPathAndQuery('/');
  /// // Returns: (path: '/', query: null)
  /// ```
  ///
  /// [fullPath] The full URL with optional query string.
  /// Returns a record with path and optional query string.
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

  /// Join base path with sub path.
  ///
  /// Combines two path segments into a properly normalized path.
  /// Handles various edge cases like root paths and trailing slashes.
  ///
  /// ## Example
  ///
  /// ```dart
  /// RouteParser.joinPaths('/user', '/123');
  /// // Returns: '/user/123'
  ///
  /// RouteParser.joinPaths('/app/', '/home/');
  /// // Returns: '/app/home'
  ///
  /// RouteParser.joinPaths('/user', '/');
  /// // Returns: '/user'
  ///
  /// RouteParser.joinPaths('/', '/dashboard');
  /// // Returns: '/dashboard'
  /// ```
  ///
  /// [base] The base path.
  /// [sub] The sub path to append.
  /// Returns the joined and normalized path.
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

  /// Extract parameter name from a parameter segment.
  ///
  /// Removes the leading ':' from a parameter segment to get the actual
  /// parameter name. Returns the segment unchanged if it's not a parameter.
  ///
  /// ## Example
  ///
  /// ```dart
  /// RouteParser.extractParamName(':id');
  /// // Returns: 'id'
  ///
  /// RouteParser.extractParamName(':userId');
  /// // Returns: 'userId'
  ///
  /// RouteParser.extractParamName('user');
  /// // Returns: 'user'
  ///
  /// RouteParser.extractParamName('*');
  /// // Returns: '*'
  /// ```
  ///
  /// [segment] The segment to extract parameter name from.
  /// Returns the parameter name without the ':' prefix.
  static String extractParamName(String segment) {
    if (segment.startsWith(':')) {
      return segment.substring(1);
    }
    return segment;
  }

  /// Check if path contains path parameters.
  ///
  /// Returns true if any segment in the path is a parameter (starts with ':').
  ///
  /// ## Example
  ///
  /// ```dart
  /// RouteParser.hasPathParams('/user/:id/posts/:postId');
  /// // Returns: true
  ///
  /// RouteParser.hasPathParams('/dashboard');
  /// // Returns: false
  ///
  /// RouteParser.hasPathParams('/files/*');
  /// // Returns: false (wildcard, not parameter)
  /// ```
  ///
  /// [path] The path to check.
  /// Returns true if the path contains parameters.
  static bool hasPathParams(String path) {
    return parseSegments(path).any(isPathParam);
  }

  /// Get parent path.
  ///
  /// Returns the parent path by removing the last segment from the given path.
  /// Returns '/' for direct children of root, and null for root itself.
  ///
  /// ## Example
  ///
  /// ```dart
  /// RouteParser.getParentPath('/user/123/posts/456');
  /// // Returns: '/user/123/posts'
  ///
  /// RouteParser.getParentPath('/user/123');
  /// // Returns: '/user'
  ///
  /// RouteParser.getParentPath('/user');
  /// // Returns: '/'
  ///
  /// RouteParser.getParentPath('/');
  /// // Returns: null
  /// ```
  ///
  /// [path] The path to get parent for.
  /// Returns the parent path or null if the path is root.
  static String? getParentPath(String path) {
    final segments = parseSegments(path);
    if (segments.isEmpty) return null;
    if (segments.length == 1) return '/';
    return '/${segments.sublist(0, segments.length - 1).join('/')}';
  }
}

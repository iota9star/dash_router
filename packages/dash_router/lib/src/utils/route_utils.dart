import 'package:flutter/material.dart';

import 'route_parser.dart';

/// General route utilities and helper functions.
///
/// This class provides static methods for common routing tasks
/// like path manipulation, naming conventions, and pattern matching.
///
/// ## Example
///
/// ```dart
/// class MyWidget extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     // Convert class name to route name
///     final routeName = RouteUtils.classNameToRouteName('UserDetailPage');
///     
///     // Convert route name to path
///     final path = RouteUtils.routeNameToPath(routeName);
///     
///     // Check if path is child of parent
///     final isChild = RouteUtils.isChildPath('/user', '/user/123');
///     
///     return Text('Route: $path, Child: $isChild');
///   }
/// }
/// ```
class RouteUtils {
  RouteUtils._();

  /// Generates a unique route key for caching.
  ///
  /// Combines path and parameters to create a unique identifier.
  /// Useful for caching route widgets or results.
  ///
  /// [path] - The route path
  /// [params] - Optional parameters to include
  ///
  /// Example:
  /// ```dart
  /// final key = RouteUtils.generateRouteKey(
  ///   '/user/123',
  ///   {'tab': 'profile', 'edit': 'true'},
  /// ); // '/user/123_edit_true_tab_profile'
  /// ```
  static String generateRouteKey(String path, [Map<String, dynamic>? params]) {
    final buffer = StringBuffer(path);
    if (params != null && params.isNotEmpty) {
      final sortedKeys = params.keys.toList()..sort();
      for (final key in sortedKeys) {
        buffer.write('_${key}_${params[key]}');
      }
    }
    return buffer.toString();
  }

  /// Converts a class name to a route name.
  ///
  /// Removes common suffixes and converts to camelCase.
  /// Used for auto-generating route names from widget names.
  ///
  /// [className] - The class name to convert
  ///
  /// Example:
  /// ```dart
  /// RouteUtils.classNameToRouteName('UserDetailPage'); // 'userDetail'
  /// RouteUtils.classNameToRouteName('SettingsScreen'); // 'settings'
  /// RouteUtils.classNameToRouteName('LoginView'); // 'login'
  /// ```
  static String classNameToRouteName(String className) {
    // Remove common suffixes
    var name = className;
    for (final suffix in ['Page', 'Screen', 'View', 'Widget']) {
      if (name.endsWith(suffix)) {
        name = name.substring(0, name.length - suffix.length);
        break;
      }
    }
    // Convert to camelCase
    if (name.isEmpty) return className.toLowerCase();
    return '${name[0].toLowerCase()}${name.substring(1)}';
  }

  /// Convert a route name to a path
  /// e.g., 'userDetail' -> '/user-detail'
  static String routeNameToPath(String routeName) {
    final buffer = StringBuffer('/');
    for (var i = 0; i < routeName.length; i++) {
      final char = routeName[i];
      if (char.toUpperCase() == char && char.toLowerCase() != char) {
        if (i > 0) buffer.write('-');
        buffer.write(char.toLowerCase());
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// Convert a path to a route name
  /// e.g., '/user-detail' -> 'userDetail'
  static String pathToRouteName(String path) {
    final segments = RouteParser.parseSegments(path);
    if (segments.isEmpty) return 'root';

    final lastSegment = segments.last;
    // Skip path parameters
    if (lastSegment.startsWith(':')) {
      if (segments.length > 1) {
        return _segmentToName(segments[segments.length - 2]);
      }
      return 'root';
    }
    return _segmentToName(lastSegment);
  }

  static String _segmentToName(String segment) {
    // Convert kebab-case to camelCase
    final parts = segment.split('-');
    if (parts.length == 1) return parts[0];
    return parts[0] +
        parts
            .skip(1)
            .map(
              (p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}',
            )
            .join();
  }

  /// Check if running on web platform
  static bool get isWeb {
    return identical(0, 0.0);
  }

  /// Check if platform uses Cupertino style
  static bool isCupertinoPlatform(BuildContext context) {
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  /// Get current platform
  static TargetPlatform getPlatform(BuildContext context) {
    return Theme.of(context).platform;
  }

  /// Deep merge two maps
  static Map<String, dynamic> deepMerge(
    Map<String, dynamic> base,
    Map<String, dynamic> override,
  ) {
    final result = Map<String, dynamic>.from(base);
    for (final entry in override.entries) {
      if (entry.value is Map<String, dynamic> &&
          result[entry.key] is Map<String, dynamic>) {
        result[entry.key] = deepMerge(
          result[entry.key] as Map<String, dynamic>,
          entry.value as Map<String, dynamic>,
        );
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  /// Safe cast with default value
  static T? safeCast<T>(dynamic value) {
    if (value is T) return value;
    return null;
  }

  /// Get depth of a path
  static int getPathDepth(String path) {
    return RouteParser.parseSegments(path).length;
  }

  /// Check if path is child of parent
  static bool isChildPath(String parent, String child) {
    final parentSegments = RouteParser.parseSegments(parent);
    final childSegments = RouteParser.parseSegments(child);

    if (childSegments.length <= parentSegments.length) return false;

    for (var i = 0; i < parentSegments.length; i++) {
      final parentSeg = parentSegments[i];
      final childSeg = childSegments[i];

      if (RouteParser.isPathParam(parentSeg)) continue;
      if (parentSeg != childSeg) return false;
    }

    return true;
  }

  /// Matches a path against a glob pattern.
  ///
  /// Supported patterns:
  /// - Exact match: `/user/profile` matches only `/user/profile`
  /// - Single segment wildcard: `/user/*` matches `/user/123` but not `/user/123/posts`
  /// - Multi-segment wildcard: `/admin/**` matches `/admin`, `/admin/users`, `/admin/users/123`
  /// - Global wildcard: `*` or `**` matches any path
  ///
  /// Example:
  /// ```dart
  /// RouteUtils.matchGlobPattern('/user/**', '/user/123/posts'); // true
  /// RouteUtils.matchGlobPattern('/user/*', '/user/123'); // true
  /// RouteUtils.matchGlobPattern('/user/*', '/user/123/posts'); // false
  /// ```
  static bool matchGlobPattern(String pattern, String path) {
    // Global wildcards match everything
    if (pattern == '*' || pattern == '**') return true;

    // Exact match
    if (pattern == path) return true;

    // Handle ** wildcard (matches multiple segments)
    if (pattern.endsWith('/**')) {
      final prefix = pattern.substring(0, pattern.length - 3);
      return path == prefix || path.startsWith('$prefix/');
    }

    // Handle * wildcard (matches single segment)
    if (pattern.contains('*')) {
      // Escape regex special characters except *
      final escaped = pattern
          .replaceAll(r'\', r'\\')
          .replaceAll('.', r'\.')
          .replaceAll('+', r'\+')
          .replaceAll('?', r'\?')
          .replaceAll('[', r'\[')
          .replaceAll(']', r'\]')
          .replaceAll('(', r'\(')
          .replaceAll(')', r'\)')
          .replaceAll('{', r'\{')
          .replaceAll('}', r'\}')
          .replaceAll('^', r'\^')
          .replaceAll(r'$', r'\$')
          .replaceAll('|', r'\|');
      final regex = RegExp('^${escaped.replaceAll('*', '[^/]*')}\$');
      return regex.hasMatch(path);
    }

    return false;
  }
}

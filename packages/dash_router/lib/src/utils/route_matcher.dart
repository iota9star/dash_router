import 'route_parser.dart';

/// Result of a route match operation
class RouteMatchResult {
  /// Whether the route matched
  final bool isMatch;

  /// Extracted path parameters
  final Map<String, String> pathParams;

  /// Remaining path segments (for wildcard matches)
  final List<String> remainingSegments;

  /// Match score (higher is better match)
  final int score;

  const RouteMatchResult({
    required this.isMatch,
    this.pathParams = const {},
    this.remainingSegments = const [],
    this.score = 0,
  });

  /// No match result
  static const noMatch = RouteMatchResult(isMatch: false);

  @override
  String toString() =>
      'RouteMatchResult(isMatch: $isMatch, pathParams: $pathParams, '
      'remainingSegments: $remainingSegments, score: $score)';
}

/// Route matching utilities
class RouteMatcher {
  RouteMatcher._();

  /// Match a path against a pattern
  static RouteMatchResult match(String pattern, String path) {
    final patternSegments = RouteParser.parseSegments(pattern);
    final pathSegments = RouteParser.parseSegments(path);

    // Handle root path
    if (patternSegments.isEmpty && pathSegments.isEmpty) {
      return const RouteMatchResult(isMatch: true, score: 1000);
    }

    final pathParams = <String, String>{};
    var score = 0;

    // Check for wildcard at the end
    final hasTrailingWildcard = patternSegments.isNotEmpty &&
        RouteParser.isWildcard(patternSegments.last);

    // Adjust length check for wildcard patterns
    if (!hasTrailingWildcard && patternSegments.length != pathSegments.length) {
      return RouteMatchResult.noMatch;
    }

    if (hasTrailingWildcard &&
        pathSegments.length < patternSegments.length - 1) {
      return RouteMatchResult.noMatch;
    }

    // Match each segment
    final segmentsToMatch = hasTrailingWildcard
        ? patternSegments.length - 1
        : patternSegments.length;

    for (var i = 0; i < segmentsToMatch; i++) {
      final patternSegment = patternSegments[i];
      final pathSegment = pathSegments[i];

      if (RouteParser.isPathParam(patternSegment)) {
        // Path parameter - matches any value
        pathParams[RouteParser.extractParamName(patternSegment)] = pathSegment;
        score += 10; // Lower score for param matches
      } else if (patternSegment == pathSegment) {
        // Exact match
        score += 100; // Higher score for exact matches
      } else {
        // No match
        return RouteMatchResult.noMatch;
      }
    }

    // Handle remaining segments for wildcard
    List<String> remainingSegments = [];
    if (hasTrailingWildcard) {
      remainingSegments = pathSegments.sublist(segmentsToMatch);
      score += 1; // Lowest score for wildcard matches
    }

    return RouteMatchResult(
      isMatch: true,
      pathParams: pathParams,
      remainingSegments: remainingSegments,
      score: score,
    );
  }

  /// Match a path against a pattern allowing extra trailing segments.
  ///
  /// This is useful for nested routing where a parent route like `/app`
  /// should match child paths like `/app/settings`.
  static RouteMatchResult matchPrefix(String pattern, String path) {
    final patternSegments = RouteParser.parseSegments(pattern);
    final pathSegments = RouteParser.parseSegments(path);

    // Root matches everything.
    if (patternSegments.isEmpty) {
      return const RouteMatchResult(isMatch: true, score: 1000);
    }

    // A prefix match requires the path to have at least as many segments as
    // the non-wildcard portion of the pattern.
    final hasTrailingWildcard = patternSegments.isNotEmpty &&
        RouteParser.isWildcard(patternSegments.last);

    final segmentsToMatch = hasTrailingWildcard
        ? patternSegments.length - 1
        : patternSegments.length;

    if (pathSegments.length < segmentsToMatch) {
      return RouteMatchResult.noMatch;
    }

    final pathParams = <String, String>{};
    var score = 0;

    for (var i = 0; i < segmentsToMatch; i++) {
      final patternSegment = patternSegments[i];
      final pathSegment = pathSegments[i];

      if (RouteParser.isPathParam(patternSegment)) {
        pathParams[RouteParser.extractParamName(patternSegment)] = pathSegment;
        score += 10;
      } else if (patternSegment == pathSegment) {
        score += 100;
      } else {
        return RouteMatchResult.noMatch;
      }
    }

    // If there is a wildcard, it matches the remaining segments.
    final remainingSegments = pathSegments.sublist(segmentsToMatch);
    if (hasTrailingWildcard) {
      score += 1;
    }

    return RouteMatchResult(
      isMatch: true,
      pathParams: pathParams,
      remainingSegments: remainingSegments,
      score: score,
    );
  }

  /// Find the best matching route from a list of patterns
  static (String pattern, RouteMatchResult result)? findBestMatch(
    List<String> patterns,
    String path,
  ) {
    RouteMatchResult? bestResult;
    String? bestPattern;

    for (final pattern in patterns) {
      final result = match(pattern, path);
      if (result.isMatch) {
        if (bestResult == null || result.score > bestResult.score) {
          bestResult = result;
          bestPattern = pattern;
        }
      }
    }

    if (bestPattern != null && bestResult != null) {
      return (bestPattern, bestResult);
    }
    return null;
  }

  /// Check if a path matches any of the given patterns
  static bool matchesAny(List<String> patterns, String path) {
    return patterns.any((pattern) => match(pattern, path).isMatch);
  }

  /// Build a path from a pattern with given parameters
  static String buildPath(String pattern, Map<String, dynamic> params) {
    final segments = RouteParser.parseSegments(pattern);
    final builtSegments = segments.map((segment) {
      if (RouteParser.isPathParam(segment)) {
        final paramName = RouteParser.extractParamName(segment);
        final value = params[paramName];
        if (value == null) {
          throw ArgumentError('Missing path parameter: $paramName');
        }
        return Uri.encodeComponent(value.toString());
      }
      return segment;
    }).toList();

    if (builtSegments.isEmpty) return '/';
    return '/${builtSegments.join('/')}';
  }

  /// Validate that all required path parameters are provided
  static List<String> validatePathParams(
    String pattern,
    Map<String, dynamic> params,
  ) {
    final requiredParams = RouteParser.extractPathParams(pattern).keys;
    return requiredParams.where((p) => !params.containsKey(p)).toList();
  }
}

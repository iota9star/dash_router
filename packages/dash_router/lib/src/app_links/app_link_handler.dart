import '../router/dash_router.dart';
import '../utils/route_parser.dart';

/// Handler for App Links (Deep Links)
class AppLinkHandler {
  /// The router instance
  final DashRouter router;

  /// Default scheme for the app
  final String? scheme;

  /// Default host for the app
  final String? host;

  /// Path prefix for app links
  final String pathPrefix;

  /// Link transformers
  final List<LinkTransformer> transformers;

  AppLinkHandler({
    required this.router,
    this.scheme,
    this.host,
    this.pathPrefix = '',
    this.transformers = const [],
  });

  /// Handle an incoming URI
  Future<bool> handleUri(Uri uri) async {
    // Validate scheme if specified
    if (scheme != null && uri.scheme != scheme) {
      return false;
    }

    // Validate host if specified
    if (host != null && uri.host != host) {
      return false;
    }

    // Extract path
    var path = uri.path;

    // Remove path prefix if present
    if (pathPrefix.isNotEmpty && path.startsWith(pathPrefix)) {
      path = path.substring(pathPrefix.length);
    }

    // Normalize path
    path = RouteParser.normalizePath(path);

    // Apply transformers
    for (final transformer in transformers) {
      final transformed = transformer.transform(path, uri.queryParameters);
      if (transformed != null) {
        path = transformed.path;
      }
    }

    // Build query params
    final queryParams =
        uri.queryParameters.isNotEmpty ? uri.queryParameters : null;

    // Navigate
    try {
      await router.pushNamed(
        path,
        query: queryParams?.cast<String, dynamic>(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Handle an incoming string URL
  Future<bool> handleUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return handleUri(uri);
  }

  /// Build an app link URL
  Uri buildUri(String path, {Map<String, String>? queryParams}) {
    return Uri(
      scheme: scheme ?? 'https',
      host: host ?? 'app',
      path: '$pathPrefix${RouteParser.normalizePath(path)}',
      queryParameters: queryParams?.isNotEmpty == true ? queryParams : null,
    );
  }

  /// Build an app link URL string
  String buildUrl(String path, {Map<String, String>? queryParams}) {
    return buildUri(path, queryParams: queryParams).toString();
  }
}

/// Transformer for link paths
abstract class LinkTransformer {
  /// Transform a path and query params
  LinkTransformResult? transform(String path, Map<String, String> queryParams);
}

/// Result of link transformation
class LinkTransformResult {
  final String path;
  final Map<String, String>? queryParams;
  final Object? extra;

  const LinkTransformResult({required this.path, this.queryParams, this.extra});
}

/// Simple path mapping transformer
class PathMappingTransformer implements LinkTransformer {
  /// Map of source paths to target paths
  final Map<String, String> mappings;

  PathMappingTransformer(this.mappings);

  @override
  LinkTransformResult? transform(String path, Map<String, String> queryParams) {
    final target = mappings[path];
    if (target != null) {
      return LinkTransformResult(path: target, queryParams: queryParams);
    }
    return null;
  }
}

/// Regex-based path transformer
class RegexPathTransformer implements LinkTransformer {
  final RegExp pattern;
  final String Function(Match match, Map<String, String> queryParams) builder;

  RegexPathTransformer({required this.pattern, required this.builder});

  @override
  LinkTransformResult? transform(String path, Map<String, String> queryParams) {
    final match = pattern.firstMatch(path);
    if (match != null) {
      return LinkTransformResult(
        path: builder(match, queryParams),
        queryParams: queryParams,
      );
    }
    return null;
  }
}

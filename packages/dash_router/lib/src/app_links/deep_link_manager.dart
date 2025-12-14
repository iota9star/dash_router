import 'dart:async';

import 'app_link_handler.dart';

/// Manager for deep links
class DeepLinkManager {
  /// App link handler
  final AppLinkHandler handler;

  /// Stream controller for incoming links
  final _linkController = StreamController<Uri>.broadcast();

  /// Initial link (if app was opened via deep link)
  Uri? _initialLink;

  /// Whether the initial link has been handled
  bool _initialLinkHandled = false;

  DeepLinkManager({required this.handler});

  /// Stream of incoming deep links
  Stream<Uri> get linkStream => _linkController.stream;

  /// Get the initial link (if any)
  Uri? get initialLink => _initialLink;

  /// Check if initial link was handled
  bool get initialLinkHandled => _initialLinkHandled;

  /// Set the initial link (called during app initialization)
  void setInitialLink(Uri? uri) {
    _initialLink = uri;
  }

  /// Handle the initial link
  Future<bool> handleInitialLink() async {
    if (_initialLink == null || _initialLinkHandled) {
      return false;
    }

    _initialLinkHandled = true;
    return handler.handleUri(_initialLink!);
  }

  /// Handle an incoming link
  Future<bool> handleLink(Uri uri) async {
    _linkController.add(uri);
    return handler.handleUri(uri);
  }

  /// Handle an incoming link string
  Future<bool> handleLinkString(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return handleLink(uri);
  }

  /// Add a listener for incoming links
  StreamSubscription<Uri> addListener(void Function(Uri uri) listener) {
    return _linkController.stream.listen(listener);
  }

  /// Dispose resources
  void dispose() {
    _linkController.close();
  }
}

/// Configuration for deep links
class DeepLinkConfig {
  /// App scheme (e.g., 'myapp')
  final String? scheme;

  /// Web host (e.g., 'example.com')
  final String? host;

  /// Path prefix to strip from incoming links
  final String pathPrefix;

  /// Whether to handle initial link automatically
  final bool handleInitialLink;

  /// Link transformers
  final List<LinkTransformer> transformers;

  const DeepLinkConfig({
    this.scheme,
    this.host,
    this.pathPrefix = '',
    this.handleInitialLink = true,
    this.transformers = const [],
  });
}

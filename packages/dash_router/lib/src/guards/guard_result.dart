import '../router/route_data.dart';

/// Route guard result
sealed class GuardResult {
  const GuardResult();
}

/// Guard allows navigation
class GuardAllow extends GuardResult {
  const GuardAllow();
}

/// Guard denies navigation
class GuardDeny extends GuardResult {
  /// Reason for denial
  final String? reason;

  const GuardDeny([this.reason]);
}

/// Guard redirects to another route
class GuardRedirect extends GuardResult {
  /// Path to redirect to
  final String redirectTo;

  /// Query parameters for redirect
  final Map<String, dynamic>? queryParams;

  /// Extra data for redirect
  final Object? extra;

  const GuardRedirect(this.redirectTo, {this.queryParams, this.extra});
}

/// Guard result is pending (async operation)
class GuardPending extends GuardResult {
  const GuardPending();
}

/// Extension methods for GuardResult
extension GuardResultExtension on GuardResult {
  /// Check if guard allowed navigation
  bool get isAllowed => this is GuardAllow;

  /// Check if guard denied navigation
  bool get isDenied => this is GuardDeny;

  /// Check if guard redirected
  bool get isRedirect => this is GuardRedirect;

  /// Check if guard is pending
  bool get isPending => this is GuardPending;

  /// Get redirect path if redirected
  String? get redirectPath {
    if (this is GuardRedirect) {
      return (this as GuardRedirect).redirectTo;
    }
    return null;
  }

  /// Get denial reason if denied
  String? get denyReason {
    if (this is GuardDeny) {
      return (this as GuardDeny).reason;
    }
    return null;
  }
}

/// Guard context with navigation information
class GuardContext {
  /// The route being navigated to
  final RouteData targetRoute;

  /// The current route (if any)
  final RouteData? currentRoute;

  /// Whether this is a push or replace navigation
  final bool isReplace;

  /// Extra data passed with navigation
  final Object? extra;

  const GuardContext({
    required this.targetRoute,
    this.currentRoute,
    this.isReplace = false,
    this.extra,
  });

  /// Get target path
  String get targetPath => targetRoute.path;

  /// Get target name
  String get targetName => targetRoute.name;

  /// Get current path
  String? get currentPath => currentRoute?.path;

  /// Get current name
  String? get currentName => currentRoute?.name;
}

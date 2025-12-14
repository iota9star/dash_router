import 'middleware.dart';
import 'middleware_context.dart';

/// Pipeline for executing middleware in order
class MiddlewarePipeline {
  final List<DashMiddleware> middleware;

  MiddlewarePipeline(this.middleware);

  /// Execute the pipeline
  Future<MiddlewareResult> execute(MiddlewareContext context) async {
    var currentContext = context;

    for (final m in middleware) {
      final result = await m.handle(currentContext);

      if (result is MiddlewareContinue) {
        // Update context if modified
        if (result.modifiedContext != null) {
          currentContext = result.modifiedContext!;
        }
        continue;
      }

      // Abort or redirect
      return result;
    }

    return const MiddlewareContinue();
  }

  /// Call afterNavigation on all middleware
  Future<void> afterNavigation(MiddlewareContext context) async {
    for (final m in middleware) {
      await m.afterNavigation(context);
    }
  }

  /// Call onAborted on all middleware
  Future<void> onAborted(MiddlewareContext context, String? reason) async {
    for (final m in middleware) {
      await m.onAborted(context, reason);
    }
  }
}

/// Manager for route middleware
class MiddlewareManager {
  final List<DashMiddleware> _middleware = [];

  /// Register middleware
  void register(DashMiddleware middleware) {
    _middleware.add(middleware);
    // Sort by priority (higher first)
    _middleware.sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// Register multiple middleware
  void registerAll(List<DashMiddleware> middlewareList) {
    for (final m in middlewareList) {
      register(m);
    }
  }

  /// Unregister middleware
  void unregister(DashMiddleware middleware) {
    _middleware.remove(middleware);
  }

  /// Unregister middleware by type
  void unregisterByType<T extends DashMiddleware>() {
    _middleware.removeWhere((m) => m is T);
  }

  /// Clear all middleware
  void clear() {
    _middleware.clear();
  }

  /// Get all registered middleware
  List<DashMiddleware> get all => List.unmodifiable(_middleware);

  /// Get middleware that applies to a specific path
  List<DashMiddleware> middlewareFor(String path) {
    return _middleware.where((m) => m.shouldRun(path)).toList();
  }

  /// Create pipeline for a path
  MiddlewarePipeline pipelineFor(String path) {
    return MiddlewarePipeline(middlewareFor(path));
  }

  /// Execute middleware for a context
  Future<MiddlewareResult> execute(MiddlewareContext context) async {
    final pipeline = pipelineFor(context.targetPath);
    return pipeline.execute(context);
  }

  /// Add a simple function middleware
  void addMiddleware({
    required Future<MiddlewareResult> Function(MiddlewareContext) handle,
    Future<void> Function(MiddlewareContext)? afterNavigation,
    int priority = 0,
    List<String>? routes,
    List<String>? excludeRoutes,
  }) {
    register(
      FunctionalMiddleware(
        handle: handle,
        afterNavigation: afterNavigation,
        priority: priority,
        routes: routes,
        excludeRoutes: excludeRoutes,
      ),
    );
  }

  /// Add logging middleware
  void addLogging({
    void Function(String)? log,
    bool logAfterNavigation = true,
    bool logTiming = true,
  }) {
    register(
      LoggingMiddleware(
        log: log,
        logAfterNavigation: logAfterNavigation,
        logTiming: logTiming,
      ),
    );
  }
}

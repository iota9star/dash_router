import 'guard.dart';
import 'guard_result.dart';

/// Manager for route guards
class GuardManager {
  /// Registered guards
  final List<DashGuard> _guards = [];

  /// Register a guard
  void register(DashGuard guard) {
    _guards.add(guard);
    // Sort by priority (higher first)
    _guards.sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// Register multiple guards
  void registerAll(List<DashGuard> guards) {
    for (final guard in guards) {
      register(guard);
    }
  }

  /// Unregister a guard
  void unregister(DashGuard guard) {
    _guards.remove(guard);
  }

  /// Unregister guards by type
  void unregisterByType<T extends DashGuard>() {
    _guards.removeWhere((g) => g is T);
  }

  /// Clear all guards
  void clear() {
    _guards.clear();
  }

  /// Get all registered guards
  List<DashGuard> get all => List.unmodifiable(_guards);

  /// Get guards that apply to a specific path
  List<DashGuard> guardsFor(String path) {
    return _guards.where((g) => g.shouldRun(path)).toList();
  }

  /// Run all applicable guards
  Future<GuardResult> runGuards(GuardContext context) async {
    final applicableGuards = guardsFor(context.targetPath);

    for (final guard in applicableGuards) {
      final result = await guard.canActivate(context);

      if (!result.isAllowed) {
        // Call onDenied callback
        await guard.onDenied(context, result);
        return result;
      }

      // Call onActivated callback
      await guard.onActivated(context);
    }

    return const GuardAllow();
  }

  /// Check if any guard would block navigation
  Future<bool> canNavigate(GuardContext context) async {
    final result = await runGuards(context);
    return result.isAllowed;
  }

  /// Add a simple function guard
  void addGuard({
    required Future<GuardResult> Function(GuardContext) canActivate,
    int priority = 0,
    List<String>? routes,
    List<String>? excludeRoutes,
  }) {
    register(
      FunctionalGuard(
        canActivate: canActivate,
        priority: priority,
        routes: routes,
        excludeRoutes: excludeRoutes,
      ),
    );
  }

  /// Add a conditional guard
  void addCondition({
    required bool Function() condition,
    required String redirectTo,
    Map<String, dynamic>? redirectParams,
    int priority = 0,
    List<String>? routes,
    List<String>? excludeRoutes,
  }) {
    register(
      ConditionalGuard(
        condition: condition,
        redirectTo: redirectTo,
        redirectParams: redirectParams,
        priority: priority,
        routes: routes,
        excludeRoutes: excludeRoutes,
      ),
    );
  }

  /// Add an async conditional guard
  void addAsyncCondition({
    required Future<bool> Function() condition,
    required String redirectTo,
    Map<String, dynamic>? redirectParams,
    int priority = 0,
    List<String>? routes,
    List<String>? excludeRoutes,
  }) {
    register(
      AsyncConditionalGuard(
        condition: condition,
        redirectTo: redirectTo,
        redirectParams: redirectParams,
        priority: priority,
        routes: routes,
        excludeRoutes: excludeRoutes,
      ),
    );
  }
}

/// Combined guard result for multiple guards
class CombinedGuardResult {
  final List<(DashGuard, GuardResult)> results;

  const CombinedGuardResult(this.results);

  /// Check if all guards allowed
  bool get allAllowed => results.every((r) => r.$2.isAllowed);

  /// Get first deny/redirect result
  GuardResult? get firstDenied {
    for (final (_, result) in results) {
      if (!result.isAllowed) return result;
    }
    return null;
  }

  /// Get all denied results
  List<(DashGuard, GuardResult)> get denied =>
      results.where((r) => !r.$2.isAllowed).toList();
}

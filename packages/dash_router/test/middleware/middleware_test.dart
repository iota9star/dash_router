// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:dash_router/dash_router.dart';

void main() {
  group('DashMiddleware', () {
    group('shouldRun', () {
      test('returns true for all routes when routes is null', () {
        final middleware = _TestMiddleware();
        expect(middleware.shouldRun('/home'), isTrue);
        expect(middleware.shouldRun('/user/123'), isTrue);
        expect(middleware.shouldRun('/any/path'), isTrue);
      });

      test('returns true only for matching routes', () {
        final middleware = _TestMiddleware(routes: ['/home', '/user/*']);
        expect(middleware.shouldRun('/home'), isTrue);
        expect(middleware.shouldRun('/user/123'), isTrue);
        expect(middleware.shouldRun('/settings'), isFalse);
      });

      test('respects excludeRoutes', () {
        final middleware = _TestMiddleware(excludeRoutes: ['/public/**']);
        expect(middleware.shouldRun('/home'), isTrue);
        expect(middleware.shouldRun('/public'), isFalse);
        expect(middleware.shouldRun('/public/docs'), isFalse);
      });

      test('excludeRoutes takes precedence over routes', () {
        final middleware = _TestMiddleware(
          routes: ['/admin/**'],
          excludeRoutes: ['/admin/public'],
        );
        expect(middleware.shouldRun('/admin/dashboard'), isTrue);
        expect(middleware.shouldRun('/admin/public'), isFalse);
      });
    });

    group('MiddlewareResult', () {
      test('MiddlewareContinue allows continuation', () {
        const result = MiddlewareContinue();
        expect(result, isA<MiddlewareContinue>());
      });

      test('MiddlewareAbort stops navigation', () {
        const result = MiddlewareAbort('Test reason');
        expect(result.reason, equals('Test reason'));
      });

      test('MiddlewareRedirect redirects to path', () {
        const result = MiddlewareRedirect('/login');
        expect(result.redirectTo, equals('/login'));
      });

      test('MiddlewareRedirect can have query params', () {
        const result = MiddlewareRedirect(
          '/login',
          queryParams: {'returnUrl': '/dashboard'},
        );
        expect(result.queryParams, equals({'returnUrl': '/dashboard'}));
      });
    });
  });

  group('FunctionalMiddleware', () {
    test('calls handle function', () async {
      var called = false;
      final middleware = FunctionalMiddleware(
        handle: (context) async {
          called = true;
          return const MiddlewareContinue();
        },
      );

      final context = _createMiddlewareContext();
      await middleware.handle(context);
      expect(called, isTrue);
    });

    test('calls afterNavigation function', () async {
      var afterCalled = false;
      final middleware = FunctionalMiddleware(
        handle: (_) async => const MiddlewareContinue(),
        afterNavigation: (context) async {
          afterCalled = true;
        },
      );

      final context = _createMiddlewareContext();
      await middleware.afterNavigation(context);
      expect(afterCalled, isTrue);
    });

    test('supports routes configuration', () {
      final middleware = FunctionalMiddleware(
        handle: (_) async => const MiddlewareContinue(),
        routes: ['/protected/**'],
      );

      expect(middleware.shouldRun('/protected/page'), isTrue);
      expect(middleware.shouldRun('/public/page'), isFalse);
    });
  });

  group('LoggingMiddleware', () {
    test('logs navigation', () async {
      final logs = <String>[];
      final middleware = LoggingMiddleware(
        log: logs.add,
      );

      final context = _createMiddlewareContext(
        targetPath: '/dashboard',
        currentPath: '/home',
      );

      await middleware.handle(context);
      expect(logs, contains('[Navigation] /home -> /dashboard'));
    });

    test('logs after navigation when enabled', () async {
      final logs = <String>[];
      final middleware = LoggingMiddleware(
        log: logs.add,
        logAfterNavigation: true,
        logTiming: false,
      );

      final context = _createMiddlewareContext(targetPath: '/dashboard');
      await middleware.afterNavigation(context);
      expect(logs.any((l) => l.contains('[Navigation Complete]')), isTrue);
    });
  });

  group('DelayMiddleware', () {
    test('adds delay before navigation', () async {
      final middleware = DelayMiddleware(
        delay: const Duration(milliseconds: 50),
      );

      final start = DateTime.now();
      await middleware.handle(_createMiddlewareContext());
      final elapsed = DateTime.now().difference(start);

      expect(elapsed.inMilliseconds, greaterThanOrEqualTo(45));
    });
  });

  group('MiddlewarePipeline', () {
    test('executes middleware in order (pipeline uses input order)', () async {
      final order = <int>[];

      // Pipeline executes in input order, not by priority
      // Use MiddlewareManager for priority-based ordering
      final pipeline = MiddlewarePipeline([
        _PriorityMiddleware(priority: 1, onHandle: () => order.add(1)),
        _PriorityMiddleware(priority: 2, onHandle: () => order.add(2)),
        _PriorityMiddleware(priority: 3, onHandle: () => order.add(3)),
      ]);

      await pipeline.execute(_createMiddlewareContext());
      expect(order, equals([1, 2, 3])); // Executes in input order
    });

    test('stops on abort', () async {
      final order = <int>[];

      final pipeline = MiddlewarePipeline([
        _PriorityMiddleware(
          priority: 3,
          onHandle: () => order.add(3),
        ),
        _PriorityMiddleware(
          priority: 2,
          onHandle: () => order.add(2),
          result: const MiddlewareAbort('stopped'),
        ),
        _PriorityMiddleware(
          priority: 1,
          onHandle: () => order.add(1),
        ),
      ]);

      final result = await pipeline.execute(_createMiddlewareContext());
      expect(result, isA<MiddlewareAbort>());
      expect(order, equals([3, 2])); // Only first two executed
    });

    test('returns redirect result', () async {
      final pipeline = MiddlewarePipeline([
        _PriorityMiddleware(
          priority: 2,
          result: const MiddlewareRedirect('/login'),
        ),
        _PriorityMiddleware(priority: 1),
      ]);

      final result = await pipeline.execute(_createMiddlewareContext());
      expect(result, isA<MiddlewareRedirect>());
      expect((result as MiddlewareRedirect).redirectTo, equals('/login'));
    });

    test('calls afterNavigation for all middleware', () async {
      var afterCount = 0;

      final pipeline = MiddlewarePipeline([
        _PriorityMiddleware(priority: 1, onAfter: () => afterCount++),
        _PriorityMiddleware(priority: 2, onAfter: () => afterCount++),
      ]);

      await pipeline.execute(_createMiddlewareContext());
      await pipeline.afterNavigation(_createMiddlewareContext());
      expect(afterCount, equals(2));
    });
  });

  group('MiddlewareManager', () {
    test('sorts middleware by priority (higher first)', () async {
      final order = <int>[];
      final manager = MiddlewareManager();

      manager.register(
          _PriorityMiddleware(priority: 1, onHandle: () => order.add(1)));
      manager.register(
          _PriorityMiddleware(priority: 3, onHandle: () => order.add(3)));
      manager.register(
          _PriorityMiddleware(priority: 2, onHandle: () => order.add(2)));

      await manager.execute(_createMiddlewareContext());
      expect(order, equals([3, 2, 1])); // Higher priority first
    });

    test('middlewareFor filters by path', () {
      final manager = MiddlewareManager();

      manager.register(_TestMiddleware(routes: ['/admin/**']));
      manager.register(_TestMiddleware(routes: ['/public/**']));
      manager.register(_TestMiddleware()); // applies to all

      expect(manager.middlewareFor('/admin/dashboard').length, equals(2));
      expect(manager.middlewareFor('/public/page').length, equals(2));
      expect(manager.middlewareFor('/other').length, equals(1));
    });

    test('unregisterByType removes middleware of type', () {
      final manager = MiddlewareManager();

      manager.register(LoggingMiddleware());
      manager.register(_TestMiddleware());

      expect(manager.all.length, equals(2));
      manager.unregisterByType<LoggingMiddleware>();
      expect(manager.all.length, equals(1));
    });
  });
}

class _TestMiddleware extends DashMiddleware {
  @override
  final List<String>? routes;

  @override
  final List<String>? excludeRoutes;

  _TestMiddleware({this.routes, this.excludeRoutes});

  @override
  Future<MiddlewareResult> handle(MiddlewareContext context) async {
    return const MiddlewareContinue();
  }
}

class _PriorityMiddleware extends DashMiddleware {
  @override
  final int priority;

  final void Function()? onHandle;
  final void Function()? onAfter;
  final MiddlewareResult result;

  _PriorityMiddleware({
    this.priority = 0,
    this.onHandle,
    this.onAfter,
    this.result = const MiddlewareContinue(),
  });

  @override
  Future<MiddlewareResult> handle(MiddlewareContext context) async {
    onHandle?.call();
    return result;
  }

  @override
  Future<void> afterNavigation(MiddlewareContext context) async {
    onAfter?.call();
  }
}

MiddlewareContext _createMiddlewareContext({
  String targetPath = '/test',
  String? currentPath,
}) {
  return MiddlewareContext(
    targetRoute: RouteData(
      pattern: targetPath,
      path: targetPath,
      fullPath: targetPath,
      name: 'test',
      params: const RouteParams(),
      isInitial: false,
      metadata: const {},
    ),
    currentRoute: currentPath != null
        ? RouteData(
            pattern: currentPath,
            path: currentPath,
            fullPath: currentPath,
            name: 'current',
            params: const RouteParams(),
            isInitial: false,
            metadata: const {},
          )
        : null,
  );
}

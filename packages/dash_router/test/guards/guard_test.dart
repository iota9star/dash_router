// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:dash_router/dash_router.dart';

void main() {
  group('DashGuard', () {
    group('shouldRun', () {
      test('returns true for all routes when routes is null', () {
        final guard = _TestGuard();
        expect(guard.shouldRun('/home'), isTrue);
        expect(guard.shouldRun('/user/123'), isTrue);
        expect(guard.shouldRun('/any/path'), isTrue);
      });

      test('returns true only for matching routes', () {
        final guard = _TestGuard(routes: ['/home', '/user/*']);
        expect(guard.shouldRun('/home'), isTrue);
        expect(guard.shouldRun('/user/123'), isTrue);
        expect(guard.shouldRun('/settings'), isFalse);
      });

      test('respects excludeRoutes', () {
        final guard = _TestGuard(excludeRoutes: ['/public/**']);
        expect(guard.shouldRun('/home'), isTrue);
        expect(guard.shouldRun('/public'), isFalse);
        expect(guard.shouldRun('/public/docs'), isFalse);
      });

      test('excludeRoutes takes precedence over routes', () {
        final guard = _TestGuard(
          routes: ['/admin/**'],
          excludeRoutes: ['/admin/public'],
        );
        expect(guard.shouldRun('/admin/dashboard'), isTrue);
        expect(guard.shouldRun('/admin/public'), isFalse);
      });
    });

    group('GuardResult', () {
      test('GuardAllow is allowed', () {
        const result = GuardAllow();
        expect(result.isAllowed, isTrue);
      });

      test('GuardDeny is not allowed', () {
        const result = GuardDeny('Test reason');
        expect(result.isAllowed, isFalse);
        expect(result.reason, equals('Test reason'));
      });

      test('GuardRedirect is not allowed', () {
        const result = GuardRedirect('/login');
        expect(result.isAllowed, isFalse);
        expect(result.redirectTo, equals('/login'));
      });

      test('GuardRedirect can have query params', () {
        const result = GuardRedirect(
          '/login',
          queryParams: {'returnUrl': '/dashboard'},
        );
        expect(result.redirectTo, equals('/login'));
        expect(result.queryParams, equals({'returnUrl': '/dashboard'}));
      });
    });
  });

  group('FunctionalGuard', () {
    test('calls canActivate function', () async {
      var called = false;
      final guard = FunctionalGuard(
        canActivate: (context) async {
          called = true;
          return const GuardAllow();
        },
      );

      final context = _createGuardContext();
      await guard.canActivate(context);
      expect(called, isTrue);
    });

    test('supports routes configuration', () {
      final guard = FunctionalGuard(
        canActivate: (_) async => const GuardAllow(),
        routes: ['/protected/**'],
      );

      expect(guard.shouldRun('/protected/page'), isTrue);
      expect(guard.shouldRun('/public/page'), isFalse);
    });
  });

  group('ConditionalGuard', () {
    test('allows when condition is true', () async {
      final guard = ConditionalGuard(
        condition: () => true,
        redirectTo: '/login',
      );

      final result = await guard.canActivate(_createGuardContext());
      expect(result.isAllowed, isTrue);
    });

    test('redirects when condition is false', () async {
      final guard = ConditionalGuard(
        condition: () => false,
        redirectTo: '/login',
      );

      final result = await guard.canActivate(_createGuardContext());
      expect(result.isAllowed, isFalse);
      expect((result as GuardRedirect).redirectTo, equals('/login'));
    });
  });

  group('AsyncConditionalGuard', () {
    test('allows when async condition is true', () async {
      final guard = AsyncConditionalGuard(
        condition: () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return true;
        },
        redirectTo: '/login',
      );

      final result = await guard.canActivate(_createGuardContext());
      expect(result.isAllowed, isTrue);
    });

    test('redirects when async condition is false', () async {
      final guard = AsyncConditionalGuard(
        condition: () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return false;
        },
        redirectTo: '/login',
      );

      final result = await guard.canActivate(_createGuardContext());
      expect(result.isAllowed, isFalse);
    });
  });
}

class _TestGuard extends DashGuard {
  @override
  final List<String>? routes;

  @override
  final List<String>? excludeRoutes;

  _TestGuard({this.routes, this.excludeRoutes});

  @override
  Future<GuardResult> canActivate(GuardContext context) async {
    return const GuardAllow();
  }
}

GuardContext _createGuardContext({
  String targetPath = '/test',
  String? currentPath,
}) {
  return GuardContext(
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

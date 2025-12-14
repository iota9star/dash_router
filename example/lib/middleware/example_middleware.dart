// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print

import 'package:dash_router/dash_router.dart';

/// Example logging middleware demonstrating middleware functionality.
///
/// This middleware logs navigation events for debugging purposes.
/// In production, replace `print` with a proper logging framework.
///
/// **Note**: Renamed to avoid clashing with dash_router's built-in
/// `LoggingMiddleware`.
class ExampleLoggingMiddleware extends DashMiddleware {
  @override
  int get priority => 100;

  @override
  Future<MiddlewareResult> handle(MiddlewareContext context) async {
    print('Navigating to: ${context.targetRoute.path}');
    print('From: ${context.currentRoute?.path ?? 'initial'}');
    print('Params: ${context.targetRoute.params.all}');

    return const MiddlewareContinue();
  }

  @override
  Future<void> afterNavigation(MiddlewareContext context) async {
    print('Navigation completed to: ${context.targetRoute.path}');
  }
}

/// Example analytics middleware demonstrating tracking capabilities.
///
/// Tracks screen views and navigation timing for analytics purposes.
class AnalyticsMiddleware extends DashMiddleware {
  @override
  int get priority => 90;

  @override
  Future<MiddlewareResult> handle(MiddlewareContext context) async {
    _trackScreenView(context.targetRoute.name, context.targetRoute.params.all);
    return const MiddlewareContinue();
  }

  @override
  Future<void> afterNavigation(MiddlewareContext context) async {
    final duration = DateTime.now().difference(context.startTime);
    _trackNavigationTiming(context.targetRoute.name, duration);
  }

  void _trackScreenView(String screenName, Map<String, dynamic> params) {
    print('[Analytics] Screen view: $screenName');
    print('Params: $params');
  }

  void _trackNavigationTiming(String screenName, Duration duration) {
    print(
      '[Analytics] Navigation to $screenName took ${duration.inMilliseconds}ms',
    );
  }
}

/// Example rate limiting middleware demonstrating navigation throttling.
///
/// Prevents rapid successive navigations to avoid UI glitches and
/// accidental double-taps.
class RateLimitMiddleware extends DashMiddleware {
  /// Creates a rate limit middleware.
  ///
  /// [cooldown] specifies the minimum time between navigations.
  RateLimitMiddleware({this.cooldown = const Duration(milliseconds: 500)});

  /// The minimum time between allowed navigations.
  final Duration cooldown;

  DateTime? _lastNavigation;

  @override
  int get priority => 200; // High priority to run early

  @override
  Future<MiddlewareResult> handle(MiddlewareContext context) async {
    final now = DateTime.now();

    if (_lastNavigation != null) {
      final elapsed = now.difference(_lastNavigation!);
      if (elapsed < cooldown) {
        print('[RateLimit] Navigation blocked - too fast');
        return const MiddlewareAbort('Navigation rate limited');
      }
    }

    _lastNavigation = now;
    return const MiddlewareContinue();
  }

  @override
  Future<void> afterNavigation(MiddlewareContext context) async {
    // Nothing to do
  }
}

/// Example data prefetching middleware demonstrating data loading.
///
/// Prefetches required data before navigation completes, ensuring
/// the destination page has the data it needs.
class PrefetchMiddleware extends DashMiddleware {
  @override
  int get priority => 50;

  @override
  Future<MiddlewareResult> handle(MiddlewareContext context) async {
    final routeName = context.targetRoute.name;

    switch (routeName) {
      case 'userDetail':
        await _prefetchUserData(
          context.targetRoute.params.pathParams['id'],
        );
      case 'settings':
        await _prefetchSettings();
    }

    return const MiddlewareContinue();
  }

  @override
  Future<void> afterNavigation(MiddlewareContext context) async {
    // Nothing to do
  }

  Future<void> _prefetchUserData(String? userId) async {
    if (userId == null) return;
    print('[Prefetch] Loading user data for: $userId');
    // Simulate API call
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _prefetchSettings() async {
    print('[Prefetch] Loading settings');
    // Simulate API call
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

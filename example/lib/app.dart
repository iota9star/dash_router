// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dash_router/dash_router.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'generated/routes.dart';
import 'guards/auth_guard.dart';
import 'middleware/example_middleware.dart';

/// The main application widget.
///
/// Configures the [DashRouter] with routes, guards, and middleware,
/// and provides the [MaterialApp] with the router configuration.
class DashRouterExampleApp extends StatefulWidget {
  /// Creates the example application.
  const DashRouterExampleApp({super.key});

  @override
  State<DashRouterExampleApp> createState() => _DashRouterExampleAppState();
}

class _DashRouterExampleAppState extends State<DashRouterExampleApp> {
  late final DashRouter _router;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _router = _createRouter();
  }

  /// Creates and configures the [DashRouter] instance.
  DashRouter _createRouter() {
    final router = DashRouter(
      config: DashRouterOptions(
        initialPath: '/',
        debugLog: true,
        observers: [DebugObserver()],
      ),
      routes: generatedRoutes,
      redirects: generatedRedirects,
    );

    // Register guards
    router.guards.register(AuthGuard());

    // Register middleware
    router.middleware.registerAll([
      ExampleLoggingMiddleware(),
      AnalyticsMiddleware(),
      RateLimitMiddleware(),
      PrefetchMiddleware(),
    ]);

    return router;
  }

  /// Toggles between light and dark theme modes.
  void _toggleTheme() {
    setState(() {
      _themeMode = switch (_themeMode) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      themeMode: _themeMode,
      onThemeToggle: _toggleTheme,
      child: MaterialApp(
        title: 'Dash Router Example',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _themeMode,
        navigatorKey: _router.navigatorKey,
        initialRoute: _router.config.initialPath,
        onGenerateRoute: _router.generateRoute,
        navigatorObservers: [
          ...(_router.observers.all),
          ...(_router.config.observers),
        ],
      ),
    );
  }
}

/// Provides theme mode and toggle functionality to descendants.
class ThemeProvider extends InheritedWidget {
  /// Creates a theme provider.
  const ThemeProvider({
    required this.themeMode,
    required this.onThemeToggle,
    required super.child,
    super.key,
  });

  /// The current theme mode.
  final ThemeMode themeMode;

  /// Callback to toggle the theme.
  final VoidCallback onThemeToggle;

  /// Returns the nearest [ThemeProvider] from the given context.
  static ThemeProvider of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    assert(provider != null, 'No ThemeProvider found in context');
    return provider!;
  }

  /// Returns the nearest [ThemeProvider] from the given context, or null.
  static ThemeProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return themeMode != oldWidget.themeMode;
  }
}

/// Extension on [BuildContext] for easy access to theme provider.
extension ThemeProviderExtension on BuildContext {
  /// Returns the current [ThemeMode].
  ThemeMode get themeMode => ThemeProvider.of(this).themeMode;

  /// Toggles the theme mode.
  void toggleTheme() => ThemeProvider.of(this).onThemeToggle();

  /// Returns true if dark mode is active.
  bool get isDarkMode {
    final mode = ThemeProvider.maybeOf(this)?.themeMode ?? ThemeMode.system;
    if (mode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(this) == Brightness.dark;
    }
    return mode == ThemeMode.dark;
  }
}

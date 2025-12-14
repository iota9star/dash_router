// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dash_router/dash_router.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../core/utils/responsive_utils.dart';

/// A responsive shell that wraps all nested `/app/*` routes.
///
/// Adapts navigation based on screen size:
/// - **Compact** (< 600dp): Bottom navigation bar
/// - **Medium** (600-839dp): Navigation rail
/// - **Expanded** (>= 840dp): Permanent navigation drawer
///
/// Uses the unified `@DashRoute` annotation with `shell: true`.
@DashRoute(path: '/app', name: 'appShell', shell: true)
class AppShell extends StatelessWidget {
  /// The child widget from nested routes.
  final Widget child;

  /// Creates the app shell.
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveUtils.getScreenType(context);
    final currentIndex = _indexForPath(context.route.uri);

    return switch (screenType) {
      ScreenType.compact => _buildCompactLayout(context, currentIndex),
      ScreenType.medium => _buildMediumLayout(context, currentIndex),
      _ => _buildExpandedLayout(context, currentIndex),
    };
  }

  /// Builds layout for compact screens with bottom navigation.
  Widget _buildCompactLayout(BuildContext context, int currentIndex) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) =>
            _onDestinationSelected(context, index),
        destinations: _buildNavigationDestinations(),
      ),
    );
  }

  /// Builds layout for medium screens with navigation rail.
  Widget _buildMediumLayout(BuildContext context, int currentIndex) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) =>
                _onDestinationSelected(context, index),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Icon(
                Icons.route,
                size: 32,
                color: theme.colorScheme.primary,
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildThemeToggle(context),
                ),
              ),
            ),
            destinations: _buildRailDestinations(),
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: theme.colorScheme.outlineVariant,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  /// Builds layout for expanded screens with navigation drawer.
  Widget _buildExpandedLayout(BuildContext context, int currentIndex) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          NavigationDrawer(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) =>
                _onDestinationSelected(context, index),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.route,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Dash Router',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
                child: Divider(),
              ),
              ..._buildDrawerDestinations(),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildThemeToggle(context),
              ),
            ],
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: theme.colorScheme.outlineVariant,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  /// Builds navigation destinations for bottom navigation.
  List<NavigationDestination> _buildNavigationDestinations() {
    return const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore),
        label: 'Demo',
      ),
      NavigationDestination(
        icon: Icon(Icons.inventory_2_outlined),
        selectedIcon: Icon(Icons.inventory_2),
        label: 'Products',
      ),
      NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];
  }

  /// Builds navigation rail destinations.
  List<NavigationRailDestination> _buildRailDestinations() {
    return const [
      NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: Text('Home'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore),
        label: Text('Demo'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.inventory_2_outlined),
        selectedIcon: Icon(Icons.inventory_2),
        label: Text('Products'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: Text('Dashboard'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: Text('Settings'),
      ),
    ];
  }

  /// Builds navigation drawer destinations.
  List<Widget> _buildDrawerDestinations() {
    return const [
      NavigationDrawerDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: Text('Home'),
      ),
      NavigationDrawerDestination(
        icon: Icon(Icons.explore_outlined),
        selectedIcon: Icon(Icons.explore),
        label: Text('Demo'),
      ),
      NavigationDrawerDestination(
        icon: Icon(Icons.inventory_2_outlined),
        selectedIcon: Icon(Icons.inventory_2),
        label: Text('Products'),
      ),
      NavigationDrawerDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: Text('Dashboard'),
      ),
      NavigationDrawerDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: Text('Settings'),
      ),
    ];
  }

  /// Builds the theme toggle button.
  Widget _buildThemeToggle(BuildContext context) {
    final themeProvider = ThemeProvider.maybeOf(context);
    if (themeProvider == null) return const SizedBox.shrink();

    final icon = switch (themeProvider.themeMode) {
      ThemeMode.system => Icons.brightness_auto,
      ThemeMode.light => Icons.light_mode,
      ThemeMode.dark => Icons.dark_mode,
    };

    return IconButton(
      onPressed: themeProvider.onThemeToggle,
      icon: Icon(icon),
      tooltip: 'Toggle theme',
    );
  }

  /// Handles destination selection.
  void _onDestinationSelected(BuildContext context, int index) {
    final paths = [
      '/app/home',
      '/app/demo',
      '/app/products',
      '/app/dashboard',
      '/app/settings',
    ];
    if (index >= 0 && index < paths.length) {
      DashRouter.of(context).pushNamed(paths[index]);
    }
  }

  /// Returns the current navigation index based on path.
  int _indexForPath(String path) {
    if (path.startsWith('/app/demo')) return 1;
    if (path.startsWith('/app/products')) return 2;
    if (path.startsWith('/app/dashboard')) return 3;
    if (path.startsWith('/app/settings')) return 4;
    return 0;
  }
}

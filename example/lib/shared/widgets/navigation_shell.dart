// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dash_router/dash_router.dart';
import 'package:flutter/material.dart';

import '../../core/utils/responsive_utils.dart';
import 'adaptive_scaffold.dart';

/// A shell widget that provides navigation for nested routes.
///
/// This widget wraps the router's nested navigation with a responsive
/// navigation shell that shows different navigation patterns based on
/// screen size.
///
/// ## Example
///
/// ```dart
/// NavigationShell(
///   navigationKey: GlobalKey<NavigatorState>(),
///   selectedIndex: 0,
///   onDestinationSelected: (index) {
///     switch (index) {
///       case 0:
///         context.pushHomePage();
///       case 1:
///         context.pushSettingsPage();
///     }
///   },
///   destinations: [
///     AdaptiveDestination(icon: Icons.home, label: 'Home'),
///     AdaptiveDestination(icon: Icons.settings, label: 'Settings'),
///   ],
///   child: child,
/// )
/// ```
class NavigationShell extends StatelessWidget {
  /// Creates a navigation shell.
  const NavigationShell({
    required this.navigationKey,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.child,
    this.title,
    this.actions,
    this.leading,
    this.floatingActionButton,
    super.key,
  });

  /// The key for the nested navigator.
  final GlobalKey<NavigatorState> navigationKey;

  /// The currently selected destination index.
  final int selectedIndex;

  /// Called when a destination is selected.
  final ValueChanged<int> onDestinationSelected;

  /// The navigation destinations.
  final List<AdaptiveDestination> destinations;

  /// The child widget (typically from router outlet).
  final Widget child;

  /// Optional title for the app bar.
  final String? title;

  /// Optional actions for the app bar.
  final List<Widget>? actions;

  /// Optional leading widget for the app bar.
  final Widget? leading;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveUtils.getScreenType(context);
    final showAppBar =
        screenType == ScreenType.compact || screenType == ScreenType.medium;

    return AdaptiveScaffold(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations,
      appBar: showAppBar && title != null
          ? AppBar(
              title: Text(title!),
              leading: leading,
              actions: actions,
              centerTitle: false,
            )
          : null,
      leadingExtended: !showAppBar ? _buildLeadingExtended(context) : null,
      trailingNavigation: _buildTrailingNavigation(context),
      floatingActionButton: floatingActionButton,
      body: child,
    );
  }

  /// Builds the leading widget for extended navigation drawer.
  Widget _buildLeadingExtended(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
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
    );
  }

  /// Builds the trailing widget for navigation.
  Widget? _buildTrailingNavigation(BuildContext context) {
    return null; // Can be customized later
  }
}

/// A navigation shell page that uses the current route state.
///
/// This is a convenience widget that automatically determines the
/// selected index based on the current route path.
class RouteAwareNavigationShell extends StatelessWidget {
  /// Creates a route-aware navigation shell.
  const RouteAwareNavigationShell({
    required this.navigationKey,
    required this.destinations,
    required this.routes,
    required this.child,
    this.title,
    this.actions,
    this.leading,
    this.floatingActionButton,
    super.key,
  });

  /// The key for the nested navigator.
  final GlobalKey<NavigatorState> navigationKey;

  /// The navigation destinations.
  final List<AdaptiveDestination> destinations;

  /// The route paths corresponding to each destination.
  final List<String> routes;

  /// The child widget (typically from router outlet).
  final Widget child;

  /// Optional title for the app bar.
  final String? title;

  /// Optional actions for the app bar.
  final List<Widget>? actions;

  /// Optional leading widget for the app bar.
  final Widget? leading;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final currentPath = context.route.uri;
    final selectedIndex = _findSelectedIndex(currentPath);

    return NavigationShell(
      navigationKey: navigationKey,
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        if (index >= 0 && index < routes.length) {
          DashRouter.of(context).pushNamed(routes[index]);
        }
      },
      destinations: destinations,
      title: title,
      actions: actions,
      leading: leading,
      floatingActionButton: floatingActionButton,
      child: child,
    );
  }

  /// Finds the selected index based on the current path.
  int _findSelectedIndex(String currentPath) {
    for (int i = 0; i < routes.length; i++) {
      if (currentPath.startsWith(routes[i])) {
        return i;
      }
    }
    return 0;
  }
}

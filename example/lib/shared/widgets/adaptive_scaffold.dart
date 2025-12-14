// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../core/utils/responsive_utils.dart';

/// An adaptive scaffold that adjusts its layout based on screen size.
///
/// On compact screens, it shows a standard [Scaffold] with a bottom navigation bar.
/// On medium screens, it shows a [NavigationRail].
/// On expanded and larger screens, it shows a permanent [NavigationDrawer].
///
/// ## Example
///
/// ```dart
/// AdaptiveScaffold(
///   selectedIndex: 0,
///   onDestinationSelected: (index) => setState(() => _index = index),
///   destinations: [
///     AdaptiveDestination(
///       icon: Icons.home_outlined,
///       selectedIcon: Icons.home,
///       label: 'Home',
///     ),
///     AdaptiveDestination(
///       icon: Icons.settings_outlined,
///       selectedIcon: Icons.settings,
///       label: 'Settings',
///     ),
///   ],
///   body: pages[_index],
/// )
/// ```
class AdaptiveScaffold extends StatelessWidget {
  /// Creates an adaptive scaffold.
  const AdaptiveScaffold({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.leadingExtended,
    this.trailingNavigation,
    this.navigationRailLabelType = NavigationRailLabelType.all,
    this.useDrawer = true,
    super.key,
  });

  /// The currently selected destination index.
  final int selectedIndex;

  /// Called when a destination is selected.
  final ValueChanged<int> onDestinationSelected;

  /// The navigation destinations.
  final List<AdaptiveDestination> destinations;

  /// The main content body.
  final Widget body;

  /// Optional app bar for compact screens.
  final PreferredSizeWidget? appBar;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  /// Location of the floating action button.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Optional widget to show above navigation in extended mode.
  final Widget? leadingExtended;

  /// Optional widget to show below navigation items.
  final Widget? trailingNavigation;

  /// Label type for navigation rail.
  final NavigationRailLabelType navigationRailLabelType;

  /// Whether to use a navigation drawer on expanded screens.
  /// If false, uses navigation rail on expanded screens too.
  final bool useDrawer;

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveUtils.getScreenType(context);

    return switch (screenType) {
      ScreenType.compact => _buildCompactLayout(context),
      ScreenType.medium => _buildMediumLayout(context),
      _ =>
        useDrawer ? _buildExpandedLayout(context) : _buildMediumLayout(context),
    };
  }

  /// Builds layout for compact screens with bottom navigation.
  Widget _buildCompactLayout(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon ?? d.icon),
                label: d.label,
                tooltip: d.tooltip,
              ),
            )
            .toList(),
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  /// Builds layout for medium screens with navigation rail.
  Widget _buildMediumLayout(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: navigationRailLabelType,
            leading: leadingExtended,
            trailing: trailingNavigation != null
                ? Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: trailingNavigation,
                    ),
                  )
                : null,
            destinations: destinations
                .map(
                  (d) => NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon ?? d.icon),
                    label: Text(d.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }

  /// Builds layout for expanded screens with navigation drawer.
  Widget _buildExpandedLayout(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Row(
        children: [
          NavigationDrawer(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            children: [
              if (leadingExtended != null) ...[
                leadingExtended!,
                const SizedBox(height: 16),
              ],
              ...destinations.asMap().entries.map(
                    (entry) => NavigationDrawerDestination(
                      icon: Icon(entry.value.icon),
                      selectedIcon: Icon(
                        entry.value.selectedIcon ?? entry.value.icon,
                      ),
                      label: Text(entry.value.label),
                    ),
                  ),
              if (trailingNavigation != null) ...[
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: trailingNavigation,
                ),
              ],
            ],
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: colorScheme.outlineVariant,
          ),
          Expanded(
            child: Column(
              children: [
                if (appBar != null) appBar!,
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

/// A navigation destination for [AdaptiveScaffold].
class AdaptiveDestination {
  /// Creates an adaptive destination.
  const AdaptiveDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.tooltip,
  });

  /// The icon to display.
  final IconData icon;

  /// The icon to display when selected.
  final IconData? selectedIcon;

  /// The label for the destination.
  final String label;

  /// Optional tooltip text.
  final String? tooltip;
}

// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dash_router/dash_router.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../generated/routes.dart';
import '../shared/transition/transition.dart';

/// Settings page demonstrating custom transitions and route info.
///
/// This page uses a [CupertinoTransition] for iOS-style slide animation.
/// It also demonstrates access to route information via `context.route`.
@DashRoute(
  path: '/app/settings',
  name: 'settings',
  parent: '/app',
  transition: SlideScaleTransition(),
)
class SettingsPage extends StatelessWidget {
  /// Creates the settings page.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.maybeOf(context);
    final themeModeName = switch (themeProvider?.themeMode) {
      ThemeMode.system => 'System',
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      null => 'System',
    };

    return ListView(
      children: [
        _buildSection(
          context,
          title: 'General',
          children: [
            _SettingsTile(
              icon: Icons.palette,
              title: 'Theme',
              subtitle: themeModeName,
              onTap: themeProvider?.onThemeToggle,
            ),
            _SettingsTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English',
              onTap: () {},
            ),
          ],
        ),
        _buildSection(
          context,
          title: 'Navigation Settings',
          children: [
            _SettingsTile(
              icon: Icons.animation,
              title: 'Default Transition',
              subtitle: 'Material',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.timer,
              title: 'Transition Duration',
              subtitle: '300ms',
              onTap: () {},
            ),
          ],
        ),
        _buildSection(
          context,
          title: 'Route Demo (Type-Safe Navigation)',
          children: [
            _SettingsTile(
              icon: Icons.home,
              title: 'Go to Home',
              subtitle: 'Using: AppHomeRoute()',
              onTap: () => context.replace(const AppHomeRoute()),
            ),
            _SettingsTile(
              icon: Icons.person,
              title: 'View Random User',
              subtitle: 'Using: AppUser\$IdRoute(id: ...)',
              onTap: () {
                final randomId = DateTime.now().millisecondsSinceEpoch % 1000;
                context.push(AppUser$IdRoute(id: randomId.toString()));
              },
            ),
            _SettingsTile(
              icon: Icons.explore,
              title: 'Full Demo Page',
              subtitle: 'Using: AppDemoRoute()',
              onTap: () => context.push(const AppDemoRoute()),
            ),
            _SettingsTile(
              icon: Icons.swap_horizontal_circle,
              title: 'Replace with Home',
              subtitle: 'Using: context.replaceWithAppHome()',
              onTap: () => context.replaceWithAppHome(),
            ),
          ],
        ),
        _buildSection(
          context,
          title: 'Route Info (context.route)',
          children: [
            _InfoTile(label: 'URI', value: context.route.uri),
            _InfoTile(label: 'Name', value: context.route.name),
            _InfoTile(label: 'Pattern', value: context.route.pattern),
            _InfoTile(label: 'Full Path', value: context.route.fullPath),
            _InfoTile(
              label: 'Previous',
              value: context.route.previousPath ?? 'none',
            ),
            _InfoTile(
              label: 'Can Go Back',
              value: context.route.canGoBack.toString(),
            ),
          ],
        ),
        _buildSection(
          context,
          title: 'About Dash Router',
          children: [
            const _SettingsTile(
              icon: Icons.info,
              title: 'Version',
              subtitle: '1.0.0',
              onTap: null,
            ),
            _SettingsTile(
              icon: Icons.code,
              title: 'Source Code',
              subtitle: 'View on GitHub',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(label),
      trailing: Text(
        value,
        style: TextStyle(
          fontFamily: 'monospace',
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }
}

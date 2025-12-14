// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:dash_router/dash_router.dart';

import '../shared/user_data.dart';
import '../shared/product.dart';
import '../generated/routes.dart';

/// Home page (nested under `/app`).
///
/// This page serves as the main entry point of the application
/// and demonstrates various navigation patterns:
///
/// - Type-safe navigation with typed routes
/// - Query parameters for filtering/pagination
/// - Body parameters for complex data
/// - Generated extension methods
/// - Different navigation stack operations
@DashRoute(path: '/app/home', name: 'home', parent: '/app')
class HomePage extends StatelessWidget {
  /// Creates the home page.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        _buildRouteSection(context),
        const SizedBox(height: 24),
        _buildFeatureSection(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Dash Router',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'A type-safe, user-friendly Flutter routing library with zero mental overhead.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Navigation Examples',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        // Type-safe navigation - Recommended!
        _NavButton(
          title: 'View User 123 (Type-Safe ✓)',
          subtitle: 'Using: AppUser\$IdRoute(id: "123")',
          onTap: () => context.push(
            const AppUser$IdRoute(id: '123'),
          ),
        ),

        // Type-safe with query params
        _NavButton(
          title: 'View User 456 (Profile Tab)',
          subtitle: 'Using: AppUser\$IdRoute(id: "456", tab: "profile")',
          onTap: () => context.push(
            const AppUser$IdRoute(id: '456', tab: 'profile'),
          ),
        ),

        // Type-safe with body param
        _NavButton(
          title: 'View User 789 (with UserData)',
          subtitle:
              'Using: AppUser\$IdRoute(id: "789", userData: UserData(...))',
          onTap: () => context.push(
            const AppUser$IdRoute(
              id: '789',
              userData: UserData(id: '789', displayName: 'Jane Doe'),
            ),
          ),
        ),

        // Order page with simplified navigation method
        _NavButton(
          title: 'Order Page (Record Body)',
          subtitle: 'Using: context.push(AppOrderRoute(...))',
          onTap: () => context.push(
            const AppOrderRoute(
              userData: UserData(id: '123', displayName: 'John Doe'),
              product: Product(
                id: 'P001',
                name: 'Flutter Book',
                price: 29.99,
              ),
            ),
          ),
        ),

        // Product list - static route example
        _NavButton(
          title: 'Product List (Static Route)',
          subtitle: 'Using: context.pushAppProducts()',
          onTap: () => context.pushAppProducts(),
        ),

        // Dashboard - nested routes example
        _NavButton(
          title: 'Dashboard (Nested Routes)',
          subtitle: 'Using: context.pushAppDashboard()',
          onTap: () => context.pushAppDashboard(),
        ),

        // Search - static/dynamic conflict example
        _NavButton(
          title: 'Search (Static vs Dynamic)',
          subtitle: 'Routes.appSearch vs Routes.appSearchQuery',
          onTap: () => context.pushAppSearch(),
        ),

        // Generated navigation method
        _NavButton(
          title: 'Navigate using Extension',
          subtitle: 'Using: context.pushAppUser\$Id(id: "500")',
          onTap: () => context.pushAppUser$Id(
            id: '500',
            tab: 'followers',
          ),
        ),

        // Navigate to settings
        _NavButton(
          title: 'Settings (Type-Safe)',
          subtitle: 'Using: AppSettingsRoute()',
          onTap: () => context.push(const AppSettingsRoute()),
        ),

        // Navigate to demo
        _NavButton(
          title: 'Full Demo Page',
          subtitle: 'See all navigation patterns',
          onTap: () => context.push(const AppDemoRoute()),
        ),
      ],
    );
  }

  Widget _buildFeatureSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Features', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        const _FeatureCard(
          icon: Icons.speed,
          title: 'O(1) Parameter Access',
          description: 'Instant access to route parameters via caching',
        ),
        const _FeatureCard(
          icon: Icons.security,
          title: 'Type-Safe Navigation',
          description: 'Complete type inference with no mental overhead',
        ),
        const _FeatureCard(
          icon: Icons.animation,
          title: 'Custom Transitions',
          description: 'Built-in Material, Cupertino, and custom animations',
        ),
        const _FeatureCard(
          icon: Icons.shield,
          title: 'Route Guards',
          description: 'Protect routes with authentication guards',
        ),
        const _FeatureCard(
          icon: Icons.layers,
          title: 'Middleware Support',
          description: 'Add cross-cutting concerns to route navigation',
        ),
        const _FeatureCard(
          icon: Icons.code,
          title: 'Record Body Types',
          description: 'Use (Type1, Type2) Record for complex body params',
        ),
        const _FeatureCard(
          icon: Icons.bolt,
          title: 'Simplified Navigation',
          description:
              'context.pushXxx(), replaceWithXxx(), clearStackAndPushXxx()',
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavButton({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}

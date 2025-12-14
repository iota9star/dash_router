import 'package:flutter/material.dart';
import 'package:dash_router/dash_router.dart';

import '../shared/user_data.dart';
import '../shared/product.dart';
import '../shared/shipping_info.dart';

// Import generated routes for type-safe navigation
import '../generated/routes.dart';

/// Demonstrates all navigation patterns in dash_router
///
/// This page shows:
/// 1. Type-safe navigation with generated route classes
/// 2. String-based navigation (traditional)
/// 3. Path parameters
/// 4. Query parameters
/// 5. Body parameters (non-serializable objects)
/// 6. Custom transitions
/// 7. Navigation with results
@DashRoute(
  path: '/app/demo',
  name: 'navigationDemo',
  parent: '/app',
)
class NavigationDemoPage extends StatelessWidget {
  const NavigationDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: '1. Type-Safe Navigation (Recommended)',
            description: 'Use generated route classes for compile-time safety',
            children: [
              _DemoButton(
                title: 'Type-Safe Navigation',
                code: '''
context.push(AppUser\$IdRoute(
  id: '42',
  tab: 'posts',
));''',
                onTap: () => context.push(
                  const AppUser$IdRoute(
                    id: '42',
                    tab: 'posts',
                  ),
                ),
              ),
              _DemoButton(
                title: 'With Body Parameter',
                code: '''
context.push(AppUser\$IdRoute(
  id: '100',
  userData: UserData(id: '100', displayName: 'Alice'),
));''',
                onTap: () => context.push(
                  const AppUser$IdRoute(
                    id: '100',
                    userData: UserData(id: '100', displayName: 'Alice'),
                  ),
                ),
              ),
            ],
          ),
          _buildSection(
            context,
            title: '2. Generated Navigation Methods',
            description: 'Extension methods on BuildContext',
            children: [
              _DemoButton(
                title: 'Using pushAppUser\$Id()',
                code: '''
context.pushAppUser\$Id(
  id: '200',
  tab: 'followers',
);''',
                onTap: () => context.pushAppUser$Id(
                  id: '200',
                  tab: 'followers',
                ),
              ),
              _DemoButton(
                title: 'Replace Current Route',
                code: '''
context.replaceWithAppSettings();''',
                onTap: () => context.replaceWithAppSettings(),
              ),
            ],
          ),
          _buildSection(
            context,
            title: '3. String-Based Navigation',
            description: 'Traditional path-based navigation with pushNamed',
            children: [
              _DemoButton(
                title: 'Simple Path',
                code: "context.pushNamed('/app/settings');",
                onTap: () => context.pushNamed('/app/settings'),
              ),
              _DemoButton(
                title: 'With Path Parameters',
                code: "context.pushNamed('/app/user/999');",
                onTap: () => context.pushNamed('/app/user/999'),
              ),
              _DemoButton(
                title: 'With Query Parameters',
                code: '''
context.pushNamed(
  '/app/user/123',
  query: {'tab': 'profile'},
);''',
                onTap: () => context.pushNamed(
                  '/app/user/123',
                  query: {'tab': 'profile'},
                ),
              ),
              _DemoButton(
                title: 'With Body Data',
                code: '''
context.pushNamed(
  '/app/user/456',
  body: {
    'userData': UserData(id: '456', displayName: 'Bob'),
  },
);''',
                onTap: () => context.pushNamed(
                  '/app/user/456',
                  body: {
                    'userData': const UserData(id: '456', displayName: 'Bob'),
                  },
                ),
              ),
            ],
          ),
          _buildSection(
            context,
            title: '4. Custom Transitions',
            description: 'Override default transition per-navigation',
            children: [
              _DemoButton(
                title: 'Slide from Right',
                code: '''
context.pushNamed(
  '/app/settings',
  transition: DashSlideTransition.right(),
);''',
                onTap: () => context.pushNamed(
                  '/app/settings',
                  transition: const DashSlideTransition.right(),
                ),
              ),
              _DemoButton(
                title: 'Fade Transition',
                code: '''
context.pushNamed(
  '/app/settings',
  transition: DashFadeTransition(),
);''',
                onTap: () => context.pushNamed(
                  '/app/settings',
                  transition: const DashFadeTransition(),
                ),
              ),
              _DemoButton(
                title: 'Scale Transition',
                code: '''
context.pushNamed(
  '/app/settings',
  transition: DashScaleTransition(),
);''',
                onTap: () => context.pushNamed(
                  '/app/settings',
                  transition: const DashScaleTransition(),
                ),
              ),
            ],
          ),
          _buildSection(
            context,
            title: '5. Navigation History',
            description: 'Navigate back, replace, pop and push',
            children: [
              _DemoButton(
                title: 'Go Back',
                code: 'context.pop();',
                onTap: () => context.pop(),
              ),
              _DemoButton(
                title: 'Pop and Push',
                code: '''
context.popAndPushNamed('/app/home');''',
                onTap: () => context.popAndPushNamed('/app/home'),
              ),
              _DemoButton(
                title: 'Replace Current',
                code: '''
context.replaceNamed('/app/settings');''',
                onTap: () => context.replaceNamed('/app/settings'),
              ),
            ],
          ),
          _buildSection(
            context,
            title: '6. Complex Multi-Parameter Routes',
            description: 'Routes with multiple path parameters',
            children: [
              _DemoButton(
                title: 'Catalog Item (3 params)',
                code: '''
context.push(AppCatalog\$Category\$Subcategory\$ItemIdRoute(
  category: 'electronics',
  subcategory: 'phones',
  itemId: 'iphone-15',
  sort: 'price',
));''',
                onTap: () => context.push(
                  const AppCatalog$Category$Subcategory$ItemIdRoute(
                    category: 'electronics',
                    subcategory: 'phones',
                    itemId: 'iphone-15',
                    sort: 'price',
                  ),
                ),
              ),
            ],
          ),
          _buildSection(
            context,
            title: '7. Nested Shell Navigation',
            description: 'Navigate to nested admin shell',
            children: [
              _DemoButton(
                title: 'Admin Users',
                code: '''
context.push(AppAdminUsersRoute());''',
                onTap: () => context.push(const AppAdminUsersRoute()),
              ),
              _DemoButton(
                title: 'Admin Settings',
                code: '''
context.push(AppAdminSettingsRoute());''',
                onTap: () => context.push(const AppAdminSettingsRoute()),
              ),
            ],
          ),
          _buildSection(
            context,
            title: '8. Fullscreen Dialog Routes',
            description: 'Routes that behave as modal dialogs',
            children: [
              _DemoButton(
                title: 'Edit Profile (Fullscreen Dialog)',
                code: '''
// Route definition:
@DashRoute(
  path: '/app/edit-profile',
  fullscreenDialog: true,
  transition: DashSlideTransition.bottom(),
)
class EditProfilePage extends StatelessWidget { ... }

// Navigation:
context.push(AppEditProfileRoute());''',
                onTap: () => context.push(const AppEditProfileRoute()),
              ),
            ],
          ),
          _buildSection(
            context,
            title: '9. Complex Body Parameters',
            description: 'Record types with multiple elements',
            children: [
              _DemoButton(
                title: 'Checkout (3-element Record)',
                code: '''
context.push(AppCheckoutRoute(
  userData: UserData(...),
  product: Product(...),
  shippingInfo: ShippingInfo(...),
));''',
                onTap: () => context.push(
                  const AppCheckoutRoute(
                    userData: UserData(id: '1', displayName: 'John'),
                    product: Product(
                      id: 'prod-1',
                      name: 'Widget Pro',
                      price: 99.99,
                    ),
                    shippingInfo: ShippingInfo(
                      address: '123 Main St',
                      city: 'San Francisco',
                      zipCode: '94102',
                      method: 'express',
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildRouteInfoCard(context),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildRouteInfoCard(BuildContext context) {
    final route = context.route;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Route Info',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            _InfoRow(label: 'URI', value: route.uri),
            _InfoRow(label: 'Name', value: route.name),
            _InfoRow(label: 'Pattern', value: route.pattern),
            _InfoRow(label: 'Can Go Back', value: route.canGoBack.toString()),
            _InfoRow(
              label: 'Previous Path',
              value: route.previousPath ?? 'none',
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  final String title;
  final String code;
  final VoidCallback onTap;

  const _DemoButton({
    required this.title,
    required this.code,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Icon(
                    Icons.play_arrow,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  code,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

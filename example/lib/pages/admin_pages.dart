import 'package:flutter/material.dart';
import 'package:dash_router/dash_router.dart';

import '../generated/routes.dart';

/// Admin shell demonstrating deep nested shell routes.
///
/// This shell creates a secondary navigation level within the main app shell:
/// - `/app` (main shell)
///   - `/app/admin` (admin shell - this)
///     - `/app/admin/users` (users list)
///     - `/app/admin/users/:userId` (user detail)
///     - `/app/admin/settings` (admin settings)
///
/// ## Features Demonstrated
///
/// - Nested shell routes (shell within a shell)
/// - Independent navigation within nested shell
/// - State preservation across navigation
/// - Breadcrumb navigation pattern
@DashRoute(
  path: '/app/admin',
  name: 'adminShell',
  parent: '/app',
  shell: true,
)
class AdminShell extends StatefulWidget {
  /// Child widget to display in the admin area
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Admin sidebar
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
              switch (index) {
                case 0:
                  context.push(const AppAdminUsersRoute());
                  break;
                case 1:
                  context.push(const AppAdminSettingsRoute());
                  break;
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          // Admin content area
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

/// Admin users list page within the admin shell.
@DashRoute(
  path: '/app/admin/users',
  name: 'adminUsers',
  parent: '/app/admin',
)
class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final route = context.route;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Users'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Route info header
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Text('Route: ${route.pattern}'),
                const Spacer(),
                Text('Name: ${route.name}'),
              ],
            ),
          ),
          // User list
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                final userId = 'user-${index + 1}';
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text('User $userId'),
                  subtitle: Text('user$userId@example.com'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(
                    AppAdminUsers$UserIdRoute(userId: userId),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Admin user detail page with path parameter.
@DashRoute(
  path: '/app/admin/users/:userId',
  name: 'adminUserDetail',
  parent: '/app/admin',
  transition: DashSlideTransition.right(),
)
class AdminUserDetailPage extends StatelessWidget {
  /// User ID path parameter
  final String userId;

  const AdminUserDetailPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final route = context.route;

    return Scaffold(
      appBar: AppBar(
        title: Text('User: $userId'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'User ID',
                      value: route.path.get<String>('userId'),
                    ),
                    _InfoRow(label: 'Route Pattern', value: route.pattern),
                    _InfoRow(label: 'Full Path', value: route.fullPath),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Users'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Admin settings page within the admin shell.
@DashRoute(
  path: '/app/admin/settings',
  name: 'adminSettings',
  parent: '/app/admin',
)
class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final route = context.route;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Text('Route: ${route.pattern}'),
                const Spacer(),
                Text('Name: ${route.name}'),
              ],
            ),
          ),
          const ListTile(
            leading: Icon(Icons.security),
            title: Text('Security Settings'),
            subtitle: Text('Manage security options'),
          ),
          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            subtitle: Text('Configure admin notifications'),
          ),
          const ListTile(
            leading: Icon(Icons.backup),
            title: Text('Backup'),
            subtitle: Text('System backup settings'),
          ),
        ],
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
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

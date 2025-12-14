import 'package:dash_router_example/guards/auth_guard.dart';
import 'package:flutter/material.dart';
import 'package:dash_router/dash_router.dart';

import '../shared/user_data.dart';
// Import generated routes for type-safe navigation and params
import '../generated/routes.dart';

/// User detail page with path and query parameters
///
/// Demonstrates the new API design:
/// - `context.route` - get route info
/// - `route.userDetailPath.userId` - typed path param access
/// - `route.userDetailQuery.initialTab` - typed query param access
@DashRoute(
  path: '/app/user/:id',
  name: 'userDetail',
  parent: '/app',
  guards: [AuthGuard()],
  transition: DashSlideTransition.right(),
)
class UserPage extends StatefulWidget {
  /// User ID from path parameter - automatically inferred from :id in route path
  final String id;

  /// Initial tab from query parameter - automatically inferred from constructor
  final String? tab;

  /// Example of a non-serializable body param - automatically inferred from constructor
  final UserData? userData;

  const UserPage({
    super.key,
    required this.id,
    this.tab,
    this.userData,
  });

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['overview', 'posts', 'followers'];

  @override
  void initState() {
    super.initState();
    final initialIndex = _tabs.indexOf(widget.tab ?? 'overview');
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // THE MAIN API: Access route info via context.route
    final route = context.route;

    return Scaffold(
      appBar: AppBar(
        title: Text('User ${widget.id}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Posts'),
            Tab(text: 'Followers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(
            userId: widget.id,
            route: route,
            userData: widget.userData,
          ),
          _PostsTab(userId: widget.id),
          _FollowersTab(userId: widget.id),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final String userId;
  final ScopedRouteInfo route;
  final UserData? userData;

  const _OverviewTab({
    required this.userId,
    required this.route,
    this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Text(
                      userId[0].toUpperCase(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData?.displayName ?? 'User $userId',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'user$userId@example.com',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Route info card - Demonstrates context.route API
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Route Info (context.route)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(label: 'Name', value: route.name),
                  _InfoRow(label: 'URI', value: route.uri),
                  _InfoRow(label: 'Pattern', value: route.pattern),
                  _InfoRow(label: 'Full Path', value: route.fullPath),
                  _InfoRow(
                      label: 'Previous', value: route.previousPath ?? 'None'),
                  _InfoRow(
                      label: 'Can Go Back', value: route.canGoBack.toString()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // NEW API: Typed params via extension on ScopedRouteInfo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type-safe Params (NEW API)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Extensions on ScopedRouteInfo provide typed accessors',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  // Using the generated extension API
                  _InfoRow(
                    label: 'route.path.id',
                    value: route.path.get<String>('id'),
                  ),
                  _InfoRow(
                    label: 'route.query.tab',
                    value: route.query.get<String?>('tab') ?? 'overview',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Generic params card - Demonstrates generic param access
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generic Params (Fallback API)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Works for any route without generated code',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: "route.path.get<String>('id')",
                    value: route.path.get<String>('id'),
                  ),
                  _InfoRow(
                    label: "route.query.get<String?>('tab')",
                    value: route.query.get<String?>('tab') ?? 'null',
                  ),
                  _InfoRow(
                    label: "route.body.get<UserData?>('userData')",
                    value: route.body.get<UserData?>('userData')?.displayName ??
                        'null',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Navigation actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Navigation Actions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Go Back'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => context.push(const AppSettingsRoute()),
                        icon: const Icon(Icons.settings),
                        label: const Text('Settings'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => context.replace(
                          const AppUser$IdRoute(id: '999'),
                        ),
                        icon: const Icon(Icons.swap_horiz),
                        label: const Text('User 999'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostsTab extends StatelessWidget {
  final String userId;

  const _PostsTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Text('${index + 1}'),
            ),
            title: Text('Post ${index + 1} by User $userId'),
            subtitle: Text(
              'This is a sample post content for post ${index + 1}',
            ),
          ),
        );
      },
    );
  }
}

class _FollowersTab extends StatelessWidget {
  final String userId;

  const _FollowersTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 20,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              child: Text('F${index + 1}'),
            ),
            title: Text('Follower ${index + 1}'),
            subtitle: const Text('Following since 2024'),
            trailing: TextButton(
              onPressed: () {
                // Type-safe navigation to another user
                context.push(
                  AppUser$IdRoute(id: (1000 + index).toString()),
                );
              },
              child: const Text('View'),
            ),
          ),
        );
      },
    );
  }
}

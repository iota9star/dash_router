import 'package:dash_router/dash_router.dart';
import 'package:flutter/material.dart';

import '../generated/routes.dart';

/// Search page demonstrating static vs dynamic route naming conflicts.
///
/// Routes in the example:
/// - `/app/search` → `Routes.appSearch` (static)
/// - `/app/search/:query` → `Routes.appSearchQuery` (dynamic)
///
/// When both exist, static routes get priority and dynamic gets unique name.
@DashRoute(
  path: '/app/search',
  name: 'search',
  parent: '/app',
)
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search query',
                hintText: 'Enter search term...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _controller.clear(),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.pushAppSearch$Query(query: value);
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                final query = _controller.text.trim();
                if (query.isNotEmpty) {
                  context.pushAppSearch$Query(query: query);
                }
              },
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),
            const SizedBox(height: 24),
            Text(
              'Quick Searches',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('Flutter'),
                  onPressed: () =>
                      context.pushAppSearch$Query(query: 'flutter'),
                ),
                ActionChip(
                  label: const Text('Dart'),
                  onPressed: () => context.pushAppSearch$Query(query: 'dart'),
                ),
                ActionChip(
                  label: const Text('Router'),
                  onPressed: () => context.pushAppSearch$Query(query: 'router'),
                ),
                ActionChip(
                  label: const Text('Navigation'),
                  onPressed: () =>
                      context.pushAppSearch$Query(query: 'navigation'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Search results page with dynamic query path param.
@DashRoute(
  path: '/app/search/:query',
  name: 'searchResults',
  parent: '/app',
)
class SearchResultsPage extends StatelessWidget {
  /// Path parameter - automatically inferred from :query in route path
  final String query;

  /// Query parameter - automatically inferred as primitive type not in path
  final String page;

  /// Query parameter - automatically inferred as primitive type not in path
  final String? filter;

  const SearchResultsPage({
    super.key,
    required this.query,
    this.page = '1',
    this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final route = context.route;
    final currentPage = int.tryParse(page) ?? 1;

    // Fake search results
    final results = List.generate(
      10,
      (i) => 'Result ${(currentPage - 1) * 10 + i + 1} for "$query"',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Search: $query'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              context.replaceWithAppSearch$Query(
                query: query,
                page: page,
                filter: value == 'all' ? null : value,
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'docs', child: Text('Documentation')),
              const PopupMenuItem(value: 'code', child: Text('Code')),
              const PopupMenuItem(value: 'issues', child: Text('Issues')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Route info
          Container(
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Page $page${filter != null ? ' • Filter: $filter' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Text(
                  route.uri,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),

          // Results list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${(currentPage - 1) * 10 + index + 1}'),
                    ),
                    title: Text(results[index]),
                    subtitle: Text('Found in ${filter ?? 'all'} category'),
                  ),
                );
              },
            ),
          ),

          // Pagination
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: currentPage > 1
                      ? () => context.replaceWithAppSearch$Query(
                            query: query,
                            page: (currentPage - 1).toString(),
                            filter: filter,
                          )
                      : null,
                ),
                for (var i = 1; i <= 3; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: currentPage == i
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        foregroundColor: currentPage == i
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      onPressed: () => context.replaceWithAppSearch$Query(
                        query: query,
                        page: i.toString(),
                        filter: filter,
                      ),
                      child: Text('$i'),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => context.replaceWithAppSearch$Query(
                    query: query,
                    page: (currentPage + 1).toString(),
                    filter: filter,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

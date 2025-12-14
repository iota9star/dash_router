import 'package:flutter/material.dart';
import 'package:dash_router/dash_router.dart';

import '../generated/routes.dart';

/// Catalog page demonstrating complex multi-parameter routing.
///
/// This page shows how to handle routes with multiple path parameters:
/// `/app/catalog/:category/:subcategory/:itemId`
///
/// Example routes:
/// - `/app/catalog/electronics/phones/iphone-15`
/// - `/app/catalog/clothing/shoes/nike-air-max`
///
/// ## Features Demonstrated
///
/// - Multiple path parameters (`:category`, `:subcategory`, `:itemId`)
/// - Query parameters for filtering and sorting
/// - Nested navigation within a shell
/// - Type-safe parameter access
@DashRoute(
  path: '/app/catalog/:category/:subcategory/:itemId',
  name: 'catalogItem',
  parent: '/app',
  transition: DashSlideTransition.right(),
)
class CatalogPage extends StatelessWidget {
  /// Category path parameter
  final String category;

  /// Subcategory path parameter
  final String subcategory;

  /// Item ID path parameter
  final String itemId;

  /// Optional sort query parameter
  final String? sort;

  /// Optional filter query parameter
  final String? filter;

  const CatalogPage({
    super.key,
    required this.category,
    required this.subcategory,
    required this.itemId,
    this.sort,
    this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final route = context.route;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog Item'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Path parameters card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Path Parameters',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Category',
                      value: route.path.get<String>('category'),
                    ),
                    _InfoRow(
                      label: 'Subcategory',
                      value: route.path.get<String>('subcategory'),
                    ),
                    _InfoRow(
                      label: 'Item ID',
                      value: route.path.get<String>('itemId'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Query parameters card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Query Parameters',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: 'Sort',
                      value: route.query.get<String?>('sort') ?? 'not set',
                    ),
                    _InfoRow(
                      label: 'Filter',
                      value: route.query.get<String?>('filter') ?? 'not set',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Route info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Route Info',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Name', value: route.name),
                    _InfoRow(label: 'Pattern', value: route.pattern),
                    _InfoRow(label: 'URI', value: route.uri),
                    _InfoRow(label: 'Full Path', value: route.fullPath),
                    _InfoRow(
                      label: 'Can Go Back',
                      value: route.canGoBack.toString(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Navigation demos
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Navigation Demos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () => context.push(
                            const AppCatalog$Category$Subcategory$ItemIdRoute(
                              category: 'electronics',
                              subcategory: 'phones',
                              itemId: 'samsung-s24',
                              sort: 'price',
                            ),
                          ),
                          child: const Text('Different Item'),
                        ),
                        ElevatedButton(
                          onPressed: () => context.push(
                            const AppCatalog$Category$Subcategory$ItemIdRoute(
                              category: 'clothing',
                              subcategory: 'shoes',
                              itemId: 'nike-air-max',
                              filter: 'in-stock',
                            ),
                          ),
                          child: const Text('Different Category'),
                        ),
                        ElevatedButton(
                          onPressed: () => context.pop(),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
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

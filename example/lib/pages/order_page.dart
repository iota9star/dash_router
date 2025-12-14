import 'package:dash_router/dash_router.dart';
import 'package:flutter/material.dart';

import '../shared/user_data.dart';
import '../shared/product.dart';
// Import generated route info for type-safe access
import '../generated/route_info/app_order.route.dart';

// Example of using arguments for Record type body params
// This allows const constructor while still receiving body arguments

/// Order page demonstrating const constructor with arguments Record.
///
/// With `arguments: [UserData, Product]`, you can:
/// 1. Use a const constructor without params
/// 2. Access body as a Record: `(UserData, Product)`
///
/// Generated extension on ScopedRouteInfo provides:
/// - `route.arguments` returns `(UserData, Product)` directly
@DashRoute(
  path: '/app/order',
  name: 'order',
  arguments: [UserData, Product], // Generates Record type (UserData, Product)
  transition: DashFadeTransition(),
)
class OrderPage extends StatelessWidget {
  const OrderPage({super.key}); // No params needed!

  @override
  Widget build(BuildContext context) {
    // Get route info via context.route (the main API)
    final route = context.route;

    // Access body as Record type using generated extension
    // The extension adds `arguments` getter on ScopedRouteInfo
    final (user, product) = route.arguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Page'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(label: 'Customer', value: user.displayName),
                    _InfoRow(label: 'Customer ID', value: user.id),
                    const Divider(),
                    _InfoRow(label: 'Product', value: product.name),
                    _InfoRow(label: 'Product ID', value: product.id),
                    _InfoRow(
                      label: 'Price',
                      value: '\$${product.price.toStringAsFixed(2)}',
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Code example card
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Code Example',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '''// Page annotation
@DashRoute(
  path: '/app/order',
  name: 'order',
  arguments: [UserData, Product],
)
class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access body as Record type
    final route = context.route;
    final (user, product) = route.arguments;
    
    return Text(user.displayName);
  }
}''',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions
            Center(
              child: ElevatedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
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
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

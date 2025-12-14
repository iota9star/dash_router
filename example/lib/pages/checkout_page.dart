import 'package:flutter/material.dart';
import 'package:dash_router/dash_router.dart';

import '../shared/user_data.dart';
import '../shared/product.dart';
import '../shared/shipping_info.dart';
import '../generated/route_info/app_checkout.route.dart';

/// Checkout page demonstrating complex body parameters.
///
/// This page shows how to handle routes with complex typed body arguments
/// using Record types: `(UserData, Product, ShippingInfo)`
///
/// ## Features Demonstrated
///
/// - Record type body parameters with 3 elements
/// - Type-safe access via generated `arguments` getter
/// - Complex object serialization in navigation
@DashRoute(
  path: '/app/checkout',
  name: 'checkout',
  parent: '/app',
  arguments: [UserData, Product, ShippingInfo],
  transition: DashSlideTransition.bottom(),
)
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final route = context.route;

    // Access complex body params using generated arguments
    final (user, product, shipping) = route.arguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 8),
                        Text(
                          'Customer',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Name', value: user.displayName),
                    _InfoRow(label: 'ID', value: user.id),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shopping_bag),
                        const SizedBox(width: 8),
                        Text(
                          'Product',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Name', value: product.name),
                    _InfoRow(label: 'ID', value: product.id),
                    _InfoRow(
                      label: 'Price',
                      value: '\$${product.price.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Shipping info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_shipping),
                        const SizedBox(width: 8),
                        Text(
                          'Shipping',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Address', value: shipping.address),
                    _InfoRow(label: 'City', value: shipping.city),
                    _InfoRow(label: 'ZIP', value: shipping.zipCode),
                    _InfoRow(label: 'Method', value: shipping.method),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Route info
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
                    _InfoRow(label: 'Pattern', value: route.pattern),
                    _InfoRow(label: 'Name', value: route.name),
                    _InfoRow(
                      label: 'Body Type',
                      value: '(UserData, Product, ShippingInfo)',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order placed!')),
                  );
                  context.pop();
                },
                icon: const Icon(Icons.check),
                label: const Text('Place Order'),
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
            width: 80,
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

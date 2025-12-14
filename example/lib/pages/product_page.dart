// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:dash_router/dash_router.dart';
import 'package:flutter/material.dart';

import '../shared/product.dart';
import '../generated/routes.dart';

/// Product list page demonstrating static routes priority.
///
/// Route priority example:
/// - `/app/products` (static) - this page
/// - `/app/products/:productId` (dynamic) - product detail
///
/// Static routes match before dynamic ones, ensuring:
/// - `/app/products` always shows the list
/// - `/app/products/P001` correctly matches the detail page
@DashRoute(
  path: '/app/products',
  name: 'productList',
  parent: '/app',
  transition: DashSlideTransition.right(),
)
class ProductListPage extends StatelessWidget {
  /// Creates the product list page.
  const ProductListPage({super.key});

  static final _products = [
    const Product(id: 'P001', name: 'Flutter Complete Guide', price: 49.99),
    const Product(id: 'P002', name: 'Dart Mastery', price: 39.99),
    const Product(id: 'P003', name: 'State Management Pro', price: 29.99),
    const Product(id: 'P004', name: 'UI/UX Design Patterns', price: 34.99),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(product.name[0]),
              ),
              title: Text(product.name),
              subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  context.pushAppProducts$ProductId(productId: product.id),
            ),
          );
        },
      ),
    );
  }
}

/// Product detail page with dynamic path parameter.
///
/// Demonstrates:
/// - **Path parameter**: `:productId` extracted from URL
/// - **Query parameters**: `highlight`, `referralCode` for optional data
/// - **Body parameter**: `product` for passing complex objects
///
/// ## Example URLs
///
/// - `/app/products/P001` - Basic product detail
/// - `/app/products/P001?highlight=true` - Highlighted product
/// - `/app/products/P001?referralCode=DASH2024` - With referral code
@DashRoute(
  path: '/app/products/:productId',
  name: 'productDetail',
  parent: '/app',
  transition: DashSlideTransition.right(),
)
class ProductDetailPage extends StatelessWidget {
  /// Path parameter - automatically inferred from `:productId` in route path.
  final String productId;

  /// Query parameter - controls product highlighting.
  final String highlight;

  /// Query parameter - optional referral tracking code.
  final String? referralCode;

  /// Body parameter - pre-fetched product data.
  final Product? product;

  /// Creates the product detail page.
  const ProductDetailPage({
    super.key,
    required this.productId,
    this.highlight = 'false',
    this.referralCode,
    this.product,
  });

  @override
  Widget build(BuildContext context) {
    final route = context.route;
    final isHighlighted = highlight == 'true';

    return Scaffold(
      appBar: AppBar(
        title: Text('Product $productId'),
        backgroundColor: isHighlighted
            ? Colors.amber
            : Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product info
            Card(
              color: isHighlighted
                  ? Colors.amber.shade50
                  : Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.name ?? 'Product $productId',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (product != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '\$${product!.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                    if (referralCode != null) ...[
                      const SizedBox(height: 8),
                      Chip(
                        label: Text('Referral: $referralCode'),
                        backgroundColor: Colors.green.shade100,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Route params display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Route Params',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'productId', value: productId),
                    _InfoRow(label: 'highlight', value: highlight),
                    _InfoRow(
                        label: 'referralCode', value: referralCode ?? 'null'),
                    _InfoRow(label: 'route.pattern', value: route.pattern),
                    _InfoRow(label: 'route.uri', value: route.uri),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Navigation actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.pushAppProducts$ProductId(
                    productId: 'P002',
                    highlight: 'true',
                  ),
                  icon: const Icon(Icons.highlight),
                  label: const Text('View P002 (Highlighted)'),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.pushAppProducts$ProductId(
                    productId: 'P003',
                    referralCode: 'DASH2024',
                  ),
                  icon: const Icon(Icons.card_giftcard),
                  label: const Text('P003 with Referral'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ],
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
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
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

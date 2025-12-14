// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Example product model for demonstrating complex parameters.
///
/// This model is used to demonstrate:
/// - Passing complex objects as body parameters
/// - Type-safe parameter handling with custom types
class Product {
  /// Creates a product.
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.categories = const [],
    this.metadata = const {},
  });

  /// Unique product identifier.
  final String id;

  /// Product display name.
  final String name;

  /// Product price.
  final double price;

  /// Product categories for filtering.
  final List<String> categories;

  /// Additional product metadata.
  final Map<String, dynamic> metadata;

  @override
  String toString() => 'Product($id: $name, \$$price)';
}

/// Shopping cart for demonstrating complex body parameters.
///
/// Shows how multiple products can be passed together.
class ShoppingCart {
  /// Creates a shopping cart.
  const ShoppingCart({
    this.items = const [],
    this.couponCode,
    this.discount = 0,
  });

  /// Items in the cart.
  final List<Product> items;

  /// Applied coupon code.
  final String? couponCode;

  /// Discount percentage (0.0 to 1.0).
  final double discount;

  /// Calculates the cart total after discount.
  double get total =>
      items.fold(0.0, (sum, item) => sum + item.price) * (1 - discount);

  @override
  String toString() =>
      'ShoppingCart(${items.length} items, total: \$${total.toStringAsFixed(2)})';
}

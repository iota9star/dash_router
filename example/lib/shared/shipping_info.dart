/// Shipping information model for checkout flow.
///
/// This class represents shipping details passed through route arguments.
///
/// ## Example
///
/// ```dart
/// const shipping = ShippingInfo(
///   address: '123 Main St',
///   city: 'San Francisco',
///   zipCode: '94102',
///   method: 'express',
/// );
/// ```
class ShippingInfo {
  /// Street address
  final String address;

  /// City name
  final String city;

  /// ZIP/Postal code
  final String zipCode;

  /// Shipping method (standard, express, overnight)
  final String method;

  /// Creates a new shipping info instance.
  const ShippingInfo({
    required this.address,
    required this.city,
    required this.zipCode,
    required this.method,
  });

  @override
  String toString() {
    return 'ShippingInfo(address: $address, city: $city, zipCode: $zipCode, method: $method)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShippingInfo &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          city == other.city &&
          zipCode == other.zipCode &&
          method == other.method;

  @override
  int get hashCode =>
      address.hashCode ^ city.hashCode ^ zipCode.hashCode ^ method.hashCode;
}

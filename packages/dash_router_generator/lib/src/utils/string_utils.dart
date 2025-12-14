/// Utility functions for string manipulation in code generation.
class StringUtils {
  StringUtils._();

  /// Convert a path pattern to a PascalCase identifier.
  ///
  /// Examples:
  /// - `/app/user/:id` -> `AppUser$Id`
  /// - `/app/settings` -> `AppSettings`
  /// - `/` -> `Root`
  ///
  /// Set [asPascalCase] to false to get camelCase output.
  static String pathToIdentifier(String path, {bool asPascalCase = true}) {
    if (path == '/') return asPascalCase ? 'Root' : 'root';

    final segments = path.split('/').where((s) => s.isNotEmpty);
    final parts = <String>[];

    for (final segment in segments) {
      if (segment.startsWith(':')) {
        // Dynamic parameter: `:id` -> `$Id`
        parts.add('\$${toPascalCase(segment.substring(1))}');
      } else {
        parts.add(toPascalCase(segment));
      }
    }

    final result = parts.join();
    if (!asPascalCase && result.isNotEmpty) {
      return result[0].toLowerCase() + result.substring(1);
    }
    return result;
  }

  /// Convert a string to PascalCase.
  ///
  /// Examples:
  /// - `user_settings` -> `UserSettings`
  /// - `user-settings` -> `UserSettings`
  /// - `userSettings` -> `UserSettings`
  static String toPascalCase(String input) {
    if (input.isEmpty) return input;

    // Split on underscores, hyphens, or camelCase boundaries
    final words = input
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (m) => '${m.group(1)}_${m.group(2)}',
        )
        .split(RegExp(r'[_\-\s]+'))
        .where((s) => s.isNotEmpty);

    return words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join();
  }

  /// Convert a string to camelCase.
  ///
  /// Examples:
  /// - `UserSettings` -> `userSettings`
  /// - `user_settings` -> `userSettings`
  static String toCamelCase(String input) {
    final pascal = toPascalCase(input);
    if (pascal.isEmpty) return pascal;
    return pascal[0].toLowerCase() + pascal.substring(1);
  }

  /// Convert a string to snake_case.
  ///
  /// Examples:
  /// - `UserSettings` -> `user_settings`
  /// - `userSettings` -> `user_settings`
  static String toSnakeCase(String input) {
    if (input.isEmpty) return input;

    return input
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (m) => '${m.group(1)}_${m.group(2)}',
        )
        .replaceAll(RegExp(r'[\-\s]+'), '_')
        .toLowerCase();
  }

  /// Generate a unique route class name from a path.
  ///
  /// Examples:
  /// - `/app/user/:id` -> `AppUser$IdRoute`
  /// - `/` -> `RootRoute`
  static String generateRouteClassName(String path) {
    return '${pathToIdentifier(path)}Route';
  }

  /// Generate a unique field name for a route, avoiding conflicts.
  static String generateRouteFieldName(
    String path,
    Set<String> existingNames,
  ) {
    var base = toCamelCase(pathToIdentifier(path));
    if (base.isEmpty) base = 'root';

    var name = base;
    var counter = 1;
    while (existingNames.contains(name)) {
      name = '$base$counter';
      counter++;
    }
    existingNames.add(name);
    return name;
  }

  /// Convert a type name to a field name (camelCase).
  ///
  /// Examples:
  /// - `UserData` -> `userData`
  /// - `Product` -> `product`
  /// - `ShippingInfo` -> `shippingInfo`
  static String typeNameToFieldName(String typeName) {
    if (typeName.isEmpty) return typeName;
    return typeName[0].toLowerCase() + typeName.substring(1);
  }
}

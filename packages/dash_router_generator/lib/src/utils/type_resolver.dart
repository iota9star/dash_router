import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';

/// Utility for resolving and working with types
class TypeResolver {
  /// Get the display string for a type, handling nullability
  static String getTypeString(DartType type) {
    return type.getDisplayString();
  }

  /// Get the non-nullable version of a type string
  static String getNonNullableTypeString(DartType type) {
    final displayString = type.getDisplayString();
    if (displayString.endsWith('?')) {
      return displayString.substring(0, displayString.length - 1);
    }
    return displayString;
  }

  /// Check if a type is nullable
  static bool isNullable(DartType type) {
    return type.nullabilitySuffix != NullabilitySuffix.none;
  }

  /// Check if a type is a primitive type
  static bool isPrimitive(DartType type) {
    return isPrimitiveString(type.getDisplayString());
  }

  /// Check if a type string represents a primitive type
  static bool isPrimitiveString(String typeString) {
    final baseType =
        typeString.replaceAll('?', '').replaceAll(RegExp(r'<.*>'), '');
    return const [
      'String',
      'int',
      'double',
      'num',
      'bool',
      'DateTime',
      'Duration',
      'Uri',
    ].contains(baseType);
  }

  /// Check if a type is a collection type
  static bool isCollection(DartType type) {
    final typeString = type.getDisplayString();
    return typeString.startsWith('List<') ||
        typeString.startsWith('Set<') ||
        typeString.startsWith('Map<');
  }

  /// Check if a type is a List
  static bool isList(DartType type) {
    return type.getDisplayString().startsWith('List<');
  }

  /// Check if a type is a Map
  static bool isMap(DartType type) {
    return type.getDisplayString().startsWith('Map<');
  }

  /// Get the element type of a List
  static String? getListElementType(DartType type) {
    if (!isList(type)) return null;
    final match = RegExp(r'List<(.+)>').firstMatch(type.getDisplayString());
    return match?.group(1);
  }

  /// Get the key and value types of a Map
  static (String?, String?) getMapTypes(DartType type) {
    if (!isMap(type)) return (null, null);
    final match = RegExp(
      r'Map<(.+),\s*(.+)>',
    ).firstMatch(type.getDisplayString());
    return (match?.group(1), match?.group(2));
  }

  /// Get the import URI for a type
  static String? getImportUri(DartType type) {
    final element = type.element;
    if (element == null) return null;

    final library = element.library;
    if (library == null) return null;

    return library.identifier;
  }

  /// Check if a type needs an import (not a built-in type)
  static bool needsImport(DartType type) {
    if (isPrimitive(type)) return false;

    final typeString = type.getDisplayString();
    final baseType =
        typeString.replaceAll('?', '').replaceAll(RegExp(r'<.*>'), '');

    return !const [
      'dynamic',
      'Object',
      'void',
      'Null',
      'Never',
      'Function',
      'List',
      'Set',
      'Map',
      'Iterable',
      'Future',
      'Stream',
    ].contains(baseType);
  }

  /// Get all types that need imports from a list of parameters
  static Set<String> collectImports(List<FormalParameterElement> parameters) {
    final imports = <String>{};

    for (final param in parameters) {
      final type = param.type;
      if (needsImport(type)) {
        final importUri = getImportUri(type);
        if (importUri != null) {
          imports.add(importUri);
        }
      }

      // Handle generic types
      if (type is ParameterizedType) {
        for (final typeArg in type.typeArguments) {
          if (needsImport(typeArg)) {
            final importUri = getImportUri(typeArg);
            if (importUri != null) {
              imports.add(importUri);
            }
          }
        }
      }
    }

    return imports;
  }
}

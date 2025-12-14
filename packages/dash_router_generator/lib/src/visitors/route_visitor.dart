// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';

import '../models/route_config_model.dart';
import 'param_visitor.dart';

/// Known annotation type names from dash_router_annotations package.
const _dashRouteAnnotations = {
  'DashRoute',
  'InitialRoute',
  'DialogRoute',
  'ShellRoute',
  'RedirectRoute',
};

/// Exception thrown when code generation fails.
///
/// This exception is thrown when the generator encounters invalid or
/// incomplete route configuration in the source code.
///
/// ## Example
///
/// ```dart
/// throw InvalidGenerationSourceError(
///   '@DashRoute must specify a path parameter',
/// );
/// ```
class InvalidGenerationSourceError implements Exception {
  /// The error message describing what went wrong.
  final String message;

  /// Creates an [InvalidGenerationSourceError] with the given [message].
  InvalidGenerationSourceError(this.message);

  @override
  String toString() => 'InvalidGenerationSourceError: $message';
}

/// Helper class to read constant values from [DartObject].
///
/// This class provides type-safe access to annotation values during
/// code generation. It wraps the analyzer's [DartObject] and provides
/// convenient methods for reading fields.
///
/// ## Example
///
/// ```dart
/// final reader = ConstantReader(annotation);
/// final path = reader.read('path').stringValue;
/// final name = reader.peek('name')?.stringValue;
/// ```
class ConstantReader {
  final DartObject _object;

  /// Creates a [ConstantReader] wrapping the given [DartObject].
  ConstantReader(this._object);

  /// Reads a required field from the annotation.
  ///
  /// Throws [InvalidGenerationSourceError] if the field is missing or null.
  ConstantReader read(String field) {
    final value = _object.getField(field);
    if (value == null || value.isNull) {
      throw InvalidGenerationSourceError('Required field "$field" is missing');
    }
    return ConstantReader(value);
  }

  /// Peeks at an optional field from the annotation.
  ///
  /// Returns `null` if the field is missing or null.
  ConstantReader? peek(String field) {
    final value = _object.getField(field);
    if (value == null || value.isNull) return null;
    return ConstantReader(value);
  }

  /// Gets the value as a [bool].
  bool? get boolValue => _object.toBoolValue();

  /// Gets the value as a [String].
  ///
  /// Throws [InvalidGenerationSourceError] if the value is not a string.
  String get stringValue {
    final v = _object.toStringValue();
    if (v == null) {
      throw InvalidGenerationSourceError('Expected string value');
    }
    return v;
  }

  /// Gets the value as an [int].
  int? get intValue => _object.toIntValue();

  /// Gets the value as a [double].
  double? get doubleValue => _object.toDoubleValue();

  /// Returns `true` if the value is null.
  bool get isNull => _object.isNull;

  /// Gets the value as a [List] of [DartObject].
  List<DartObject> get listValue => _object.toListValue() ?? [];

  /// Gets the value as a [Map] of [DartObject].
  Map<DartObject?, DartObject?> get mapValue => _object.toMapValue() ?? {};

  /// Gets the underlying [DartObject].
  DartObject get objectValue => _object;
}

/// Visitor for extracting route configuration from annotations.
///
/// This class analyzes Dart class elements and extracts route configuration
/// from `@DashRoute` and related annotations.
///
/// ## Example
///
/// ```dart
/// final visitor = RouteVisitor();
/// final route = visitor.visitClass(classElement);
/// if (route != null) {
///   // Process the route configuration
/// }
/// ```
class RouteVisitor {
  /// Checks if a type name matches a dash_router annotation.
  static bool _isDashRouteAnnotation(String? typeName) {
    if (typeName == null) return false;
    return _dashRouteAnnotations.contains(typeName);
  }

  /// Finds any dash_router annotation on the element.
  static (String, DartObject)? _findDashRouteAnnotation(ClassElement element) {
    for (final meta in element.metadata.annotations) {
      final value = meta.computeConstantValue();
      if (value == null) continue;
      final type = value.type;
      if (type == null) continue;
      final name = type.getDisplayString(withNullability: false);
      if (_isDashRouteAnnotation(name)) {
        return (name, value);
      }
    }
    return null;
  }

  /// Extracts route configuration from a class element.
  ///
  /// Returns `null` if the element does not have a dash_router annotation.
  RouteConfigModel? visitClass(ClassElement element) {
    final found = _findDashRouteAnnotation(element);
    if (found == null) return null;

    final (typeName, annotation) = found;

    switch (typeName) {
      case 'DashRoute':
      case 'ShellRoute':
      case 'RedirectRoute':
        return _extractDashRoute(element, annotation, typeName);
      case 'InitialRoute':
        return _extractInitialRoute(element, annotation);
      case 'DialogRoute':
        return _extractDialogRoute(element, annotation);
      default:
        return null;
    }
  }

  RouteConfigModel _extractDashRoute(
    ClassElement element,
    DartObject annotation,
    String annotationType,
  ) {
    final reader = ConstantReader(annotation);

    final path = reader.read('path').stringValue;
    final name = reader.peek('name')?.stringValue;
    final parent = reader.peek('parent')?.stringValue;
    final keepAlive = reader.peek('keepAlive')?.boolValue ?? false;
    final fullscreenDialog =
        reader.peek('fullscreenDialog')?.boolValue ?? false;
    final maintainState = reader.peek('maintainState')?.boolValue ?? true;
    final transitionCode =
        _extractTransitionCodeFromSource(element, annotationType) ??
            _extractTransitionCode(reader);

    // Extract transition imports
    final transitionImports = _extractTransitionImports(reader);

    // Extract guards code and imports from source
    final guardsExtract =
        _extractListCodeFromSource(element, annotationType, 'guards');
    final guardsCode = guardsExtract.$1;
    final guardImports = guardsExtract.$2;

    // Extract middleware code and imports from source
    final middlewareExtract =
        _extractListCodeFromSource(element, annotationType, 'middleware');
    final middlewareCode = middlewareExtract.$1;
    final middlewareImports = middlewareExtract.$2;

    // Check for unified shell/redirect properties
    final isShell = annotationType == 'ShellRoute' ||
        (reader.peek('shell')?.boolValue ?? false);
    final redirectTo = reader.peek('redirectTo')?.stringValue;
    final permanentRedirect =
        reader.peek('permanentRedirect')?.boolValue ?? false;

    // Extract arguments types for Record-type body params (with imports)
    final argumentTypesWithImports =
        _extractTypeNamesWithImports(reader, 'arguments');
    final argumentTypes = argumentTypesWithImports.keys.toList();
    final argumentImports =
        argumentTypesWithImports.values.whereType<String>().toList();

    // Extract metadata
    final metadata = <String, dynamic>{};
    final metadataField = reader.peek('metadata');
    if (metadataField != null && !metadataField.isNull) {
      final mapValue = metadataField.mapValue;
      for (final entry in mapValue.entries) {
        final key = entry.key?.toStringValue();
        if (key != null) {
          metadata[key] = _extractDartObjectValue(entry.value);
        }
      }
    }

    // If it's a redirect route, return early
    if (redirectTo != null && redirectTo.isNotEmpty) {
      return RouteConfigModel(
        classElement: element,
        path: path,
        name: name,
        redirectTo: redirectTo,
        redirectPermanent: permanentRedirect,
      );
    }

    // Extract children for shell routes
    List<String>? childrenMeta;
    if (isShell) {
      final childrenField = reader.peek('children');
      if (childrenField != null && !childrenField.isNull) {
        childrenMeta = <String>[];
        for (final child in childrenField.listValue) {
          final value = child.toStringValue();
          if (value != null) {
            childrenMeta.add(value);
          }
        }
      }
      if (childrenMeta != null) {
        metadata['children'] = childrenMeta;
      }
    }

    // Store argument types in metadata if present
    if (argumentTypes.isNotEmpty) {
      metadata['argumentTypes'] = argumentTypes;
      metadata['argumentImports'] = argumentImports;
    }

    // Extract parameters from constructor
    final paramVisitor = ParamVisitor();
    final params = paramVisitor
        .extractParams(element, path)
        .where((p) => p.fieldName != 'child')
        .toList();

    return RouteConfigModel(
      classElement: element,
      path: path,
      name: name,
      parent: parent,
      keepAlive: keepAlive,
      fullscreenDialog: fullscreenDialog,
      maintainState: maintainState,
      transitionCode: transitionCode,
      transitionImports: transitionImports,
      guardsCode: guardsCode,
      guardImports: guardImports,
      middlewareCode: middlewareCode,
      middlewareImports: middlewareImports,
      isShell: isShell,
      pathParams: params.where((p) => p.kind == ParamKind.path).toList(),
      queryParams: params.where((p) => p.kind == ParamKind.query).toList(),
      bodyParams: params.where((p) => p.kind == ParamKind.body).toList(),
      metadata: metadata,
    );
  }

  RouteConfigModel _extractInitialRoute(
    ClassElement element,
    DartObject annotation,
  ) {
    final reader = ConstantReader(annotation);

    final name = reader.peek('name')?.stringValue;
    final transitionCode =
        _extractTransitionCodeFromSource(element, 'InitialRoute') ??
            _extractTransitionCode(reader);

    // Extract transition imports
    final transitionImports = _extractTransitionImports(reader);

    // Extract guards and middleware from source
    final guardsExtract =
        _extractListCodeFromSource(element, 'InitialRoute', 'guards');
    final middlewareExtract =
        _extractListCodeFromSource(element, 'InitialRoute', 'middleware');

    final paramVisitor = ParamVisitor();
    final params = paramVisitor.extractParams(element, '/');

    return RouteConfigModel(
      classElement: element,
      path: '/',
      name: name,
      isInitial: true,
      transitionCode: transitionCode,
      transitionImports: transitionImports,
      guardsCode: guardsExtract.$1,
      guardImports: guardsExtract.$2,
      middlewareCode: middlewareExtract.$1,
      middlewareImports: middlewareExtract.$2,
      pathParams: params.where((p) => p.kind == ParamKind.path).toList(),
      queryParams: params.where((p) => p.kind == ParamKind.query).toList(),
      bodyParams: params.where((p) => p.kind == ParamKind.body).toList(),
    );
  }

  RouteConfigModel _extractDialogRoute(
    ClassElement element,
    DartObject annotation,
  ) {
    final reader = ConstantReader(annotation);

    final path = reader.read('path').stringValue;
    final name = reader.peek('name')?.stringValue;
    final barrierDismissible =
        reader.peek('barrierDismissible')?.boolValue ?? true;

    // Extract transition imports (dialog routes can also have transitions)
    final transitionCode =
        _extractTransitionCodeFromSource(element, 'DialogRoute') ??
            _extractTransitionCode(reader);
    final transitionImports = _extractTransitionImports(reader);

    // Extract guards and middleware from source
    final guardsExtract =
        _extractListCodeFromSource(element, 'DialogRoute', 'guards');
    final middlewareExtract =
        _extractListCodeFromSource(element, 'DialogRoute', 'middleware');

    final paramVisitor = ParamVisitor();
    final params = paramVisitor.extractParams(element, path);

    return RouteConfigModel(
      classElement: element,
      path: path,
      name: name,
      isDialog: true,
      fullscreenDialog: true,
      transitionCode: transitionCode,
      transitionImports: transitionImports,
      guardsCode: guardsExtract.$1,
      guardImports: guardsExtract.$2,
      middlewareCode: middlewareExtract.$1,
      middlewareImports: middlewareExtract.$2,
      pathParams: params.where((p) => p.kind == ParamKind.path).toList(),
      queryParams: params.where((p) => p.kind == ParamKind.query).toList(),
      bodyParams: params.where((p) => p.kind == ParamKind.body).toList(),
      metadata: {'barrierDismissible': barrierDismissible},
    );
  }

  /// Extracts list code expression and imports from source annotation.
  ///
  /// This is used for guards and middleware to extract the literal list
  /// expression the user wrote, along with the import paths of the types used.
  ///
  /// Returns a tuple of (codeExpression, importPaths).
  (String?, List<String>) _extractListCodeFromSource(
    ClassElement element,
    String annotationType,
    String fieldName,
  ) {
    for (final meta in element.metadata.annotations) {
      final constValue = meta.computeConstantValue();
      final type = constValue?.type;
      if (type == null) continue;
      final typeName = type.getDisplayString(withNullability: false);
      if (typeName != annotationType) continue;

      final source = meta.toSource();
      final value = _extractNamedArgExpression(source, fieldName);
      if (value != null && value.isNotEmpty) {
        // Extract imports from the list items
        final imports = _extractImportsFromListField(constValue!, fieldName);
        return (value, imports);
      }
    }
    return (null, const []);
  }

  /// Extracts import paths from a list field in a constant value.
  List<String> _extractImportsFromListField(
      DartObject constValue, String fieldName) {
    final imports = <String>[];
    final field = constValue.getField(fieldName);
    if (field == null || field.isNull) return imports;

    final listValue = field.toListValue();
    if (listValue == null) return imports;

    for (final item in listValue) {
      final itemType = item.type;
      if (itemType == null) continue;
      final element = itemType.element;
      if (element != null && element.library != null) {
        final uri = element.library!.identifier;
        // Exclude dart: and package:dash_router imports
        if (!uri.startsWith('dart:') &&
            !uri.contains('dash_router/') &&
            !uri.contains('dash_router_annotations/')) {
          if (!imports.contains(uri)) {
            imports.add(uri);
          }
        }
      }
    }
    return imports;
  }

  /// Extracts import URIs from the transition field.
  ///
  /// This method extracts the import URI of custom transition classes
  /// so they can be properly imported in the generated code.
  static List<String> _extractTransitionImports(ConstantReader reader) {
    final out = <String>[];
    final transition = reader.peek('transition');
    if (transition == null || transition.isNull) return out;

    final object = transition.objectValue;
    final type = object.type;
    if (type == null) return out;

    final element = type.element;
    if (element != null && element.library != null) {
      final uri = element.library!.identifier;
      // Exclude dart:, dash_router and dash_router_annotations imports
      if (!uri.startsWith('dart:') &&
          !uri.contains('dash_router/') &&
          !uri.contains('dash_router_annotations/')) {
        out.add(uri);
      }
    }

    return out;
  }

  /// Extract type names with their import URIs for the arguments field.
  ///
  /// Returns a map of type names to their import URIs.
  static Map<String, String?> _extractTypeNamesWithImports(
    ConstantReader reader,
    String field,
  ) {
    final out = <String, String?>{};
    final fieldValue = reader.peek(field);
    if (fieldValue == null || fieldValue.isNull) return out;

    for (final item in fieldValue.listValue) {
      final t = item.toTypeValue();
      if (t != null) {
        final typeName = t.getDisplayString();
        final element = t.element;
        String? importUri;
        if (element != null && element.library != null) {
          importUri = element.library!.identifier;
        }
        out[typeName] = importUri;
      }
    }
    return out;
  }

  dynamic _extractDartObjectValue(DartObject? object) {
    if (object == null) return null;

    if (object.isNull) return null;
    if (object.toBoolValue() != null) return object.toBoolValue();
    if (object.toIntValue() != null) return object.toIntValue();
    if (object.toDoubleValue() != null) return object.toDoubleValue();
    if (object.toStringValue() != null) return object.toStringValue();

    final listValue = object.toListValue();
    if (listValue != null) {
      return listValue.map(_extractDartObjectValue).toList();
    }

    final mapValue = object.toMapValue();
    if (mapValue != null) {
      return Map.fromEntries(
        mapValue.entries.map(
          (e) => MapEntry(
            _extractDartObjectValue(e.key),
            _extractDartObjectValue(e.value),
          ),
        ),
      );
    }

    return object.toString();
  }

  /// Prefer reading the literal expression the user wrote for `transition:`.
  ///
  /// This avoids serializing const object fields and preserves user style.
  String? _extractTransitionCodeFromSource(
    ClassElement element,
    String annotationType,
  ) {
    for (final meta in element.metadata.annotations) {
      final constValue = meta.computeConstantValue();
      final type = constValue?.type;
      if (type == null) continue;
      final typeName = type.getDisplayString(withNullability: false);
      if (typeName != annotationType) continue;

      final source = meta.toSource();
      final value = _extractNamedArgExpression(source, 'transition');
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  String? _extractNamedArgExpression(String annotationSource, String name) {
    final open = annotationSource.indexOf('(');
    final close = annotationSource.lastIndexOf(')');
    if (open == -1 || close == -1 || close <= open) return null;

    final args = annotationSource.substring(open + 1, close);
    final parts = _splitTopLevelArgs(args);
    for (final part in parts) {
      final colonIndex = _indexOfTopLevelColon(part);
      if (colonIndex == -1) continue;
      final key = part.substring(0, colonIndex).trim();
      if (key != name) continue;
      return part.substring(colonIndex + 1).trim();
    }
    return null;
  }

  List<String> _splitTopLevelArgs(String args) {
    final out = <String>[];
    var start = 0;

    var paren = 0;
    var bracket = 0;
    var brace = 0;
    var inSingle = false;
    var inDouble = false;
    var escape = false;

    for (var i = 0; i < args.length; i++) {
      final ch = args[i];

      if (escape) {
        escape = false;
        continue;
      }

      if (inSingle) {
        if (ch == '\\') {
          escape = true;
        } else if (ch == "'") {
          inSingle = false;
        }
        continue;
      }

      if (inDouble) {
        if (ch == '\\') {
          escape = true;
        } else if (ch == '"') {
          inDouble = false;
        }
        continue;
      }

      switch (ch) {
        case "'":
          inSingle = true;
          continue;
        case '"':
          inDouble = true;
          continue;
        case '(':
          paren++;
          continue;
        case ')':
          if (paren > 0) paren--;
          continue;
        case '[':
          bracket++;
          continue;
        case ']':
          if (bracket > 0) bracket--;
          continue;
        case '{':
          brace++;
          continue;
        case '}':
          if (brace > 0) brace--;
          continue;
        case ',':
          if (paren == 0 && bracket == 0 && brace == 0) {
            out.add(args.substring(start, i).trim());
            start = i + 1;
          }
          continue;
      }
    }

    final tail = args.substring(start).trim();
    if (tail.isNotEmpty) out.add(tail);
    return out;
  }

  int _indexOfTopLevelColon(String s) {
    var paren = 0;
    var bracket = 0;
    var brace = 0;
    var inSingle = false;
    var inDouble = false;
    var escape = false;

    for (var i = 0; i < s.length; i++) {
      final ch = s[i];

      if (escape) {
        escape = false;
        continue;
      }

      if (inSingle) {
        if (ch == '\\') {
          escape = true;
        } else if (ch == "'") {
          inSingle = false;
        }
        continue;
      }

      if (inDouble) {
        if (ch == '\\') {
          escape = true;
        } else if (ch == '"') {
          inDouble = false;
        }
        continue;
      }

      switch (ch) {
        case "'":
          inSingle = true;
          continue;
        case '"':
          inDouble = true;
          continue;
        case '(':
          paren++;
          continue;
        case ')':
          if (paren > 0) paren--;
          continue;
        case '[':
          bracket++;
          continue;
        case ']':
          if (bracket > 0) bracket--;
          continue;
        case '{':
          brace++;
          continue;
        case '}':
          if (brace > 0) brace--;
          continue;
        case ':':
          if (paren == 0 && bracket == 0 && brace == 0) return i;
          continue;
      }
    }
    return -1;
  }

  String? _extractTransitionCode(ConstantReader reader) {
    final transition = reader.peek('transition');
    if (transition == null || transition.isNull) return null;

    final object = transition.objectValue;
    if (object.type == null) {
      throw InvalidGenerationSourceError(
        'DashRoute.transition must be a const DashTransition instance.',
      );
    }

    return _dartObjectToConstCode(object);
  }

  String _dartObjectToConstCode(DartObject object) {
    if (object.isNull) return 'null';

    final boolValue = object.toBoolValue();
    if (boolValue != null) return boolValue.toString();

    final intValue = object.toIntValue();
    if (intValue != null) return intValue.toString();

    final doubleValue = object.toDoubleValue();
    if (doubleValue != null) return doubleValue.toString();

    final stringValue = object.toStringValue();
    if (stringValue != null) {
      final escaped = stringValue
          .replaceAll('\\', r'\\')
          .replaceAll("'", r"\'")
          .replaceAll('\n', r'\\n')
          .replaceAll('\r', r'\\r')
          .replaceAll('\t', r'\\t');
      return "'$escaped'";
    }

    final listValue = object.toListValue();
    if (listValue != null) {
      final items = listValue.map((e) => _dartObjectToConstCode(e)).join(', ');
      return 'const [$items]';
    }

    final mapValue = object.toMapValue();
    if (mapValue != null) {
      final entries = mapValue.entries
          .map(
            (e) =>
                '${_dartObjectToConstCode(e.key!)}: ${_dartObjectToConstCode(e.value!)}',
          )
          .join(', ');
      return 'const {$entries}';
    }

    final type = object.type;
    final typeName = type?.getDisplayString(withNullability: false);
    if (typeName == null) {
      throw InvalidGenerationSourceError(
          'Unsupported const value in transition');
    }

    // Handle common framework value types.
    if (typeName == 'Duration') {
      final micros = object.getField('inMicroseconds')?.toIntValue() ??
          // Fallback: private field used by Dart SDK implementation.
          object.getField('_duration')?.toIntValue();
      if (micros == null) {
        throw InvalidGenerationSourceError('Unsupported const Duration value');
      }
      return 'const Duration(microseconds: $micros)';
    }

    if (typeName == 'Offset') {
      final dx = object.getField('dx')?.toDoubleValue();
      final dy = object.getField('dy')?.toDoubleValue();
      if (dx != null && dy != null) {
        return 'const Offset($dx, $dy)';
      }
    }

    if (typeName == 'Color') {
      final value = object.getField('value')?.toIntValue();
      if (value != null) {
        final hex = value.toRadixString(16).padLeft(8, '0');
        return 'const Color(0x$hex)';
      }
    }

    if (typeName == 'Alignment') {
      final x = object.getField('x')?.toDoubleValue();
      final y = object.getField('y')?.toDoubleValue();
      if (x != null && y != null) {
        return 'const Alignment($x, $y)';
      }
    }

    if (typeName == 'Cubic') {
      final a = object.getField('a')?.toDoubleValue();
      final b = object.getField('b')?.toDoubleValue();
      final c = object.getField('c')?.toDoubleValue();
      final d = object.getField('d')?.toDoubleValue();
      if (a != null && b != null && c != null && d != null) {
        return 'const Cubic($a, $b, $c, $d)';
      }
    }

    // Fallback: const ClassName(field: value, ...)
    final element = type!.element;
    if (element is ClassElement) {
      final seen = <String>{};
      final fields = _collectAllPublicInstanceFields(element, seen);

      final args = <String>[];
      for (final field in fields) {
        final fieldName = field.name;
        if (fieldName == null) continue;
        final value = object.getField(fieldName);
        if (value == null) continue;
        args.add('$fieldName: ${_dartObjectToConstCode(value)}');
      }

      return 'const $typeName(${args.join(', ')})';
    }

    throw InvalidGenerationSourceError(
      'Unsupported const object type for transition: $typeName',
    );
  }

  List<FieldElement> _collectAllPublicInstanceFields(
    ClassElement element,
    Set<String> seen,
  ) {
    final out = <FieldElement>[];
    ClassElement? current = element;
    while (current != null) {
      for (final f in current.fields) {
        final fieldName = f.name;
        if (fieldName == null) continue;
        if (f.isStatic || f.isSynthetic || !f.isPublic) continue;
        if (!seen.add(fieldName)) continue;
        out.add(f);
      }

      final supertype = current.supertype;
      if (supertype == null) break;
      final superEl = supertype.element;
      if (superEl.name == 'Object') break;
      if (superEl is ClassElement) {
        current = superEl;
      } else {
        break;
      }
    }
    return out;
  }
}

import 'package:analyzer/dart/element/type.dart';

import 'route_config_model.dart';

/// Detailed parameter configuration model
class ParamDetailModel {
  /// Parameter name
  final String name;

  /// Field name in the class
  final String fieldName;

  /// Dart type
  final DartType dartType;

  /// Type as string representation
  final String typeString;

  /// Whether the parameter is required
  final bool isRequired;

  /// Default value expression
  final String? defaultValue;

  /// Parameter kind
  final ParamKind kind;

  /// Custom decoder type name
  final String? decoderType;

  /// Validation constraints
  final ParamValidation? validation;

  /// Documentation
  final String? documentation;

  ParamDetailModel({
    required this.name,
    required this.fieldName,
    required this.dartType,
    required this.typeString,
    this.isRequired = true,
    this.defaultValue,
    this.kind = ParamKind.path,
    this.decoderType,
    this.validation,
    this.documentation,
  });

  /// Whether the type is a primitive
  bool get isPrimitive => _isPrimitiveType(typeString);

  /// Whether the type is a list
  bool get isList => typeString.startsWith('List<');

  /// Whether the type is nullable
  bool get isNullable => typeString.endsWith('?');

  /// Get the base type (without nullability)
  String get baseType {
    var type = typeString;
    if (type.endsWith('?')) {
      type = type.substring(0, type.length - 1);
    }
    return type;
  }

  /// Get the element type for lists
  String? get listElementType {
    if (!isList) return null;
    final match = RegExp(r'List<(.+)>').firstMatch(baseType);
    return match?.group(1);
  }

  static bool _isPrimitiveType(String type) {
    final baseType = type.replaceAll('?', '');
    return const [
      'String',
      'int',
      'double',
      'num',
      'bool',
      'DateTime',
    ].contains(baseType);
  }

  /// Convert to ParamConfigModel
  ParamConfigModel toConfigModel() {
    return ParamConfigModel(
      name: name,
      fieldName: fieldName,
      type: dartType,
      typeString: typeString,
      isRequired: isRequired,
      defaultValue: defaultValue,
      kind: kind,
      decoder: decoderType,
      pattern: validation?.pattern,
      min: validation?.min,
      max: validation?.max,
      description: documentation,
    );
  }
}

/// Validation constraints for a parameter
class ParamValidation {
  /// Regex pattern for string validation
  final String? pattern;

  /// Minimum value for numeric types
  final num? min;

  /// Maximum value for numeric types
  final num? max;

  /// Minimum length for strings/lists
  final int? minLength;

  /// Maximum length for strings/lists
  final int? maxLength;

  /// Custom validation function name
  final String? customValidator;

  /// Error message for validation failures
  final String? errorMessage;

  const ParamValidation({
    this.pattern,
    this.min,
    this.max,
    this.minLength,
    this.maxLength,
    this.customValidator,
    this.errorMessage,
  });

  bool get hasConstraints =>
      pattern != null ||
      min != null ||
      max != null ||
      minLength != null ||
      maxLength != null ||
      customValidator != null;
}

/// Collection of parameters grouped by kind
class ParamCollection {
  final List<ParamDetailModel> pathParams;
  final List<ParamDetailModel> queryParams;
  final List<ParamDetailModel> bodyParams;

  const ParamCollection({
    this.pathParams = const [],
    this.queryParams = const [],
    this.bodyParams = const [],
  });

  /// All parameters
  List<ParamDetailModel> get all => [
        ...pathParams,
        ...queryParams,
        ...bodyParams,
      ];

  /// Whether there are any parameters
  bool get isEmpty =>
      pathParams.isEmpty && queryParams.isEmpty && bodyParams.isEmpty;

  /// Whether there are any parameters
  bool get isNotEmpty => !isEmpty;

  /// Required parameters
  List<ParamDetailModel> get required =>
      all.where((p) => p.isRequired).toList();

  /// Optional parameters
  List<ParamDetailModel> get optional =>
      all.where((p) => !p.isRequired).toList();

  /// Parameters that need custom decoders
  List<ParamDetailModel> get withDecoders =>
      all.where((p) => p.decoderType != null).toList();

  /// Parameters that need validation
  List<ParamDetailModel> get withValidation =>
      all.where((p) => p.validation?.hasConstraints ?? false).toList();
}

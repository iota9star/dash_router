import 'route_exceptions.dart';

/// Base class for parameter-related exceptions.
///
/// All parameter-specific exceptions in Dash Router extend this class.
/// It provides a common base for catching parameter-related errors.
///
/// ## Example
///
/// ```dart
/// try {
///   final params = route.params;
///   final userId = params.path['id']!;
/// } on ParamsException catch (e) {
///   print('Parameter error: ${e.message}');
///   // Handle the error gracefully
/// }
/// ```
abstract class ParamsException extends DashRouterException {
  /// Creates a parameter exception.
  ///
  /// [message] - Error message describing the parameter issue
  /// [stackTrace] - Optional stack trace for debugging
  const ParamsException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Thrown when a required parameter is missing.
///
/// This exception is raised when trying to access a parameter
/// that is required but not provided in the route URL.
///
/// ## Example
///
/// ```dart
/// // Route: @DashRoute(path: '/user/:id')
/// try {
///   final params = route.params;
///   final userId = params.path['id']; // Throws if 'id' is missing
/// } on MissingParamException catch (e) {
///   print('Missing parameter: ${e.paramName}');
///   print('Parameter type: ${e.paramType}');
/// }
/// ```
class MissingParamException extends ParamsException {
  /// Name of the missing parameter.
  final String paramName;

  /// Type of the missing parameter.
  final String paramType;

  /// Creates a missing parameter exception.
  ///
  /// [paramName] - Name of the missing parameter
  /// [paramType] - Type of the parameter (defaults to 'unknown')
  /// [stackTrace] - Optional stack trace for debugging
  ///
  /// Example:
  /// ```dart
  /// throw MissingParamException('id', paramType: 'String');
  /// ```
  const MissingParamException(
    this.paramName, {
    this.paramType = 'unknown',
    StackTrace? stackTrace,
  }) : super('Missing required parameter: $paramName ($paramType)', stackTrace);
}

/// Thrown when parameter type conversion fails.
///
/// This exception occurs when trying to convert a parameter
/// from string to its expected type but the conversion fails.
///
/// ## Example
///
/// ```dart
/// // Route: @DashRoute(path: '/user/:id')
/// try {
///   final params = route.params;
///   final userId = params.getAs<int>('id'); // Throws if 'abc' cannot convert to int
/// } on ParamTypeException catch (e) {
///   print('Type conversion failed: ${e.message}');
///   print('Expected: ${e.expectedType}, Got: ${e.actualValue}');
/// }
/// ```
class ParamTypeException extends ParamsException {
  /// Name of the parameter that failed conversion.
  final String paramName;

  /// Expected type for the parameter.
  final String expectedType;

  /// Actual value that failed to convert.
  final String actualValue;

  /// Creates a parameter type exception.
  ///
  /// [paramName] - Name of the parameter
  /// [expectedType] - Expected type for conversion
  /// [actualValue] - Actual value that failed conversion
  /// [stackTrace] - Optional stack trace for debugging
  ///
  /// Example:
  /// ```dart
  /// throw ParamTypeException(
  ///   'age',
  ///   expectedType: 'int',
  ///   actualValue: 'twenty',
  /// );
  /// ```
  const ParamTypeException(
    this.paramName, {
    required this.expectedType,
    required this.actualValue,
    StackTrace? stackTrace,
  }) : super(
          'Cannot convert parameter "$paramName" to $expectedType: $actualValue',
          stackTrace,
        );
}

/// Thrown when parameter validation fails.
///
/// This exception occurs when a parameter exists but fails
/// custom validation rules like format, range, or pattern checks.
///
/// ## Example
///
/// ```dart
/// // Custom validation for age parameter
/// try {
///   final age = params.getAs<int>('age');
///   if (age < 0 || age > 120) {
///     throw ParamValidationException(
///       'age',
///       validationRule: '0-120',
///       message: 'Age must be between 0 and 120',
///     );
///   }
/// } on ParamValidationException catch (e) {
///   print('Validation failed: ${e.message}');
///   print('Rule: ${e.validationRule}');
/// }
/// ```
class ParamValidationException extends ParamsException {
  /// Name of the parameter that failed validation.
  final String paramName;

  /// Description of the validation rule that failed.
  final String? validationRule;

  /// Creates a parameter validation exception.
  ///
  /// [paramName] - Name of the parameter
  /// [validationRule] - Optional description of the validation rule
  /// [message] - Optional custom error message
  /// [stackTrace] - Optional stack trace for debugging
  ///
  /// Example:
  /// ```dart
  /// throw ParamValidationException(
  ///   'email',
  ///   validationRule: 'email-format',
  ///   message: 'Invalid email format',
  /// );
  /// ```
  const ParamValidationException(
    this.paramName, {
    this.validationRule,
    String? message,
    StackTrace? stackTrace,
  }) : super(
          message ??
              'Validation failed for parameter "$paramName"${validationRule != null ? ' (rule: $validationRule)' : ''}',
          stackTrace,
        );
}

/// Thrown when parameter decoding fails.
///
/// This exception occurs when trying to decode a parameter
/// from its string representation, often due to malformed data.
///
/// ## Example
///
/// ```dart
/// try {
///   // Decode JSON string parameter
///   final userData = params.decodeAs<User>('user');
/// } on ParamDecodeException catch (e) {
///   print('Decoding failed: ${e.message}');
///   print('Original error: ${e.originalError}');
///   // Handle malformed JSON or invalid data
/// }
/// ```
class ParamDecodeException extends ParamsException {
  /// Name of the parameter that failed decoding.
  final String paramName;

  /// The original error that caused the decode failure.
  final Object? originalError;

  /// Creates a parameter decode exception.
  ///
  /// [paramName] - Name of the parameter
  /// [originalError] - The underlying error that caused failure
  /// [message] - Optional custom error message
  /// [stackTrace] - Optional stack trace for debugging
  ///
  /// Example:
  /// ```dart
  /// throw ParamDecodeException(
  ///   'user',
  ///   originalError: FormatException('Invalid JSON'),
  ///   message: 'User data is malformed',
  /// );
  /// ```
  const ParamDecodeException(
    this.paramName, {
    this.originalError,
    String? message,
    StackTrace? stackTrace,
  }) : super(message ?? 'Failed to decode parameter: $paramName', stackTrace);
}

/// Thrown when parameter encoding fails.
///
/// This exception occurs when trying to encode a parameter
/// to its string representation, often due to circular references
/// or objects that cannot be serialized.
///
/// ## Example
///
/// ```dart
/// try {
///   // Encode complex object to URL parameter
///   final userParam = params.encodeObject('user', userData);
/// } on ParamEncodeException catch (e) {
///   print('Encoding failed: ${e.message}');
///   print('Original error: ${e.originalError}');
///   // Handle circular references or non-serializable objects
/// }
/// ```
class ParamEncodeException extends ParamsException {
  /// Name of the parameter that failed encoding.
  final String paramName;

  /// The original error that caused the encode failure.
  final Object? originalError;

  /// Creates a parameter encode exception.
  ///
  /// [paramName] - Name of parameter
  /// [originalError] - The underlying error that caused failure
  /// [message] - Optional custom error message
  /// [stackTrace] - Optional stack trace for debugging
  ///
  /// Example:
  /// ```dart
  /// throw ParamEncodeException(
  ///   'user',
  ///   originalError: 'Circular reference detected',
  ///   message: 'Cannot serialize user object',
  /// );
  /// ```
  const ParamEncodeException(
    this.paramName, {
    this.originalError,
    String? message,
    StackTrace? stackTrace,
  }) : super(message ?? 'Failed to encode parameter: $paramName', stackTrace);
}

/// Thrown when an unknown parameter is accessed.
///
/// This exception occurs when trying to access a parameter
/// that doesn't exist in the current route context.
///
/// ## Example
///
/// ```dart
/// // Route: @DashRoute(path: '/user/:id')
/// try {
///   final params = route.params;
///   final unknown = params.path['name']; // Throws if 'name' is not defined
/// } on UnknownParamException catch (e) {
///   print('Unknown parameter: ${e.paramName}');
///   // Handle access to non-existent parameters
/// }
/// ```
class UnknownParamException extends ParamsException {
  /// Name of the unknown parameter.
  final String paramName;

  /// Creates an unknown parameter exception.
  ///
  /// [paramName] - Name of the unknown parameter
  /// [stackTrace] - Optional stack trace for debugging
  ///
  /// Example:
  /// ```dart
  /// throw UnknownParamException('name');
  /// ```
  const UnknownParamException(this.paramName, [StackTrace? stackTrace])
      : super('Unknown parameter: $paramName', stackTrace);
}

/// Thrown when parameter access is invalid.
///
/// This exception occurs when trying to access parameters
/// in an invalid context, such as when the route context
/// has been disposed or when parameters are accessed from
/// outside the widget tree.
///
/// ## Example
///
/// ```dart
/// try {
///   // Access parameters outside of route context
///   final params = route.params; // Throws if not in route scope
/// } on InvalidParamAccessException catch (e) {
///   print('Invalid access: ${e.message}');
///   // Handle access in invalid context
/// }
/// ```
class InvalidParamAccessException extends ParamsException {
  /// Creates an invalid parameter access exception.
  ///
  /// [message] - Error message describing the invalid access
  /// [stackTrace] - Optional stack trace for debugging
  ///
  /// Example:
  /// ```dart
  /// throw InvalidParamAccessException(
  ///     'Cannot access parameters outside route context',
  ///   );
  /// ```
  const InvalidParamAccessException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

import 'route_exceptions.dart';

/// Base class for parameter-related exceptions
abstract class ParamsException extends DashRouterException {
  const ParamsException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

/// Thrown when a required parameter is missing
class MissingParamException extends ParamsException {
  final String paramName;
  final String paramType;

  const MissingParamException(
    this.paramName, {
    this.paramType = 'unknown',
    StackTrace? stackTrace,
  }) : super('Missing required parameter: $paramName ($paramType)', stackTrace);
}

/// Thrown when parameter type conversion fails
class ParamTypeException extends ParamsException {
  final String paramName;
  final String expectedType;
  final String actualValue;

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

/// Thrown when parameter validation fails
class ParamValidationException extends ParamsException {
  final String paramName;
  final String? validationRule;

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

/// Thrown when parameter decoding fails
class ParamDecodeException extends ParamsException {
  final String paramName;
  final Object? originalError;

  const ParamDecodeException(
    this.paramName, {
    this.originalError,
    String? message,
    StackTrace? stackTrace,
  }) : super(message ?? 'Failed to decode parameter: $paramName', stackTrace);
}

/// Thrown when parameter encoding fails
class ParamEncodeException extends ParamsException {
  final String paramName;
  final Object? originalError;

  const ParamEncodeException(
    this.paramName, {
    this.originalError,
    String? message,
    StackTrace? stackTrace,
  }) : super(message ?? 'Failed to encode parameter: $paramName', stackTrace);
}

/// Thrown when an unknown parameter is accessed
class UnknownParamException extends ParamsException {
  final String paramName;

  const UnknownParamException(this.paramName, [StackTrace? stackTrace])
      : super('Unknown parameter: $paramName', stackTrace);
}

/// Thrown when parameter access is invalid
class InvalidParamAccessException extends ParamsException {
  const InvalidParamAccessException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

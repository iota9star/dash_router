import '../exceptions/params_exceptions.dart';

/// Defines a validation rule for parameter validation.
///
/// This class encapsulates a validation check that can be applied
/// to route parameters. Rules are reusable and composable.
///
/// ## Example
///
/// ```dart
/// final usernameRule = ValidationRule(
///   name: 'notEmpty',
///   validate: (value) => value.isNotEmpty,
///   message: 'Username cannot be empty',
/// );
/// ```
class ValidationRule {
  /// Unique identifier for this validation rule.
  ///
  /// Used in error messages to identify which rule failed.
  final String name;

  /// Validation function that checks if a value passes the rule.
  ///
  /// Returns true if the value is valid, false otherwise.
  final bool Function(String value) validate;

  /// Error message to display when validation fails.
  final String message;

  /// Creates a validation rule.
  ///
  /// [name] - Unique identifier for this rule
  /// [validate] - Function that validates the value
  /// [message] - Error message for validation failures
  const ValidationRule({
    required this.name,
    required this.validate,
    required this.message,
  });
}

/// Provides static methods for parameter validation.
///
/// This utility class offers built-in validators for common scenarios
/// and methods to apply multiple validation rules to parameters.
///
/// ## Example
///
/// ```dart
/// // Validate email
/// ParamValidator.validateEmail('email', 'user@example.com');
///
/// // Validate with custom rules
/// ParamValidator.validate(
///   'username',
///   'john',
///   rules: [usernameRule],
/// );
/// ```
class ParamValidator {
  /// Private constructor to prevent instantiation.
  ParamValidator._();

  /// Validates a parameter value against multiple validation rules.
  ///
  /// Throws [ParamValidationException] if any rule fails.
  ///
  /// [paramName] - Name of the parameter being validated
  /// [value] - The value to validate
  /// [rules] - List of validation rules to apply
  static void validate(
    String paramName,
    String value,
    List<ValidationRule> rules,
  ) {
    for (final rule in rules) {
      if (!rule.validate(value)) {
        throw ParamValidationException(
          paramName,
          validationRule: rule.name,
          message: rule.message,
        );
      }
    }
  }

  /// Validate with a regex pattern
  static void validatePattern(
    String paramName,
    String value,
    String pattern, {
    String? message,
  }) {
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      throw ParamValidationException(
        paramName,
        validationRule: 'pattern: $pattern',
        message: message ?? 'Value "$value" does not match pattern "$pattern"',
      );
    }
  }

  /// Validate string length
  static void validateLength(
    String paramName,
    String value, {
    int? minLength,
    int? maxLength,
    String? message,
  }) {
    if (minLength != null && value.length < minLength) {
      throw ParamValidationException(
        paramName,
        validationRule: 'minLength: $minLength',
        message:
            message ?? 'Value length ${value.length} is less than $minLength',
      );
    }
    if (maxLength != null && value.length > maxLength) {
      throw ParamValidationException(
        paramName,
        validationRule: 'maxLength: $maxLength',
        message: message ??
            'Value length ${value.length} is greater than $maxLength',
      );
    }
  }

  /// Validate numeric range
  static void validateRange(
    String paramName,
    num value, {
    num? min,
    num? max,
    String? message,
  }) {
    if (min != null && value < min) {
      throw ParamValidationException(
        paramName,
        validationRule: 'min: $min',
        message: message ?? 'Value $value is less than minimum $min',
      );
    }
    if (max != null && value > max) {
      throw ParamValidationException(
        paramName,
        validationRule: 'max: $max',
        message: message ?? 'Value $value is greater than maximum $max',
      );
    }
  }

  /// Validate that value is not empty
  static void validateNotEmpty(
    String paramName,
    String value, {
    String? message,
  }) {
    if (value.isEmpty) {
      throw ParamValidationException(
        paramName,
        validationRule: 'notEmpty',
        message: message ?? 'Value cannot be empty',
      );
    }
  }

  /// Validate that value is in allowed list
  static void validateIn(
    String paramName,
    String value,
    List<String> allowed, {
    String? message,
  }) {
    if (!allowed.contains(value)) {
      throw ParamValidationException(
        paramName,
        validationRule: 'in: ${allowed.join(', ')}',
        message: message ?? 'Value "$value" is not in allowed values: $allowed',
      );
    }
  }

  /// Validate email format
  static void validateEmail(String paramName, String value, {String? message}) {
    const emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    validatePattern(
      paramName,
      value,
      emailPattern,
      message: message ?? 'Invalid email format: $value',
    );
  }

  /// Validate URL format
  static void validateUrl(String paramName, String value, {String? message}) {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw ParamValidationException(
        paramName,
        validationRule: 'url',
        message: message ?? 'Invalid URL format: $value',
      );
    }
  }

  /// Validate UUID format
  static void validateUuid(String paramName, String value, {String? message}) {
    const uuidPattern =
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$';
    validatePattern(
      paramName,
      value,
      uuidPattern,
      message: message ?? 'Invalid UUID format: $value',
    );
  }

  /// Validate numeric string
  static void validateNumeric(
    String paramName,
    String value, {
    String? message,
  }) {
    if (num.tryParse(value) == null) {
      throw ParamValidationException(
        paramName,
        validationRule: 'numeric',
        message: message ?? 'Value must be numeric: $value',
      );
    }
  }

  /// Validate integer string
  static void validateInteger(
    String paramName,
    String value, {
    String? message,
  }) {
    if (int.tryParse(value) == null) {
      throw ParamValidationException(
        paramName,
        validationRule: 'integer',
        message: message ?? 'Value must be an integer: $value',
      );
    }
  }
}

/// Represents the result of a validation operation.
///
/// This class is useful when validating multiple parameters
/// and collecting all validation errors rather than stopping
/// at the first failure.
class ValidationResult {
  /// Whether validation was successful.
  final bool isValid;

  /// List of validation error messages.
  final List<String> errors;

  const ValidationResult.valid()
      : isValid = true,
        errors = const [];

  const ValidationResult.invalid(this.errors) : isValid = false;

  factory ValidationResult.fromErrors(List<String> errors) {
    if (errors.isEmpty) return const ValidationResult.valid();
    return ValidationResult.invalid(errors);
  }
}

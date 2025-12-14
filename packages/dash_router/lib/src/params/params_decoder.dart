// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../exceptions/params_exceptions.dart';

/// Abstract base class for custom parameter decoders.
///
/// Implement this class to create custom decoders for complex types
/// that aren't handled by the built-in [ParamDecoders].
///
/// ## Example
///
/// ```dart
/// class UserIdDecoder extends ParamDecoderBase<UserId> {
///   const UserIdDecoder();
///
///   @override
///   UserId decode(String value) => UserId(value);
///
///   @override
///   bool canDecode(Type type) => type == UserId;
/// }
/// ```
abstract class ParamDecoderBase<T> {
  /// Creates a [ParamDecoderBase] instance.
  const ParamDecoderBase();

  /// Decodes a string [value] to the target type [T].
  ///
  /// Throws an exception if the value cannot be decoded.
  T decode(String value);

  /// Returns `true` if this decoder can handle the given [type].
  bool canDecode(Type type);
}

/// Built-in parameter decoders for common Dart types.
///
/// This class provides static methods for decoding string parameters
/// to typed values. It supports all common Dart primitive types and
/// some complex types like [DateTime], [Uri], and [Duration].
///
/// ## Supported Types
///
/// - [String] and [String?]
/// - [int] and [int?]
/// - [double] and [double?]
/// - [num] and [num?]
/// - [bool] and [bool?]
/// - [DateTime] and [DateTime?]
/// - [Uri] and [Uri?]
/// - [Duration] and [Duration?]
///
/// ## Example
///
/// ```dart
/// // Decode a string to int
/// final count = ParamDecoders.decode<int>('42');
/// print(count); // 42
///
/// // Decode with default value
/// final page = ParamDecoders.decode<int>('invalid', defaultValue: 1);
/// print(page); // 1
///
/// // Decode a nullable string (always succeeds)
/// final name = ParamDecoders.decode<String?>('John');
/// print(name); // John
///
/// // Try decode (returns null on failure)
/// final maybeInt = ParamDecoders.tryDecode<int>('not-a-number');
/// print(maybeInt); // null
/// ```
class ParamDecoders {
  ParamDecoders._();

  /// Decodes a string [value] to the specified type [T].
  ///
  /// If decoding fails and [defaultValue] is provided, returns the default.
  /// Otherwise, throws a [ParamDecodeException].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final count = ParamDecoders.decode<int>('42');
  /// final page = ParamDecoders.decode<int>('invalid', defaultValue: 1);
  /// ```
  static T decode<T>(String value, {T? defaultValue}) {
    try {
      final result = _decodeValue<T>(value);
      if (result == null && null is! T) {
        if (defaultValue != null) {
          return defaultValue;
        }
        throw ParamDecodeException(
          'value',
          message: 'Failed to decode empty value to non-nullable type $T',
        );
      }
      return result as T;
    } catch (e, st) {
      if (defaultValue != null) {
        return defaultValue;
      }
      if (e is ParamDecodeException || e is ParamTypeException) {
        rethrow;
      }
      throw ParamDecodeException(
        'value',
        originalError: e,
        message: 'Failed to decode "$value" to type $T',
        stackTrace: st,
      );
    }
  }

  /// Decodes a value with proper handling for nullable types.
  static T? _decodeValue<T>(String value) {
    // Handle empty string - return null for any nullable type
    if (value.isEmpty) {
      return null;
    }

    // Check if T is a String type (including String?)
    // We use runtime type checking to handle nullable types properly
    if (_isStringType<T>()) {
      return value as T;
    }

    // int and int?
    if (_isIntType<T>()) {
      return int.parse(value) as T;
    }

    // double and double?
    if (_isDoubleType<T>()) {
      return double.parse(value) as T;
    }

    // num and num?
    if (_isNumType<T>()) {
      return num.parse(value) as T;
    }

    // bool and bool?
    if (_isBoolType<T>()) {
      return _decodeBool(value) as T;
    }

    // DateTime and DateTime?
    if (_isDateTimeType<T>()) {
      return DateTime.parse(value) as T;
    }

    // Uri and Uri?
    if (_isUriType<T>()) {
      return Uri.parse(value) as T;
    }

    // Duration and Duration? (in milliseconds)
    if (_isDurationType<T>()) {
      return Duration(milliseconds: int.parse(value)) as T;
    }

    // Default: return as string if T is dynamic or Object
    if (T == dynamic || T == Object) {
      return value as T;
    }

    throw ParamTypeException(
      'value',
      expectedType: T.toString(),
      actualValue: value,
    );
  }

  /// Checks if type [T] is [String] or [String?].
  static bool _isStringType<T>() {
    return T == String || _isNullableOf<T, String>();
  }

  /// Checks if type [T] is [int] or [int?].
  static bool _isIntType<T>() {
    return T == int || _isNullableOf<T, int>();
  }

  /// Checks if type [T] is [double] or [double?].
  static bool _isDoubleType<T>() {
    return T == double || _isNullableOf<T, double>();
  }

  /// Checks if type [T] is [num] or [num?].
  static bool _isNumType<T>() {
    return T == num || _isNullableOf<T, num>();
  }

  /// Checks if type [T] is [bool] or [bool?].
  static bool _isBoolType<T>() {
    return T == bool || _isNullableOf<T, bool>();
  }

  /// Checks if type [T] is [DateTime] or [DateTime?].
  static bool _isDateTimeType<T>() {
    return T == DateTime || _isNullableOf<T, DateTime>();
  }

  /// Checks if type [T] is [Uri] or [Uri?].
  static bool _isUriType<T>() {
    return T == Uri || _isNullableOf<T, Uri>();
  }

  /// Checks if type [T] is [Duration] or [Duration?].
  static bool _isDurationType<T>() {
    return T == Duration || _isNullableOf<T, Duration>();
  }

  /// Checks if [T] is the nullable version of [S].
  ///
  /// This works by checking if null can be assigned to T and if
  /// a non-null S value can also be assigned to T.
  static bool _isNullableOf<T, S>() {
    // T must accept null
    if (null is! T) return false;
    // Check if S? == T by seeing if S satisfies T
    try {
      // If T is S?, then both null and S values should be assignable to T
      return null is T && _canAssign<S, T>();
    } catch (_) {
      return false;
    }
  }

  /// Helper to check type assignability at runtime.
  static bool _canAssign<From, To>() {
    // Use a simple type check - if From is a subtype of the non-nullable
    // version of To, this should work
    try {
      // This is a compile-time check that From can be assigned to To
      // We use a type test pattern
      return <From>[] is List<To> || From == To;
    } catch (_) {
      return false;
    }
  }

  /// Decodes a boolean value from a string.
  ///
  /// Recognizes the following values:
  /// - `true`: 'true', '1', 'yes', 'on' (case-insensitive)
  /// - `false`: 'false', '0', 'no', 'off' (case-insensitive)
  ///
  /// Throws [ParamTypeException] for unrecognized values.
  ///
  /// ## Example
  ///
  /// ```dart
  /// ParamDecoders.decode<bool>('true');  // true
  /// ParamDecoders.decode<bool>('1');     // true
  /// ParamDecoders.decode<bool>('yes');   // true
  /// ParamDecoders.decode<bool>('false'); // false
  /// ParamDecoders.decode<bool>('0');     // false
  /// ```
  static bool _decodeBool(String value) {
    final lower = value.toLowerCase();
    if (lower == 'true' || lower == '1' || lower == 'yes' || lower == 'on') {
      return true;
    }
    if (lower == 'false' || lower == '0' || lower == 'no' || lower == 'off') {
      return false;
    }
    throw ParamTypeException('value', expectedType: 'bool', actualValue: value);
  }

  /// Decodes a comma-separated string into a list of typed values.
  ///
  /// Each element is decoded using [decode].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final ids = ParamDecoders.decodeList<int>('1,2,3');
  /// print(ids); // [1, 2, 3]
  ///
  /// final names = ParamDecoders.decodeList<String>('a|b|c', separator: '|');
  /// print(names); // ['a', 'b', 'c']
  /// ```
  static List<T> decodeList<T>(String value, {String separator = ','}) {
    if (value.isEmpty) return [];
    return value.split(separator).map((v) => decode<T>(v.trim())).toList();
  }

  /// Tries to decode a value, returning `null` on failure.
  ///
  /// Unlike [decode], this method never throws an exception.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final maybeInt = ParamDecoders.tryDecode<int>('42');
  /// print(maybeInt); // 42
  ///
  /// final invalid = ParamDecoders.tryDecode<int>('not-a-number');
  /// print(invalid); // null
  /// ```
  static T? tryDecode<T>(String value) {
    try {
      return decode<T>(value);
    } catch (_) {
      return null;
    }
  }
}

/// Utility class for encoding typed values to strings.
///
/// This class provides static methods for converting typed values
/// to their string representations, suitable for use in URLs or
/// route parameters.
///
/// ## Example
///
/// ```dart
/// // Basic encoding
/// final str = ParamEncoders.encode(42);
/// print(str); // '42'
///
/// // Boolean encoding
/// final boolStr = ParamEncoders.encode(true);
/// print(boolStr); // 'true'
///
/// // DateTime encoding
/// final dateStr = ParamEncoders.encode(DateTime(2025, 12, 13));
/// print(dateStr); // '2025-12-13T00:00:00.000'
///
/// // URL encoding
/// final urlEncoded = ParamEncoders.urlEncode('hello world');
/// print(urlEncoded); // 'hello%20world'
/// ```
class ParamEncoders {
  ParamEncoders._();

  /// Encodes a typed [value] to its string representation.
  ///
  /// Returns an empty string for `null` values.
  ///
  /// ## Example
  ///
  /// ```dart
  /// ParamEncoders.encode(42);        // '42'
  /// ParamEncoders.encode(true);      // 'true'
  /// ParamEncoders.encode(null);      // ''
  /// ParamEncoders.encode('hello');   // 'hello'
  /// ```
  static String encode<T>(T value) {
    if (value == null) return '';

    if (value is String) return value;
    if (value is bool) return value ? 'true' : 'false';
    if (value is DateTime) return value.toIso8601String();
    if (value is Duration) return value.inMilliseconds.toString();
    if (value is Uri) return value.toString();

    return value.toString();
  }

  /// Encodes a list of values into a separated string.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final str = ParamEncoders.encodeList([1, 2, 3]);
  /// print(str); // '1,2,3'
  ///
  /// final custom = ParamEncoders.encodeList(['a', 'b'], separator: '|');
  /// print(custom); // 'a|b'
  /// ```
  static String encodeList<T>(List<T> values, {String separator = ','}) {
    return values.map((v) => encode(v)).join(separator);
  }

  /// URL-encodes a string value using percent-encoding.
  ///
  /// This is useful for encoding parameter values that may contain
  /// special characters.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final encoded = ParamEncoders.urlEncode('hello world');
  /// print(encoded); // 'hello%20world'
  /// ```
  static String urlEncode(String value) {
    return Uri.encodeComponent(value);
  }

  /// URL-decodes a percent-encoded string.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final decoded = ParamEncoders.urlDecode('hello%20world');
  /// print(decoded); // 'hello world'
  /// ```
  static String urlDecode(String value) {
    return Uri.decodeComponent(value);
  }
}

import 'package:dart_style/dart_style.dart';

/// Utility for formatting generated Dart code
class CodeFormatter {
  static final DartFormatter _formatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  );

  /// Format Dart code
  static String format(String code) {
    try {
      return _formatter.format(code);
    } catch (_) {
      // Return unformatted code if formatting fails
      return code;
    }
  }

  /// Format Dart code with line length
  static String formatWithLineLength(String code, int lineLength) {
    try {
      return DartFormatter(
        languageVersion: DartFormatter.latestLanguageVersion,
        pageWidth: lineLength,
      ).format(code);
    } catch (_) {
      return code;
    }
  }

  /// Check if code is valid Dart
  static bool isValidDart(String code) {
    try {
      _formatter.format(code);
      return true;
    } catch (_) {
      return false;
    }
  }
}

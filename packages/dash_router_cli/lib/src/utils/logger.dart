import 'dart:io';

/// Simple logger for CLI output.
class Logger {
  static bool _verbose = false;

  /// Enable verbose logging.
  static void setVerbose(bool enabled) {
    _verbose = enabled;
  }

  /// Log an info message.
  static void info(String message) {
    stdout.writeln(message);
  }

  /// Log a verbose message (only if verbose mode is enabled).
  static void verbose(String message) {
    if (_verbose) {
      stdout.writeln(message);
    }
  }

  /// Log a success message.
  static void success(String message) {
    stdout.writeln('✓ $message');
  }

  /// Log a warning message.
  static void warning(String message) {
    stdout.writeln('⚠ $message');
  }

  /// Log an error message.
  static void error(String message) {
    stderr.writeln('✗ $message');
  }
}

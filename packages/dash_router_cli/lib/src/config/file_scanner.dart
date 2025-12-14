import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as p;

/// Scanner for finding route files
class FileScanner {
  final Map<String, dynamic> config;

  FileScanner(this.config);

  /// Scan for route files based on configuration
  Future<List<String>> scan() async {
    final scan = config['scan'] as Map<String, dynamic>?;
    final rawPaths =
        (scan?['paths'] as List?)?.cast<String>() ?? ['lib/**/*.dart'];
    final rawExclude = (scan?['exclude'] as List?)?.cast<String>() ??
        ['**/*.g.dart', '**/*.freezed.dart'];

    final paths = _normalizeGlobPatterns(rawPaths);
    final exclude = _normalizeGlobPatterns(rawExclude);

    final files = <String>[];

    for (final pattern in paths) {
      final glob = Glob(pattern);

      await for (final entity in glob.list()) {
        if (entity is File) {
          final path = p.relative(entity.path);

          // Check if excluded
          if (_isExcluded(path, exclude)) {
            continue;
          }

          files.add(path);
        }
      }
    }

    return files..sort();
  }

  bool _isExcluded(String path, List<String> exclude) {
    for (final pattern in exclude) {
      final glob = Glob(pattern);
      if (glob.matches(path)) {
        return true;
      }
    }
    return false;
  }

  List<String> _normalizeGlobPatterns(List<String> patterns) {
    final normalized = <String>{};

    for (final pattern in patterns) {
      normalized.add(pattern);

      // The `glob` package does not treat `**/` as matching an empty segment,
      // so `lib/pages/**/*.dart` will not match `lib/pages/home.dart`.
      // Add a fallback variant that removes the LAST `**/`.
      const token = '**/';
      final lastIndex = pattern.lastIndexOf(token);
      if (lastIndex != -1) {
        normalized.add(
          pattern.replaceRange(lastIndex, lastIndex + token.length, ''),
        );
      }
    }

    return normalized.toList();
  }
}

import 'dart:async';
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:watcher/watcher.dart';

/// File watcher for dash_router routes.
class DashRouterFileWatcher {
  final Map<String, dynamic> _config;
  final List<DirectoryWatcher> _watchers = [];
  final Set<String> _changedFiles = {};
  Timer? _debounceTimer;

  DashRouterFileWatcher(this._config);

  /// Start watching for changes.
  Future<void> start(Future<void> Function(List<String>) onChanged) async {
    final scan = (_config['scan'] as Map?)?.cast<String, dynamic>() ?? {};
    final paths = (scan['paths'] as List?)?.cast<String>() ?? ['lib/**/*.dart'];
    final exclude = (scan['exclude'] as List?)?.cast<String>() ?? [];

    final excludeGlobs = exclude.map((e) => Glob(e)).toList();

    // Find all directories to watch
    final dirsToWatch = <String>{};

    for (final pattern in paths) {
      final glob = Glob(pattern);
      for (final entity in glob.listSync()) {
        if (entity is File) {
          final dir = entity.parent.path;
          dirsToWatch.add(dir);
        }
      }
    }

    // Start watchers
    for (final dir in dirsToWatch) {
      final watcher = DirectoryWatcher(dir);
      _watchers.add(watcher);

      watcher.events.listen((event) {
        if (!event.path.endsWith('.dart')) return;

        // Check excludes
        for (final exclude in excludeGlobs) {
          if (exclude.matches(event.path)) return;
        }

        _changedFiles.add(event.path);

        // Debounce
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
          final files = _changedFiles.toList();
          _changedFiles.clear();
          await onChanged(files);
        });
      });
    }
  }

  /// Stop watching.
  Future<void> stop() async {
    _debounceTimer?.cancel();
    _watchers.clear();
  }
}

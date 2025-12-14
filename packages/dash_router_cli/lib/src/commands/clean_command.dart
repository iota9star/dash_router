import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../config/config_loader.dart';
import '../utils/logger.dart';

/// Command for cleaning generated files
class CleanCommand extends Command<int> {
  @override
  final String name = 'clean';

  @override
  final String description = 'Remove generated route files';

  CleanCommand() {
    argParser.addOption(
      'config',
      abbr: 'c',
      help: 'Path to configuration file',
    );
    argParser.addFlag(
      'dry-run',
      help: 'Show what would be deleted without actually deleting',
      defaultsTo: false,
    );
  }

  @override
  Future<int> run() async {
    final configPath = argResults!['config'] as String?;
    final dryRun = argResults!['dry-run'] as bool;

    // Determine project directory
    final projectDir = configPath != null
        ? p.dirname(p.normalize(p.absolute(configPath)))
        : Directory.current.path;

    try {
      // Load configuration
      final config = await ConfigLoader.loadFromProject(projectDir);

      final generate = config['generate'] as Map<String, dynamic>?;
      final outputPath =
          generate?['output'] as String? ?? 'lib/generated/routes.dart';
      final routeInfoOutput = generate?['route_info_output'] as String? ??
          'lib/generated/route_info/';

      final filesToDelete = <String>[];

      await _withWorkingDirectory(projectDir, () async {
        // Find generated files
        final outputFile = File(outputPath);
        if (outputFile.existsSync()) {
          filesToDelete.add(outputPath);
        }

        // Find route info directory
        final routeInfoDir = Directory(routeInfoOutput);
        if (routeInfoDir.existsSync()) {
          filesToDelete.add(routeInfoOutput);
        }

        // Find entire generated directory if empty after cleanup
        final generatedDir = Directory('lib/generated');
        if (generatedDir.existsSync()) {
          filesToDelete.add('lib/generated');
        }
      });

      if (filesToDelete.isEmpty) {
        Logger.info('No generated files to clean');
        return 0;
      }

      if (dryRun) {
        Logger.info('Would delete:');
        for (final file in filesToDelete) {
          Logger.info('  - $file');
        }
        return 0;
      }

      Logger.info('Cleaning generated files...');

      var deleted = 0;
      await _withWorkingDirectory(projectDir, () async {
        for (final path in filesToDelete) {
          try {
            final entity = FileSystemEntity.typeSync(path);
            if (entity == FileSystemEntityType.directory) {
              await Directory(path).delete(recursive: true);
            } else if (entity == FileSystemEntityType.file) {
              await File(path).delete();
            }
            Logger.verbose('  Deleted: $path');
            deleted++;
          } catch (e) {
            Logger.warning('  Failed to delete: $path - $e');
          }
        }
      });

      Logger.success('Cleaned $deleted item(s)');
      return 0;
    } catch (e) {
      Logger.error('Clean failed: $e');
      return 1;
    }
  }

  Future<T> _withWorkingDirectory<T>(
    String dir,
    Future<T> Function() action,
  ) async {
    final previous = Directory.current;
    Directory.current = dir;
    try {
      return await action();
    } finally {
      Directory.current = previous;
    }
  }
}

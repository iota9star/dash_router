import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:dash_router_generator/dash_router_generator.dart';

import '../config/config_loader.dart';
import '../config/file_scanner.dart';
import '../utils/file_watcher.dart';
import '../utils/logger.dart';

/// Command for watching files and regenerating on changes.
///
/// Configuration is optional and can be auto-detected.
class WatchCommand extends Command<int> {
  @override
  final String name = 'watch';

  @override
  final String description = 'Watch for file changes and regenerate routes';

  @override
  List<String> get aliases => ['w'];

  WatchCommand() {
    argParser.addOption(
      'config',
      abbr: 'c',
      help: 'Path to configuration file (optional, defaults to auto-detect)',
    );
    argParser.addFlag(
      'verbose',
      abbr: 'v',
      help: 'Enable verbose output',
      defaultsTo: false,
    );
  }

  @override
  Future<int> run() async {
    final configPath = argResults!['config'] as String?;
    final verbose = argResults!['verbose'] as bool;

    // Determine project directory
    final projectDir = configPath != null
        ? p.dirname(p.normalize(p.absolute(configPath)))
        : Directory.current.path;

    if (verbose) {
      Logger.setVerbose(true);
    }

    try {
      // Load configuration (optional - uses defaults if not found)
      Logger.verbose('Loading configuration from project: $projectDir');

      Map<String, dynamic> config;
      if (configPath != null) {
        final loaded =
            await ConfigLoader.load(p.normalize(p.absolute(configPath)));
        if (loaded == null) {
          Logger.error('Configuration file not found: $configPath');
          return 1;
        }
        config = loaded;
      } else {
        config = await ConfigLoader.loadFromProject(projectDir);
        Logger.verbose('Using auto-detected configuration');
      }

      // Start watching
      Logger.info('Starting file watcher...');
      Logger.info('Press Ctrl+C to stop');
      Logger.info('');

      return await _withWorkingDirectory(projectDir, () async {
        final watcher = DashRouterFileWatcher(config);
        await watcher.start((files) async {
          Logger.info('');
          Logger.info('Changes detected:');
          for (final file in files) {
            Logger.info('  - $file');
          }
          Logger.info('');

          Logger.info('Regenerating routes...');
          final result = await _runGenerate(
            projectDir: projectDir,
            config: config,
            verbose: verbose,
          );

          if (result == 0) {
            Logger.success('Routes regenerated successfully!');
          } else {
            Logger.error('Route generation failed');
          }
        });

        // Keep running until interrupted
        await ProcessSignal.sigint.watch().first;
        await watcher.stop();

        Logger.info('');
        Logger.info('Watcher stopped');
        return 0;
      });
    } catch (e, stack) {
      Logger.error('Watch failed: $e');
      if (verbose) {
        Logger.verbose(stack.toString());
      }
      return 1;
    }
  }

  Future<int> _runGenerate({
    required String projectDir,
    required Map<String, dynamic> config,
    required bool verbose,
  }) async {
    try {
      final scanner = FileScanner(config);
      final files = await scanner.scan();

      if (files.isEmpty) {
        Logger.warning('No route files found');
        return 0;
      }

      final generateConfig =
          (config['generate'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
      final routesOutput =
          (generateConfig['output'] as String?) ?? 'lib/generated/routes.dart';
      final routeInfoOutput =
          (generateConfig['route_info_output'] as String?) ??
              'lib/generated/route_info/';
      final options =
          (generateConfig['options'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};

      final generateRouteInfo =
          (options['generate_route_info'] as bool?) ?? true;
      final generateNavigation =
          (options['generate_navigation'] as bool?) ?? true;
      final generateTypedRoutes =
          (options['generate_typed_routes'] as bool?) ?? true;
      final generateTypedExtensions =
          (options['generate_typed_extensions'] as bool?) ?? true;

      final result = await DashRouterCliCodegen.generate(
        packageRoot: projectDir,
        inputFiles: files,
        options: DashRouterCliCodegenOptions(
          routesOutput: routesOutput,
          routeInfoOutputDir: routeInfoOutput,
          generateRouteInfo: generateRouteInfo,
          generateNavigation: generateNavigation,
          generateTypedRoutes: generateTypedRoutes,
          generateTypedExtensions: generateTypedExtensions,
        ),
        format: true,
      );

      Logger.verbose('Generated ${result.writtenFiles.length} files');
      return 0;
    } catch (e) {
      Logger.error('Generation error: $e');
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

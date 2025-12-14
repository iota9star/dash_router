import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:dash_router_generator/dash_router_generator.dart';

import '../config/config_loader.dart';
import '../config/file_scanner.dart';
import '../utils/logger.dart';

/// Command for generating routes.
///
/// Configuration is optional and can be provided in several ways:
/// 1. `dash_router.yaml` in project root
/// 2. `dash_router` key in `pubspec.yaml`
/// 3. Default configuration (if neither exists)
class GenerateCommand extends Command<int> {
  @override
  final String name = 'generate';

  @override
  final String description = 'Generate route files from annotated classes';

  @override
  List<String> get aliases => ['gen', 'g'];

  GenerateCommand() {
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
    argParser.addFlag(
      'dry-run',
      help: 'Show what would be generated without writing files',
      defaultsTo: false,
    );
  }

  @override
  Future<int> run() async {
    final configPath = argResults!['config'] as String?;
    final verbose = argResults!['verbose'] as bool;
    final dryRun = argResults!['dry-run'] as bool;

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
        // Explicit config path provided
        final loaded =
            await ConfigLoader.load(p.normalize(p.absolute(configPath)));
        if (loaded == null) {
          Logger.error('Configuration file not found: $configPath');
          return 1;
        }
        config = loaded;
      } else {
        // Auto-detect from project (dash_router.yaml, pubspec.yaml, or defaults)
        config = await ConfigLoader.loadFromProject(projectDir);
        Logger.verbose('Using auto-detected configuration');
      }

      return await _withWorkingDirectory(projectDir, () async {
        // Scan for files
        Logger.info('Scanning for route files...');
        final scanner = FileScanner(config);
        final files = await scanner.scan();

        if (files.isEmpty) {
          Logger.warning('No route files found');
          Logger.info('Make sure your files match the configured paths');
          Logger.info('Default paths: lib/**/*.dart');
          return 0;
        }

        Logger.verbose('Found ${files.length} files to process');

        if (dryRun) {
          Logger.info('');
          Logger.info('Dry run - would scan:');
          for (final file in files) {
            Logger.info('  - $file');
          }
          return 0;
        }

        // Run CLI generator
        Logger.info('Generating code...');

        final generateConfig =
            (config['generate'] as Map?)?.cast<String, dynamic>() ??
                const <String, dynamic>{};
        final routesOutput = (generateConfig['output'] as String?) ??
            'lib/generated/routes.dart';
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
          dryRun: dryRun,
          format: true,
        );

        Logger.success('Generated ${result.writtenFiles.length} files');
        for (final file in result.writtenFiles) {
          Logger.info('  Wrote: $file');
        }

        return 0;
      });
    } catch (e, stack) {
      Logger.error('Generation failed: $e');
      if (verbose) {
        Logger.verbose(stack.toString());
      }
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

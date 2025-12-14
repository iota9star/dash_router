import 'dart:io';

import 'package:args/command_runner.dart';

import '../utils/logger.dart';

/// Command for initializing dash_router configuration
class InitCommand extends Command<int> {
  @override
  final String name = 'init';

  @override
  final String description = 'Initialize dash_router configuration file';

  InitCommand() {
    argParser.addFlag(
      'force',
      abbr: 'f',
      help: 'Overwrite existing configuration file',
      defaultsTo: false,
    );
    argParser.addOption(
      'output',
      abbr: 'o',
      help: 'Output path for configuration file',
      defaultsTo: 'dash_router.yaml',
    );
  }

  @override
  Future<int> run() async {
    final force = argResults!['force'] as bool;
    final output = argResults!['output'] as String;

    final configFile = File(output);

    if (configFile.existsSync() && !force) {
      Logger.error('Configuration file already exists: $output');
      Logger.info('Use --force to overwrite');
      return 1;
    }

    try {
      await configFile.writeAsString(_defaultConfig);
      Logger.success('Created configuration file: $output');
      Logger.info('');
      Logger.info('Next steps:');
      Logger.info('  1. Edit $output to configure your routes');
      Logger.info('  2. Add @DashRoute annotations to your page classes');
      Logger.info('  3. Run "dash_router generate" to generate routes');
      return 0;
    } catch (e) {
      Logger.error('Failed to create configuration file: $e');
      return 1;
    }
  }

  static const _defaultConfig = '''
# Dash Router Configuration
# https://github.com/example/dash_router

# Route scanning configuration
scan:
  # Paths to scan for route files (glob patterns)
  paths:
    - "lib/pages/**/*.dart"
    - "lib/features/**/pages/**/*.dart"
  # Paths to exclude from scanning
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

# Generation configuration
generate:
  # Output path for generated routes file
  output: "lib/generated/routes.dart"
  # Output directory for route info files
  route_info_output: "lib/generated/route_info/"
  # Generation options
  options:
    # Generate type-safe route info classes
    generate_route_info: true
    # Enable cache optimization for O(1) access
    enable_cache_optimization: true
    # Generate typed context extensions
    generate_typed_extensions: true
    # Generate params helper classes
    generate_params: true
    # Generate navigation methods
    generate_navigation: true

# Global configuration
global:
  # Default transition animation
  # Options: material, cupertino, fade, slide, scale, none
  default_transition: "material"
  # Default route guards (applied to all routes)
  default_guards: []
  # Default middleware (applied to all routes)
  default_middleware: []
  # Enable global route observer
  enable_observer: true
  # Cache size limit for route info
  cache_size_limit: 100
''';
}

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../config/config_loader.dart';
import '../config/config_validator.dart';
import '../config/file_scanner.dart';
import '../utils/logger.dart';

/// Command for validating route configuration
class ValidateCommand extends Command<int> {
  @override
  final String name = 'validate';

  @override
  final String description = 'Validate route configuration and annotations';

  @override
  List<String> get aliases => ['check', 'v'];

  ValidateCommand() {
    argParser.addOption(
      'config',
      abbr: 'c',
      help: 'Path to configuration file',
      defaultsTo: 'dash_router.yaml',
    );
    argParser.addFlag(
      'strict',
      abbr: 's',
      help: 'Enable strict validation (warnings become errors)',
      defaultsTo: false,
    );
  }

  @override
  Future<int> run() async {
    final configPath = argResults!['config'] as String;
    final strict = argResults!['strict'] as bool;

    final configAbsPath = p.normalize(p.absolute(configPath));
    final projectDir = p.dirname(configAbsPath);

    try {
      Logger.info('Validating configuration...');
      Logger.info('');

      // Check if config file exists
      if (!File(configAbsPath).existsSync()) {
        Logger.error('Configuration file not found: $configAbsPath');
        Logger.info('Run "dash_router init" to create a configuration file');
        return 1;
      }

      // Load and validate configuration
      final config = await ConfigLoader.load(configAbsPath);
      if (config == null) {
        Logger.error('Failed to load configuration');
        return 1;
      }

      final validator = ConfigValidator(config);
      final result = validator.validate();

      // Report errors
      if (result.errors.isNotEmpty) {
        Logger.error('Errors:');
        for (final error in result.errors) {
          Logger.error('  ✗ $error');
        }
        Logger.info('');
      }

      // Report warnings
      if (result.warnings.isNotEmpty) {
        Logger.warning('Warnings:');
        for (final warning in result.warnings) {
          Logger.warning('  ⚠ $warning');
        }
        Logger.info('');
      }

      // Scan for route files
      Logger.info('Checking route files...');
      final files = await _withWorkingDirectory(projectDir, () async {
        final scanner = FileScanner(config);
        return scanner.scan();
      });

      if (files.isEmpty) {
        Logger.warning('No route files found matching configured paths');
      } else {
        Logger.info('  Found ${files.length} route files');
      }

      Logger.info('');

      // Check output directory
      final outputDir = Directory(_getOutputDir(config));
      if (!outputDir.existsSync()) {
        Logger.warning('Output directory does not exist: ${outputDir.path}');
        Logger.info('  It will be created during generation');
      }

      // Summary
      final hasErrors = result.errors.isNotEmpty;
      final hasWarnings = result.warnings.isNotEmpty;

      if (hasErrors) {
        Logger.error('Validation failed with ${result.errors.length} error(s)');
        return 1;
      }

      if (hasWarnings && strict) {
        Logger.error(
          'Validation failed with ${result.warnings.length} warning(s) (strict mode)',
        );
        return 1;
      }

      if (hasWarnings) {
        Logger.success(
          'Validation passed with ${result.warnings.length} warning(s)',
        );
        return 0;
      }

      Logger.success('Validation passed!');
      return 0;
    } catch (e) {
      Logger.error('Validation failed: $e');
      return 1;
    }
  }

  String _getOutputDir(Map<String, dynamic> config) {
    final generate = config['generate'] as Map<String, dynamic>?;
    final output =
        generate?['output'] as String? ?? 'lib/generated/routes.dart';
    return p.dirname(output);
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

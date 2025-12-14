import 'dart:io';

import 'package:args/command_runner.dart';

import 'package:dash_router_cli/src/commands/init_command.dart';
import 'package:dash_router_cli/src/commands/generate_command.dart';
import 'package:dash_router_cli/src/commands/watch_command.dart';
import 'package:dash_router_cli/src/commands/validate_command.dart';
import 'package:dash_router_cli/src/commands/clean_command.dart';
import 'package:dash_router_cli/src/utils/logger.dart';

/// Main entry point for the dash_router CLI
Future<void> main(List<String> arguments) async {
  final runner = CommandRunner<int>(
    'dash_router',
    'CLI tool for dash_router - type-safe Flutter routing',
  )
    ..addCommand(InitCommand())
    ..addCommand(GenerateCommand())
    ..addCommand(WatchCommand())
    ..addCommand(ValidateCommand())
    ..addCommand(CleanCommand());

  try {
    final result = await runner.run(arguments);
    exit(result ?? 0);
  } on UsageException catch (e) {
    Logger.error(e.message);
    Logger.info('');
    Logger.info(e.usage);
    exit(64);
  } catch (e) {
    Logger.error('An unexpected error occurred: $e');
    exit(1);
  }
}

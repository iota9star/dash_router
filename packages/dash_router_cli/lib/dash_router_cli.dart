/// CLI tool for dash_router
///
/// Provides commands for generating routes, watching files, and managing configuration
library dash_router_cli;

export 'src/commands/init_command.dart';
export 'src/commands/generate_command.dart';
export 'src/commands/watch_command.dart';
export 'src/commands/validate_command.dart';
export 'src/commands/clean_command.dart';

export 'src/config/config_loader.dart';
export 'src/config/config_validator.dart';
export 'src/config/file_scanner.dart';

export 'src/utils/logger.dart';
export 'src/utils/file_watcher.dart';

// Re-export from dash_router_generator
export 'package:dash_router_generator/dash_router_generator.dart';

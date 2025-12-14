import 'package:path/path.dart' as p;

/// Configuration for output files
class OutputConfig {
  /// Base output directory
  final String outputDir;

  /// Routes file name
  final String routesFileName;

  /// Route info directory name
  final String routeInfoDirName;

  /// Navigation file name
  final String navigationFileName;

  /// Params file name
  final String paramsFileName;

  const OutputConfig({
    this.outputDir = 'lib/generated',
    this.routesFileName = 'routes.dart',
    this.routeInfoDirName = 'route_info',
    this.navigationFileName = 'navigation.dart',
    this.paramsFileName = 'params.dart',
  });

  /// Full path to routes file
  String get routesFilePath => p.join(outputDir, routesFileName);

  /// Full path to route info directory
  String get routeInfoDirPath => p.join(outputDir, routeInfoDirName);

  /// Full path to navigation file
  String get navigationFilePath => p.join(outputDir, navigationFileName);

  /// Full path to params file
  String get paramsFilePath => p.join(outputDir, paramsFileName);

  /// Get route info file path for a page class
  String routeInfoFilePathFor(String className) {
    final snakeName = _toSnakeCase(className);
    return p.join(routeInfoDirPath, '${snakeName}_route_info.dart');
  }

  String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceFirst('_', '');
  }

  /// Create from YAML map
  factory OutputConfig.fromYaml(Map<String, dynamic> yaml) {
    final generate = yaml['generate'] as Map<String, dynamic>? ?? {};

    final outputPath =
        generate['output'] as String? ?? 'lib/generated/routes.dart';
    final outputDir = p.dirname(outputPath);
    final routesFileName = p.basename(outputPath);

    final routeInfoOutput =
        generate['route_info_output'] as String? ?? 'lib/generated/route_info/';
    final routeInfoDirName = p.basename(
      routeInfoOutput.replaceAll(RegExp(r'/$'), ''),
    );

    return OutputConfig(
      outputDir: outputDir,
      routesFileName: routesFileName,
      routeInfoDirName: routeInfoDirName,
    );
  }

  /// Convert to YAML map
  Map<String, dynamic> toYaml() {
    return {
      'generate': {
        'output': routesFilePath,
        'route_info_output': '$routeInfoDirPath/',
      },
    };
  }

  /// Create a copy with modifications
  OutputConfig copyWith({
    String? outputDir,
    String? routesFileName,
    String? routeInfoDirName,
    String? navigationFileName,
    String? paramsFileName,
  }) {
    return OutputConfig(
      outputDir: outputDir ?? this.outputDir,
      routesFileName: routesFileName ?? this.routesFileName,
      routeInfoDirName: routeInfoDirName ?? this.routeInfoDirName,
      navigationFileName: navigationFileName ?? this.navigationFileName,
      paramsFileName: paramsFileName ?? this.paramsFileName,
    );
  }
}

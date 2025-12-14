import 'dart:io';

import 'package:yaml/yaml.dart';

/// Default configuration values for dash_router.
const defaultConfig = <String, dynamic>{
  'scan': <String, dynamic>{
    'paths': ['lib/**/*.dart'],
    'exclude': ['**/*.g.dart', '**/*.freezed.dart'],
  },
  'generate': <String, dynamic>{
    'output': 'lib/generated/routes.dart',
    'route_info_output': 'lib/generated/route_info/',
    'options': <String, dynamic>{
      'generate_route_info': true,
      'enable_cache_optimization': true,
      'generate_typed_extensions': true,
      'generate_params': true,
      'generate_navigation': true,
    },
  },
  'global': <String, dynamic>{
    'default_transition': 'material',
    'default_guards': <String>[],
    'default_middleware': <String>[],
    'enable_observer': true,
    'cache_size_limit': 100,
  },
};

/// Loader for dash_router configuration.
///
/// Configuration can be provided in several ways (in priority order):
/// 1. `dash_router.yaml` in project root
/// 2. `dash_router` key in `pubspec.yaml`
/// 3. Default configuration (if neither exists)
class ConfigLoader {
  /// Load configuration from available sources.
  ///
  /// Searches for configuration in the following order:
  /// 1. `dash_router.yaml` in project root
  /// 2. `dash_router` key in `pubspec.yaml`
  /// 3. Falls back to default configuration
  static Future<Map<String, dynamic>> loadFromProject(
    String projectRoot,
  ) async {
    // Try dash_router.yaml first
    final dashRouterPath = '$projectRoot/dash_router.yaml';
    final dashRouterConfig = await load(dashRouterPath);
    if (dashRouterConfig != null) {
      return _mergeWithDefaults(dashRouterConfig);
    }

    // Try pubspec.yaml dash_router key
    final pubspecPath = '$projectRoot/pubspec.yaml';
    final pubspecConfig = await loadFromPubspec(pubspecPath);
    if (pubspecConfig != null) {
      return _mergeWithDefaults(pubspecConfig);
    }

    // Use defaults
    return Map<String, dynamic>.from(defaultConfig);
  }

  /// Load configuration from pubspec.yaml under `dash_router` key.
  static Future<Map<String, dynamic>?> loadFromPubspec(String path) async {
    final file = File(path);

    if (!file.existsSync()) {
      return null;
    }

    try {
      final content = await file.readAsString();
      final yaml = loadYaml(content);

      if (yaml == null || yaml is! Map) {
        return null;
      }

      final dashRouterConfig = yaml['dash_router'];
      if (dashRouterConfig == null) {
        return null;
      }

      return _convertYamlToDart(dashRouterConfig) as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  /// Load configuration from a specific file.
  static Future<Map<String, dynamic>?> load(String path) async {
    final file = File(path);

    if (!file.existsSync()) {
      return null;
    }

    try {
      final content = await file.readAsString();
      final yaml = loadYaml(content);

      if (yaml == null) {
        return {};
      }

      final converted = _convertYamlToDart(yaml);
      if (converted == null) {
        return {};
      }
      if (converted is Map<String, dynamic>) {
        return converted;
      }
      if (converted is Map) {
        return converted.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }

      throw ConfigLoadException(
        'Configuration root must be a YAML map, got: ${converted.runtimeType}',
      );
    } catch (e) {
      throw ConfigLoadException('Failed to load configuration: $e');
    }
  }

  /// Save configuration to a file.
  static Future<void> save(String path, Map<String, dynamic> config) async {
    final file = File(path);
    final content = _convertMapToYaml(config);
    await file.writeAsString(content);
  }

  /// Merge user config with defaults, preserving user values.
  static Map<String, dynamic> _mergeWithDefaults(
    Map<String, dynamic> userConfig,
  ) {
    return _deepMerge(
      Map<String, dynamic>.from(defaultConfig),
      userConfig,
    );
  }

  /// Deep merge two maps, with [override] values taking precedence.
  static Map<String, dynamic> _deepMerge(
    Map<String, dynamic> base,
    Map<String, dynamic> override,
  ) {
    final result = Map<String, dynamic>.from(base);

    for (final entry in override.entries) {
      final key = entry.key;
      final value = entry.value;

      if (result.containsKey(key) &&
          result[key] is Map<String, dynamic> &&
          value is Map<String, dynamic>) {
        result[key] = _deepMerge(
          result[key] as Map<String, dynamic>,
          value,
        );
      } else {
        result[key] = value;
      }
    }

    return result;
  }

  static dynamic _convertYamlToDart(dynamic value) {
    if (value is YamlMap) {
      return value.map(
        (key, v) => MapEntry(key.toString(), _convertYamlToDart(v)),
      );
    }
    if (value is YamlList) {
      return value.map(_convertYamlToDart).toList();
    }
    if (value is Map) {
      return value.map(
        (key, v) => MapEntry(key.toString(), _convertYamlToDart(v)),
      );
    }
    if (value is List) {
      return value.map(_convertYamlToDart).toList();
    }
    return value;
  }

  static String _convertMapToYaml(Map<String, dynamic> map, {int indent = 0}) {
    final buffer = StringBuffer();
    final prefix = '  ' * indent;

    for (final entry in map.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is Map<String, dynamic>) {
        buffer.writeln('$prefix$key:');
        buffer.write(_convertMapToYaml(value, indent: indent + 1));
      } else if (value is List) {
        buffer.writeln('$prefix$key:');
        for (final item in value) {
          if (item is Map<String, dynamic>) {
            buffer.writeln('$prefix  -');
            buffer.write(_convertMapToYaml(item, indent: indent + 2));
          } else {
            buffer.writeln('$prefix  - $item');
          }
        }
      } else if (value is String) {
        buffer.writeln('$prefix$key: "$value"');
      } else {
        buffer.writeln('$prefix$key: $value');
      }
    }

    return buffer.toString();
  }
}

/// Exception thrown when configuration loading fails.
class ConfigLoadException implements Exception {
  final String message;

  ConfigLoadException(this.message);

  @override
  String toString() => message;
}

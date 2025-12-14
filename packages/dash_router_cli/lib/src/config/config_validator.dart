/// Validator for dash_router configuration
class ConfigValidator {
  final Map<String, dynamic> config;

  ConfigValidator(this.config);

  /// Validate the configuration
  ValidationResult validate() {
    final errors = <String>[];
    final warnings = <String>[];

    // Validate scan configuration
    _validateScan(errors, warnings);

    // Validate generate configuration
    _validateGenerate(errors, warnings);

    // Validate global configuration
    _validateGlobal(errors, warnings);

    return ValidationResult(errors: errors, warnings: warnings);
  }

  void _validateScan(List<String> errors, List<String> warnings) {
    final scan = config['scan'];

    if (scan == null) {
      warnings.add('No scan configuration found, using defaults');
      return;
    }

    if (scan is! Map) {
      errors.add('scan must be a map');
      return;
    }

    final paths = scan['paths'];
    if (paths != null && paths is! List) {
      errors.add('scan.paths must be a list');
    }

    final exclude = scan['exclude'];
    if (exclude != null && exclude is! List) {
      errors.add('scan.exclude must be a list');
    }

    if (paths is List && paths.isEmpty) {
      warnings.add('scan.paths is empty, no files will be scanned');
    }
  }

  void _validateGenerate(List<String> errors, List<String> warnings) {
    final generate = config['generate'];

    if (generate == null) {
      warnings.add('No generate configuration found, using defaults');
      return;
    }

    if (generate is! Map) {
      errors.add('generate must be a map');
      return;
    }

    final output = generate['output'];
    if (output != null) {
      if (output is! String) {
        errors.add('generate.output must be a string');
      } else if (!output.endsWith('.dart')) {
        warnings.add('generate.output should end with .dart');
      }
    }

    final routeInfoOutput = generate['route_info_output'];
    if (routeInfoOutput != null) {
      if (routeInfoOutput is! String) {
        errors.add('generate.route_info_output must be a string');
      } else if (!routeInfoOutput.endsWith('/')) {
        warnings.add('generate.route_info_output should end with /');
      }
    }

    final options = generate['options'];
    if (options != null && options is! Map) {
      errors.add('generate.options must be a map');
    }
  }

  void _validateGlobal(List<String> errors, List<String> warnings) {
    final global = config['global'];

    if (global == null) {
      return; // Global is optional
    }

    if (global is! Map) {
      errors.add('global must be a map');
      return;
    }

    final defaultTransition = global['default_transition'];
    if (defaultTransition != null) {
      if (defaultTransition is! String) {
        errors.add('global.default_transition must be a string');
      } else if (!_validTransitions.contains(defaultTransition)) {
        warnings.add(
          'Unknown transition type: $defaultTransition. '
          'Valid options: ${_validTransitions.join(', ')}',
        );
      }
    }

    final cacheSizeLimit = global['cache_size_limit'];
    if (cacheSizeLimit != null) {
      if (cacheSizeLimit is! int) {
        errors.add('global.cache_size_limit must be an integer');
      } else if (cacheSizeLimit < 1) {
        errors.add('global.cache_size_limit must be at least 1');
      } else if (cacheSizeLimit > 1000) {
        warnings.add('global.cache_size_limit is very high ($cacheSizeLimit)');
      }
    }
  }

  static const _validTransitions = [
    'material',
    'cupertino',
    'fade',
    'slide',
    'scale',
    'none',
    'custom',
  ];
}

/// Result of configuration validation
class ValidationResult {
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({this.errors = const [], this.warnings = const []});

  bool get isValid => errors.isEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
}

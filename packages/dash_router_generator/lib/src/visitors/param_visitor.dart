import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';

import '../models/route_config_model.dart';

/// Visitor for extracting parameter configurations from constructor parameters.
///
/// All parameters are automatically inferred from the constructor:
/// - Path parameters: Match `:paramName` in route path pattern
/// - Query parameters: Primitive types (String, int, bool, etc.) that are not path params
/// - Body parameters: Complex types that can't be serialized to URL
///
/// Example:
/// ```dart
/// @DashRoute(path: '/user/:id')
/// class UserPage extends StatelessWidget {
///   final String id;        // Path param (matches :id in path)
///   final String? tab;      // Query param (nullable primitive)
///   final UserData? data;   // Body param (complex type)
///
///   const UserPage({
///     super.key,             // Handled specially - passed through
///     required this.id,
///     this.tab,
///     this.data,
///   });
/// }
/// ```
class ParamVisitor {
  /// Extract parameters from a class element based on its constructor
  List<ParamConfigModel> extractParams(ClassElement element, String path) {
    final params = <ParamConfigModel>[];

    // Extract path parameters from path pattern
    final pathParamNames = _extractPathParamNames(path);

    // Find the primary constructor
    final constructor = element.unnamedConstructor ??
        element.constructors.firstWhere(
          (c) => !c.isFactory,
          orElse: () => element.constructors.first,
        );

    for (final param in constructor.formalParameters) {
      final paramConfig = _extractParamConfig(param, pathParamNames);
      if (paramConfig != null) {
        params.add(paramConfig);
      }
    }

    return params;
  }

  List<String> _extractPathParamNames(String path) {
    final regex = RegExp(r':(\w+)');
    return regex.allMatches(path).map((m) => m.group(1)!).toList();
  }

  ParamConfigModel? _extractParamConfig(
    FormalParameterElement param,
    List<String> pathParamNames,
  ) {
    final paramName = param.name;
    if (paramName == null) return null;

    final type = param.type;
    final typeString = type.getDisplayString();
    final isRequired = _isRequiredParam(param);
    final defaultValue = _extractDefaultValue(param);

    // 'key' parameter is handled specially - it's a Key type param
    if (paramName == 'key') {
      // Key is passed through from navigation, treat as body param
      return ParamConfigModel(
        name: paramName,
        fieldName: paramName,
        type: type,
        typeString: typeString,
        isRequired: isRequired,
        defaultValue: defaultValue,
        kind: ParamKind.body,
        isKey: true,
      );
    }

    // Skip 'child' parameter for shell routes
    if (paramName == 'child') {
      return null;
    }

    // Auto-detect parameter type based on path and name
    if (pathParamNames.contains(paramName)) {
      // This is a path parameter
      return ParamConfigModel(
        name: paramName,
        fieldName: paramName,
        type: type,
        typeString: typeString,
        isRequired: isRequired,
        defaultValue: defaultValue,
        kind: ParamKind.path,
      );
    }

    // Check if it's a primitive type - likely a query param
    if (_isPrimitiveType(typeString)) {
      return ParamConfigModel(
        name: paramName,
        fieldName: paramName,
        type: type,
        typeString: typeString,
        isRequired: isRequired,
        defaultValue: defaultValue,
        kind: ParamKind.query,
      );
    }

    // Complex types are body params
    return ParamConfigModel(
      name: paramName,
      fieldName: paramName,
      type: type,
      typeString: typeString,
      isRequired: isRequired,
      defaultValue: defaultValue,
      kind: ParamKind.body,
    );
  }

  bool _isRequiredParam(FormalParameterElement param) {
    // `isRequired` on analyzer elements can be confusing; handle both named/positional.
    return param.isRequiredNamed || param.isRequiredPositional;
  }

  String? _extractDefaultValue(FormalParameterElement param) {
    if (!param.hasDefaultValue) return null;
    return param.defaultValueCode;
  }

  bool _isPrimitiveType(String type) {
    final baseType = type.replaceAll('?', '').replaceAll(RegExp(r'<.*>'), '');
    return const [
      'String',
      'int',
      'double',
      'num',
      'bool',
      'DateTime',
      'List',
      'Set',
      'Map',
    ].contains(baseType);
  }
}

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

import '../utils/string_utils.dart';

/// Model representing a route configuration extracted from annotations.
///
/// This model holds all the information needed to generate route code,
/// including the path pattern, parameters, guards, middleware, and
/// transition configuration.
///
/// ## Example
///
/// ```dart
/// // For a route annotated as:
/// @DashRoute(path: '/user/:id')
/// class UserPage extends StatelessWidget { ... }
///
/// // The model will contain:
/// // - path: '/user/:id'
/// // - pathParams: [ParamConfigModel(name: 'id', ...)]
/// // - Generated route class name: 'User$IdRoute'
/// ```
///
/// ## Generation Process
///
/// 1. **Extract Information**: Scans class for route annotations
/// 2. **Parse Parameters**: Extracts path, query, and body parameters
/// 3. **Generate Names**: Creates route, info, and params class names
/// 4. **Create Models**: Populates this model with all metadata
/// 5. **Template Rendering**: Uses model to generate final code
///
/// ## Usage in Generator
///
/// This model is used throughout the code generation pipeline:
/// - **Visitor**: Extracts from AST
/// - **Template**: Renders to code templates
/// - **Validator**: Ensures configuration validity
class RouteConfigModel {
  /// The annotated class element
  final ClassElement classElement;

  /// Route path pattern (e.g., '/user/:id')
  final String path;

  /// Route name (e.g., 'userDetail')
  final String? name;

  /// Parent route name for nested routes
  final String? parent;

  /// Whether to keep this route alive
  final bool keepAlive;

  /// Whether this is fullscreen dialog
  final bool fullscreenDialog;

  /// Whether to maintain state
  final bool maintainState;

  /// Route-level transition expression (const DashTransition ...), emitted into
  /// generated `RouteEntry.transition`.
  final String? transitionCode;

  /// Import paths needed for the transition types used in transitionCode.
  final List<String> transitionImports;

  /// Whether this is the initial route
  final bool isInitial;

  /// Whether this is a dialog route
  final bool isDialog;

  /// Whether this is a shell route
  final bool isShell;

  /// Redirect target
  final String? redirectTo;

  /// Redirect permanence (for @RedirectRoute)
  final bool redirectPermanent;

  /// Route guards code expression (e.g., '[const AuthGuard()]')
  ///
  /// This is extracted directly from the source annotation to preserve
  /// the exact code the user wrote.
  final String? guardsCode;

  /// Import paths needed for guard types
  final List<String> guardImports;

  /// Route middleware code expression (e.g., '[const LoggingMiddleware()]')
  ///
  /// This is extracted directly from the source annotation to preserve
  /// the exact code the user wrote.
  final String? middlewareCode;

  /// Import paths needed for middleware types
  final List<String> middlewareImports;

  /// Path parameters
  final List<ParamConfigModel> pathParams;

  /// Query parameters
  final List<ParamConfigModel> queryParams;

  /// Body parameters
  final List<ParamConfigModel> bodyParams;

  /// Extra metadata
  final Map<String, dynamic> metadata;

  RouteConfigModel({
    required this.classElement,
    required this.path,
    this.name,
    this.parent,
    this.keepAlive = false,
    this.fullscreenDialog = false,
    this.maintainState = true,
    this.transitionCode,
    this.transitionImports = const [],
    this.isInitial = false,
    this.isDialog = false,
    this.isShell = false,
    this.redirectTo,
    this.redirectPermanent = false,
    this.guardsCode,
    this.guardImports = const [],
    this.middlewareCode,
    this.middlewareImports = const [],
    this.pathParams = const [],
    this.queryParams = const [],
    this.bodyParams = const [],
    this.metadata = const {},
  });

  /// Get the class name
  String get className => classElement.name ?? 'UnnamedClass';

  /// Get the full import path
  String get importPath => classElement.library.identifier;

  /// Get the generated route name (camelCase) based on path.
  ///
  /// This follows the naming convention:
  /// - `/app/user/:id` -> `appUser$Id`
  /// - `/app/settings` -> `appSettings`
  /// - `/` -> `root`
  ///
  /// If a custom name is provided via the annotation, it will be used instead.
  String get routeName => name ?? StringUtils.pathToIdentifier(path);

  /// Get the generated route class name (PascalCase) based on path.
  ///
  /// This follows the naming convention:
  /// - `/app/user/:id` -> `AppUser$IdRoute`
  /// - `/app/settings` -> `AppSettingsRoute`
  /// - `/` -> `RootRoute`
  String get routeClassName => StringUtils.generateRouteClassName(path);

  /// Get the generated route info class name.
  ///
  /// This follows the naming convention:
  /// - `/app/user/:id` -> `AppUser$IdRouteInfo`
  /// - `/app/settings` -> `AppSettingsRouteInfo`
  String get routeInfoClassName => '${routeClassName}Info';

  /// Get the generated params class name.
  ///
  /// This follows the naming convention:
  /// - `/app/user/:id` -> `AppUser$IdParams`
  /// - `/app/settings` -> `AppSettingsParams`
  String get paramsClassName =>
      '${routeClassName.replaceAll('Route', '')}Params';

  /// Check if route has any parameters
  bool get hasParams =>
      pathParams.isNotEmpty || queryParams.isNotEmpty || bodyParams.isNotEmpty;

  /// Check if route has path parameters
  bool get hasPathParams => pathParams.isNotEmpty;

  /// Check if route has query parameters
  bool get hasQueryParams => queryParams.isNotEmpty;

  /// Check if route has body parameters
  bool get hasBodyParams => bodyParams.isNotEmpty;

  /// Get all parameters
  List<ParamConfigModel> get allParams => [
        ...pathParams,
        ...queryParams,
        ...bodyParams,
      ];

  /// Get required parameters
  List<ParamConfigModel> get requiredParams =>
      allParams.where((p) => p.isRequired).toList();

  /// Get optional parameters.
  List<ParamConfigModel> get optionalParams =>
      allParams.where((p) => !p.isRequired).toList();

  /// Create a copy with modifications.
  RouteConfigModel copyWith({
    ClassElement? classElement,
    String? path,
    String? name,
    String? parent,
    bool? keepAlive,
    bool? fullscreenDialog,
    bool? maintainState,
    String? transitionCode,
    List<String>? transitionImports,
    bool? isInitial,
    bool? isDialog,
    bool? isShell,
    String? redirectTo,
    bool? redirectPermanent,
    String? guardsCode,
    List<String>? guardImports,
    String? middlewareCode,
    List<String>? middlewareImports,
    List<ParamConfigModel>? pathParams,
    List<ParamConfigModel>? queryParams,
    List<ParamConfigModel>? bodyParams,
    Map<String, dynamic>? metadata,
  }) {
    return RouteConfigModel(
      classElement: classElement ?? this.classElement,
      path: path ?? this.path,
      name: name ?? this.name,
      parent: parent ?? this.parent,
      keepAlive: keepAlive ?? this.keepAlive,
      fullscreenDialog: fullscreenDialog ?? this.fullscreenDialog,
      maintainState: maintainState ?? this.maintainState,
      transitionCode: transitionCode ?? this.transitionCode,
      transitionImports: transitionImports ?? this.transitionImports,
      isInitial: isInitial ?? this.isInitial,
      isDialog: isDialog ?? this.isDialog,
      isShell: isShell ?? this.isShell,
      redirectTo: redirectTo ?? this.redirectTo,
      redirectPermanent: redirectPermanent ?? this.redirectPermanent,
      guardsCode: guardsCode ?? this.guardsCode,
      guardImports: guardImports ?? this.guardImports,
      middlewareCode: middlewareCode ?? this.middlewareCode,
      middlewareImports: middlewareImports ?? this.middlewareImports,
      pathParams: pathParams ?? this.pathParams,
      queryParams: queryParams ?? this.queryParams,
      bodyParams: bodyParams ?? this.bodyParams,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Model representing a parameter configuration
class ParamConfigModel {
  /// Parameter name in the route
  final String name;

  /// Parameter name in the class (may differ from route name)
  final String fieldName;

  /// Parameter type
  final DartType type;

  /// Parameter type as string
  final String typeString;

  /// Whether this parameter is required
  final bool isRequired;

  /// Default value (as string)
  final String? defaultValue;

  /// Parameter kind (path, query, body)
  final ParamKind kind;

  /// Custom decoder class name
  final String? decoder;

  /// Validation pattern (for string params)
  final String? pattern;

  /// Minimum value (for numeric params)
  final num? min;

  /// Maximum value (for numeric params)
  final num? max;

  /// Description for documentation
  final String? description;

  /// Whether this is a Key parameter (Flutter Key for widget)
  final bool isKey;

  ParamConfigModel({
    required this.name,
    required this.fieldName,
    required this.type,
    required this.typeString,
    this.isRequired = true,
    this.defaultValue,
    this.kind = ParamKind.path,
    this.decoder,
    this.pattern,
    this.min,
    this.max,
    this.description,
    this.isKey = false,
  });

  /// Check if this is a path parameter
  bool get isPathParam => kind == ParamKind.path;

  /// Check if this is a query parameter
  bool get isQueryParam => kind == ParamKind.query;

  /// Check if this is a body parameter
  bool get isBodyParam => kind == ParamKind.body;

  /// Check if type is nullable
  bool get isNullable => type.nullabilitySuffix != NullabilitySuffix.none;

  /// Check if has custom decoder
  bool get hasDecoder => decoder != null && decoder!.isNotEmpty;

  /// Check if has validation
  bool get hasValidation => pattern != null || min != null || max != null;

  /// Get the non-nullable type string
  String get nonNullableTypeString {
    if (typeString.endsWith('?')) {
      return typeString.substring(0, typeString.length - 1);
    }
    return typeString;
  }
}

/// Kind of route parameter
enum ParamKind {
  /// Path parameter (e.g., /user/:id)
  path,

  /// Query parameter (e.g., ?tab=profile)
  query,

  /// Body parameter (passed via arguments)
  body,
}

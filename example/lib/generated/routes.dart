// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_element, unnecessary_cast, unused_local_variable

import 'package:flutter/widgets.dart';
import 'package:dash_router/dash_router.dart';

import 'package:dash_router_example/pages/admin_pages.dart';
import 'package:dash_router_example/pages/app_shell.dart';
import 'package:dash_router_example/pages/catalog_page.dart';
import 'package:dash_router_example/pages/checkout_page.dart';
import 'package:dash_router_example/shared/user_data.dart';
import 'package:dash_router_example/shared/product.dart';
import 'package:dash_router_example/shared/shipping_info.dart';
import 'package:dash_router_example/pages/dashboard_page.dart';
import 'package:dash_router_example/pages/edit_profile_page.dart';
import 'package:dash_router_example/pages/home_page.dart';
import 'package:dash_router_example/pages/login_page.dart';
import 'package:dash_router_example/pages/navigation_demo_page.dart';
import 'package:dash_router_example/pages/order_page.dart';
import 'package:dash_router_example/pages/product_page.dart';
import 'package:dash_router_example/pages/search_page.dart';
import 'package:dash_router_example/pages/settings_page.dart';
import 'package:dash_router_example/shared/transition/transition.dart';
import 'package:dash_router_example/pages/user_page.dart';
import 'package:dash_router_example/guards/auth_guard.dart';

/// Generated routes with static priority over dynamic.
///
/// Usage:
/// ```dart
/// // Access route entry
/// Routes.appSettings.pattern // '/app/settings'
/// Routes.appUserId.pattern   // '/app/user/:id'
/// ```
abstract final class Routes {
  /// Redirect: / → /app/home
  static const rootRedirect = RedirectEntry(from: '/', to: '/app/home');

  /// Route: /app → AppShell
  static final app = RouteEntry(
    pattern: '/app',
    name: 'appShell',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return AppShell(
        child: const SizedBox.shrink(),
        key: params.body.get<Key?>('key'),
      );
    })(),
    shellBuilder: (context, data, child) => (() {
      final params = TypedParamsResolver(data.params);
      return AppShell(child: child, key: params.body.get<Key?>('key'));
    })(),
  );

  /// Route: /app/admin → AdminShell
  static final appAdmin = RouteEntry(
    pattern: '/app/admin',
    name: 'adminShell',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return AdminShell(
        child: const SizedBox.shrink(),
        key: params.body.get<Key?>('key'),
      );
    })(),
    shellBuilder: (context, data, child) => (() {
      final params = TypedParamsResolver(data.params);
      return AdminShell(child: child, key: params.body.get<Key?>('key'));
    })(),
    parent: '/app',
  );

  /// Route: /app/admin/settings → AdminSettingsPage
  static final appAdminSettings = RouteEntry(
    pattern: '/app/admin/settings',
    name: 'adminSettings',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return AdminSettingsPage(key: params.body.get<Key?>('key'));
    })(),
    parent: '/app/admin',
  );

  /// Route: /app/admin/users → AdminUsersPage
  static final appAdminUsers = RouteEntry(
    pattern: '/app/admin/users',
    name: 'adminUsers',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return AdminUsersPage(key: params.body.get<Key?>('key'));
    })(),
    parent: '/app/admin',
  );

  /// Route: /app/checkout → CheckoutPage
  static final appCheckout = RouteEntry(
    pattern: '/app/checkout',
    name: 'checkout',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return CheckoutPage(key: params.body.get<Key?>('key'));
    })(),
    parent: '/app',
    metadata: const <String, dynamic>{},
    transition: const DashSlideTransition.bottom(),
  );

  /// Route: /app/dashboard → DashboardPage
  static final appDashboard = RouteEntry(
    pattern: '/app/dashboard',
    name: 'dashboard',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return DashboardPage(key: params.body.get<Key?>('key'));
    })(),
    parent: '/app',
    transition: const DashSlideTransition.bottom(),
  );

  /// Route: /app/dashboard/analytics → DashboardAnalyticsPage
  static final appDashboardAnalytics = RouteEntry(
    pattern: '/app/dashboard/analytics',
    name: 'dashboardAnalytics',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return DashboardAnalyticsPage(key: params.body.get<Key?>('key'));
    })(),
    parent: '/app',
    transition: const DashSlideTransition.right(),
  );

  /// Route: /app/dashboard/reports → DashboardReportsPage
  static final appDashboardReports = RouteEntry(
    pattern: '/app/dashboard/reports',
    name: 'dashboardReports',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return DashboardReportsPage(
        key: params.body.get<Key?>('key'),
        dateRange: params.query.get<String>(
          'dateRange',
          defaultValue: 'last_7_days',
        ),
        reportType: params.query.get<String?>('reportType'),
      );
    })(),
    parent: '/app',
    transition: const DashSlideTransition.right(),
  );

  /// Route: /app/demo → NavigationDemoPage
  static final appDemo = RouteEntry(
    pattern: '/app/demo',
    name: 'navigationDemo',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return NavigationDemoPage(key: params.body.get<Key?>('key'));
    })(),
    parent: '/app',
  );

  /// Route: /app/edit-profile → EditProfilePage
  static final appEditProfile = RouteEntry(
    pattern: '/app/edit-profile',
    name: 'editProfile',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return EditProfilePage(key: params.body.get<Key?>('key'));
    })(),
    parent: '/app',
    transition: const DashSlideTransition.bottom(),
    fullscreenDialog: true,
  );

  /// Route: /app/home → HomePage
  static final appHome = RouteEntry(
    pattern: '/app/home',
    name: 'home',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return HomePage(key: params.body.get<Key?>('key'));
    })(),
    parent: '/app',
  );

  /// Route: /app/order → OrderPage
  static final appOrder = RouteEntry(
    pattern: '/app/order',
    name: 'order',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return OrderPage(key: params.body.get<Key?>('key'));
    })(),
    metadata: const <String, dynamic>{},
    transition: const DashFadeTransition(),
  );

  /// Route: /app/products → ProductListPage
  static final appProducts = RouteEntry(
    pattern: '/app/products',
    name: 'productList',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return ProductListPage(key: params.body.get<Key?>('key'));
    })(),
    parent: '/app',
    transition: const DashSlideTransition.right(),
  );

  /// Route: /app/search → SearchPage
  static final appSearch = RouteEntry(
    pattern: '/app/search',
    name: 'search',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return SearchPage(key: params.body.get<Key?>('key'));
    })(),
    parent: '/app',
  );

  /// Route: /app/settings → SettingsPage
  static final appSettings = RouteEntry(
    pattern: '/app/settings',
    name: 'settings',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return SettingsPage(key: params.body.get<Key?>('key'));
    })(),
    parent: '/app',
    transition: const SlideScaleTransition(),
  );

  /// Route: /login → LoginPage
  static final login = RouteEntry(
    pattern: '/login',
    name: 'login',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return LoginPage(key: params.body.get<Key?>('key'));
    })(),
  );

  /// Route: /app/admin/users/:userId → AdminUserDetailPage
  static final appAdminUsers$userId = RouteEntry(
    pattern: '/app/admin/users/:userId',
    name: 'adminUserDetail',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return AdminUserDetailPage(
        key: params.body.get<Key?>('key'),
        userId: params.path.get<String>('userId'),
      );
    })(),
    parent: '/app/admin',
    transition: const DashSlideTransition.right(),
  );

  /// Route: /app/catalog/:category/:subcategory/:itemId → CatalogPage
  static final appCatalog$category$subcategory$itemId = RouteEntry(
    pattern: '/app/catalog/:category/:subcategory/:itemId',
    name: 'catalogItem',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return CatalogPage(
        key: params.body.get<Key?>('key'),
        category: params.path.get<String>('category'),
        subcategory: params.path.get<String>('subcategory'),
        itemId: params.path.get<String>('itemId'),
        sort: params.query.get<String?>('sort'),
        filter: params.query.get<String?>('filter'),
      );
    })(),
    parent: '/app',
    transition: const DashSlideTransition.right(),
  );

  /// Route: /app/products/:productId → ProductDetailPage
  static final appProducts$productId = RouteEntry(
    pattern: '/app/products/:productId',
    name: 'productDetail',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return ProductDetailPage(
        key: params.body.get<Key?>('key'),
        productId: params.path.get<String>('productId'),
        highlight: params.query.get<String>('highlight', defaultValue: 'false'),
        referralCode: params.query.get<String?>('referralCode'),
        product: params.body.get<Product?>('product'),
      );
    })(),
    parent: '/app',
    transition: const DashSlideTransition.right(),
  );

  /// Route: /app/search/:query → SearchResultsPage
  static final appSearch$query = RouteEntry(
    pattern: '/app/search/:query',
    name: 'searchResults',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return SearchResultsPage(
        key: params.body.get<Key?>('key'),
        query: params.path.get<String>('query'),
        page: params.query.get<String>('page', defaultValue: '1'),
        filter: params.query.get<String?>('filter'),
      );
    })(),
    parent: '/app',
  );

  /// Route: /app/user/:id → UserPage
  static final appUser$id = RouteEntry(
    pattern: '/app/user/:id',
    name: 'userDetail',
    builder: (context, data) => (() {
      final params = TypedParamsResolver(data.params);
      return UserPage(
        key: params.body.get<Key?>('key'),
        id: params.path.get<String>('id'),
        tab: params.query.get<String?>('tab'),
        userData: params.body.get<UserData?>('userData'),
      );
    })(),
    parent: '/app',
    guards: [AuthGuard()],
    transition: const DashSlideTransition.right(),
  );
}

/// Generated route entries for DashRouter.
///
/// Routes are ordered with static paths before dynamic paths,
/// ensuring `/app/user/admin` matches before `/app/user/:id`.
final List<RouteEntry> generatedRoutes = [
  Routes.app,
  Routes.appAdmin,
  Routes.appAdminSettings,
  Routes.appAdminUsers,
  Routes.appCheckout,
  Routes.appDashboard,
  Routes.appDashboardAnalytics,
  Routes.appDashboardReports,
  Routes.appDemo,
  Routes.appEditProfile,
  Routes.appHome,
  Routes.appOrder,
  Routes.appProducts,
  Routes.appSearch,
  Routes.appSettings,
  Routes.login,
  Routes.appAdminUsers$userId,
  Routes.appCatalog$category$subcategory$itemId,
  Routes.appProducts$productId,
  Routes.appSearch$query,
  Routes.appUser$id,
];

/// Generated redirect entries for DashRouter
final List<RedirectEntry> generatedRedirects = [Routes.rootRedirect];

// ============================================
// Typed Route Objects (Type-Safe Navigation)
// ============================================

/// Typed route objects provide compile-time type safety
/// for navigation parameters.
///
/// Usage:
/// ```dart
/// // Navigate with type-safe parameters
/// context.push(AppUser$IdRoute(id: '123'));
///
/// // With query parameters
/// context.push(AppUser$IdRoute(id: '123', tab: 'profile'));
/// ```

/// Typed route for [AdminShell] at `/app/admin`.
///
/// This route class provides type-safe navigation to
/// the AdminShell widget.
///
/// ## Example
///
/// ```dart
/// context.push(AppAdminRoute(
/// ));
/// ```
class AppAdminRoute extends DashTypedRoute {
  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for AdminShell.
  const AppAdminRoute({this.$transition});

  /// Route pattern: `/app/admin`
  @override
  String get $pattern => '/app/admin';

  /// Route name: `adminShell`
  @override
  String get $name => 'adminShell';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/admin';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => null;

  /// Body arguments for this route.
  @override
  Object? get $body => null;
}

/// Typed route for [AdminUsersPage] at `/app/admin/users`.
///
/// This route class provides type-safe navigation to
/// the AdminUsersPage widget.
///
/// ## Example
///
/// ```dart
/// context.push(AppAdminUsersRoute(
/// ));
/// ```
class AppAdminUsersRoute extends DashTypedRoute {
  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for AdminUsersPage.
  const AppAdminUsersRoute({this.$transition});

  /// Route pattern: `/app/admin/users`
  @override
  String get $pattern => '/app/admin/users';

  /// Route name: `adminUsers`
  @override
  String get $name => 'adminUsers';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/admin/users';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => null;

  /// Body arguments for this route.
  @override
  Object? get $body => null;
}

/// Typed route for [AdminUserDetailPage] at `/app/admin/users/:userId`.
///
/// This route class provides type-safe navigation to
/// the AdminUserDetailPage widget.
///
/// ## Path Parameters
///
/// - `userId` (String) - required path parameter
///
/// ## Example
///
/// ```dart
/// context.push(AppAdminUsers$UserIdRoute(
///   userId: '<value>',
/// ));
/// ```
class AppAdminUsers$UserIdRoute extends DashTypedRoute {
  /// Path parameter: userId
  final String userId;

  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for AdminUserDetailPage.
  const AppAdminUsers$UserIdRoute({required this.userId, this.$transition});

  /// Route pattern: `/app/admin/users/:userId`
  @override
  String get $pattern => '/app/admin/users/:userId';

  /// Route name: `adminUserDetail`
  @override
  String get $name => 'adminUserDetail';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/admin/users/${userId}';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => null;

  /// Body arguments for this route.
  @override
  Object? get $body => null;
}

/// Typed route for [AdminSettingsPage] at `/app/admin/settings`.
///
/// This route class provides type-safe navigation to
/// the AdminSettingsPage widget.
///
/// ## Example
///
/// ```dart
/// context.push(AppAdminSettingsRoute(
/// ));
/// ```
class AppAdminSettingsRoute extends DashTypedRoute {
  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for AdminSettingsPage.
  const AppAdminSettingsRoute({this.$transition});

  /// Route pattern: `/app/admin/settings`
  @override
  String get $pattern => '/app/admin/settings';

  /// Route name: `adminSettings`
  @override
  String get $name => 'adminSettings';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/admin/settings';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => null;

  /// Body arguments for this route.
  @override
  Object? get $body => null;
}

/// Typed route for [AppShell] at `/app`.
///
/// This route class provides type-safe navigation to
/// the AppShell widget.
///
/// ## Example
///
/// ```dart
/// context.push(AppRoute(
/// ));
/// ```
class AppRoute extends DashTypedRoute {
  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for AppShell.
  const AppRoute({this.$transition});

  /// Route pattern: `/app`
  @override
  String get $pattern => '/app';

  /// Route name: `appShell`
  @override
  String get $name => 'appShell';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => null;

  /// Body arguments for this route.
  @override
  Object? get $body => null;
}

/// Typed route for [CatalogPage] at `/app/catalog/:category/:subcategory/:itemId`.
///
/// This route class provides type-safe navigation to
/// the CatalogPage widget.
///
/// ## Path Parameters
///
/// - `category` (String) - required path parameter
/// - `subcategory` (String) - required path parameter
/// - `itemId` (String) - required path parameter
///
/// ## Query Parameters
///
/// - `sort` (String?)
/// - `filter` (String?)
///
/// ## Example
///
/// ```dart
/// context.push(AppCatalog$Category$Subcategory$ItemIdRoute(
///   category: '<value>',
///   subcategory: '<value>',
///   itemId: '<value>',
/// ));
/// ```
class AppCatalog$Category$Subcategory$ItemIdRoute extends DashTypedRoute {
  /// Path parameter: category
  final String category;

  /// Path parameter: subcategory
  final String subcategory;

  /// Path parameter: itemId
  final String itemId;

  /// Query parameter: sort
  final String? sort;

  /// Query parameter: filter
  final String? filter;

  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for CatalogPage.
  const AppCatalog$Category$Subcategory$ItemIdRoute({
    required this.category,
    required this.subcategory,
    required this.itemId,
    this.sort,
    this.filter,
    this.$transition,
  });

  /// Route pattern: `/app/catalog/:category/:subcategory/:itemId`
  @override
  String get $pattern => '/app/catalog/:category/:subcategory/:itemId';

  /// Route name: `catalogItem`
  @override
  String get $name => 'catalogItem';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/catalog/${category}/${subcategory}/${itemId}';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => {
        if (sort != null) 'sort': sort,
        if (filter != null) 'filter': filter,
      };

  /// Body arguments for this route.
  @override
  Object? get $body => null;
}

/// Typed route for [CheckoutPage] at `/app/checkout`.
///
/// This route class provides type-safe navigation to
/// the CheckoutPage widget.
///
/// ## Example
///
/// ```dart
/// context.push(AppCheckoutRoute(
/// ));
/// ```
class AppCheckoutRoute extends DashTypedRoute {
  /// Body argument: UserData
  final UserData userData;

  /// Body argument: Product
  final Product product;

  /// Body argument: ShippingInfo
  final ShippingInfo shippingInfo;

  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for CheckoutPage.
  const AppCheckoutRoute({
    required this.userData,
    required this.product,
    required this.shippingInfo,
    this.$transition,
  });

  /// Route pattern: `/app/checkout`
  @override
  String get $pattern => '/app/checkout';

  /// Route name: `checkout`
  @override
  String get $name => 'checkout';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/checkout';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => null;

  /// Body arguments for this route.
  @override
  Object? get $body => (userData, product, shippingInfo);
}

/// Typed route for [DashboardPage] at `/app/dashboard`.
///
/// This route class provides type-safe navigation to
/// the DashboardPage widget.
///
/// ## Example
///
/// ```dart
/// context.push(AppDashboardRoute(
/// ));
/// ```
class AppDashboardRoute extends DashTypedRoute {
  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for DashboardPage.
  const AppDashboardRoute({this.$transition});

  /// Route pattern: `/app/dashboard`
  @override
  String get $pattern => '/app/dashboard';

  /// Route name: `dashboard`
  @override
  String get $name => 'dashboard';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/dashboard';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => null;

  /// Body arguments for this route.
  @override
  Object? get $body => null;
}

/// Typed route for [DashboardAnalyticsPage] at `/app/dashboard/analytics`.
///
/// This route class provides type-safe navigation to
/// the DashboardAnalyticsPage widget.
///
/// ## Example
///
/// ```dart
/// context.push(AppDashboardAnalyticsRoute(
/// ));
/// ```
class AppDashboardAnalyticsRoute extends DashTypedRoute {
  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for DashboardAnalyticsPage.
  const AppDashboardAnalyticsRoute({this.$transition});

  /// Route pattern: `/app/dashboard/analytics`
  @override
  String get $pattern => '/app/dashboard/analytics';

  /// Route name: `dashboardAnalytics`
  @override
  String get $name => 'dashboardAnalytics';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/dashboard/analytics';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => null;

  /// Body arguments for this route.
  @override
  Object? get $body => null;
}

/// Typed route for [DashboardReportsPage] at `/app/dashboard/reports`.
///
/// This route class provides type-safe navigation to
/// the DashboardReportsPage widget.
///
/// ## Query Parameters
///
/// - `dateRange` (String, default: 'last_7_days')
/// - `reportType` (String?)
///
/// ## Example
///
/// ```dart
/// context.push(AppDashboardReportsRoute(
/// ));
/// ```
class AppDashboardReportsRoute extends DashTypedRoute {
  /// Query parameter: dateRange
  ///
  /// Default: `'last_7_days'`
  final String dateRange;

  /// Query parameter: reportType
  final String? reportType;

  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for DashboardReportsPage.
  const AppDashboardReportsRoute({
    this.dateRange = 'last_7_days',
    this.reportType,
    this.$transition,
  });

  /// Route pattern: `/app/dashboard/reports`
  @override
  String get $pattern => '/app/dashboard/reports';

  /// Route name: `dashboardReports`
  @override
  String get $name => 'dashboardReports';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/dashboard/reports';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => {
        'dateRange': dateRange,
        if (reportType != null) 'reportType': reportType,
      };

  /// Body arguments for this route.
  @override
  Object? get $body => null;
}

/// Typed route for [EditProfilePage] at `/app/edit-profile`.
///
/// This route class provides type-safe navigation to
/// the EditProfilePage widget.
///
/// ## Example
///
/// ```dart
/// context.push(AppEditProfileRoute(
/// ));
/// ```
class AppEditProfileRoute extends DashTypedRoute {
  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for EditProfilePage.
  const AppEditProfileRoute({this.$transition});

  /// Route pattern: `/app/edit-profile`
  @override
  String get $pattern => '/app/edit-profile';

  /// Route name: `editProfile`
  @override
  String get $name => 'editProfile';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/edit-profile';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => null;

  /// Body arguments for this route.
  @override
  Object? get $body => null;
}

/// Typed route for [HomePage] at `/app/home`.
///
/// This route class provides type-safe navigation to
/// the HomePage widget.
///
/// ## Example
///
/// ```dart
/// context.push(AppHomeRoute(
/// ));
/// ```
class AppHomeRoute extends DashTypedRoute {
  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for HomePage.
  const AppHomeRoute({this.$transition});

  /// Route pattern: `/app/home`
  @override
  String get $pattern => '/app/home';

  /// Route name: `home`
  @override
  String get $name => 'home';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/home';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => null;

  /// Body arguments for this route.
  @override
  Object? get $body => null;
}

/// Typed route for [LoginPage] at `/login`.
///
/// This route class provides type-safe navigation to
/// the LoginPage widget.
///
/// ## Example
///
/// ```dart
/// context.push(LoginRoute(
/// ));
/// ```
class LoginRoute extends DashTypedRoute {
  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for LoginPage.
  const LoginRoute({this.$transition});

  /// Route pattern: `/login`
  @override
  String get $pattern => '/login';

  /// Route name: `login`
  @override
  String get $name => 'login';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/login';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => null;

  /// Body arguments for this route.
  @override
  Object? get $body => null;
}

/// Typed route for [NavigationDemoPage] at `/app/demo`.
///
/// This route class provides type-safe navigation to
/// the NavigationDemoPage widget.
///
/// ## Example
///
/// ```dart
/// context.push(AppDemoRoute(
/// ));
/// ```
class AppDemoRoute extends DashTypedRoute {
  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for NavigationDemoPage.
  const AppDemoRoute({this.$transition});

  /// Route pattern: `/app/demo`
  @override
  String get $pattern => '/app/demo';

  /// Route name: `navigationDemo`
  @override
  String get $name => 'navigationDemo';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/demo';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => null;

  /// Body arguments for this route.
  @override
  Object? get $body => null;
}

/// Typed route for [OrderPage] at `/app/order`.
///
/// This route class provides type-safe navigation to
/// the OrderPage widget.
///
/// ## Example
///
/// ```dart
/// context.push(AppOrderRoute(
/// ));
/// ```
class AppOrderRoute extends DashTypedRoute {
  /// Body argument: UserData
  final UserData userData;

  /// Body argument: Product
  final Product product;

  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for OrderPage.
  const AppOrderRoute({
    required this.userData,
    required this.product,
    this.$transition,
  });

  /// Route pattern: `/app/order`
  @override
  String get $pattern => '/app/order';

  /// Route name: `order`
  @override
  String get $name => 'order';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/order';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => null;

  /// Body arguments for this route.
  @override
  Object? get $body => (userData, product);
}

/// Typed route for [ProductListPage] at `/app/products`.
///
/// This route class provides type-safe navigation to
/// the ProductListPage widget.
///
/// ## Example
///
/// ```dart
/// context.push(AppProductsRoute(
/// ));
/// ```
class AppProductsRoute extends DashTypedRoute {
  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for ProductListPage.
  const AppProductsRoute({this.$transition});

  /// Route pattern: `/app/products`
  @override
  String get $pattern => '/app/products';

  /// Route name: `productList`
  @override
  String get $name => 'productList';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/products';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => null;

  /// Body arguments for this route.
  @override
  Object? get $body => null;
}

/// Typed route for [ProductDetailPage] at `/app/products/:productId`.
///
/// This route class provides type-safe navigation to
/// the ProductDetailPage widget.
///
/// ## Path Parameters
///
/// - `productId` (String) - required path parameter
///
/// ## Query Parameters
///
/// - `highlight` (String, default: 'false')
/// - `referralCode` (String?)
///
/// ## Example
///
/// ```dart
/// context.push(AppProducts$ProductIdRoute(
///   productId: '<value>',
/// ));
/// ```
class AppProducts$ProductIdRoute extends DashTypedRoute {
  /// Path parameter: productId
  final String productId;

  /// Query parameter: highlight
  ///
  /// Default: `'false'`
  final String highlight;

  /// Query parameter: referralCode
  final String? referralCode;

  /// Body parameter: product
  final Product? product;

  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for ProductDetailPage.
  const AppProducts$ProductIdRoute({
    required this.productId,
    this.highlight = 'false',
    this.referralCode,
    this.product,
    this.$transition,
  });

  /// Route pattern: `/app/products/:productId`
  @override
  String get $pattern => '/app/products/:productId';

  /// Route name: `productDetail`
  @override
  String get $name => 'productDetail';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/products/${productId}';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => {
        'highlight': highlight,
        if (referralCode != null) 'referralCode': referralCode,
      };

  /// Body arguments for this route.
  @override
  Object? get $body => {'product': product};
}

/// Typed route for [SearchPage] at `/app/search`.
///
/// This route class provides type-safe navigation to
/// the SearchPage widget.
///
/// ## Example
///
/// ```dart
/// context.push(AppSearchRoute(
/// ));
/// ```
class AppSearchRoute extends DashTypedRoute {
  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for SearchPage.
  const AppSearchRoute({this.$transition});

  /// Route pattern: `/app/search`
  @override
  String get $pattern => '/app/search';

  /// Route name: `search`
  @override
  String get $name => 'search';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/search';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => null;

  /// Body arguments for this route.
  @override
  Object? get $body => null;
}

/// Typed route for [SearchResultsPage] at `/app/search/:query`.
///
/// This route class provides type-safe navigation to
/// the SearchResultsPage widget.
///
/// ## Path Parameters
///
/// - `query` (String) - required path parameter
///
/// ## Query Parameters
///
/// - `page` (String, default: '1')
/// - `filter` (String?)
///
/// ## Example
///
/// ```dart
/// context.push(AppSearch$QueryRoute(
///   query: '<value>',
/// ));
/// ```
class AppSearch$QueryRoute extends DashTypedRoute {
  /// Path parameter: query
  final String query;

  /// Query parameter: page
  ///
  /// Default: `'1'`
  final String page;

  /// Query parameter: filter
  final String? filter;

  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for SearchResultsPage.
  const AppSearch$QueryRoute({
    required this.query,
    this.page = '1',
    this.filter,
    this.$transition,
  });

  /// Route pattern: `/app/search/:query`
  @override
  String get $pattern => '/app/search/:query';

  /// Route name: `searchResults`
  @override
  String get $name => 'searchResults';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/search/${query}';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => {
        'page': page,
        if (filter != null) 'filter': filter,
      };

  /// Body arguments for this route.
  @override
  Object? get $body => null;
}

/// Typed route for [SettingsPage] at `/app/settings`.
///
/// This route class provides type-safe navigation to
/// the SettingsPage widget.
///
/// ## Example
///
/// ```dart
/// context.push(AppSettingsRoute(
/// ));
/// ```
class AppSettingsRoute extends DashTypedRoute {
  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for SettingsPage.
  const AppSettingsRoute({this.$transition});

  /// Route pattern: `/app/settings`
  @override
  String get $pattern => '/app/settings';

  /// Route name: `settings`
  @override
  String get $name => 'settings';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/settings';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => null;

  /// Body arguments for this route.
  @override
  Object? get $body => null;
}

/// Typed route for [UserPage] at `/app/user/:id`.
///
/// This route class provides type-safe navigation to
/// the UserPage widget.
///
/// ## Path Parameters
///
/// - `id` (String) - required path parameter
///
/// ## Query Parameters
///
/// - `tab` (String?)
///
/// ## Example
///
/// ```dart
/// context.push(AppUser$IdRoute(
///   id: '<value>',
/// ));
/// ```
class AppUser$IdRoute extends DashTypedRoute {
  /// Path parameter: id
  final String id;

  /// Query parameter: tab
  final String? tab;

  /// Body parameter: userData
  final UserData? userData;

  /// Optional custom transition for this navigation.
  @override
  final DashTransition? $transition;

  /// Creates a typed route for UserPage.
  const AppUser$IdRoute({
    required this.id,
    this.tab,
    this.userData,
    this.$transition,
  });

  /// Route pattern: `/app/user/:id`
  @override
  String get $pattern => '/app/user/:id';

  /// Route name: `userDetail`
  @override
  String get $name => 'userDetail';

  /// Concrete path with interpolated parameters.
  @override
  String get $path => '/app/user/${id}';

  /// Query parameters for this route.
  @override
  Map<String, dynamic>? get $query => {if (tab != null) 'tab': tab};

  /// Body arguments for this route.
  @override
  Object? get $body => {'userData': userData};
}

/// Navigation extension for [AdminShell] at `/app/admin`.
///
/// Provides type-safe navigation methods:
/// - `pushAppAdmin()` - Push route onto stack
/// - `replaceWithAppAdmin()` - Replace current route
/// - `popAndPushAppAdmin()` - Pop and push
/// - `pushAppAdminAndRemoveUntil()` - Push and remove until
extension AppAdminNavigation on BuildContext {
  /// Push `/app/admin` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppAdmin();
  /// ```
  Future<T?> pushAppAdmin<T>({Key? key, DashTransition? $transition}) {
    final path_ = '/app/admin';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(path_, body: body_, transition: $transition);
  }

  /// Replace current route with `/app/admin`.
  Future<T?> replaceWithAppAdmin<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/admin';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/admin`.
  Future<T?> popAndPushAppAdmin<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/admin';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/admin` and remove routes until predicate returns true.
  Future<T?> pushAppAdminAndRemoveUntil<T>({
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/admin';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [AdminUsersPage] at `/app/admin/users`.
///
/// Provides type-safe navigation methods:
/// - `pushAppAdminUsers()` - Push route onto stack
/// - `replaceWithAppAdminUsers()` - Replace current route
/// - `popAndPushAppAdminUsers()` - Pop and push
/// - `pushAppAdminUsersAndRemoveUntil()` - Push and remove until
extension AppAdminUsersNavigation on BuildContext {
  /// Push `/app/admin/users` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppAdminUsers();
  /// ```
  Future<T?> pushAppAdminUsers<T>({Key? key, DashTransition? $transition}) {
    final path_ = '/app/admin/users';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(path_, body: body_, transition: $transition);
  }

  /// Replace current route with `/app/admin/users`.
  Future<T?> replaceWithAppAdminUsers<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/admin/users';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/admin/users`.
  Future<T?> popAndPushAppAdminUsers<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/admin/users';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/admin/users` and remove routes until predicate returns true.
  Future<T?> pushAppAdminUsersAndRemoveUntil<T>({
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/admin/users';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [AdminUserDetailPage] at `/app/admin/users/:userId`.
///
/// Provides type-safe navigation methods:
/// - `pushAppAdminUsers$UserId()` - Push route onto stack
/// - `replaceWithAppAdminUsers$UserId()` - Replace current route
/// - `popAndPushAppAdminUsers$UserId()` - Pop and push
/// - `pushAppAdminUsers$UserIdAndRemoveUntil()` - Push and remove until
extension AppAdminUsers$UserIdNavigation on BuildContext {
  /// Push `/app/admin/users/:userId` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppAdminUsers$UserId(userId: '...');
  /// ```
  Future<T?> pushAppAdminUsers$UserId<T>({
    required String userId,
    Key? key,
    DashTransition? $transition,
  }) {
    final path_ = '/app/admin/users/${userId}';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(path_, body: body_, transition: $transition);
  }

  /// Replace current route with `/app/admin/users/:userId`.
  Future<T?> replaceWithAppAdminUsers$UserId<T, TO extends Object?>({
    required String userId,
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/admin/users/${userId}';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/admin/users/:userId`.
  Future<T?> popAndPushAppAdminUsers$UserId<T, TO extends Object?>({
    required String userId,
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/admin/users/${userId}';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/admin/users/:userId` and remove routes until predicate returns true.
  Future<T?> pushAppAdminUsers$UserIdAndRemoveUntil<T>({
    required String userId,
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/admin/users/${userId}';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [AdminSettingsPage] at `/app/admin/settings`.
///
/// Provides type-safe navigation methods:
/// - `pushAppAdminSettings()` - Push route onto stack
/// - `replaceWithAppAdminSettings()` - Replace current route
/// - `popAndPushAppAdminSettings()` - Pop and push
/// - `pushAppAdminSettingsAndRemoveUntil()` - Push and remove until
extension AppAdminSettingsNavigation on BuildContext {
  /// Push `/app/admin/settings` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppAdminSettings();
  /// ```
  Future<T?> pushAppAdminSettings<T>({Key? key, DashTransition? $transition}) {
    final path_ = '/app/admin/settings';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(path_, body: body_, transition: $transition);
  }

  /// Replace current route with `/app/admin/settings`.
  Future<T?> replaceWithAppAdminSettings<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/admin/settings';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/admin/settings`.
  Future<T?> popAndPushAppAdminSettings<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/admin/settings';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/admin/settings` and remove routes until predicate returns true.
  Future<T?> pushAppAdminSettingsAndRemoveUntil<T>({
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/admin/settings';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [AppShell] at `/app`.
///
/// Provides type-safe navigation methods:
/// - `pushApp()` - Push route onto stack
/// - `replaceWithApp()` - Replace current route
/// - `popAndPushApp()` - Pop and push
/// - `pushAppAndRemoveUntil()` - Push and remove until
extension AppNavigation on BuildContext {
  /// Push `/app` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushApp();
  /// ```
  Future<T?> pushApp<T>({Key? key, DashTransition? $transition}) {
    final path_ = '/app';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(path_, body: body_, transition: $transition);
  }

  /// Replace current route with `/app`.
  Future<T?> replaceWithApp<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app`.
  Future<T?> popAndPushApp<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app` and remove routes until predicate returns true.
  Future<T?> pushAppAndRemoveUntil<T>({
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [CatalogPage] at `/app/catalog/:category/:subcategory/:itemId`.
///
/// Provides type-safe navigation methods:
/// - `pushAppCatalog$Category$Subcategory$ItemId()` - Push route onto stack
/// - `replaceWithAppCatalog$Category$Subcategory$ItemId()` - Replace current route
/// - `popAndPushAppCatalog$Category$Subcategory$ItemId()` - Pop and push
/// - `pushAppCatalog$Category$Subcategory$ItemIdAndRemoveUntil()` - Push and remove until
extension AppCatalog$Category$Subcategory$ItemIdNavigation on BuildContext {
  /// Push `/app/catalog/:category/:subcategory/:itemId` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppCatalog$Category$Subcategory$ItemId(category: '...', subcategory: '...', itemId: '...');
  /// ```
  Future<T?> pushAppCatalog$Category$Subcategory$ItemId<T>({
    required String category,
    required String subcategory,
    required String itemId,
    String? sort,
    String? filter,
    Key? key,
    DashTransition? $transition,
  }) {
    final path_ = '/app/catalog/${category}/${subcategory}/${itemId}';
    final query_ = <String, dynamic>{
      if (sort != null) 'sort': sort.toString(),
      if (filter != null) 'filter': filter.toString(),
    };
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(
      path_,
      query: query_,
      body: body_,
      transition: $transition,
    );
  }

  /// Replace current route with `/app/catalog/:category/:subcategory/:itemId`.
  Future<T?>
      replaceWithAppCatalog$Category$Subcategory$ItemId<T, TO extends Object?>({
    required String category,
    required String subcategory,
    required String itemId,
    String? sort,
    String? filter,
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/catalog/${category}/${subcategory}/${itemId}';
    final query_ = <String, dynamic>{
      if (sort != null) 'sort': sort.toString(),
      if (filter != null) 'filter': filter.toString(),
    };
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      query: query_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/catalog/:category/:subcategory/:itemId`.
  Future<T?>
      popAndPushAppCatalog$Category$Subcategory$ItemId<T, TO extends Object?>({
    required String category,
    required String subcategory,
    required String itemId,
    String? sort,
    String? filter,
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/catalog/${category}/${subcategory}/${itemId}';
    final query_ = <String, dynamic>{
      if (sort != null) 'sort': sort.toString(),
      if (filter != null) 'filter': filter.toString(),
    };
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      query: query_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/catalog/:category/:subcategory/:itemId` and remove routes until predicate returns true.
  Future<T?> pushAppCatalog$Category$Subcategory$ItemIdAndRemoveUntil<T>({
    required String category,
    required String subcategory,
    required String itemId,
    String? sort,
    String? filter,
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/catalog/${category}/${subcategory}/${itemId}';
    final query_ = <String, dynamic>{
      if (sort != null) 'sort': sort.toString(),
      if (filter != null) 'filter': filter.toString(),
    };
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      query: query_,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [CheckoutPage] at `/app/checkout`.
///
/// Provides type-safe navigation methods:
/// - `pushAppCheckout()` - Push route onto stack
/// - `replaceWithAppCheckout()` - Replace current route
/// - `popAndPushAppCheckout()` - Pop and push
/// - `pushAppCheckoutAndRemoveUntil()` - Push and remove until
extension AppCheckoutNavigation on BuildContext {
  /// Push `/app/checkout` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppCheckout();
  /// ```
  Future<T?> pushAppCheckout<T>({Key? key, DashTransition? $transition}) {
    final path_ = '/app/checkout';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(path_, body: body_, transition: $transition);
  }

  /// Replace current route with `/app/checkout`.
  Future<T?> replaceWithAppCheckout<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/checkout';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/checkout`.
  Future<T?> popAndPushAppCheckout<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/checkout';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/checkout` and remove routes until predicate returns true.
  Future<T?> pushAppCheckoutAndRemoveUntil<T>({
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/checkout';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [DashboardPage] at `/app/dashboard`.
///
/// Provides type-safe navigation methods:
/// - `pushAppDashboard()` - Push route onto stack
/// - `replaceWithAppDashboard()` - Replace current route
/// - `popAndPushAppDashboard()` - Pop and push
/// - `pushAppDashboardAndRemoveUntil()` - Push and remove until
extension AppDashboardNavigation on BuildContext {
  /// Push `/app/dashboard` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppDashboard();
  /// ```
  Future<T?> pushAppDashboard<T>({Key? key, DashTransition? $transition}) {
    final path_ = '/app/dashboard';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(path_, body: body_, transition: $transition);
  }

  /// Replace current route with `/app/dashboard`.
  Future<T?> replaceWithAppDashboard<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/dashboard';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/dashboard`.
  Future<T?> popAndPushAppDashboard<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/dashboard';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/dashboard` and remove routes until predicate returns true.
  Future<T?> pushAppDashboardAndRemoveUntil<T>({
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/dashboard';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [DashboardAnalyticsPage] at `/app/dashboard/analytics`.
///
/// Provides type-safe navigation methods:
/// - `pushAppDashboardAnalytics()` - Push route onto stack
/// - `replaceWithAppDashboardAnalytics()` - Replace current route
/// - `popAndPushAppDashboardAnalytics()` - Pop and push
/// - `pushAppDashboardAnalyticsAndRemoveUntil()` - Push and remove until
extension AppDashboardAnalyticsNavigation on BuildContext {
  /// Push `/app/dashboard/analytics` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppDashboardAnalytics();
  /// ```
  Future<T?> pushAppDashboardAnalytics<T>({
    Key? key,
    DashTransition? $transition,
  }) {
    final path_ = '/app/dashboard/analytics';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(path_, body: body_, transition: $transition);
  }

  /// Replace current route with `/app/dashboard/analytics`.
  Future<T?> replaceWithAppDashboardAnalytics<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/dashboard/analytics';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/dashboard/analytics`.
  Future<T?> popAndPushAppDashboardAnalytics<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/dashboard/analytics';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/dashboard/analytics` and remove routes until predicate returns true.
  Future<T?> pushAppDashboardAnalyticsAndRemoveUntil<T>({
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/dashboard/analytics';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [DashboardReportsPage] at `/app/dashboard/reports`.
///
/// Provides type-safe navigation methods:
/// - `pushAppDashboardReports()` - Push route onto stack
/// - `replaceWithAppDashboardReports()` - Replace current route
/// - `popAndPushAppDashboardReports()` - Pop and push
/// - `pushAppDashboardReportsAndRemoveUntil()` - Push and remove until
extension AppDashboardReportsNavigation on BuildContext {
  /// Push `/app/dashboard/reports` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppDashboardReports();
  /// ```
  Future<T?> pushAppDashboardReports<T>({
    String dateRange = 'last_7_days',
    String? reportType,
    Key? key,
    DashTransition? $transition,
  }) {
    final path_ = '/app/dashboard/reports';
    final query_ = <String, dynamic>{
      'dateRange': dateRange.toString(),
      if (reportType != null) 'reportType': reportType.toString(),
    };
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(
      path_,
      query: query_,
      body: body_,
      transition: $transition,
    );
  }

  /// Replace current route with `/app/dashboard/reports`.
  Future<T?> replaceWithAppDashboardReports<T, TO extends Object?>({
    String dateRange = 'last_7_days',
    String? reportType,
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/dashboard/reports';
    final query_ = <String, dynamic>{
      'dateRange': dateRange.toString(),
      if (reportType != null) 'reportType': reportType.toString(),
    };
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      query: query_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/dashboard/reports`.
  Future<T?> popAndPushAppDashboardReports<T, TO extends Object?>({
    String dateRange = 'last_7_days',
    String? reportType,
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/dashboard/reports';
    final query_ = <String, dynamic>{
      'dateRange': dateRange.toString(),
      if (reportType != null) 'reportType': reportType.toString(),
    };
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      query: query_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/dashboard/reports` and remove routes until predicate returns true.
  Future<T?> pushAppDashboardReportsAndRemoveUntil<T>({
    String dateRange = 'last_7_days',
    String? reportType,
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/dashboard/reports';
    final query_ = <String, dynamic>{
      'dateRange': dateRange.toString(),
      if (reportType != null) 'reportType': reportType.toString(),
    };
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      query: query_,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [EditProfilePage] at `/app/edit-profile`.
///
/// Provides type-safe navigation methods:
/// - `pushAppEditProfile()` - Push route onto stack
/// - `replaceWithAppEditProfile()` - Replace current route
/// - `popAndPushAppEditProfile()` - Pop and push
/// - `pushAppEditProfileAndRemoveUntil()` - Push and remove until
extension AppEditProfileNavigation on BuildContext {
  /// Push `/app/edit-profile` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppEditProfile();
  /// ```
  Future<T?> pushAppEditProfile<T>({Key? key, DashTransition? $transition}) {
    final path_ = '/app/edit-profile';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(path_, body: body_, transition: $transition);
  }

  /// Replace current route with `/app/edit-profile`.
  Future<T?> replaceWithAppEditProfile<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/edit-profile';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/edit-profile`.
  Future<T?> popAndPushAppEditProfile<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/edit-profile';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/edit-profile` and remove routes until predicate returns true.
  Future<T?> pushAppEditProfileAndRemoveUntil<T>({
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/edit-profile';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [HomePage] at `/app/home`.
///
/// Provides type-safe navigation methods:
/// - `pushAppHome()` - Push route onto stack
/// - `replaceWithAppHome()` - Replace current route
/// - `popAndPushAppHome()` - Pop and push
/// - `pushAppHomeAndRemoveUntil()` - Push and remove until
extension AppHomeNavigation on BuildContext {
  /// Push `/app/home` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppHome();
  /// ```
  Future<T?> pushAppHome<T>({Key? key, DashTransition? $transition}) {
    final path_ = '/app/home';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(path_, body: body_, transition: $transition);
  }

  /// Replace current route with `/app/home`.
  Future<T?> replaceWithAppHome<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/home';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/home`.
  Future<T?> popAndPushAppHome<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/home';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/home` and remove routes until predicate returns true.
  Future<T?> pushAppHomeAndRemoveUntil<T>({
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/home';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [LoginPage] at `/login`.
///
/// Provides type-safe navigation methods:
/// - `pushLogin()` - Push route onto stack
/// - `replaceWithLogin()` - Replace current route
/// - `popAndPushLogin()` - Pop and push
/// - `pushLoginAndRemoveUntil()` - Push and remove until
extension LoginNavigation on BuildContext {
  /// Push `/login` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushLogin();
  /// ```
  Future<T?> pushLogin<T>({Key? key, DashTransition? $transition}) {
    final path_ = '/login';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(path_, body: body_, transition: $transition);
  }

  /// Replace current route with `/login`.
  Future<T?> replaceWithLogin<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/login';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/login`.
  Future<T?> popAndPushLogin<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/login';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/login` and remove routes until predicate returns true.
  Future<T?> pushLoginAndRemoveUntil<T>({
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/login';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [NavigationDemoPage] at `/app/demo`.
///
/// Provides type-safe navigation methods:
/// - `pushAppDemo()` - Push route onto stack
/// - `replaceWithAppDemo()` - Replace current route
/// - `popAndPushAppDemo()` - Pop and push
/// - `pushAppDemoAndRemoveUntil()` - Push and remove until
extension AppDemoNavigation on BuildContext {
  /// Push `/app/demo` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppDemo();
  /// ```
  Future<T?> pushAppDemo<T>({Key? key, DashTransition? $transition}) {
    final path_ = '/app/demo';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(path_, body: body_, transition: $transition);
  }

  /// Replace current route with `/app/demo`.
  Future<T?> replaceWithAppDemo<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/demo';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/demo`.
  Future<T?> popAndPushAppDemo<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/demo';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/demo` and remove routes until predicate returns true.
  Future<T?> pushAppDemoAndRemoveUntil<T>({
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/demo';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [OrderPage] at `/app/order`.
///
/// Provides type-safe navigation methods:
/// - `pushAppOrder()` - Push route onto stack
/// - `replaceWithAppOrder()` - Replace current route
/// - `popAndPushAppOrder()` - Pop and push
/// - `pushAppOrderAndRemoveUntil()` - Push and remove until
extension AppOrderNavigation on BuildContext {
  /// Push `/app/order` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppOrder();
  /// ```
  Future<T?> pushAppOrder<T>({Key? key, DashTransition? $transition}) {
    final path_ = '/app/order';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(path_, body: body_, transition: $transition);
  }

  /// Replace current route with `/app/order`.
  Future<T?> replaceWithAppOrder<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/order';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/order`.
  Future<T?> popAndPushAppOrder<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/order';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/order` and remove routes until predicate returns true.
  Future<T?> pushAppOrderAndRemoveUntil<T>({
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/order';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [ProductListPage] at `/app/products`.
///
/// Provides type-safe navigation methods:
/// - `pushAppProducts()` - Push route onto stack
/// - `replaceWithAppProducts()` - Replace current route
/// - `popAndPushAppProducts()` - Pop and push
/// - `pushAppProductsAndRemoveUntil()` - Push and remove until
extension AppProductsNavigation on BuildContext {
  /// Push `/app/products` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppProducts();
  /// ```
  Future<T?> pushAppProducts<T>({Key? key, DashTransition? $transition}) {
    final path_ = '/app/products';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(path_, body: body_, transition: $transition);
  }

  /// Replace current route with `/app/products`.
  Future<T?> replaceWithAppProducts<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/products';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/products`.
  Future<T?> popAndPushAppProducts<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/products';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/products` and remove routes until predicate returns true.
  Future<T?> pushAppProductsAndRemoveUntil<T>({
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/products';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [ProductDetailPage] at `/app/products/:productId`.
///
/// Provides type-safe navigation methods:
/// - `pushAppProducts$ProductId()` - Push route onto stack
/// - `replaceWithAppProducts$ProductId()` - Replace current route
/// - `popAndPushAppProducts$ProductId()` - Pop and push
/// - `pushAppProducts$ProductIdAndRemoveUntil()` - Push and remove until
extension AppProducts$ProductIdNavigation on BuildContext {
  /// Push `/app/products/:productId` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppProducts$ProductId(productId: '...');
  /// ```
  Future<T?> pushAppProducts$ProductId<T>({
    required String productId,
    String highlight = 'false',
    String? referralCode,
    Key? key,
    Product? product,
    DashTransition? $transition,
  }) {
    final path_ = '/app/products/${productId}';
    final query_ = <String, dynamic>{
      'highlight': highlight.toString(),
      if (referralCode != null) 'referralCode': referralCode.toString(),
    };
    final body_ = <String, dynamic>{'key': key, 'product': product};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(
      path_,
      query: query_,
      body: body_,
      transition: $transition,
    );
  }

  /// Replace current route with `/app/products/:productId`.
  Future<T?> replaceWithAppProducts$ProductId<T, TO extends Object?>({
    required String productId,
    String highlight = 'false',
    String? referralCode,
    Key? key,
    Product? product,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/products/${productId}';
    final query_ = <String, dynamic>{
      'highlight': highlight.toString(),
      if (referralCode != null) 'referralCode': referralCode.toString(),
    };
    final body_ = <String, dynamic>{'key': key, 'product': product};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      query: query_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/products/:productId`.
  Future<T?> popAndPushAppProducts$ProductId<T, TO extends Object?>({
    required String productId,
    String highlight = 'false',
    String? referralCode,
    Key? key,
    Product? product,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/products/${productId}';
    final query_ = <String, dynamic>{
      'highlight': highlight.toString(),
      if (referralCode != null) 'referralCode': referralCode.toString(),
    };
    final body_ = <String, dynamic>{'key': key, 'product': product};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      query: query_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/products/:productId` and remove routes until predicate returns true.
  Future<T?> pushAppProducts$ProductIdAndRemoveUntil<T>({
    required String productId,
    String highlight = 'false',
    String? referralCode,
    Key? key,
    Product? product,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/products/${productId}';
    final query_ = <String, dynamic>{
      'highlight': highlight.toString(),
      if (referralCode != null) 'referralCode': referralCode.toString(),
    };
    final body_ = <String, dynamic>{'key': key, 'product': product};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      query: query_,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [SearchPage] at `/app/search`.
///
/// Provides type-safe navigation methods:
/// - `pushAppSearch()` - Push route onto stack
/// - `replaceWithAppSearch()` - Replace current route
/// - `popAndPushAppSearch()` - Pop and push
/// - `pushAppSearchAndRemoveUntil()` - Push and remove until
extension AppSearchNavigation on BuildContext {
  /// Push `/app/search` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppSearch();
  /// ```
  Future<T?> pushAppSearch<T>({Key? key, DashTransition? $transition}) {
    final path_ = '/app/search';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(path_, body: body_, transition: $transition);
  }

  /// Replace current route with `/app/search`.
  Future<T?> replaceWithAppSearch<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/search';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/search`.
  Future<T?> popAndPushAppSearch<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/search';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/search` and remove routes until predicate returns true.
  Future<T?> pushAppSearchAndRemoveUntil<T>({
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/search';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [SearchResultsPage] at `/app/search/:query`.
///
/// Provides type-safe navigation methods:
/// - `pushAppSearch$Query()` - Push route onto stack
/// - `replaceWithAppSearch$Query()` - Replace current route
/// - `popAndPushAppSearch$Query()` - Pop and push
/// - `pushAppSearch$QueryAndRemoveUntil()` - Push and remove until
extension AppSearch$QueryNavigation on BuildContext {
  /// Push `/app/search/:query` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppSearch$Query(query: '...');
  /// ```
  Future<T?> pushAppSearch$Query<T>({
    required String query,
    String page = '1',
    String? filter,
    Key? key,
    DashTransition? $transition,
  }) {
    final path_ = '/app/search/${query}';
    final query_ = <String, dynamic>{
      'page': page.toString(),
      if (filter != null) 'filter': filter.toString(),
    };
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(
      path_,
      query: query_,
      body: body_,
      transition: $transition,
    );
  }

  /// Replace current route with `/app/search/:query`.
  Future<T?> replaceWithAppSearch$Query<T, TO extends Object?>({
    required String query,
    String page = '1',
    String? filter,
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/search/${query}';
    final query_ = <String, dynamic>{
      'page': page.toString(),
      if (filter != null) 'filter': filter.toString(),
    };
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      query: query_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/search/:query`.
  Future<T?> popAndPushAppSearch$Query<T, TO extends Object?>({
    required String query,
    String page = '1',
    String? filter,
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/search/${query}';
    final query_ = <String, dynamic>{
      'page': page.toString(),
      if (filter != null) 'filter': filter.toString(),
    };
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      query: query_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/search/:query` and remove routes until predicate returns true.
  Future<T?> pushAppSearch$QueryAndRemoveUntil<T>({
    required String query,
    String page = '1',
    String? filter,
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/search/${query}';
    final query_ = <String, dynamic>{
      'page': page.toString(),
      if (filter != null) 'filter': filter.toString(),
    };
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      query: query_,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [SettingsPage] at `/app/settings`.
///
/// Provides type-safe navigation methods:
/// - `pushAppSettings()` - Push route onto stack
/// - `replaceWithAppSettings()` - Replace current route
/// - `popAndPushAppSettings()` - Pop and push
/// - `pushAppSettingsAndRemoveUntil()` - Push and remove until
extension AppSettingsNavigation on BuildContext {
  /// Push `/app/settings` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppSettings();
  /// ```
  Future<T?> pushAppSettings<T>({Key? key, DashTransition? $transition}) {
    final path_ = '/app/settings';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(path_, body: body_, transition: $transition);
  }

  /// Replace current route with `/app/settings`.
  Future<T?> replaceWithAppSettings<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/settings';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/settings`.
  Future<T?> popAndPushAppSettings<T, TO extends Object?>({
    Key? key,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/settings';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/settings` and remove routes until predicate returns true.
  Future<T?> pushAppSettingsAndRemoveUntil<T>({
    Key? key,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/settings';
    final body_ = <String, dynamic>{'key': key};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      body: body_,
      transition: $transition,
    );
  }
}

/// Navigation extension for [UserPage] at `/app/user/:id`.
///
/// Provides type-safe navigation methods:
/// - `pushAppUser$Id()` - Push route onto stack
/// - `replaceWithAppUser$Id()` - Replace current route
/// - `popAndPushAppUser$Id()` - Pop and push
/// - `pushAppUser$IdAndRemoveUntil()` - Push and remove until
extension AppUser$IdNavigation on BuildContext {
  /// Push `/app/user/:id` onto navigation stack.
  ///
  /// Example:
  /// ```dart
  /// context.pushAppUser$Id(id: '...');
  /// ```
  Future<T?> pushAppUser$Id<T>({
    required String id,
    String? tab,
    Key? key,
    UserData? userData,
    DashTransition? $transition,
  }) {
    final path_ = '/app/user/${id}';
    final query_ = <String, dynamic>{if (tab != null) 'tab': tab.toString()};
    final body_ = <String, dynamic>{'key': key, 'userData': userData};
    final router = DashRouter.of(this);
    return router.pushNamed<T>(
      path_,
      query: query_,
      body: body_,
      transition: $transition,
    );
  }

  /// Replace current route with `/app/user/:id`.
  Future<T?> replaceWithAppUser$Id<T, TO extends Object?>({
    required String id,
    String? tab,
    Key? key,
    UserData? userData,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/user/${id}';
    final query_ = <String, dynamic>{if (tab != null) 'tab': tab.toString()};
    final body_ = <String, dynamic>{'key': key, 'userData': userData};
    final router = DashRouter.of(this);
    return router.pushReplacementNamed<T, TO>(
      path_,
      query: query_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Pop current route and push `/app/user/:id`.
  Future<T?> popAndPushAppUser$Id<T, TO extends Object?>({
    required String id,
    String? tab,
    Key? key,
    UserData? userData,
    TO? result,
    DashTransition? $transition,
  }) {
    final path_ = '/app/user/${id}';
    final query_ = <String, dynamic>{if (tab != null) 'tab': tab.toString()};
    final body_ = <String, dynamic>{'key': key, 'userData': userData};
    final router = DashRouter.of(this);
    return router.popAndPushNamed<T, TO>(
      path_,
      query: query_,
      body: body_,
      result: result,
      transition: $transition,
    );
  }

  /// Push `/app/user/:id` and remove routes until predicate returns true.
  Future<T?> pushAppUser$IdAndRemoveUntil<T>({
    required String id,
    String? tab,
    Key? key,
    UserData? userData,
    required bool Function(Route<dynamic>) predicate,
    DashTransition? $transition,
  }) {
    final path_ = '/app/user/${id}';
    final query_ = <String, dynamic>{if (tab != null) 'tab': tab.toString()};
    final body_ = <String, dynamic>{'key': key, 'userData': userData};
    final router = DashRouter.of(this);
    return router.pushNamedAndRemoveUntil<T>(
      path_,
      predicate,
      query: query_,
      body: body_,
      transition: $transition,
    );
  }
}

# dash_router

[![pub package](https://img.shields.io/pub/v/dash_router.svg)](https://pub.dev/packages/dash_router)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

Flutter 应用的核心路由库。提供类型安全的导航、路由守卫、中间件和丰富的转场动画。

## 特性

- 🚀 **O(1) 参数访问** - 基于 InheritedWidget 的缓存实现即时参数获取
- 🔒 **类型安全** - 所有路由参数的编译时类型检查
- 🎨 **丰富的转场动画** - 内置 Material、Cupertino 及自定义动画
- 🛡️ **路由守卫** - 认证和授权保护
- 🔌 **中间件** - 日志、分析和横切关注点
- 📱 **跨平台** - 支持 iOS、Android、Web、macOS、Windows、Linux

## 安装

添加到 `pubspec.yaml`：

```yaml
dependencies:
  dash_router: ^1.0.0
```

## 使用

### 基本设置

```dart
import 'package:dash_router/dash_router.dart';
import 'generated/routes.dart';

class MyApp extends StatelessWidget {
  static final _router = DashRouter(
    config: DashRouterOptions(
      initialPath: '/',
      debugLog: true,
    ),
    routes: generatedRoutes,
    redirects: generatedRedirects,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _router.navigatorKey,
      initialRoute: _router.config.initialPath,
      onGenerateRoute: _router.generateRoute,
    );
  }
}
```

### 导航

```dart
// 推送新路由
context.push('/user/123');

// 替换当前路由
context.replace('/home');

// 弹出当前路由
context.pop();

// 带返回值弹出
context.pop<String>('result');

// 清空栈并推送
context.pushAndRemoveAll('/login');
```

### 访问路由参数

```dart
@override
Widget build(BuildContext context) {
  final route = context.route;
  
  // 路径参数 - O(1) 访问
  final id = route.path.get<String>('id');
  
  // 查询参数
  final page = route.query.get<int>('page', defaultValue: 1);
  
  // Body 参数 - 统一 API
  final user = route.body.get<User>('user');
  
  // 原始 arguments 访问
  final rawArgs = route.body.arguments;
  
  // 使用生成的扩展（类型安全）：
  // final (user, product) = route.typedBody; // 返回类型化的 Record
  
  return ...;
}
```

### 转场动画

使用内置转场或创建自定义转场：

```dart
// 带转场推送
context.push(
  '/details',
  transition: const DashSlideTransition.right(),
);

// 自定义转场
context.push(
  '/custom',
  transition: CustomAnimatedTransition(
    duration: Duration(milliseconds: 500),
    transitionBuilder: (context, animation, secondary, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  ),
);
```

### 路由守卫

```dart
class AuthGuard extends DashGuard {
  @override
  Future<GuardResult> canActivate(GuardContext context) async {
    if (await isAuthenticated()) {
      return const GuardAllow();
    }
    return const GuardRedirect('/login');
  }
}

// 注册
router.guards.register(AuthGuard());
```

### 中间件

```dart
class AnalyticsMiddleware extends DashMiddleware {
  @override
  Future<MiddlewareResult> handle(MiddlewareContext context) async {
    analytics.logScreenView(context.targetPath);
    return const MiddlewareContinue();
  }
}

// 注册
router.middleware.register(AnalyticsMiddleware());
```

## API 参考

完整详情请参阅 [API 文档](https://pub.dev/documentation/dash_router/latest/)。

## 相关包

- [dash_router_annotations](https://pub.dev/packages/dash_router_annotations) - 路由注解
- [dash_router_generator](https://pub.dev/packages/dash_router_generator) - 代码生成器
- [dash_router_cli](https://pub.dev/packages/dash_router_cli) - CLI 工具

## License

MIT License - 详见 [LICENSE](LICENSE)。

# Dash Router

<p align="center">
  <strong>🚀 零心智负担，完全类型安全的 Flutter 路由库</strong>
</p>

<p align="center">
  <a href="https://pub.dev/packages/dash_router"><img src="https://img.shields.io/pub/v/dash_router.svg" alt="Pub Version"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License"></a>
</p>

<p align="center">
  <a href="#特性">特性</a> •
  <a href="#快速开始">快速开始</a> •
  <a href="#文档">文档</a> •
  <a href="#示例">示例</a> •
  <a href="./README.md">English</a>
</p>

---

## 特性

- ✅ **O(1) 参数访问** - 通过 InheritedWidget 缓存机制实现即时参数获取
- ✅ **完全类型安全** - 编译时类型检查，零运行时错误
- ✅ **单一入口点** - 只需记住 `context.route`
- ✅ **丰富的转场动画** - 内置 Material、Cupertino 及自定义动画（全部支持 `const`）
- ✅ **路由守卫** - 灵活的权限控制和认证保护
- ✅ **中间件支持** - 日志、分析、限流等横切关注点
- ✅ **Navigator 1.0 & 2.0 支持** - 完整的声明式导航，支持 `MaterialApp.router`
  - 添加 `DashRouterWidget` 简化路由器设置
  - 添加 `DashRouterScope` 从组件树访问路由器
  - 增强 URL 同步和浏览器历史集成
- ✅ **深度链接** - 完整的 URL 处理，支持 Web 和移动平台
  - Web 浏览器历史集成
  - 系统返回按钮处理
  - 完整支持应用链接和 Web URL
- ✅ **Shell 路由** - 嵌套导航，具有独立动画
- ✅ **代码生成** - 自动生成类型安全的导航扩展
- ✅ **CLI 工具** - 便捷的命令行工具
- ✅ **全平台支持** - iOS、Android、Web、macOS、Windows、Linux

## 快速开始

### 1. 安装依赖

```yaml
dependencies:
  dash_router: any
  dash_router_annotations: any

dev_dependencies:
  dash_router_cli: any
  dash_router_generator: any
```

### 2. 定义路由

使用注解定义页面路由。参数从构造函数自动推断：

```dart
import 'package:flutter/material.dart';
import 'package:dash_router/dash_router.dart';

// 基础页面路由
@DashRoute(path: '/user/:id')
class UserPage extends StatelessWidget {
  final String id;      // 路径参数（来自 :id）
  final String? tab;    // 查询参数（可选）
  
  const UserPage({
    super.key,
    required this.id,
    this.tab,
  });
  
  @override
  Widget build(BuildContext context) {
    final route = context.route;
    
    return Scaffold(
      appBar: AppBar(title: Text('User $id')),
      body: Column(
        children: [
          Text('Route: ${route.name}'),
          Text('Path: ${route.fullPath}'),
          Text('Tab: $tab'),
        ],
      ),
    );
  }
}

// 带自定义转场的路由
@DashRoute(
  path: '/settings',
  transition: CupertinoTransition(),
)
class SettingsPage extends StatelessWidget { ... }

// Shell 路由（包裹嵌套路由）
@DashRoute(path: '/app', shell: true)
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const MyNavBar(),
    );
  }
}

// 重定向路由
@DashRoute(path: '/', redirectTo: '/app/home')
class RootRedirect {}

// 全屏对话框路由
@DashRoute(
  path: '/edit-profile',
  fullscreenDialog: true,
  transition: DashSlideTransition.bottom(),
)
class EditProfilePage extends StatelessWidget { ... }
```

### 3. 生成代码

```bash
# 使用 CLI 工具（推荐）
dart run dash_router_cli:dash_router generate

# 或监听文件变化
dart run dash_router_cli:dash_router watch
```

### 4. 配置路由器

```dart
import 'generated/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
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
      title: 'My App',
      navigatorKey: _router.navigatorKey,
      initialRoute: _router.config.initialPath,
      onGenerateRoute: _router.generateRoute,
    );
  }
}
```

### 5. 导航

```dart
// 使用生成的类型安全扩展（推荐）
context.pushAppUser$Id(id: '123', tab: 'profile');

// 使用类型化路由对象
context.push(AppUser$IdRoute(id: '123', tab: 'profile'));

// 使用字符串路径
context.pushNamed('/user/123?tab=profile');

// 替换当前路由
context.replace(AppHomeRoute());
context.replaceNamed('/home');

// 返回
context.pop();

// 带返回值
context.pop<String>('success');

// 清空栈并导航
context.pushAndRemoveAll(AppLoginRoute());
```

## 文档

### 参数类型

参数从构造函数参数**自动推断**：

```dart
@DashRoute(path: '/search/:category')
class SearchPage extends StatelessWidget {
  // 路径参数 - 匹配路径中的 :category
  final String category;
  
  // 查询参数 - 可选参数成为查询参数
  final int page;
  final String? sortBy;
  
  const SearchPage({
    super.key,
    required this.category,
    this.page = 1,
    this.sortBy,
  });
}
```

### Body 参数（复杂类型）

使用 `arguments` 传递复杂对象：

```dart
@DashRoute(
  path: '/checkout',
  arguments: [UserData, Product],  // Record 类型: (UserData, Product)
)
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    // 通过生成的扩展进行类型安全访问
    final (user, product) = context.route.arguments;
    return Text(user.name);
  }
}
```

### 参数访问

```dart
@override
Widget build(BuildContext context) {
  final route = context.route;
  
  // 路径参数 - O(1) 访问
  final id = route.path.get<String>('id');
  
  // 查询参数
  final page = route.query.get<int>('page', defaultValue: 1);
  
  // Body 参数（原始 arguments）
  final args = route.body.arguments;
  
  // 命名 body 参数
  final user = route.body.get<User>('user');
  
  // 全部参数
  final allParams = route.allParams;
  
  return ...;
}
```

### 转场动画

所有内置转场都支持 `const` 构造：

```dart
// 平台自适应
@DashRoute(path: '/a', transition: PlatformTransition())

// Material Design
@DashRoute(path: '/b', transition: MaterialTransition())

// iOS 风格
@DashRoute(path: '/c', transition: CupertinoTransition())

// 无动画
@DashRoute(path: '/d', transition: NoTransition())

// 淡入淡出
@DashRoute(path: '/e', transition: DashFadeTransition())

// 滑动
@DashRoute(path: '/f', transition: DashSlideTransition.right())
@DashRoute(path: '/g', transition: DashSlideTransition.bottom())

// 缩放
@DashRoute(path: '/h', transition: DashScaleTransition())

// 组合动画
@DashRoute(path: '/i', transition: DashScaleFadeTransition())
@DashRoute(path: '/j', transition: DashSlideFadeTransition.right())
```

运行时自定义转场：

```dart
context.pushNamed(
  '/custom',
  transition: CustomAnimatedTransition(
    duration: Duration(milliseconds: 500),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return RotationTransition(turns: animation, child: child);
    },
  ),
);
```

### 路由守卫

```dart
class AuthGuard extends DashGuard {
  final AuthService authService;
  
  const AuthGuard(this.authService);
  
  @override
  Future<GuardResult> canActivate(GuardContext context) async {
    if (await authService.isLoggedIn()) {
      return const GuardAllow();
    }
    return const GuardRedirect('/login');
  }
}

// 全局注册守卫
router.guards.register(AuthGuard(authService));

// 在特定路由上使用（传入实例）
@DashRoute(
  path: '/admin',
  guards: [AuthGuard(authService)],
)
class AdminPage extends StatelessWidget { ... }
```

### 中间件

```dart
class LoggingMiddleware extends DashMiddleware {
  @override
  Future<MiddlewareResult> handle(MiddlewareContext context) async {
    print('Navigating to: ${context.targetPath}');
    return const MiddlewareContinue();
  }
  
  @override
  Future<void> afterNavigation(MiddlewareContext context) async {
    print('Navigation completed in ${context.elapsed.inMilliseconds}ms');
  }
}

// 注册中间件
router.middleware.register(LoggingMiddleware());
```

### 命名约定

生成的代码遵循基于路径的命名约定：

| 路径 | 路由类名 | 字段名 |
|------|---------|--------|
| `/app/user/:id` | `AppUser$IdRoute` | `appUser$Id` |
| `/app/settings` | `AppSettingsRoute` | `appSettings` |
| `/` | `RootRoute` | `root` |

动态参数使用 `$` 前缀来区分静态段。

## CLI 工具

```bash
# 初始化配置
dart run dash_router_cli:dash_router init

# 生成路由代码
dart run dash_router_cli:dash_router generate

# 监听文件变化
dart run dash_router_cli:dash_router watch

# 验证配置
dart run dash_router_cli:dash_router validate

# 清理生成的文件
dart run dash_router_cli:dash_router clean

# monorepo 场景：用 --config 指定配置文件
dart run dash_router_cli:dash_router generate --config example/dash_router.yaml
```

## 架构

```
dash_router/
├── packages/
│   ├── dash_router/              # 核心路由库
│   ├── dash_router_annotations/  # 注解定义
│   ├── dash_router_generator/    # 代码生成器
│   └── dash_router_cli/          # CLI 工具
└── example/                      # 示例应用
```

## 性能

- **O(1) 参数访问**: InheritedWidget + 缓存机制
- **懒加载**: 路由信息按需创建
- **编译时优化**: 代码生成零运行时开销
- **历史记录管理**: 智能管理带大小限制的导航历史

## 示例

查看 [example](./example) 目录获取完整示例。

## 贡献

欢迎贡献！请查看 [CONTRIBUTING.md](./CONTRIBUTING.md) 了解详情。

## License

MIT License - 详见 [LICENSE](./LICENSE) 文件

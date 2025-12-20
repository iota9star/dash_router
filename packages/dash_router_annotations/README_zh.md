# dash_router_annotations

[![pub package](https://img.shields.io/pub/v/dash_router_annotations.svg)](https://pub.dev/packages/dash_router_annotations)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

dash_router 路由库的注解定义。此包提供用于定义路由和配置代码生成的注解。

## 特性

- 📝 **路由注解** - 使用 `@DashRoute` 及相关注解定义路由
- 🎯 **自动参数推断** - 从构造函数自动推断参数
- 🎨 **转场定义** - 内置的路由动画转场类
- ⚙️ **配置** - `@DashRouterConfig` 用于代码生成设置

## 安装

添加到 `pubspec.yaml`：

```yaml
dependencies:
  dash_router_annotations: any
```

## 注解

### @DashRoute

为页面 widget 定义路由。参数从构造函数自动推断：
- 路径参数从路径中的 `:param` 模式获取
- 查询参数从可选构造函数参数获取
- Body 参数通过 `arguments` 属性定义

```dart
@DashRoute(
  path: '/user/:id',
  transition: CupertinoTransition(),
  guards: [AuthGuard()],
  middleware: [LoggingMiddleware()],
)
class UserPage extends StatelessWidget {
  final String id;         // 路径参数（来自 :id）
  final String? tab;       // 查询参数（可选）
  
  const UserPage({
    super.key,
    required this.id,
    this.tab,
  });
  // ...
}
```

### @DashRouterConfig

配置路由生成器：

```dart
@DashRouterConfig(
  generateNavigation: true,
  generateRouteInfo: true,
)
class AppRouter {}
```

### 参数处理

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

// 导航时使用：
// context.pushSearch(category: 'books', page: 2, sortBy: 'price');
// 生成 URL: /search/books?page=2&sortBy=price
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

### Shell 路由

使用 `shell: true` 定义用于嵌套导航的 shell 路由：

```dart
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
```

### 初始路由

使用 `initial: true` 标记为初始路由：

```dart
@DashRoute(path: '/', initial: true)
class HomePage extends StatelessWidget { ... }
```

### 重定向路由

使用 `redirectTo` 定义路由重定向：

```dart
@DashRoute(path: '/old-path', redirectTo: '/new-path')
class OldPageRedirect {}

// 永久重定向
@DashRoute(path: '/legacy', redirectTo: '/modern', permanentRedirect: true)
class LegacyRedirect {}
```

### 全屏对话框路由

使用 `fullscreenDialog: true` 定义全屏对话框路由：

```dart
@DashRoute(
  path: '/edit-profile',
  fullscreenDialog: true,
  transition: DashSlideTransition.bottom(),
)
class EditProfilePage extends StatelessWidget { ... }
```

### @IgnoreParam

从路由参数中排除构造函数参数：

```dart
@DashRoute(path: '/user/:id')
class UserPage extends StatelessWidget {
  final String id;
  
  @IgnoreParam()
  final VoidCallback? onTap;  // 不是路由参数
  
  const UserPage({
    super.key,
    required this.id,
    this.onTap,
  });
}
```

## 转场动画

所有转场都支持 `const` 构造：

```dart
// 平台自适应
const PlatformTransition()

// Material Design
const MaterialTransition()

// iOS 风格
const CupertinoTransition()

// 无动画
const NoTransition()

// 自定义动画
const DashFadeTransition()
const DashFadeTransition(duration: Duration(milliseconds: 300))

const DashSlideTransition.right()
const DashSlideTransition.bottom()
const DashSlideTransition(begin: Offset(-1, 0))

const DashScaleTransition()
const DashScaleTransition(alignment: Alignment.center)

const DashRotationTransition()

const DashScaleFadeTransition()
const DashSlideFadeTransition.right()
```

## 命名约定

生成的代码遵循基于路径的命名约定：

| 路径 | 生成的类 | 生成的字段 |
|------|---------|-----------|
| `/app/user/:id` | `AppUser$IdRoute` | `appUser$Id` |
| `/app/settings` | `AppSettingsRoute` | `appSettings` |
| `/` | `RootRoute` | `root` |

动态参数使用 `$` 前缀来区分静态段。

## API 参考

完整详情请参阅 [API 文档](https://pub.dev/documentation/dash_router_annotations/latest/)。

## 相关包

- [dash_router](https://pub.dev/packages/dash_router) - 核心路由库
- [dash_router_generator](https://pub.dev/packages/dash_router_generator) - 代码生成器
- [dash_router_cli](https://pub.dev/packages/dash_router_cli) - CLI 工具

## License

MIT License - 详见 [LICENSE](LICENSE)。

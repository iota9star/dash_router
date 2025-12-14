# dash_router_annotations

[![pub package](https://img.shields.io/pub/v/dash_router_annotations.svg)](https://pub.dev/packages/dash_router_annotations)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

dash_router 路由库的注解定义。此包提供用于定义路由和配置代码生成的注解。

## 特性

- 📝 **路由注解** - 使用 `@DashRoute` 及相关注解定义路由
- 🎯 **参数注解** - 使用 `@PathParam`、`@QueryParam`、`@BodyParam` 定义类型安全的参数
- 🎨 **转场定义** - 内置的路由动画转场类
- ⚙️ **配置** - `@DashRouterConfig` 用于代码生成设置

## 安装

添加到 `pubspec.yaml`：

```yaml
dependencies:
  dash_router_annotations: ^1.0.0
```

## 注解

### @DashRoute

为页面 widget 定义路由：

```dart
@DashRoute(
  path: '/user/:id',
  transition: CupertinoTransition(),
  guards: [AuthGuard],
  middleware: [LoggingMiddleware],
)
class UserPage extends StatelessWidget {
  final String id;
  const UserPage({super.key, required this.id});
  // ...
}
```

### @DashRouterConfig

配置路由生成器：

```dart
@DashRouterConfig(
  generateNavigation: true,
  generateTypedRoutes: true,
)
class AppRouter {}
```

### 参数注解

```dart
@DashRoute(path: '/search')
class SearchPage extends StatelessWidget {
  @PathParam()
  final String? category;
  
  @QueryParam(defaultValue: '1')
  final int page;
  
  @QueryParam(name: 'sort_by')
  final String? sortBy;
  
  @BodyParam()
  final SearchFilter? filter;
  
  const SearchPage({
    super.key,
    this.category,
    this.page = 1,
    this.sortBy,
    this.filter,
  });
}
```

### @ShellRoute

定义用于嵌套导航的 shell 路由：

```dart
@ShellRoute(path: '/app')
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});
  // ...
}
```

### @InitialRoute

标记为初始路由：

```dart
@InitialRoute()
@DashRoute(path: '/')
class HomePage extends StatelessWidget { ... }
```

### @RedirectRoute

定义路由重定向：

```dart
@RedirectRoute(from: '/old-path', to: '/new-path')
class OldPageRedirect {}
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

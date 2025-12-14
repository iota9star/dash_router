# dash_router_generator

[![pub package](https://img.shields.io/pub/v/dash_router_generator.svg)](https://pub.dev/packages/dash_router_generator)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

dash_router 的代码生成器。从 `@DashRoute` 注解生成类型安全的路由代码。

## 特性

- 🔧 **CLI 生成** - 快速代码生成，无需 build_runner 开销
- 📁 **独立路由信息文件** - 为每个路由生成单独的类型信息文件
- 🎯 **类型安全导航** - 生成完全类型安全的导航扩展
- 🔄 **监听模式** - 文件变更时自动重新生成
- ⚙️ **可配置** - 自定义输出路径和生成选项

## 安装

添加到 `pubspec.yaml`：

```yaml
dev_dependencies:
  dash_router_generator: ^1.0.0
  dash_router_cli: ^1.0.0
```

## 使用

### CLI 生成

```bash
# 生成路由
dart run dash_router_cli generate

# 监听文件变更
dart run dash_router_cli watch

# 预览（不写入文件）
dart run dash_router_cli generate --dry-run
```

### 配置

在项目根目录创建 `dash_router.yaml`：

```yaml
dash_router:
  scan:
    - "lib/**/*.dart"
  generate:
    output: "lib/generated/routes.dart"
    route_info_output: "lib/generated/route_info/"
  options:
    generate_navigation: true
    generate_typed_routes: true
    generate_route_info: true
```

### 生成的代码

生成器生成以下内容：

1. **路由文件** (`routes.dart`)
   - `generatedRoutes` - 所有路由条目列表
   - `generatedRedirects` - 重定向条目列表

2. **路由信息文件**（每个路由）
   - 类型安全的参数访问扩展
   - 路由模式检查

3. **导航扩展**
   - `context.pushUserPage(id: '123')`
   - `context.replaceWithHomePage()`
   - 等等

## 生成代码示例

对于如下定义的路由：

```dart
@DashRoute(
  path: '/user/:id',
  arguments: [UserData],
)
class UserPage extends StatelessWidget { ... }
```

生成器生成：

```dart
// 在 route_info/user_$id.route.dart 中
extension User$IdRouteInfoX on ScopedRouteInfo {
  bool get isUser$IdRoute => pattern == '/user/:id';
  UserData get typedBody => body.arguments as UserData;
}

// 导航扩展
extension UserPageNavigation on BuildContext {
  Future<T?> pushUserPage<T>({required String id, UserData? userData}) { ... }
  Future<T?> replaceWithUserPage<T>({required String id}) { ... }
}
```

## API 参考

完整详情请参阅 [API 文档](https://pub.dev/documentation/dash_router_generator/latest/)。

## 相关包

- [dash_router](https://pub.dev/packages/dash_router) - 核心路由库
- [dash_router_annotations](https://pub.dev/packages/dash_router_annotations) - 路由注解
- [dash_router_cli](https://pub.dev/packages/dash_router_cli) - CLI 工具

## License

MIT License - 详见 [LICENSE](LICENSE)。

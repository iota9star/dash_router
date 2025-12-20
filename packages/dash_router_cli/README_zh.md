# dash_router_cli

[![pub package](https://img.shields.io/pub/v/dash_router_cli.svg)](https://pub.dev/packages/dash_router_cli)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

dash_router 路由库的命令行工具。提供代码生成、配置管理和开发工作流自动化命令。

## 特性

- 🚀 **快速生成** - 无需 build_runner 开销即可生成路由代码
- 👁️ **监听模式** - 文件变化时自动重新生成
- ✅ **验证** - 验证路由配置
- 🧹 **清理** - 删除生成的文件
- ⚙️ **配置** - 支持自动检测或显式配置文件

## 安装

添加到 `pubspec.yaml`：

```yaml
dev_dependencies:
  dash_router_cli: any
```

## 命令

### generate

从注解类生成路由代码：

```bash
# 基本生成
dart run dash_router_cli:dash_router generate

# 详细输出
dart run dash_router_cli:dash_router generate --verbose

# 演示运行（显示将生成什么）
dart run dash_router_cli:dash_router generate --dry-run

# 使用 build_runner 而非 CLI 生成器
dart run dash_router_cli:dash_router generate --build-runner

# 显式配置文件（用于 monorepo）
dart run dash_router_cli:dash_router generate --config example/dash_router.yaml
```

别名: `gen`, `g`

### watch

监听文件变化并自动重新生成：

```bash
# 开始监听
dart run dash_router_cli:dash_router watch

# 详细输出
dart run dash_router_cli:dash_router watch --verbose
```

别名: `w`

### init

在项目中初始化 dash_router 配置：

```bash
# 创建 dash_router.yaml 配置文件
dart run dash_router_cli:dash_router init

# 强制覆盖现有配置
dart run dash_router_cli:dash_router init --force
```

### validate

验证路由配置：

```bash
# 验证配置
dart run dash_router_cli:dash_router validate

# 详细输出
dart run dash_router_cli:dash_router validate --verbose
```

### clean

删除生成的文件：

```bash
# 清理生成的文件
dart run dash_router_cli:dash_router clean

# 演示运行
dart run dash_router_cli:dash_router clean --dry-run
```

## 配置

配置自动从以下位置检测：

1. 项目根目录的 `dash_router.yaml`
2. `pubspec.yaml` 中的 `dash_router` 键
3. 默认配置（如果都不存在）

### dash_router.yaml

```yaml
# 扫描路由的文件路径
paths:
  - lib/**/*.dart

# 生成选项
generate:
  output: lib/generated/routes.dart
  route_info_output: lib/generated/route_info/
  options:
    generate_route_info: true
    generate_navigation: true
    generate_typed_extensions: true

# 排除模式
exclude:
  - "**/*.g.dart"
  - "**/*.freezed.dart"
```

### Monorepo 使用

对于 monorepo 项目，指定配置文件路径：

```bash
# 为特定包生成
dart run dash_router_cli:dash_router generate --config packages/app/dash_router.yaml

# 为示例生成
dart run dash_router_cli:dash_router generate --config example/dash_router.yaml
```

## 输出

CLI 生成与 build_runner 生成器相同的代码：

- `Routes` 类中的路由条目
- 路由列表 `generatedRoutes`
- 重定向列表 `generatedRedirects`
- 类型化路由类（例如 `AppUser$IdRoute`）
- 导航扩展（例如 `AppUser$IdNavigation`）
- 路由信息类（可选）

## API 参考

完整详情请参阅 [API 文档](https://pub.dev/documentation/dash_router_cli/latest/)。

## 相关包

- [dash_router](https://pub.dev/packages/dash_router) - 核心路由库
- [dash_router_annotations](https://pub.dev/packages/dash_router_annotations) - 注解定义
- [dash_router_generator](https://pub.dev/packages/dash_router_generator) - 代码生成器

## License

MIT License - 详见 [LICENSE](LICENSE)。

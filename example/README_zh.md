# Dash Router 示例

<p align="center">
  <strong>🎯 Dash Router 完整示例应用</strong>
</p>

<p align="center">
  <a href="./README.md">English</a>
</p>

---

## 概述

这是一个展示 Dash Router 所有功能的完整示例应用，支持全平台（iOS、Android、Web、macOS、Windows、Linux）。

## 功能演示

### 📍 基础路由

- 简单页面导航
- 带参数的路由
- 查询参数
- Body 参数传递

### 🔄 转场动画

- Material 转场
- Cupertino 转场
- 自定义转场（淡入淡出、滑动、缩放、旋转）
- 组合动画转场
- 平台自适应转场

### 🛡️ 路由守卫

- 认证守卫（登录保护）
- 权限守卫（角色检查）
- 守卫优先级

### 🔗 中间件

- 日志中间件
- 分析中间件
- 加载状态中间件

### 🏠 嵌套导航

- Shell 路由（底部导航栏）
- Tab 导航
- 嵌套路由栈

### 🔀 重定向

- 初始路由重定向
- 条件重定向
- 守卫重定向

## 运行示例

### 前置条件

确保已安装：
- Flutter SDK >= 3.24.0
- Dart SDK >= 3.6.0

### 步骤

1. **克隆仓库**
   ```bash
   git clone https://github.com/iota9star/dash_router.git
   cd dash_router
   ```

2. **安装依赖**
   ```bash
   # 使用 Melos
   melos bootstrap
   
   # 或手动安装
   cd example
   flutter pub get
   ```

3. **生成路由代码**
   ```bash
   # 使用 CLI
   dart run dash_router_cli:dash_router generate --config example/dash_router.yaml
   
   # 或使用 build_runner
   dart run build_runner build
   ```

4. **运行应用**
   ```bash
   # iOS
   flutter run -d ios
   
   # Android
   flutter run -d android
   
   # Web
   flutter run -d chrome
   
   # macOS
   flutter run -d macos
   
   # Windows
   flutter run -d windows
   
   # Linux
   flutter run -d linux
   ```

## 项目结构

```
example/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── generated/                # 生成的路由代码
│   │   ├── routes.dart
│   │   └── route_info/
│   ├── guards/                   # 路由守卫
│   │   └── auth_guard.dart
│   ├── middleware/               # 中间件
│   │   └── example_middleware.dart
│   ├── pages/                    # 页面组件
│   │   ├── app_shell.dart
│   │   ├── home_page.dart
│   │   ├── user_page.dart
│   │   └── ...
│   └── shared/                   # 共享组件
├── test/                         # 测试文件
├── dash_router.yaml              # 路由配置
└── pubspec.yaml
```

## 示例代码

### 定义路由

```dart
// lib/pages/user_page.dart
import 'package:dash_router/dash_router.dart';
import 'package:flutter/material.dart';

@DashRoute(
  path: '/user/:id',
  transition: DashSlideTransition.right(),
)
class UserPage extends StatelessWidget {
  @PathParam()
  final String id;
  
  @QueryParam()
  final String? tab;
  
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
          Text('Tab: ${tab ?? "default"}'),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
```

### 路由守卫

```dart
// lib/guards/auth_guard.dart
import 'package:dash_router/dash_router.dart';

class AuthGuard extends DashGuard {
  @override
  String get name => 'AuthGuard';
  
  @override
  int get priority => 100;
  
  @override
  Future<GuardResult> canActivate(GuardContext context) async {
    // 模拟认证检查
    final isLoggedIn = await checkAuth();
    
    if (isLoggedIn) {
      return const GuardAllow();
    }
    
    return const GuardRedirect('/login');
  }
  
  Future<bool> checkAuth() async {
    // 实际应用中这里会检查认证状态
    return true;
  }
}
```

### 中间件

```dart
// lib/middleware/example_middleware.dart
import 'package:dash_router/dash_router.dart';

class LoggingMiddleware extends DashMiddleware {
  @override
  String get name => 'LoggingMiddleware';
  
  @override
  int get priority => 100;
  
  @override
  Future<MiddlewareResult> handle(MiddlewareContext context) async {
    print('📍 Navigating to: ${context.targetPath}');
    return const MiddlewareContinue();
  }
  
  @override
  Future<void> afterNavigation(MiddlewareContext context) async {
    print('✅ Navigation completed');
  }
}
```

### 导航

```dart
// 使用生成的类型安全扩展
context.pushUser$Id(id: '123', tab: 'profile');

// 使用路径
context.push('/user/123?tab=profile');

// 返回
context.pop();

// 返回并传值
context.pop<String>('result');
```

## 配置文件

### dash_router.yaml

```yaml
paths:
  - lib/**/*.dart

generate:
  output: lib/generated/routes.dart
  route_info_output: lib/generated/route_info/
  options:
    generate_route_info: true
    generate_navigation: true
    generate_typed_extensions: true

exclude:
  - "**/*.g.dart"
  - "**/*.freezed.dart"
```

## License

MIT License

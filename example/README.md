# Dash Router Example

<p align="center">
  <strong>🎯 Production-Ready Example Application for Dash Router</strong>
</p>

<p align="center">
  <a href="./README_zh.md">中文</a>
</p>

---

## Overview

A comprehensive example application demonstrating all features of Dash Router with a production-ready architecture. Supports responsive layouts for mobile, tablet, and desktop, with full Material 3 theming.

## Features

### 📱 Responsive Layout

- **Mobile** (< 600dp): Bottom navigation bar
- **Tablet** (600-839dp): Navigation rail
- **Desktop** (≥ 840dp): Permanent navigation drawer

### 🎨 Material 3 Design

- Light and dark theme support
- Custom color schemes with `ColorScheme.fromSeed()`
- Adaptive components following Material 3 guidelines

### 📍 Complete Navigation Patterns

| Feature | Demonstration |
|---------|---------------|
| Type-safe navigation | `context.push(UserPageRoute(id: '123'))` |
| Generated extensions | `context.pushUserPage(id: '456')` |
| Path parameters | `/app/products/:productId` |
| Query parameters | `?highlight=true&referralCode=DASH` |
| Body parameters | Complex objects via `arguments` |
| Nested routes | `/app/dashboard/analytics` |
| Shell routes | App shell with bottom nav |

### 🔄 Custom Transitions

\`\`\`dart
@DashRoute(
  path: '/app/settings',
  transition: CupertinoTransition(),  // iOS-style
)

@DashRoute(
  path: '/app/dashboard',
  transition: DashSlideTransition.bottom(),  // Slide from bottom
)
\`\`\`

### 🛡️ Route Guards

\`\`\`dart
class AuthGuard extends DashGuard {
  @override
  Future<GuardResult> canActivate(GuardContext context) async {
    if (isLoggedIn) return const GuardAllow();
    return const GuardRedirect('/login');
  }
}
\`\`\`

### 🔗 Middleware

- **Logging**: Track navigation events
- **Analytics**: Screen view tracking
- **Rate Limiting**: Prevent rapid navigation
- **Prefetching**: Load data before navigation

## Project Structure

\`\`\`
example/
├── lib/
│   ├── main.dart                     # Entry point
│   ├── app.dart                      # App configuration & theme provider
│   ├── core/                         # Core utilities
│   │   ├── theme/                    # Theme configuration
│   │   │   ├── app_theme.dart        # Material 3 theme
│   │   │   └── color_schemes.dart    # Color definitions
│   │   └── utils/                    # Utility classes
│   │       └── responsive_utils.dart # Responsive breakpoints
│   ├── generated/                    # Generated route code
│   │   ├── routes.dart               # Main routes file
│   │   └── route_info/               # Individual route info
│   ├── guards/                       # Route guards
│   │   └── auth_guard.dart
│   ├── middleware/                   # Middleware
│   │   └── example_middleware.dart
│   ├── pages/                        # Page components
│   │   ├── app_shell.dart            # Responsive shell
│   │   ├── home_page.dart
│   │   ├── login_page.dart
│   │   ├── dashboard_page.dart
│   │   ├── product_page.dart
│   │   ├── settings_page.dart
│   │   └── ...
│   └── shared/                       # Shared components
│       ├── product.dart              # Product model
│       ├── user_data.dart            # User model
│       └── widgets/                  # Reusable widgets
│           ├── adaptive_scaffold.dart
│           └── navigation_shell.dart
├── test/                             # Tests
├── dash_router.yaml                  # Route configuration
└── pubspec.yaml
\`\`\`

## Quick Start

### Prerequisites

- Flutter SDK >= 3.22.0
- Dart SDK >= 3.5.0

### Installation

\`\`\`bash
# Clone repository
git clone https://github.com/iota9star/dash_router.git
cd dash_router

# Install dependencies with Melos
melos bootstrap

# Or manually
cd example && flutter pub get
\`\`\`

### Generate Routes

\`\`\`bash
cd example
dart run dash_router_cli:dash_router generate
\`\`\`

### Run

\`\`\`bash
# Run on any platform
flutter run

# Specific platforms
flutter run -d chrome    # Web
flutter run -d macos     # macOS
flutter run -d ios       # iOS
flutter run -d android   # Android
\`\`\`

## Code Examples

### Define a Route

\`\`\`dart
@DashRoute(
  path: '/app/user/:id',
  name: 'userDetail',
  parent: '/app',
  guards: ['AuthGuard'],
  transition: DashSlideTransition.right(),
)
class UserPage extends StatelessWidget {
  final String id;           // Path parameter
  final String? tab;         // Query parameter
  final UserData? userData;  // Body parameter
  
  const UserPage({
    super.key,
    required this.id,
    this.tab,
    this.userData,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User \$id')),
      body: Text('Tab: \${tab ?? "default"}'),
    );
  }
}
\`\`\`

### Navigate Type-Safely

\`\`\`dart
// Using typed route
context.push(const UserPageRoute(
  id: '123',
  tab: 'profile',
  userData: UserData(id: '123', displayName: 'John'),
));

// Using generated extension
context.pushUserPage(
  id: '123',
  tab: 'profile',
);

// Replace current route
context.replaceWithUserPage(id: '456');

// Clear stack and push
context.clearStackAndPushHomePage();
\`\`\`

### Access Route Info

\`\`\`dart
@override
Widget build(BuildContext context) {
  final route = context.route;
  
  return Column(
    children: [
      Text('Path: \${route.fullPath}'),
      Text('Name: \${route.name}'),
      Text('Pattern: \${route.pattern}'),
      Text('Can go back: \${route.canGoBack}'),
    ],
  );
}
\`\`\`

## Configuration

### dash_router.yaml

\`\`\`yaml
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
\`\`\`

## Testing

\`\`\`bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
\`\`\`

## License

MIT License - see [LICENSE](../LICENSE) for details.

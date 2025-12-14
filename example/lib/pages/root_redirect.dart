import 'package:dash_router_annotations/dash_router_annotations.dart';

/// Redirect root path to home page.
///
/// Uses the unified `@DashRoute` annotation with `redirectTo`.
@DashRoute(path: '/', name: 'rootRedirect', redirectTo: '/app/home')
class RootRedirect {
  const RootRedirect();
}

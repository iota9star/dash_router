import 'package:dash_router/dash_router.dart';
import 'package:flutter/widgets.dart';

class SlideScaleTransition extends DashTransition {
  const SlideScaleTransition();
  @override
  PageRouteBuilder<T> buildPageRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      settings: settings,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const beginOffset = Offset(1.0, 0.0);
        const endOffset = Offset.zero;
        const curve = Curves.ease;

        final tween = Tween(begin: beginOffset, end: endOffset)
            .chain(CurveTween(curve: curve));
        final scaleTween =
            Tween<double>(begin: 0.8, end: 1.0).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: ScaleTransition(
            scale: animation.drive(scaleTween),
            child: child,
          ),
        );
      },
    );
  }
}

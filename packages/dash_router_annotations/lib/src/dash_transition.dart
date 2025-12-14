// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Base class for all page transition animations in dash_router.
///
/// This abstract class defines the contract for building page routes with
/// custom transition animations. Implement this class to create custom
/// transitions for your routes.
///
/// ## Built-in Transitions
///
/// dash_router provides several built-in transition implementations:
///
/// - [DashFadeTransition] - Fade in/out animation
/// - [DashSlideTransition] - Slide from any direction
/// - [DashScaleTransition] - Scale (zoom) animation
/// - [DashRotationTransition] - Rotation animation
/// - [DashScaleFadeTransition] - Combined scale and fade
/// - [DashSlideFadeTransition] - Combined slide and fade
/// - [PlatformTransition] - Platform-adaptive transition
/// - [MaterialTransition] - Material Design transition
/// - [CupertinoTransition] - iOS-style transition
/// - [NoTransition] - Instant transition (no animation)
///
/// ## Usage in Route Annotations
///
/// ```dart
/// @DashRoute(
///   path: '/user/:id',
///   transition: DashFadeTransition(),
/// )
/// class UserPage extends StatelessWidget {
///   const UserPage({super.key, required this.id});
///   final String id;
///
///   @override
///   Widget build(BuildContext context) => Text('User: $id');
/// }
/// ```
///
/// ## Custom Transition Example
///
/// ```dart
/// final class MyCustomTransition implements DashTransition {
///   const MyCustomTransition({this.duration = const Duration(milliseconds: 400)});
///
///   final Duration duration;
///
///   @override
///   PageRouteBuilder<T> buildPageRoute<T>(Widget page, RouteSettings settings) {
///     return PageRouteBuilder<T>(
///       settings: settings,
///       pageBuilder: (context, animation, secondaryAnimation) => page,
///       transitionsBuilder: (context, animation, secondaryAnimation, child) {
///         return RotationTransition(
///           turns: Tween<double>(begin: 0.5, end: 1.0).animate(animation),
///           child: child,
///         );
///       },
///       transitionDuration: duration,
///     );
///   }
/// }
/// ```
abstract class DashTransition {
  /// Creates a [DashTransition] instance.
  const DashTransition();

  /// Builds a [PageRouteBuilder] with the configured transition animation.
  ///
  /// This method is called by the router when navigating to a route that
  /// uses this transition. Implement this method to define how the page
  /// should animate when entering or leaving the screen.
  ///
  /// [page] - The widget to display as the page content.
  /// [settings] - The route settings containing the route name and arguments.
  ///
  /// Returns a [PageRouteBuilder] configured with the transition animation.
  ///
  /// Example implementation:
  /// ```dart
  /// @override
  /// PageRouteBuilder<T> buildPageRoute<T>(Widget page, RouteSettings settings) {
  ///   return PageRouteBuilder<T>(
  ///     settings: settings,
  ///     pageBuilder: (context, animation, secondaryAnimation) => page,
  ///     transitionsBuilder: (context, animation, secondaryAnimation, child) {
  ///       return FadeTransition(opacity: animation, child: child);
  ///     },
  ///     transitionDuration: const Duration(milliseconds: 300),
  ///   );
  /// }
  /// ```
  PageRouteBuilder<T> buildPageRoute<T>(Widget page, RouteSettings settings);
}

/// A fade transition animation for page routes.
///
/// This transition fades the page in when entering and fades it out when
/// leaving. It provides a smooth, subtle animation suitable for most
/// navigation scenarios.
///
/// ## Example
///
/// ```dart
/// @DashRoute(
///   path: '/profile',
///   transition: DashFadeTransition(duration: Duration(milliseconds: 400)),
/// )
/// class ProfilePage extends StatelessWidget {
///   const ProfilePage({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Profile');
/// }
/// ```
///
/// ## Programmatic Usage
///
/// ```dart
/// const transition = DashFadeTransition(duration: Duration(milliseconds: 500));
/// final route = transition.buildPageRoute<void>(MyPage(), RouteSettings(name: '/my-page'));
/// Navigator.of(context).push(route);
/// ```
final class DashFadeTransition implements DashTransition {
  /// Creates a fade transition with the specified duration.
  ///
  /// [duration] - The duration of the fade animation. Defaults to 300ms.
  ///
  /// Example:
  /// ```dart
  /// const transition = DashFadeTransition(
  ///   duration: Duration(milliseconds: 500),
  /// );
  /// ```
  const DashFadeTransition({
    this.duration = const Duration(milliseconds: 300),
  });

  /// The duration of the fade animation.
  ///
  /// This value is used for both the forward and reverse transitions.
  final Duration duration;

  @override
  PageRouteBuilder<T> buildPageRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: child,
        );
      },
      transitionDuration: duration,
      reverseTransitionDuration: duration,
    );
  }
}

/// A slide transition animation for page routes.
///
/// This transition slides the page in from a specified direction when entering
/// and slides it out when leaving. The direction can be customized using the
/// begin and end offset parameters, or you can use the convenient named
/// constructors for common directions.
///
/// ## Named Constructors
///
/// - [DashSlideTransition.right] - Slide from the right edge
/// - [DashSlideTransition.left] - Slide from the left edge
/// - [DashSlideTransition.bottom] - Slide from the bottom edge
/// - [DashSlideTransition.top] - Slide from the top edge
///
/// ## Example
///
/// ```dart
/// // Slide from right (most common for push navigation)
/// @DashRoute(
///   path: '/details',
///   transition: DashSlideTransition.right(),
/// )
/// class DetailsPage extends StatelessWidget {
///   const DetailsPage({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Details');
/// }
///
/// // Slide from bottom (good for modal-style pages)
/// @DashRoute(
///   path: '/modal',
///   transition: DashSlideTransition.bottom(),
/// )
/// class ModalPage extends StatelessWidget {
///   const ModalPage({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Modal');
/// }
///
/// // Custom slide direction
/// @DashRoute(
///   path: '/custom',
///   transition: DashSlideTransition(beginX: 0.5, beginY: 0.5),
/// )
/// class CustomPage extends StatelessWidget {
///   const CustomPage({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Custom');
/// }
/// ```
final class DashSlideTransition implements DashTransition {
  /// Creates a slide transition with custom begin and end offsets.
  ///
  /// The offset values represent fractions of the screen size:
  /// - `1.0` means fully off-screen to the right/bottom
  /// - `-1.0` means fully off-screen to the left/top
  /// - `0.0` means at the normal position
  ///
  /// [beginX] - Starting X offset. Defaults to 1.0 (from right).
  /// [beginY] - Starting Y offset. Defaults to 0.0.
  /// [endX] - Ending X offset. Defaults to 0.0 (normal position).
  /// [endY] - Ending Y offset. Defaults to 0.0 (normal position).
  /// [duration] - Duration of the slide animation. Defaults to 300ms.
  ///
  /// Example:
  /// ```dart
  /// // Slide from bottom-right corner
  /// const transition = DashSlideTransition(
  ///   beginX: 1.0,
  ///   beginY: 1.0,
  /// );
  /// ```
  const DashSlideTransition({
    this.beginX = 1.0,
    this.beginY = 0.0,
    this.endX = 0.0,
    this.endY = 0.0,
    this.duration = const Duration(milliseconds: 300),
  });

  /// Creates a slide transition from the right edge.
  ///
  /// This is the default iOS navigation style.
  ///
  /// [duration] - Duration of the slide animation. Defaults to 300ms.
  ///
  /// Example:
  /// ```dart
  /// const transition = DashSlideTransition.right();
  /// ```
  const DashSlideTransition.right({
    this.duration = const Duration(milliseconds: 300),
  })  : beginX = 1.0,
        beginY = 0.0,
        endX = 0.0,
        endY = 0.0;

  /// Creates a slide transition from the left edge.
  ///
  /// [duration] - Duration of the slide animation. Defaults to 300ms.
  ///
  /// Example:
  /// ```dart
  /// const transition = DashSlideTransition.left();
  /// ```
  const DashSlideTransition.left({
    this.duration = const Duration(milliseconds: 300),
  })  : beginX = -1.0,
        beginY = 0.0,
        endX = 0.0,
        endY = 0.0;

  /// Creates a slide transition from the bottom edge.
  ///
  /// This is commonly used for modal-style presentations.
  ///
  /// [duration] - Duration of the slide animation. Defaults to 300ms.
  ///
  /// Example:
  /// ```dart
  /// const transition = DashSlideTransition.bottom();
  /// ```
  const DashSlideTransition.bottom({
    this.duration = const Duration(milliseconds: 300),
  })  : beginX = 0.0,
        beginY = 1.0,
        endX = 0.0,
        endY = 0.0;

  /// Creates a slide transition from the top edge.
  ///
  /// [duration] - Duration of the slide animation. Defaults to 300ms.
  ///
  /// Example:
  /// ```dart
  /// const transition = DashSlideTransition.top();
  /// ```
  const DashSlideTransition.top({
    this.duration = const Duration(milliseconds: 300),
  })  : beginX = 0.0,
        beginY = -1.0,
        endX = 0.0,
        endY = 0.0;

  /// Starting X offset (-1.0 to 1.0).
  final double beginX;

  /// Starting Y offset (-1.0 to 1.0).
  final double beginY;

  /// Ending X offset (usually 0.0).
  final double endX;

  /// Ending Y offset (usually 0.0).
  final double endY;

  /// Duration of the slide animation.
  final Duration duration;

  @override
  PageRouteBuilder<T> buildPageRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(beginX, beginY),
            end: Offset(endX, endY),
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
      transitionDuration: duration,
      reverseTransitionDuration: duration,
    );
  }
}

/// A scale (zoom) transition animation for page routes.
///
/// This transition scales the page from a starting size to an ending size.
/// The scaling occurs around a specified alignment point.
///
/// ## Example
///
/// ```dart
/// @DashRoute(
///   path: '/zoom',
///   transition: DashScaleTransition(begin: 0.8, end: 1.0),
/// )
/// class ZoomPage extends StatelessWidget {
///   const ZoomPage({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Zoom');
/// }
/// ```
final class DashScaleTransition implements DashTransition {
  /// Creates a scale transition with custom parameters.
  ///
  /// [begin] - Starting scale value (0.0 to 1.0 typically). Defaults to 0.0.
  /// [end] - Ending scale value (usually 1.0 for full size). Defaults to 1.0.
  /// [alignmentX] - X alignment for scaling (-1.0 to 1.0). Defaults to 0.0 (center).
  /// [alignmentY] - Y alignment for scaling (-1.0 to 1.0). Defaults to 0.0 (center).
  /// [duration] - Duration of the scale animation. Defaults to 300ms.
  ///
  /// Example:
  /// ```dart
  /// // Scale from center
  /// const transition = DashScaleTransition(begin: 0.5, end: 1.0);
  ///
  /// // Scale from top-left corner
  /// const cornerTransition = DashScaleTransition(
  ///   begin: 0.0,
  ///   end: 1.0,
  ///   alignmentX: -1.0,
  ///   alignmentY: -1.0,
  /// );
  /// ```
  const DashScaleTransition({
    this.begin = 0.0,
    this.end = 1.0,
    this.alignmentX = 0.0,
    this.alignmentY = 0.0,
    this.duration = const Duration(milliseconds: 300),
  });

  /// Starting scale value.
  final double begin;

  /// Ending scale value.
  final double end;

  /// X alignment for scaling (-1.0 to 1.0).
  final double alignmentX;

  /// Y alignment for scaling (-1.0 to 1.0).
  final double alignmentY;

  /// Duration of the scale animation.
  final Duration duration;

  @override
  PageRouteBuilder<T> buildPageRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: begin, end: end).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          alignment: Alignment(alignmentX, alignmentY),
          child: child,
        );
      },
      transitionDuration: duration,
      reverseTransitionDuration: duration,
    );
  }
}

/// A rotation transition animation for page routes.
///
/// This transition rotates the page from a starting angle to an ending angle.
/// Values represent full turns (1.0 = 360 degrees).
///
/// ## Example
///
/// ```dart
/// @DashRoute(
///   path: '/rotate',
///   transition: DashRotationTransition(begin: 0.0, end: 1.0),
/// )
/// class RotatePage extends StatelessWidget {
///   const RotatePage({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Rotate');
/// }
/// ```
final class DashRotationTransition implements DashTransition {
  /// Creates a rotation transition with custom parameters.
  ///
  /// [begin] - Starting rotation (0.0 = 0 degrees). Defaults to 0.0.
  /// [end] - Ending rotation (1.0 = 360 degrees). Defaults to 1.0.
  /// [duration] - Duration of the rotation animation. Defaults to 300ms.
  ///
  /// Example:
  /// ```dart
  /// // Full rotation
  /// const transition = DashRotationTransition(begin: 0.0, end: 1.0);
  ///
  /// // Half rotation
  /// const halfTransition = DashRotationTransition(begin: 0.0, end: 0.5);
  /// ```
  const DashRotationTransition({
    this.begin = 0.0,
    this.end = 1.0,
    this.duration = const Duration(milliseconds: 300),
  });

  /// Starting rotation value (0.0 = 0 degrees, 1.0 = 360 degrees).
  final double begin;

  /// Ending rotation value.
  final double end;

  /// Duration of the rotation animation.
  final Duration duration;

  @override
  PageRouteBuilder<T> buildPageRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return RotationTransition(
          turns: Tween<double>(begin: begin, end: end).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          ),
          child: child,
        );
      },
      transitionDuration: duration,
      reverseTransitionDuration: duration,
    );
  }
}

/// A combined scale and fade transition animation for page routes.
///
/// This transition applies both scaling and fading simultaneously,
/// creating a more dramatic effect. It's often used for dialog or
/// modal presentations.
///
/// ## Example
///
/// ```dart
/// @DashRoute(
///   path: '/dialog',
///   transition: DashScaleFadeTransition(scaleBegin: 0.8, scaleEnd: 1.0),
/// )
/// class DialogPage extends StatelessWidget {
///   const DialogPage({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Dialog');
/// }
/// ```
final class DashScaleFadeTransition implements DashTransition {
  /// Creates a combined scale and fade transition.
  ///
  /// [scaleBegin] - Starting scale value. Defaults to 0.8.
  /// [scaleEnd] - Ending scale value. Defaults to 1.0.
  /// [opacityBegin] - Starting opacity. Defaults to 0.0.
  /// [opacityEnd] - Ending opacity. Defaults to 1.0.
  /// [duration] - Duration of the animation. Defaults to 300ms.
  ///
  /// Example:
  /// ```dart
  /// const transition = DashScaleFadeTransition(
  ///   scaleBegin: 0.5,
  ///   scaleEnd: 1.0,
  ///   opacityBegin: 0.0,
  ///   opacityEnd: 1.0,
  /// );
  /// ```
  const DashScaleFadeTransition({
    this.scaleBegin = 0.8,
    this.scaleEnd = 1.0,
    this.opacityBegin = 0.0,
    this.opacityEnd = 1.0,
    this.duration = const Duration(milliseconds: 300),
  });

  /// Starting scale value.
  final double scaleBegin;

  /// Ending scale value.
  final double scaleEnd;

  /// Starting opacity value.
  final double opacityBegin;

  /// Ending opacity value.
  final double opacityEnd;

  /// Duration of the animation.
  final Duration duration;

  @override
  PageRouteBuilder<T> buildPageRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        return FadeTransition(
          opacity: Tween<double>(
            begin: opacityBegin,
            end: opacityEnd,
          ).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: scaleBegin,
              end: scaleEnd,
            ).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: duration,
      reverseTransitionDuration: duration,
    );
  }
}

/// A combined slide and fade transition animation for page routes.
///
/// This transition applies both sliding and fading simultaneously,
/// creating a smooth, elegant effect.
///
/// ## Named Constructors
///
/// - [DashSlideFadeTransition.right] - Slide from right with fade
/// - [DashSlideFadeTransition.bottom] - Slide from bottom with fade
///
/// ## Example
///
/// ```dart
/// @DashRoute(
///   path: '/overlay',
///   transition: DashSlideFadeTransition.right(),
/// )
/// class OverlayPage extends StatelessWidget {
///   const OverlayPage({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Overlay');
/// }
/// ```
final class DashSlideFadeTransition implements DashTransition {
  /// Creates a combined slide and fade transition.
  ///
  /// [slideBeginX] - Starting X offset. Defaults to 0.0.
  /// [slideBeginY] - Starting Y offset. Defaults to 0.1.
  /// [slideEndX] - Ending X offset. Defaults to 0.0.
  /// [slideEndY] - Ending Y offset. Defaults to 0.0.
  /// [opacityBegin] - Starting opacity. Defaults to 0.0.
  /// [opacityEnd] - Ending opacity. Defaults to 1.0.
  /// [duration] - Duration of the animation. Defaults to 300ms.
  ///
  /// Example:
  /// ```dart
  /// const transition = DashSlideFadeTransition(
  ///   slideBeginX: 0.5,
  ///   slideBeginY: 0.0,
  /// );
  /// ```
  const DashSlideFadeTransition({
    this.slideBeginX = 0.0,
    this.slideBeginY = 0.1,
    this.slideEndX = 0.0,
    this.slideEndY = 0.0,
    this.opacityBegin = 0.0,
    this.opacityEnd = 1.0,
    this.duration = const Duration(milliseconds: 300),
  });

  /// Creates a slide-fade transition from the right.
  ///
  /// [opacityBegin] - Starting opacity. Defaults to 0.0.
  /// [opacityEnd] - Ending opacity. Defaults to 1.0.
  /// [duration] - Duration of the animation. Defaults to 300ms.
  ///
  /// Example:
  /// ```dart
  /// const transition = DashSlideFadeTransition.right();
  /// ```
  const DashSlideFadeTransition.right({
    this.opacityBegin = 0.0,
    this.opacityEnd = 1.0,
    this.duration = const Duration(milliseconds: 300),
  })  : slideBeginX = 0.3,
        slideBeginY = 0.0,
        slideEndX = 0.0,
        slideEndY = 0.0;

  /// Creates a slide-fade transition from the bottom.
  ///
  /// [opacityBegin] - Starting opacity. Defaults to 0.0.
  /// [opacityEnd] - Ending opacity. Defaults to 1.0.
  /// [duration] - Duration of the animation. Defaults to 300ms.
  ///
  /// Example:
  /// ```dart
  /// const transition = DashSlideFadeTransition.bottom();
  /// ```
  const DashSlideFadeTransition.bottom({
    this.opacityBegin = 0.0,
    this.opacityEnd = 1.0,
    this.duration = const Duration(milliseconds: 300),
  })  : slideBeginX = 0.0,
        slideBeginY = 0.3,
        slideEndX = 0.0,
        slideEndY = 0.0;

  /// Starting X offset.
  final double slideBeginX;

  /// Starting Y offset.
  final double slideBeginY;

  /// Ending X offset.
  final double slideEndX;

  /// Ending Y offset.
  final double slideEndY;

  /// Starting opacity value.
  final double opacityBegin;

  /// Ending opacity value.
  final double opacityEnd;

  /// Duration of the animation.
  final Duration duration;

  @override
  PageRouteBuilder<T> buildPageRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        return FadeTransition(
          opacity: Tween<double>(
            begin: opacityBegin,
            end: opacityEnd,
          ).animate(curved),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(slideBeginX, slideBeginY),
              end: Offset(slideEndX, slideEndY),
            ).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: duration,
      reverseTransitionDuration: duration,
    );
  }
}

/// A platform-adaptive transition that automatically selects the appropriate
/// transition style based on the current platform.
///
/// On iOS and macOS, this uses a Cupertino-style slide-from-right transition.
/// On Android and other platforms, it uses the Material Design transition.
///
/// This is the recommended transition for most apps as it provides a
/// native feel on each platform.
///
/// ## Example
///
/// ```dart
/// @DashRoute(
///   path: '/adaptive',
///   transition: PlatformTransition(),
/// )
/// class AdaptivePage extends StatelessWidget {
///   const AdaptivePage({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Adaptive');
/// }
/// ```
final class PlatformTransition implements DashTransition {
  /// Creates a platform-adaptive transition.
  ///
  /// Example:
  /// ```dart
  /// const transition = PlatformTransition();
  /// ```
  const PlatformTransition();

  @override
  PageRouteBuilder<T> buildPageRoute<T>(Widget page, RouteSettings settings) {
    final platform = defaultTargetPlatform;
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return _buildCupertinoRoute<T>(page, settings);
    }
    return _buildMaterialRoute<T>(page, settings);
  }

  PageRouteBuilder<T> _buildMaterialRoute<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.05),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }

  PageRouteBuilder<T> _buildCupertinoRoute<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 400),
    );
  }
}

/// A Material Design transition animation for page routes.
///
/// This uses the standard Material Design page transition with a fade
/// and slight vertical movement effect.
///
/// ## Example
///
/// ```dart
/// @DashRoute(
///   path: '/material',
///   transition: MaterialTransition(),
/// )
/// class MaterialStylePage extends StatelessWidget {
///   const MaterialStylePage({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Material');
/// }
/// ```
final class MaterialTransition implements DashTransition {
  /// Creates a Material Design transition.
  ///
  /// Example:
  /// ```dart
  /// const transition = MaterialTransition();
  /// ```
  const MaterialTransition();

  @override
  PageRouteBuilder<T> buildPageRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.05),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }
}

/// A Cupertino (iOS) style transition animation for page routes.
///
/// This uses the standard iOS page transition with a slide-from-right effect.
///
/// ## Example
///
/// ```dart
/// @DashRoute(
///   path: '/cupertino',
///   transition: CupertinoTransition(),
/// )
/// class CupertinoStylePage extends StatelessWidget {
///   const CupertinoStylePage({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Cupertino');
/// }
/// ```
final class CupertinoTransition implements DashTransition {
  /// Creates a Cupertino-style transition.
  ///
  /// Example:
  /// ```dart
  /// const transition = CupertinoTransition();
  /// ```
  const CupertinoTransition();

  @override
  PageRouteBuilder<T> buildPageRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 400),
    );
  }
}

/// An instant transition with no animation for page routes.
///
/// The new page appears immediately without any animation. This is useful
/// for tab switching or when you want to show content instantly.
///
/// ## Example
///
/// ```dart
/// @DashRoute(
///   path: '/instant',
///   transition: NoTransition(),
/// )
/// class InstantPage extends StatelessWidget {
///   const InstantPage({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Instant');
/// }
/// ```
final class NoTransition implements DashTransition {
  /// Creates an instant transition with no animation.
  ///
  /// Example:
  /// ```dart
  /// const transition = NoTransition();
  /// ```
  const NoTransition();

  @override
  PageRouteBuilder<T> buildPageRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}

// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Responsive breakpoints for adaptive layouts.
///
/// Following Material Design 3 responsive layout guidelines.
///
/// ## Usage
///
/// ```dart
/// final screenType = ResponsiveUtils.getScreenType(context);
/// if (screenType == ScreenType.mobile) {
///   // Show mobile layout
/// }
/// ```
abstract final class Breakpoints {
  /// Compact screens (phones in portrait).
  /// Width: 0 - 599dp
  static const double compact = 600;

  /// Medium screens (tablets in portrait, phones in landscape).
  /// Width: 600 - 839dp
  static const double medium = 840;

  /// Expanded screens (tablets in landscape, small desktop).
  /// Width: 840 - 1199dp
  static const double expanded = 1200;

  /// Large screens (desktop).
  /// Width: 1200 - 1599dp
  static const double large = 1600;

  /// Extra-large screens (large desktop).
  /// Width: 1600dp+
  static const double extraLarge = double.infinity;
}

/// Screen type categories for responsive design.
enum ScreenType {
  /// Compact screens (< 600dp), typically phones in portrait.
  compact,

  /// Medium screens (600dp - 839dp), typically tablets in portrait.
  medium,

  /// Expanded screens (840dp - 1199dp), typically tablets in landscape.
  expanded,

  /// Large screens (1200dp - 1599dp), typically desktop.
  large,

  /// Extra-large screens (>= 1600dp), typically large desktop.
  extraLarge,
}

/// Utility class for responsive layout calculations.
///
/// ## Example
///
/// ```dart
/// Widget build(BuildContext context) {
///   return ResponsiveBuilder(
///     compact: (context) => MobileLayout(),
///     medium: (context) => TabletLayout(),
///     expanded: (context) => DesktopLayout(),
///   );
/// }
/// ```
abstract final class ResponsiveUtils {
  /// Returns the [ScreenType] based on screen width.
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return getScreenTypeFromWidth(width);
  }

  /// Returns the [ScreenType] based on width value.
  static ScreenType getScreenTypeFromWidth(double width) {
    if (width < Breakpoints.compact) {
      return ScreenType.compact;
    } else if (width < Breakpoints.medium) {
      return ScreenType.medium;
    } else if (width < Breakpoints.expanded) {
      return ScreenType.expanded;
    } else if (width < Breakpoints.large) {
      return ScreenType.large;
    } else {
      return ScreenType.extraLarge;
    }
  }

  /// Returns true if the screen is compact (mobile phone).
  static bool isCompact(BuildContext context) {
    return getScreenType(context) == ScreenType.compact;
  }

  /// Returns true if the screen is medium (tablet portrait).
  static bool isMedium(BuildContext context) {
    return getScreenType(context) == ScreenType.medium;
  }

  /// Returns true if the screen is expanded or larger (tablet landscape+).
  static bool isExpanded(BuildContext context) {
    final type = getScreenType(context);
    return type == ScreenType.expanded ||
        type == ScreenType.large ||
        type == ScreenType.extraLarge;
  }

  /// Returns true if the screen is large or larger (desktop+).
  static bool isLarge(BuildContext context) {
    final type = getScreenType(context);
    return type == ScreenType.large || type == ScreenType.extraLarge;
  }

  /// Returns the number of grid columns based on screen type.
  static int getGridColumns(BuildContext context) {
    return switch (getScreenType(context)) {
      ScreenType.compact => 4,
      ScreenType.medium => 8,
      ScreenType.expanded => 12,
      ScreenType.large => 12,
      ScreenType.extraLarge => 12,
    };
  }

  /// Returns the recommended content max width based on screen type.
  static double? getMaxContentWidth(BuildContext context) {
    return switch (getScreenType(context)) {
      ScreenType.compact => null,
      ScreenType.medium => null,
      ScreenType.expanded => 1040,
      ScreenType.large => 1280,
      ScreenType.extraLarge => 1440,
    };
  }

  /// Returns horizontal padding based on screen type.
  static double getHorizontalPadding(BuildContext context) {
    return switch (getScreenType(context)) {
      ScreenType.compact => 16,
      ScreenType.medium => 24,
      ScreenType.expanded => 32,
      ScreenType.large => 48,
      ScreenType.extraLarge => 64,
    };
  }
}

/// A responsive builder widget that builds different layouts based on screen size.
///
/// ## Example
///
/// ```dart
/// ResponsiveBuilder(
///   compact: (context) => MobileView(),
///   medium: (context) => TabletView(),
///   expanded: (context) => DesktopView(),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  /// Creates a responsive builder.
  ///
  /// The [compact] builder is required as the base layout.
  /// Other builders will fall back to smaller screen builders if not provided.
  const ResponsiveBuilder({
    required this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
    super.key,
  });

  /// Builder for compact screens (< 600dp).
  final WidgetBuilder compact;

  /// Builder for medium screens (600dp - 839dp).
  /// Falls back to [compact] if null.
  final WidgetBuilder? medium;

  /// Builder for expanded screens (840dp - 1199dp).
  /// Falls back to [medium] or [compact] if null.
  final WidgetBuilder? expanded;

  /// Builder for large screens (1200dp - 1599dp).
  /// Falls back to [expanded], [medium], or [compact] if null.
  final WidgetBuilder? large;

  /// Builder for extra-large screens (>= 1600dp).
  /// Falls back to [large], [expanded], [medium], or [compact] if null.
  final WidgetBuilder? extraLarge;

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveUtils.getScreenType(context);

    return switch (screenType) {
      ScreenType.compact => compact(context),
      ScreenType.medium => (medium ?? compact)(context),
      ScreenType.expanded => (expanded ?? medium ?? compact)(context),
      ScreenType.large => (large ?? expanded ?? medium ?? compact)(context),
      ScreenType.extraLarge =>
        (extraLarge ?? large ?? expanded ?? medium ?? compact)(context),
    };
  }
}

/// Extension on [BuildContext] for responsive utilities.
extension ResponsiveContextExtension on BuildContext {
  /// Returns the current [ScreenType] for this context.
  ScreenType get screenType => ResponsiveUtils.getScreenType(this);

  /// Returns true if the screen is compact (mobile phone).
  bool get isCompact => ResponsiveUtils.isCompact(this);

  /// Returns true if the screen is medium (tablet portrait).
  bool get isMedium => ResponsiveUtils.isMedium(this);

  /// Returns true if the screen is expanded or larger.
  bool get isExpanded => ResponsiveUtils.isExpanded(this);

  /// Returns true if the screen is large or larger.
  bool get isLarge => ResponsiveUtils.isLarge(this);

  /// Returns the recommended number of grid columns.
  int get gridColumns => ResponsiveUtils.getGridColumns(this);

  /// Returns the recommended max content width.
  double? get maxContentWidth => ResponsiveUtils.getMaxContentWidth(this);

  /// Returns the recommended horizontal padding.
  double get horizontalPadding => ResponsiveUtils.getHorizontalPadding(this);
}

// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

/// Application color schemes for light and dark themes.
///
/// Uses Material 3 color system with a blue seed color.
///
/// ## Usage
///
/// ```dart
/// final colorScheme = AppColors.lightColorScheme;
/// final primary = colorScheme.primary;
/// ```
abstract final class AppColors {
  /// Primary seed color for generating color schemes.
  static const Color seedColor = Color(0xFF2196F3);

  /// Light theme color scheme.
  ///
  /// Generated from [seedColor] with [Brightness.light].
  static final ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );

  /// Dark theme color scheme.
  ///
  /// Generated from [seedColor] with [Brightness.dark].
  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );

  /// Success color for positive states.
  static const Color success = Color(0xFF4CAF50);

  /// Warning color for caution states.
  static const Color warning = Color(0xFFFFC107);

  /// Error color for error states.
  static const Color error = Color(0xFFF44336);

  /// Info color for informational states.
  static const Color info = Color(0xFF2196F3);
}

/// Extension on [ColorScheme] for additional utility colors.
extension ColorSchemeExtension on ColorScheme {
  /// Success color adapted to the current brightness.
  Color get success => brightness == Brightness.light
      ? AppColors.success
      : AppColors.success.withValues(alpha: 0.8);

  /// Warning color adapted to the current brightness.
  Color get warning => brightness == Brightness.light
      ? AppColors.warning
      : AppColors.warning.withValues(alpha: 0.8);

  /// Info color adapted to the current brightness.
  Color get info => brightness == Brightness.light
      ? AppColors.info
      : AppColors.info.withValues(alpha: 0.8);
}

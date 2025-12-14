// Copyright 2025 The Dash Router Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'color_schemes.dart';

/// Application theme configuration for dash_router example.
///
/// This class provides both light and dark theme configurations
/// using Material 3 design system.
///
/// ## Usage
///
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
///   themeMode: ThemeMode.system,
/// )
/// ```
abstract final class AppTheme {
  /// Light theme configuration.
  ///
  /// Uses [AppColors.lightColorScheme] as the base color scheme.
  static ThemeData get light => _buildTheme(Brightness.light);

  /// Dark theme configuration.
  ///
  /// Uses [AppColors.darkColorScheme] as the base color scheme.
  static ThemeData get dark => _buildTheme(Brightness.dark);

  /// Builds a theme for the given brightness.
  static ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = brightness == Brightness.light
        ? AppColors.lightColorScheme
        : AppColors.darkColorScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      // AppBar theme
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      // Card theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      // Chip theme
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      // Button themes
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      // Navigation bar theme (bottom navigation)
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
      // Navigation rail theme
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        selectedIconTheme: IconThemeData(
          color: colorScheme.onSecondaryContainer,
        ),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
        ),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      // Drawer theme
      drawerTheme: DrawerThemeData(
        elevation: 1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        backgroundColor: colorScheme.surface,
      ),
      // List tile theme
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
      ),
      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      // Dialog theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 3,
      ),
      // Bottom sheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
      ),
      // Page transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // iOS system colors
  static const blue = Color(0xFF007AFF);
  static const blueDark = Color(0xFF0A84FF);
  static const green = Color(0xFF34C759);
  static const red = Color(0xFFFF3B30);
  static const orange = Color(0xFFFF9500);

  static const lightBackground = Color(0xFFF2F2F7); // systemGroupedBackground
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSeparator = Color(0x333C3C43);
  static const lightLabel = Color(0xFF000000);
  static const lightSecondaryLabel = Color(0x993C3C43);

  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF1C1C1E);
  static const darkSeparator = Color(0x99545458);
  static const darkLabel = Color(0xFFFFFFFF);
  static const darkSecondaryLabel = Color(0x99EBEBF5);
}

class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final primary = isDark ? AppColors.blueDark : AppColors.blue;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final label = isDark ? AppColors.darkLabel : AppColors.lightLabel;
    final secondary =
        isDark ? AppColors.darkSecondaryLabel : AppColors.lightSecondaryLabel;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      brightness: brightness,
    ).copyWith(
      primary: primary,
      surface: surface,
      onSurface: label,
      error: AppColors.red,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      splashFactory: NoSplash.splashFactory, // no Material ripple, like iOS
      highlightColor: Colors.transparent,
      dividerColor: isDark ? AppColors.darkSeparator : AppColors.lightSeparator,

      // Smooth iOS-style swipe-back transitions on every platform
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),

      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: label),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: label),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: label),
        titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: label),
        bodyLarge: TextStyle(fontSize: 17, color: label),
        bodyMedium: TextStyle(fontSize: 15, color: label),
        bodySmall: TextStyle(fontSize: 13, color: secondary),
        labelSmall: TextStyle(fontSize: 11, color: secondary),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: label,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: label,
        ),
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(50),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontSize: 17),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: secondary),
      ),

      listTileTheme: ListTileThemeData(
        tileColor: surface,
        iconColor: primary,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.green
                : (isDark ? const Color(0xFF39393D) : const Color(0xFFE9E9EA))),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }
}
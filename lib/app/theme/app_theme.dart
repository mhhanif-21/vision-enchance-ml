// File ini menggabungkan konfigurasi warna dan tipografi menjadi ThemeData.
// ThemeData ini kemudian dipasangkan ke MaterialApp di main.dart.
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.secondary,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        tertiary: AppColors.tertiary,
        error: AppColors.error,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
      ),
      textTheme: ThemeData.light().textTheme.copyWith(
        displayLarge: AppTypography.headlineXl,
        displayMedium: AppTypography.headlineLg,
        displaySmall: AppTypography.headlineMd,
        headlineLarge: AppTypography.headlineXl,
        headlineMedium: AppTypography.headlineLg,
        headlineSmall: AppTypography.headlineMd,
        titleLarge: AppTypography.headlineMd,
        titleMedium: AppTypography.bodyLg,
        titleSmall: AppTypography.bodyMd,
        bodyLarge: AppTypography.bodyLg,
        bodyMedium: AppTypography.bodyMd,
        bodySmall: AppTypography.bodySm,
        labelLarge: AppTypography.labelMd,
        labelMedium: AppTypography.bodySm,
        labelSmall: AppTypography.bodySm,
      ).apply(
        bodyColor: AppColors.onSurface,
        displayColor: AppColors.onSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded 0.5rem
          ),
          textStyle: AppTypography.labelMd,
          elevation: 2,
          shadowColor: AppColors.secondary.withValues(alpha: 0.1),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: const BorderSide(color: AppColors.secondary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: AppTypography.labelMd,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          textStyle: AppTypography.labelMd,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0), // Rounded 1.5rem for cards
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  // Tema gelap yang menggunakan warna dark selaras dengan design system Stitch.
  static ThemeData get darkTheme {
    const darkSurface = Color(0xFF1A1C1C);
    const darkOnSurface = Color(0xFFE2E3E3);
    const darkContainer = Color(0xFF2A2C2C);
    const darkSecondary = Color(0xFF7ECAC8);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkSurface,
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFFC7C7C3),
        onPrimary: const Color(0xFF303030),
        secondary: darkSecondary,
        onSecondary: const Color(0xFF003332),
        surface: darkSurface,
        onSurface: darkOnSurface,
        error: const Color(0xFFFFB4AB),
      ),
      textTheme: ThemeData.dark().textTheme.copyWith(
        displayLarge: AppTypography.headlineXl,
        displayMedium: AppTypography.headlineLg,
        displaySmall: AppTypography.headlineMd,
        headlineLarge: AppTypography.headlineXl,
        headlineMedium: AppTypography.headlineLg,
        headlineSmall: AppTypography.headlineMd,
        titleLarge: AppTypography.headlineMd,
        titleMedium: AppTypography.bodyLg,
        titleSmall: AppTypography.bodyMd,
        bodyLarge: AppTypography.bodyLg,
        bodyMedium: AppTypography.bodyMd,
        bodySmall: AppTypography.bodySm,
        labelLarge: AppTypography.labelMd,
        labelMedium: AppTypography.bodySm,
        labelSmall: AppTypography.bodySm,
      ).apply(bodyColor: darkOnSurface, displayColor: darkOnSurface),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkSecondary,
          foregroundColor: const Color(0xFF003332),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTypography.labelMd,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkContainer,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkSecondary, width: 2),
        ),
      ),
    );
  }
}

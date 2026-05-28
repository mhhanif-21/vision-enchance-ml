/// File ini menggabungkan konfigurasi warna dan tipografi menjadi ThemeData.
/// ThemeData ini kemudian dipasangkan ke MaterialApp di main.dart.
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  // Mendapatkan konfigurasi tema terang (Light Theme) secara keseluruhan.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.secondary,
        primary: AppColors.secondary,
        background: AppColors.background,
        error: AppColors.error,
        surface: AppColors.surface,
        onBackground: AppColors.onBackground,
      ),
      // Menerapkan font Inter sebagai default text theme
      textTheme: TextTheme(
        displayLarge: AppTypography.headlineXl,
        displayMedium: AppTypography.headlineLg,
        displaySmall: AppTypography.headlineMd,
        bodyLarge: AppTypography.bodyLg,
        bodyMedium: AppTypography.bodyMd,
        bodySmall: AppTypography.bodySm,
        labelLarge: AppTypography.labelMd,
      ).apply(
        bodyColor: AppColors.onBackground,
        displayColor: AppColors.onBackground,
      ),
      // Konfigurasi style khusus untuk tombol (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded 0.5rem
          ),
          textStyle: AppTypography.labelMd,
          elevation: 2,
        ),
      ),
      // Konfigurasi style khusus untuk kartu penampung (Card)
      cardTheme: CardThemeData(
        color: AppColors.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // Rounded 1rem untuk cards
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}

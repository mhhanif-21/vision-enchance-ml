import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => TextTheme(
    displayLarge: _headlineXl,
    displayMedium: _headlineLg,
    displaySmall: _headlineMd,
    headlineLarge: _headlineLg,
    headlineMedium: _headlineMd,
    titleLarge: _headlineMd,
    titleMedium: _bodyLg,
    bodyLarge: _bodyLg,
    bodyMedium: _bodyMd,
    bodySmall: _bodySm,
    labelLarge: _labelMd,
    labelMedium: _labelMd,
    labelSmall: _labelSm,
  );

  static TextStyle get _headlineXl => GoogleFonts.manrope(
    fontSize: 40,
    fontWeight: FontWeight.w300,
    height: 48 / 40,
    letterSpacing: -0.8,
  );

  static TextStyle get _headlineLg => GoogleFonts.manrope(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 40 / 32,
    letterSpacing: -0.32,
  );

  static TextStyle get _headlineMd => GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 32 / 24,
  );

  static TextStyle get _bodyLg => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 28 / 18,
  );

  static TextStyle get _bodyMd => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static TextStyle get _bodySm => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
  );

  static TextStyle get _labelMd => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 16 / 14,
    letterSpacing: 0.7,
  );

  static TextStyle get _labelSm => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 14 / 12,
  );
}

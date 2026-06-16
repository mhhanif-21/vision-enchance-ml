// Tipografi aplikasi (Font size, weight, font family).
// Menggunakan Manrope untuk judul dan Inter untuk body text.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextStyle get headlineXl => GoogleFonts.manrope(
        fontSize: 40,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.02,
        height: 1.2,
      ).copyWith(inherit: false);

  static TextStyle get headlineLg => GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.01,
        height: 1.25,
      ).copyWith(inherit: false);

  static TextStyle get headlineMd => GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.33,
      ).copyWith(inherit: false);

  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.55,
      ).copyWith(inherit: false);

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ).copyWith(inherit: false);

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.42,
      ).copyWith(inherit: false);

  static TextStyle get labelMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05,
        height: 1.14,
      ).copyWith(inherit: false);
}

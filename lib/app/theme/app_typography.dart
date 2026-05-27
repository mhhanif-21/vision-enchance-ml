/// File ini mengatur tipografi aplikasi (Font size, weight, font family).
/// Berdasarkan desain, menggunakan Manrope untuk judul dan Inter untuk body text.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Gaya teks untuk judul besar (Manrope).
  static TextStyle get headlineXl => GoogleFonts.manrope(
        fontSize: 40,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.02,
        height: 1.2,
      );

  // Gaya teks untuk sub-judul (Manrope).
  static TextStyle get headlineLg => GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.01,
        height: 1.25,
      );

  // Gaya teks untuk judul kartu/komponen (Manrope).
  static TextStyle get headlineMd => GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.33,
      );

  // Gaya teks utama untuk paragraf besar (Inter).
  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.55,
      );

  // Gaya teks reguler untuk paragraf standar (Inter).
  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  // Gaya teks kecil untuk keterangan (Inter).
  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.42,
      );

  // Gaya teks untuk label pada tombol atau form (Inter).
  static TextStyle get labelMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05,
        height: 1.14,
      );
}

import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const background   = Color(0xFF1E2235);
  static const surface      = Color(0xFF262D45);
  static const surfaceBorder = Color(0x18FFFFFF);

  // Text
  static const textPrimary   = Color(0xFFEEF0F8);
  static const textSecondary = Color(0xFF8A90A8);
  static const textMuted     = Color(0xFF4A5068);

  // Accent
  static const accent        = Color(0xFF5B8AF0);
  static const accentBg      = Color(0x1A5B8AF0);
  static const accentBorder  = Color(0x4D5B8AF0);

  // Semantic
  static const green         = Color(0xFF3DBE7A);
  static const greenBg       = Color(0x1A3DBE7A);
  static const amber         = Color(0xFFE8A020);
  static const amberBg       = Color(0x1AE8A020);
  static const red           = Color(0xFFE05050);
  static const redBg         = Color(0x1AE05050);
  static const blue          = Color(0xFF378ADD);
  static const blueBg        = Color(0x1A378ADD);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.accent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w500,
      ),
      iconTheme: IconThemeData(color: AppColors.textSecondary),
    ),
  );
}
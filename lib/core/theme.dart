import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF28282B);
  static const Color cardColor = Color(0xFF2C2C2E);
  static const Color primary = Color(0xFF534AB7);
  static const Color contentBg = Color(0xFFF4F3F0);
  static const Color priceGreen = Color(0xFF1D9E75);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A8C0);
  static const Color textMuted = Color(0xFF6E6E73);
  static const Color border = Color(0xFF3A3A3C);

  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: contentBg,
        primaryColor: primary,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: textPrimary,
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: primary,
          surface: Color(0xFF1A1A2E),
        ),
      );
}
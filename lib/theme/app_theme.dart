 
import 'package:flutter/material.dart';

// অ্যাপের সব রঙ এক জায়গায় রাখা হয়েছে।
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF7B5EA7);
  static const Color primaryDark = Color(0xFF5B3F8C);
  static const Color lavender = Color(0xFFE6DFF5);
  static const Color lavenderLight = Color(0xFFF3EFFA);
  static const Color cream = Color(0xFFFFF8EE);
  static const Color offWhite = Color(0xFFFBF9F6);
  static const Color textDark = Color(0xFF2E2540);
  static const Color textMuted = Color(0xFF7A6F8C);
  static const Color gold = Color(0xFFE8C98B);
  static const Color error = Color(0xFFC0504D);
  static const Color success = Color(0xFF6BAA8E);
}

// পুরো অ্যাপের Theme।
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      surface: AppColors.offWhite,
      onSurface: AppColors.textDark,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cream,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

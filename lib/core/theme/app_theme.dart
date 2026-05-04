import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryTeal,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryTeal,
        secondary: AppColors.primaryMagenta,
        surface: AppColors.surface,
        error: Colors.redAccent,
      ),
      textTheme: GoogleFonts.rajdhaniTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTeal,
            letterSpacing: 2.0,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.textMain,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
      ).copyWith(
        // For technical data, we'll use a separate class or style
      ),
    );
  }

  static TextStyle monoStyle({
    double fontSize = 12,
    Color color = AppColors.primaryTeal,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.shareTechMono(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    );
  }
}

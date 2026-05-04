import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF080C16);
  static const Color surface = Color(0xFF0D1420);
  static const Color cardInner = Color(0xFF080C16);
  
  static const Color primaryTeal = Color(0xFF00E5FF);
  static const Color primaryMagenta = Color(0xFFE040FB);
  static const Color primaryGreen = Color(0xFF39FF14);
  
  static const Color textMain = Color(0xFFD0D8E8); // Brighter white/blue-ish
  static const Color textMuted = Color(0x66D0D8E8); // rgba(208,216,232,0.4)
  
  static const Color glowTeal = Color(0x8000E5FF);
  static const Color glowMagenta = Color(0x80E040FB);

  static LinearGradient cardBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryTeal.withOpacity(0.35),
      primaryTeal.withOpacity(0.12),
      primaryTeal.withOpacity(0.12),
    ],
  );

  static LinearGradient activeCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryTeal.withOpacity(0.7),
      primaryTeal.withOpacity(0.3),
    ],
  );
}

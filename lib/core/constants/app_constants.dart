import 'package:flutter/material.dart';

class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://34.101.80.230:8080';
  
  // UI Dimensions
  static const double miniPlayerHeight = 76.0;
  static const double bottomNavHeight = 85.0;
  static const double angularCutSize = 14.0;
  
  // Animation Durations
  static const Duration fastAnim = Duration(milliseconds: 200);
  static const Duration mediumAnim = Duration(milliseconds: 400);
  static const Duration slowAnim = Duration(seconds: 1);
  
  // Design Tokens (Shadows, Glows)
  static List<BoxShadow> neonGlow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: 12,
      spreadRadius: 2,
    ),
  ];
}

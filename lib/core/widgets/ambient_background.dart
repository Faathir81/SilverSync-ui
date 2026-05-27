import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// A clean, full-screen background with subtle radial violet glows.
/// No more matrix rain — replaced with a premium static gradient.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.background),

        // Top-left violet glow
        Positioned(
          top: -120,
          left: -80,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Bottom-right warm glow
        Positioned(
          bottom: -100,
          right: -60,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentWarm.withValues(alpha: 0.07),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Centre very subtle noise overlay for depth
        Positioned.fill(
          child: Opacity(
            opacity: 0.015,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.transparent, Colors.transparent],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

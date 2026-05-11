import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'matrix_background.dart';

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark background
        Container(color: AppColors.background),
        
        // Matrix Effect with isolation
        const Positioned.fill(
          child: RepaintBoundary(
            child: MatrixBackground(),
          ),
        ),

        // Top Left Teal Glow
        Positioned(
          top: -100,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.primaryTeal.withOpacity(0.08), Colors.transparent],
              ),
            ),
          ),
        ),

        // Bottom Right Magenta Glow
        Positioned(
          bottom: -100,
          right: -50,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.primaryMagenta.withOpacity(0.05), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

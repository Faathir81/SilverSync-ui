import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class MatrixBackground extends StatefulWidget {
  const MatrixBackground({super.key});

  @override
  State<MatrixBackground> createState() => _MatrixBackgroundState();
}

class _MatrixBackgroundState extends State<MatrixBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _MatrixPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _MatrixPainter extends CustomPainter {
  final double animationValue;

  _MatrixPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Medium density for columns
    const int columnWidth = 45;
    final int columnCount = (size.width / columnWidth).ceil();

    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < columnCount; i++) {
      // Use pseudo-random logic based on column index so it doesn't change every frame
      final double speed = 0.1 + ((i * 13) % 10) / 20.0; // Fixed speed per column
      final double offset = ((i * 7) % 10) / 10.0; // Fixed offset per column
      
      // Calculate current vertical position, adding extra height so it completely clears the screen
      double y = ((animationValue * speed + offset) % 1.0) * (size.height + 300);
      double x = i * columnWidth.toDouble() + ((i * 11) % 20); // Add some jitter to x

      // Draw a trailing vertical line of '1's and '0's
      for (int j = 0; j < 12; j++) {
        // Very dim opacity, trailing off
        final double opacity = 1.0 - (j / 12.0);
        // Static pseudo-random character so it doesn't flicker/patah-patah
        final String char = ((i + j) % 3 == 0) ? '1' : '0';
        
        // Alternate column colors between Teal and Magenta
        final Color baseColor = (i % 2 == 0) ? AppColors.primaryTeal : AppColors.primaryMagenta;

        textPainter.text = TextSpan(
          text: char,
          style: TextStyle(
            color: baseColor.withOpacity(opacity * 0.08), // Redup / almost invisible
            fontFamily: 'Share Tech Mono',
            fontSize: 14,
          ),
        );
        textPainter.layout();
        
        final double drawY = y - (j * 18);
        if (drawY > -20 && drawY < size.height + 20) {
          textPainter.paint(canvas, Offset(x, drawY));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MatrixPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

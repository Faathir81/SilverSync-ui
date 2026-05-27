import 'package:flutter/material.dart';
import '../constants/colors.dart';


class MatrixBackground extends StatefulWidget {
  const MatrixBackground({super.key});

  @override
  State<MatrixBackground> createState() => _MatrixBackgroundState();
}

class _MatrixBackgroundState extends State<MatrixBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Map<String, TextPainter> _painters = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _initPainters();
  }

  void _initPainters() {
    // Cache the 24 possible combinations (12 opacities x 2 colors x 2 chars)
    for (int j = 0; j < 12; j++) {
      final double opacity = 1.0 - (j / 12.0);
      for (final color in [AppColors.primaryTeal, AppColors.primaryMagenta]) {
        for (final char in ['0', '1']) {
          final tp = TextPainter(
            text: TextSpan(
              text: char,
              style: TextStyle(
                color: color.withOpacity(opacity * 0.08),
                fontFamily: 'Share Tech Mono',
                fontSize: 14,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          tp.layout();
          final key = '${char}_${color.value}_$j';
          _painters[key] = tp;
        }
      }
    }
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
          painter: _MatrixPainter(_controller.value, _painters),
          size: Size.infinite,
        );
      },
    );
  }
}

class _MatrixPainter extends CustomPainter {
  final double animationValue;
  final Map<String, TextPainter> painters;

  _MatrixPainter(this.animationValue, this.painters);

  @override
  void paint(Canvas canvas, Size size) {
    const int columnWidth = 45;
    final int columnCount = (size.width / columnWidth).ceil();

    for (int i = 0; i < columnCount; i++) {
      final double speed = 0.1 + ((i * 13) % 10) / 20.0;
      final double offset = ((i * 7) % 10) / 10.0;
      
      double y = ((animationValue * speed + offset) % 1.0) * (size.height + 300);
      double x = i * columnWidth.toDouble() + ((i * 11) % 20);

      for (int j = 0; j < 12; j++) {
        final String char = ((i + j) % 3 == 0) ? '1' : '0';
        final Color baseColor = (i % 2 == 0) ? AppColors.primaryTeal : AppColors.primaryMagenta;
        final key = '${char}_${baseColor.value}_$j';
        
        final double drawY = y - (j * 18);
        if (drawY > -20 && drawY < size.height + 20) {
          painters[key]?.paint(canvas, Offset(x, drawY));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MatrixPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

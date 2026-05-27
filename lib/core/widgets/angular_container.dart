import 'package:flutter/material.dart';
import '../constants/colors.dart';

class _AngularPainter extends CustomPainter {
  final double cutSize;
  final bool isActive;
  final Color fillColor;
  final Gradient borderGradient;

  _AngularPainter({
    required this.cutSize,
    required this.isActive,
    required this.fillColor,
    required this.borderGradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path();
    path.moveTo(cutSize, 0);
    path.lineTo(size.width - cutSize, 0);
    path.lineTo(size.width, cutSize);
    path.lineTo(size.width, size.height - cutSize);
    path.lineTo(size.width - cutSize, size.height);
    path.lineTo(cutSize, size.height);
    path.lineTo(0, size.height - cutSize);
    path.lineTo(0, cutSize);
    path.close();

    // Draw shadow if active
    if (isActive) {
      canvas.drawShadow(path, AppColors.primaryTeal.withOpacity(0.15), 12, false);
    }

    // Fill
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor;
    canvas.drawPath(path, fillPaint);

    // Border
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..shader = borderGradient.createShader(rect);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _AngularPainter oldDelegate) {
    return oldDelegate.isActive != isActive || 
           oldDelegate.cutSize != cutSize ||
           oldDelegate.fillColor != fillColor ||
           oldDelegate.borderGradient != borderGradient;
  }
}

class AngularContainer extends StatelessWidget {
  final Widget child;
  final double cutSize;
  final bool isActive;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  const AngularContainer({
    super.key,
    required this.child,
    this.cutSize = 14.0,
    this.isActive = false,
    this.padding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AngularPainter(
        cutSize: cutSize,
        isActive: isActive,
        fillColor: isActive 
          ? AppColors.primaryTeal.withOpacity(0.05) 
          : const Color.fromRGBO(8, 12, 22, 0.6), // Matched from prototype
        borderGradient: isActive ? AppColors.activeCardGradient : AppColors.cardBorderGradient,
      ),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        child: child,
      ),
    );
  }
}

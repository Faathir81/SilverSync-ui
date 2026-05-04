import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AngularClipper extends CustomClipper<Path> {
  final double cutSize;

  AngularClipper({this.cutSize = 14.0});

  @override
  Path getClip(Size size) {
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
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
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
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: isActive 
          ? [
              BoxShadow(
                color: AppColors.primaryTeal.withOpacity(0.15),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ]
          : [],
      ),
      child: ClipPath(
        clipper: AngularClipper(cutSize: cutSize),
        child: Container(
          padding: const EdgeInsets.all(1), // Border width
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.activeCardGradient : AppColors.cardBorderGradient,
          ),
          child: ClipPath(
            clipper: AngularClipper(cutSize: cutSize - 1),
            child: Container(
              padding: padding,
              color: isActive 
                ? AppColors.primaryTeal.withOpacity(0.05) 
                : const Color.fromRGBO(8, 12, 22, 0.6), // Matched from prototype
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

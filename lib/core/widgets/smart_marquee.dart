import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

/// A smart text widget that scrolls (marquee) when [isActive] is true,
/// and falls back to a static ellipsis text when false.
///
/// Only animates when playing to conserve CPU and battery.
class SmartMarquee extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double height;

  /// When true, the text will scroll. When false, it is static with ellipsis.
  final bool isActive;

  const SmartMarquee({
    super.key,
    required this.text,
    required this.style,
    this.height = 20,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: isActive
          ? Marquee(
              text: text,
              style: style,
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              blankSpace: 50.0,
              velocity: 30.0,
              pauseAfterRound: const Duration(seconds: 2),
              startPadding: 0,
              accelerationDuration: const Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: const Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            )
          : Text(
              text,
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
    );
  }
}

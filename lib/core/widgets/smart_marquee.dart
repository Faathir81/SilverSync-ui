import 'package:flutter/material.dart';
import 'marquee_text.dart';

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
          ? MarqueeText(
              text: text,
              style: style,
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

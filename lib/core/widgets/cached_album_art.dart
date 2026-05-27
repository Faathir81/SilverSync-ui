import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/colors.dart';

/// A consistent, rounded album art widget with gradient placeholder.
class CachedAlbumArt extends StatelessWidget {
  final String? url;
  final double size;
  final double borderRadius;
  final bool isPlaying;
  final bool showGlow;

  const CachedAlbumArt({
    super.key,
    required this.url,
    required this.size,
    this.borderRadius = 8,
    this.isPlaying = false,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget art = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: (url != null && url!.isNotEmpty)
          ? CachedNetworkImage(
              imageUrl: url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, __) => _Placeholder(size: size, radius: borderRadius),
              errorWidget: (_, __, ___) => _Placeholder(size: size, radius: borderRadius),
            )
          : _Placeholder(size: size, radius: borderRadius),
    );

    if (!showGlow) return art;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: showGlow ? 0.35 : 0),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: art,
    );
  }
}

class _Placeholder extends StatelessWidget {
  final double size;
  final double radius;
  const _Placeholder({required this.size, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2440), Color(0xFF1A1830)],
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        size: size * 0.4,
        color: AppColors.textTertiary,
      ),
    );
  }
}

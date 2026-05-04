import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

/// Reusable album art widget with automatic caching via CachedNetworkImage.
/// - Uses [CachedNetworkImage] to cache images in disk → no re-download on scroll
/// - Shows a glowing placeholder while loading
/// - Gracefully falls back to a music note icon on error
class CachedAlbumArt extends StatelessWidget {
  final String? url;
  final double size;
  final double borderRadius;
  final bool showGlow;
  final bool isPlaying;

  const CachedAlbumArt({
    super.key,
    this.url,
    this.size = 48,
    this.borderRadius = 4,
    this.showGlow = false,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.isFinite ? size : null,
      height: size.isFinite ? size : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.primaryTeal.withValues(alpha: 0.25),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ]
            : null,
        border: Border.all(
          color: isPlaying
              ? AppColors.primaryTeal.withValues(alpha: 0.6)
              : AppColors.primaryTeal.withValues(alpha: 0.18),
          width: isPlaying ? 1.5 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(),
            // Playing overlay
            if (isPlaying)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: const Icon(
                  Icons.graphic_eq,
                  color: AppColors.primaryTeal,
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final hasUrl = url != null && url!.isNotEmpty;
    if (!hasUrl) return _placeholder();

    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      // Memory cache: only set if size is finite to avoid Infinity error
      memCacheWidth: size.isFinite ? (size * 2).toInt() : null,
      memCacheHeight: size.isFinite ? (size * 2).toInt() : null,
      placeholder: (_, __) => _shimmer(),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }

  Widget _shimmer() => Container(
        color: AppColors.surface,
        child: Center(
          child: SizedBox(
            width: size.isFinite ? size * 0.3 : 40,
            height: size.isFinite ? size * 0.3 : 40,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation(
                AppColors.primaryTeal.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      );

  Widget _placeholder() => Container(
        color: AppColors.surface,
        child: Center(
          child: Icon(
            Icons.music_note_rounded,
            color: AppColors.primaryTeal.withValues(alpha: 0.25),
            size: size.isFinite ? size * 0.45 : 80,
          ),
        ),
      );
}

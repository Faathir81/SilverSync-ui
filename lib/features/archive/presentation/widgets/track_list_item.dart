import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cached_album_art.dart';
import '../../data/models/track_model.dart';


class TrackListItem extends StatelessWidget {
  final TrackModel track;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Widget Function({required String text, required TextStyle style, double height, bool isPlaying}) buildMarquee;

  const TrackListItem({
    super.key,
    required this.track,
    this.isPlaying = false,
    required this.onTap,
    required this.onLongPress,
    required this.buildMarquee,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isPlaying ? AppColors.primaryTeal.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          onTap: onTap,
          onLongPress: onLongPress,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: Hero(
            tag: 'albumArt_${track.id}',
            child: CachedAlbumArt(
              url: track.albumArtUrl,
              size: 52,
              showGlow: isPlaying,
            ),
          ),
          title: buildMarquee(
            text: track.title,
            style: AppTheme.darkTheme.textTheme.bodyLarge!.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isPlaying ? AppColors.primaryTeal : AppColors.textMain,
            ),
            height: 18,
            isPlaying: isPlaying,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              buildMarquee(
                text: track.artist,
                style: AppTheme.monoStyle(fontSize: 11, color: AppColors.textMuted.withOpacity(0.8)),
                height: 15,
                isPlaying: isPlaying,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildQualityBadge(track.quality),
                  const SizedBox(width: 8),
                  if (track.isFavorite)
                    const Icon(Icons.favorite, size: 10, color: AppColors.primaryMagenta),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '--',
                style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted.withOpacity(0.5)),
              ),
              const SizedBox(height: 4),
              Icon(
                track.driveFileId.isNotEmpty ? Icons.cloud_done_rounded : Icons.cloud_download_rounded,
                size: 14,
                color: track.driveFileId.isNotEmpty ? AppColors.primaryGreen.withOpacity(0.7) : AppColors.primaryTeal.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQualityBadge(String quality) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.primaryTeal.withOpacity(0.1),
        border: Border.all(color: AppColors.primaryTeal.withOpacity(0.3)),
      ),
      child: Text(
        quality.toUpperCase(),
        style: AppTheme.monoStyle(fontSize: 8, color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cached_album_art.dart';
import '../../../../core/widgets/smart_marquee.dart';
import '../../data/models/track_model.dart';

class TrackListItem extends StatefulWidget {
  final TrackModel track;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const TrackListItem({
    super.key,
    required this.track,
    this.isPlaying = false,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<TrackListItem> createState() => _TrackListItemState();
}

class _TrackListItemState extends State<TrackListItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onLongPress: widget.onLongPress,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: widget.isPlaying ? AppColors.surface.withValues(alpha: 0.5) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Hero(
                  tag: 'albumArt_${widget.track.id}',
                  child: CachedAlbumArt(
                    url: widget.track.albumArtUrl,
                    size: 56,
                    borderRadius: 8,
                    showGlow: widget.isPlaying,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SmartMarquee(
                        text: widget.track.title,
                        style: AppTheme.darkTheme.textTheme.bodyLarge!.copyWith(
                          fontSize: 16,
                          fontWeight: widget.isPlaying ? FontWeight.w700 : FontWeight.w500,
                          color: widget.isPlaying ? AppColors.accent : AppColors.textMain,
                        ),
                        height: 20,
                        isActive: widget.isPlaying,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildQualityBadge(widget.track.quality),
                          const SizedBox(width: 6),
                          Expanded(
                            child: SmartMarquee(
                              text: widget.track.artist,
                              style: AppTheme.darkTheme.textTheme.bodyMedium!.copyWith(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                              height: 18,
                              isActive: widget.isPlaying,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (widget.track.isFavorite)
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.favorite_rounded, size: 16, color: AppColors.primaryMagenta),
                  ),
                Icon(
                  widget.track.driveFileId.isNotEmpty ? Icons.cloud_done_rounded : Icons.cloud_download_rounded,
                  size: 18,
                  color: widget.track.driveFileId.isNotEmpty 
                      ? AppColors.primaryTeal.withValues(alpha: 0.8) 
                      : AppColors.textMuted.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQualityBadge(String quality) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        quality.toUpperCase(),
        style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
          fontSize: 9, 
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

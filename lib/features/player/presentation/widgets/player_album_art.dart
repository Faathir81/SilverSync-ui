import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/cached_album_art.dart';
import '../../../archive/data/models/track_model.dart';

class PlayerAlbumArt extends StatefulWidget {
  final TrackModel track;
  final bool isPlaying;

  const PlayerAlbumArt({
    super.key,
    required this.track,
    required this.isPlaying,
  });

  @override
  State<PlayerAlbumArt> createState() => _PlayerAlbumArtState();
}

class _PlayerAlbumArtState extends State<PlayerAlbumArt> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    if (widget.isPlaying) _rotationController.repeat();
  }

  @override
  void didUpdateWidget(PlayerAlbumArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Glow
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.20),
                  blurRadius: 60,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Rotating Art
          RotationTransition(
            turns: _rotationController,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.25), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(130),
                child: CachedAlbumArt(url: widget.track.albumArtUrl, size: 260),
              ),
            ),
          ),
          // Inner Hole (Vinyl look)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2),
              ],
            ),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cached_album_art.dart';
import '../../data/models/playlist_model.dart';
import '../pages/playlist_detail_page.dart';

class PlaylistListItem extends StatefulWidget {
  final PlaylistModel playlist;

  const PlaylistListItem({super.key, required this.playlist});

  @override
  State<PlaylistListItem> createState() => _PlaylistListItemState();
}

class _PlaylistListItemState extends State<PlaylistListItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlaylistDetailPage(
              playlistId: widget.playlist.id,
              playlistName: widget.playlist.name,
            ),
          ),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Row(
            children: [
              // Art
              Hero(
                tag: 'playlist_${widget.playlist.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: widget.playlist.tracks.isNotEmpty
                      ? CachedAlbumArt(
                          url: widget.playlist.tracks.first.albumArtUrl,
                          size: 60,
                          borderRadius: 10,
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceHigh,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.queue_music_rounded, color: AppColors.accent, size: 28),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.playlist.name,
                      style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.playlist.tracks.length} ${widget.playlist.tracks.length == 1 ? 'track' : 'tracks'}',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),

              Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

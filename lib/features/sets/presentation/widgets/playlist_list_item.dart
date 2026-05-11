import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cached_album_art.dart';
import '../../data/models/playlist_model.dart';
import '../pages/playlist_detail_page.dart';

class PlaylistListItem extends StatelessWidget {
  final PlaylistModel playlist;

  const PlaylistListItem({
    super.key,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryTeal.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Hero(
          tag: 'playlist_${playlist.id}',
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryTeal.withOpacity(0.1)),
            ),
            child: playlist.tracks.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedAlbumArt(url: playlist.tracks.first.albumArtUrl, size: 56),
                  )
                : const Icon(Icons.playlist_play_rounded, color: AppColors.primaryTeal, size: 28),
          ),
        ),
        title: Text(
          playlist.name,
          style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Collection • ${playlist.tracks.length} tracks',
          style: AppTheme.monoStyle(fontSize: 11, color: AppColors.textMuted.withOpacity(0.6)),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted.withOpacity(0.3)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlaylistDetailPage(
                playlistId: playlist.id,
                playlistName: playlist.name,
              ),
            ),
          );
        },
      ),
    );
  }
}

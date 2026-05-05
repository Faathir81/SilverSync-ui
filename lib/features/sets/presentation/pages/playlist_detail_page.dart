import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cached_album_art.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/audio_player_service.dart';
import '../providers/playlist_provider.dart';

class PlaylistDetailPage extends ConsumerWidget {
  final int playlistId;
  final String playlistName;

  const PlaylistDetailPage({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistAsync = ref.watch(playlistDetailProvider(playlistId));
    final playerState = ref.watch(audioPlayerProvider);
    final player = ref.read(audioPlayerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: playlistAsync.when(
        data: (playlist) => CustomScrollView(
          slivers: [
            // ── Functional Sliver Header ─────────────────────────────────────
            SliverAppBar(
              expandedHeight: 340,
              pinned: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textMain, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    // Subtle Gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryTeal.withValues(alpha: 0.15),
                            AppColors.background,
                          ],
                        ),
                      ),
                    ),
                    // Core Info
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Hero(
                            tag: 'playlist_${playlist.id}',
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: playlist.tracks.isNotEmpty
                                    ? CachedAlbumArt(url: playlist.tracks.first.albumArtUrl, size: 180)
                                    : Container(
                                        color: AppColors.surface,
                                        child: const Icon(Icons.playlist_play_rounded, size: 64, color: AppColors.primaryTeal),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            playlist.name,
                            style: AppTheme.darkTheme.textTheme.displaySmall?.copyWith(fontSize: 26, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'STREAMING FROM GOOGLE DRIVE',
                            style: AppTheme.monoStyle(fontSize: 9, color: AppColors.primaryTeal.withValues(alpha: 0.6), letterSpacing: 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Play Control Row ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${playlist.tracks.length} TRACKS',
                          style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'PUBLIC COLLECTION',
                          style: AppTheme.monoStyle(fontSize: 8, color: AppColors.textMuted.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Actual Play Button
                    if (playlist.tracks.isNotEmpty)
                      GestureDetector(
                        onTap: () => player.playTrack(playlist.tracks.first, queue: playlist.tracks, startIndex: 0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryTeal,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 32),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Track List ───────────────────────────────────────────────────
            if (playlist.tracks.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text('EMPTY COLLECTION', style: AppTheme.monoStyle(fontSize: 11, color: AppColors.textMuted)),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final track = playlist.tracks[index];
                    final isPlaying = playerState.currentTrack?.id == track.id;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: CachedAlbumArt(url: track.albumArtUrl, size: 48, isPlaying: isPlaying),
                      title: Text(
                        track.title,
                        style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                          fontSize: 14,
                          color: isPlaying ? AppColors.primaryTeal : AppColors.textMain,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        track.artist,
                        style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted.withValues(alpha: 0.6)),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_horiz, color: AppColors.textMuted, size: 20),
                        onPressed: () => _showTrackActions(context, ref, playlist.id, track),
                      ),
                      onTap: () => player.playTrack(track, queue: playlist.tracks, startIndex: index),
                    );
                  },
                  childCount: playlist.tracks.length,
                ),
              ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 180)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal))),
        error: (err, _) => Center(child: Text('ERROR LOADING COLLECTION', style: AppTheme.monoStyle(color: Colors.redAccent))),
      ),
    );
  }

  void _showTrackActions(BuildContext context, WidgetRef ref, int playlistId, track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
              title: Text('Remove from Collection', style: AppTheme.monoStyle(fontSize: 14, color: Colors.redAccent)),
              onTap: () {
                final api = ref.read(apiServiceProvider);
                removeTrackFromPlaylist(api, ref, playlistId, track.id);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

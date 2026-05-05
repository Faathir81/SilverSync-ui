import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/angular_container.dart';
import '../../../../core/widgets/cached_album_art.dart';
import '../../../../core/services/api_service.dart';
import '../providers/playlist_provider.dart';
import 'playlist_detail_page.dart';
import '../../../dashboard/presentation/providers/quota_provider.dart';

class SetsPage extends ConsumerWidget {
  const SetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);
    final quotaAsync = ref.watch(quotaProvider);

    // Compute stats for sticky header
    int collectionsCount = playlistsAsync.maybeWhen(data: (p) => p.length, orElse: () => 0);
    int totalTracks = playlistsAsync.maybeWhen(data: (p) => p.fold<int>(0, (sum, pl) => sum + (pl.trackCount as int)), orElse: () => 0);
    String libraryUsed = quotaAsync.maybeWhen(
      data: (q) => q.silversyncUsed,
      orElse: () => '— MB',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ═══════════════ ORIGINAL CYBERPUNK HEADER ═══════════════
        Container(
          color: AppColors.background,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SYS // ACTIVE', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal.withValues(alpha: 0.7))),
              const SizedBox(height: 4),
              Text('SILVERSYNC', style: AppTheme.darkTheme.textTheme.displayLarge),
              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('COLLECTIONS // DRIVE FOLDERS', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal.withValues(alpha: 0.4), letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text('Playlists', style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 18)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showCreatePlaylistDialog(context, ref),
                    child: AngularContainer(
                      cutSize: 6,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.add, size: 14, color: AppColors.primaryTeal),
                          const SizedBox(width: 6),
                          Text('NEW COLLECTION', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Original Stats bar
              _buildStatsBar(collectionsCount, totalTracks, libraryUsed),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.primaryTeal.withValues(alpha: 0.15)),

        // ═══════════════ SCROLLABLE CONTENT ═══════════════
        Expanded(
          child: playlistsAsync.when(
            data: (playlists) {
              if (playlists.isEmpty) {
                return Center(
                  child: Text('NO COLLECTIONS FOUND', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal.withValues(alpha: 0.3), letterSpacing: 2)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 15, 12, 180),
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: Hero(
                        tag: 'playlist_${playlist.id}',
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.1)),
                          ),
                          child: playlist.tracks.isNotEmpty
                              ? CachedAlbumArt(url: playlist.tracks.first.albumArtUrl, size: 56)
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
                        style: AppTheme.monoStyle(fontSize: 11, color: AppColors.textMuted.withValues(alpha: 0.6)),
                      ),
                      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textMuted.withValues(alpha: 0.3)),
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
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal))),
            error: (err, _) => Center(
              child: Text('DATABASE UNREACHABLE', style: AppTheme.monoStyle(fontSize: 10, color: Colors.redAccent)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar(int collectionsCount, int totalTracks, String libraryUsed) {
    return AngularContainer(
      cutSize: 8,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(collectionsCount.toString(), 'COLLECTIONS', AppColors.primaryTeal),
          Container(width: 1, height: 32, color: AppColors.primaryTeal.withValues(alpha: 0.15)),
          _buildStatItem(totalTracks.toString(), 'TOTAL TRACKS', AppColors.primaryMagenta),
          Container(width: 1, height: 32, color: AppColors.primaryTeal.withValues(alpha: 0.15)),
          _buildStatItem(libraryUsed, 'LIBRARY', AppColors.textMain),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color valueColor) {
    return Column(
      children: [
        Text(value, style: AppTheme.monoStyle(fontSize: 18, color: valueColor).copyWith(shadows: [Shadow(color: valueColor.withValues(alpha: 0.6), blurRadius: 5)])),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted.withValues(alpha: 0.5))),
      ],
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.primaryTeal.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NEW COLLECTION',
                style: AppTheme.monoStyle(fontSize: 16, color: AppColors.primaryTeal, letterSpacing: 2, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a new group for your synced tracks',
                style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: AppColors.textMain, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Collection Name',
                  hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.3)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryTeal.withValues(alpha: 0.2))),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryTeal)),
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    final api = ref.read(apiServiceProvider);
                    createPlaylist(api, ref, val.trim());
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('CANCEL', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.textMuted)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        final api = ref.read(apiServiceProvider);
                        createPlaylist(api, ref, controller.text.trim());
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('CREATE', style: AppTheme.monoStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

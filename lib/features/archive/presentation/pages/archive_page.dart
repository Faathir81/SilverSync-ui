import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/angular_container.dart';
import '../../../../core/widgets/cached_album_art.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/audio_player_service.dart';
import '../providers/track_provider.dart';

class ArchivePage extends ConsumerStatefulWidget {
  const ArchivePage({super.key});

  @override
  ConsumerState<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends ConsumerState<ArchivePage> {
  String searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracksAsync = ref.watch(tracksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ═══════════════════════════════════════════════════════════
        // STICKY HEADER — everything here stays fixed at the top
        // ═══════════════════════════════════════════════════════════
        Container(
          color: AppColors.background,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ──
              Text('SYS // ACTIVE', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal.withOpacity(0.7))),
              const SizedBox(height: 4),
              Text('SILVERSYNC', style: AppTheme.darkTheme.textTheme.displayLarge),
              const SizedBox(height: 25),

              // ── Subtitle + File Count ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ARCHIVE // SYNCED TRACKS', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal.withOpacity(0.4), letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text('Library', style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 18)),
                    ],
                  ),
                  tracksAsync.when(
                    data: (tracks) => _buildFileBadge('${tracks.length} FILES', false),
                    loading: () => _buildFileBadge('LOADING...', false),
                    error: (_, __) => _buildFileBadge('OFFLINE', true),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // ── Search Bar ──
              _buildSearchBar(),
            ],
          ),
        ),

        // Divider line between header and list
        Container(height: 1, color: AppColors.primaryTeal.withOpacity(0.15)),

        // ═══════════════════════════════════════════════════════════
        // SCROLLABLE TRACK LIST — only this part scrolls
        // ═══════════════════════════════════════════════════════════
        Expanded(
          child: tracksAsync.when(
            data: (tracks) {
              final filtered = tracks.where((t) =>
                t.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                t.artist.toLowerCase().contains(searchQuery.toLowerCase())
              ).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    searchQuery.isEmpty ? 'NO TRACKS IN ARCHIVE' : 'NO RECORDS FOUND',
                    style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal.withOpacity(0.3), letterSpacing: 2),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 150),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final track = filtered[index];
                  // Watch is outside itemBuilder call via closure — no extra rebuild per item
                  final currentTrackId = ref.watch(
                    audioPlayerProvider.select((s) => s.currentTrack?.id),
                  );
                  final isCurrentTrack = currentTrackId == track.id;
                  final isPlayingCurrent = isCurrentTrack &&
                      ref.watch(audioPlayerProvider.select((s) => s.isPlaying));
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(audioPlayerProvider.notifier).playTrack(
                          track,
                          queue: filtered,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: isCurrentTrack
                            ? BoxDecoration(
                                border: Border.all(
                                  color: AppColors.primaryTeal.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                                color: AppColors.primaryTeal.withValues(alpha: 0.04),
                              )
                            : null,
                        child: AngularContainer(
                          cutSize: 6,
                          padding: EdgeInsets.zero,
                          child: _buildTrackItem(track, isPlaying: isPlayingCurrent),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
              ),
            ),
            error: (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 40, color: Colors.redAccent.withOpacity(0.4)),
                  const SizedBox(height: 15),
                  Text('DATABASE UNREACHABLE', style: AppTheme.monoStyle(fontSize: 12, color: Colors.redAccent.withOpacity(0.5), letterSpacing: 2)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────

  Widget _buildFileBadge(String text, bool isError) {
    final color = isError ? Colors.redAccent : AppColors.primaryTeal;
    return AngularContainer(
      cutSize: 5,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          Icon(isError ? Icons.warning : Icons.storage, size: 12, color: color),
          const SizedBox(width: 6),
          Text(text, style: AppTheme.monoStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return AngularContainer(
      cutSize: 8,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.search, size: 16, color: AppColors.primaryTeal.withOpacity(0.4)),
          const SizedBox(width: 10),
          Text('//', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal.withOpacity(0.3))),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => searchQuery = val),
              style: AppTheme.monoStyle(fontSize: 14, color: AppColors.textMain),
              decoration: InputDecoration(
                hintText: 'SEARCH ARCHIVE...',
                hintStyle: AppTheme.monoStyle(fontSize: 14, color: AppColors.textMuted.withOpacity(0.5)),
                border: InputBorder.none,
              ),
            ),
          ),
          if (searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, size: 14, color: AppColors.textMuted.withOpacity(0.5)),
              onPressed: () {
                _searchController.clear();
                setState(() => searchQuery = '');
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildTrackItem(track, {bool isPlaying = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          // Album art with playing indicator overlay
                // Album art — cached, no re-download on scroll
                CachedAlbumArt(
                  url: track.albumArtUrl,
                  size: 48,
                  isPlaying: isPlaying,
                ),
          const SizedBox(width: 15),

          // Title + Artist
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        track.artist,
                        style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted.withOpacity(0.7)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      track.quality ?? 'HIGH',
                      style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal.withOpacity(0.5)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Cloud status icon
          Icon(
            track.driveFileId.isNotEmpty ? Icons.cloud_done : Icons.cloud_off,
            size: 16,
            color: track.driveFileId.isNotEmpty
                ? AppColors.primaryTeal
                : AppColors.textMuted.withOpacity(0.3),
          ),
          const SizedBox(width: 4),

          // Favorite button
          IconButton(
            icon: Icon(
              track.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: track.isFavorite ? AppColors.primaryMagenta : AppColors.textMuted.withOpacity(0.3),
              size: 20,
            ),
            onPressed: () {
              final api = ref.read(apiServiceProvider);
              toggleFavorite(api, ref, track.id, newValue: !track.isFavorite);
            },
          ),
        ],
      ),
    );
  }

}

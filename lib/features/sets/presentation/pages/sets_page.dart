import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/angular_container.dart';
import '../providers/playlist_provider.dart';
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
    // Use full formatted string (e.g. "170.2 MB") — no stripping
    String libraryUsed = quotaAsync.maybeWhen(
      data: (q) => q.silversyncUsed,
      orElse: () => '— MB',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ═══════════════ STICKY HEADER ═══════════════
        Container(
          color: AppColors.background,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text('SYS // ACTIVE', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal.withOpacity(0.7))),
              const SizedBox(height: 4),
              Text('SILVERSYNC', style: AppTheme.darkTheme.textTheme.displayLarge),
              const SizedBox(height: 25),

              // Subtitle + NEW COLLECTION button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('COLLECTIONS // DRIVE FOLDERS', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal.withOpacity(0.4), letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text('Playlists', style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 18)),
                    ],
                  ),
                  AngularContainer(
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
                ],
              ),
              const SizedBox(height: 15),

              // Stats bar
              _buildStatsBar(collectionsCount, totalTracks, libraryUsed),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.primaryTeal.withOpacity(0.15)),

        // ═══════════════ SCROLLABLE CONTENT ═══════════════
        Expanded(
          child: playlistsAsync.when(
            data: (playlists) {
              if (playlists.isEmpty) {
                return Center(
                  child: Text('NO COLLECTIONS FOUND', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal.withOpacity(0.3), letterSpacing: 2)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 150),
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildPlaylistItem(playlists[index]),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal))),
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

  Widget _buildStatsBar(int collectionsCount, int totalTracks, String libraryUsed) {
    return AngularContainer(
      cutSize: 8,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(collectionsCount.toString(), 'COLLECTIONS', AppColors.primaryTeal),
          Container(width: 1, height: 32, color: AppColors.primaryTeal.withOpacity(0.15)),
          _buildStatItem(totalTracks.toString(), 'TOTAL TRACKS', AppColors.primaryMagenta),
          Container(width: 1, height: 32, color: AppColors.primaryTeal.withOpacity(0.15)),
          // Show full string e.g. "170.2 MB" with dynamic unit
          _buildStatItem(libraryUsed, 'LIBRARY', AppColors.textMain),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color valueColor) {
    return Column(
      children: [
        Text(value, style: AppTheme.monoStyle(fontSize: 18, color: valueColor).copyWith(shadows: [Shadow(color: valueColor.withOpacity(0.6), blurRadius: 5)])),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted.withOpacity(0.5))),
      ],
    );
  }

  Widget _buildPlaylistItem(playlist) {
    return AngularContainer(
      cutSize: 10,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryMagenta.withOpacity(0.1),
              border: Border.all(color: AppColors.primaryMagenta.withOpacity(0.3)),
            ),
            child: const Icon(Icons.music_note, color: AppColors.primaryMagenta, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(playlist.name, style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('${playlist.trackCount}', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryMagenta)),
                    Text(' TRACKS', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.textMuted.withOpacity(0.7))),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.primaryTeal.withOpacity(0.5)),
        ],
      ),
    );
  }
}

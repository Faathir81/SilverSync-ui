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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          playlistsAsync.when(
            data: (playlists) => _buildContent(playlists, quotaAsync),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => _buildContentWithError(err.toString(), quotaAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SYS // ACTIVE', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal.withOpacity(0.7))),
        const SizedBox(height: 4),
        Text('SILVERSYNC', style: AppTheme.darkTheme.textTheme.displayLarge),
      ],
    );
  }

  Widget _buildContent(List playlists, AsyncValue quotaAsync) {
    String gbUsed = quotaAsync.maybeWhen(
      data: (q) => q.silversyncUsed.replaceAll(RegExp(r'[a-zA-Z\s]'), ''), // strip " GB" or " MB"
      orElse: () => '0.00',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 20),
        _buildStatsBar(playlists.length, playlists.fold<int>(0, (sum, p) => sum + (p.trackCount as int)), gbUsed),
        const SizedBox(height: 20),
        playlists.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text('NO COLLECTIONS FOUND', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal.withOpacity(0.3), letterSpacing: 2)),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: playlists.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildPlaylistItem(playlists[index]),
              ),
      ],
    );
  }

  Widget _buildContentWithError(String error, AsyncValue quotaAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              cutSize: 5,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.warning, size: 12, color: Colors.redAccent),
                  const SizedBox(width: 6),
                  Text('OFFLINE', style: AppTheme.monoStyle(fontSize: 10, color: Colors.redAccent)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildStatsBar(0, 0, '0.00'),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text('DATABASE UNREACHABLE', style: AppTheme.monoStyle(fontSize: 12, color: Colors.redAccent.withOpacity(0.5), letterSpacing: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar(int collectionsCount, int totalTracks, String gbUsed) {
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
          _buildStatItem(gbUsed, 'GB USED', AppColors.textMain),
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

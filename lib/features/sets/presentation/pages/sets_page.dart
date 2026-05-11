import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../providers/playlist_provider.dart';
import '../../../dashboard/presentation/providers/quota_provider.dart';
import '../../../../core/widgets/connection_error_widget.dart';
import '../widgets/playlist_list_item.dart';
import '../widgets/playlist_stats_bar.dart';

class SetsPage extends ConsumerWidget {
  const SetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);
    final quotaAsync = ref.watch(quotaProvider);

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SYS // ACTIVE', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.primaryTeal.withOpacity(0.7))),
                      const SizedBox(height: 4),
                      Text('SILVERSYNC', style: AppTheme.darkTheme.textTheme.displayLarge?.copyWith(
                shadows: [const Shadow(color: AppColors.primaryTeal, blurRadius: 10)],
              )),
                    ],
                  ),
                  _buildAddButton(context, ref),
                ],
              ),
              const SizedBox(height: 25),
              _buildModuleHeader('COLLECTIONS // DATABASE'),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.primaryTeal.withOpacity(0.15)),

        // ═══════════════ SCROLLABLE CONTENT ═══════════════
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Bar
                playlistsAsync.when(
                  data: (playlists) {
                    final totalTracks = playlists.fold(0, (sum, pl) => sum + pl.tracks.length);
                    final libraryUsed = quotaAsync.maybeWhen(
                      data: (q) => q.used,
                      orElse: () => '...',
                    );
                    return PlaylistStatsBar(
                      collectionsCount: playlists.length,
                      totalTracks: totalTracks,
                      libraryUsed: libraryUsed,
                    );
                  },
                  loading: () => const PlaylistStatsBar(collectionsCount: 0, totalTracks: 0, libraryUsed: '...'),
                  error: (_, __) => const PlaylistStatsBar(collectionsCount: 0, totalTracks: 0, libraryUsed: 'ERR'),
                ),

                const SizedBox(height: 30),
                _buildSectionHeader('YOUR COLLECTIONS'),
                const SizedBox(height: 15),

                // Playlists List
                playlistsAsync.when(
                  data: (playlists) {
                    if (playlists.isEmpty) {
                      return _buildEmptyState();
                    }
                    return Column(
                      children: playlists.map((pl) => PlaylistListItem(playlist: pl)).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal))),
                  error: (err, _) => ConnectionErrorWidget(
                    message: err.toString(),
                    onRetry: () => ref.invalidate(playlistsProvider),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showCreatePlaylistDialog(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryTeal.withOpacity(0.1),
          border: Border.all(color: AppColors.primaryTeal.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.add, size: 16, color: AppColors.primaryTeal),
            const SizedBox(width: 4),
            Text('NEW_SET', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: AppColors.primaryTeal),
        const SizedBox(width: 10),
        Text(title, style: AppTheme.monoStyle(fontSize: 12, color: AppColors.textMain)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted, letterSpacing: 2));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.playlist_add, size: 48, color: AppColors.primaryTeal.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text('NO COLLECTIONS FOUND', style: AppTheme.monoStyle(fontSize: 12, color: AppColors.textMuted, letterSpacing: 2)),
          ],
        ),
      ),
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
            color: AppColors.background.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.primaryTeal.withOpacity(0.2)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NEW COLLECTION', style: AppTheme.monoStyle(fontSize: 16, color: AppColors.primaryTeal, letterSpacing: 2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Create a new group for your synced tracks', style: AppTheme.monoStyle(fontSize: 10, color: AppColors.textMuted)),
              const SizedBox(height: 32),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: AppColors.textMain, fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'Collection Name',
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primaryTeal)),
                ),
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
                        createPlaylist(ref.read(apiServiceProvider), ref, controller.text.trim());
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
                    child: const Text('CREATE'),
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
